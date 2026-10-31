#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# check-lock-pin-provenance.sh — the REPRESENTATION and PROVENANCE layer of
# actions.lock verification, for one lock plus the workflows beside it.
#
# ── Why this exists (measured, 2026-10-31) ──────────────────────────────────
# GitHub resolves a called reusable workflow at workflow STARTUP and validates
# the CALLEE against the callee repository's own `.github/workflows/actions.lock`
# *as it exists at the pinned commit*. A leaf dependency record whose `ref`
# repeats its own 40-hex pin is rejected there:
#
#   Unable to resolve action `actions/checkout@3d3c42e5…`:
#   invalid lockfile pin. Run `gh actions-lock` to update the lockfile
#
#   hyperpolymath/cyo run 39007442235, 2026-10-17 — 14 of 14 jobs, step
#   "Set up job", annotation naming the CALLEE's leaf record. The same
#   immutable pin (metadatastician/standards fad242d) started those jobs on
#   2026-10-03 (run 37113819760): the source did not change, enforcement did.
#
# The repair for that class landed on main in f335165 (#1271, tag refs for nine
# leaf entries) and cf8f912 (#1285, the rest). This script is the guard that
# keeps the class from shipping again, and it deliberately does NOT re-tell the
# whole story:
#
#   * REPRESENTATION (this script, always): a leaf record must name the reviewed
#     tag/branch in `ref:`; a reusable-workflow record may pin by SHA; every
#     record must carry `commit: sha1-<40 hex>` agreeing with a SHA-shaped key.
#   * COVERAGE and CLOSURE are NOT re-implemented here. They live in
#     `check-lock-sync.sh` (both-direction workflow<->lock equality, job-level
#     reusables and local composite actions included) and `close-lock.sh
#     --check` (no dangling edges). `lock-selfcheck.sh` composes all three per
#     commit. A representation pass here is NOT a statement that a commit is
#     safe to pin.
#   * REMOTE RESOLUTION (`--remote`) is opt-in and advisory on drift, because
#     drift is measured NOT to be startup-fatal: metadatastician/standards
#     333b06a records `dtolnay/rust-toolchain@e2a55d2f… ref: v1` while v1 now
#     resolves to 683b588c…, and hypatia's governance jobs at that pin start and
#     run (run 41196238803, 2026-10-31). A ref that does not resolve at all is a
#     different matter and fails.
#
# Sibling: hyperpolymath/cicd-suite PR #66 (`scripts/check-lock-pin-contract.sh`)
# carries the same representation rule for that repository. It is a
# representation guard, not a lock/provenance/closure verifier; neither is this
# script on its own.
#
# USAGE
#   check-lock-pin-provenance.sh [LOCKFILE] [--remote]
#       LOCKFILE   default .github/workflows/actions.lock
#       --remote   also resolve tag/branch refs with `git ls-remote`
#
# EXIT
#   0 = representation accepted (and, with --remote, every ref resolved)
#   1 = at least one INVALID record
#   2 = inspection NOT performed (no lock, unknown schema, empty population,
#       no workflow files) — never reported as a pass
#
# Test seam: LOCK_RESOLVE_CMD, a command whose final word is the action repo URL
# and whose earlier words are passed through; it must print `git ls-remote`
# output. Defaults to `git ls-remote --tags --heads`.
set -uo pipefail

REMOTE=0
LOCK=""
for arg in "$@"; do
  case "$arg" in
    --remote) REMOTE=1 ;;
    -h|--help) sed -n '2,60p' "$0"; exit 2 ;;
    -*) echo "check-lock-pin-provenance: unknown option $arg" >&2; exit 2 ;;
    *) LOCK="$arg" ;;
  esac
done
LOCK="${LOCK:-.github/workflows/actions.lock}"
WF_DIR="$(dirname "$LOCK")"
RESOLVE_CMD="${LOCK_RESOLVE_CMD:-git ls-remote --tags --heads}"

if [ ! -f "$LOCK" ]; then
  echo "::error file=$LOCK::lockfile missing; nothing inspected, no assurance" >&2
  exit 2
fi

shopt -s nullglob
WORKFLOWS=("$WF_DIR"/*.yml "$WF_DIR"/*.yaml)
shopt -u nullglob
if [ "${#WORKFLOWS[@]}" -eq 0 ]; then
  echo "::error file=$LOCK::no workflow files under $WF_DIR; the reusable/leaf distinction cannot be made, so no assurance" >&2
  exit 2
fi

VERSION="$(awk -F"'" '/^version:/{print $2; exit}' "$LOCK")"
case "$VERSION" in
  v0.0.2|v0.0.3) ;;
  "")
    echo "::error file=$LOCK::no lockfile schema version; nothing inspected, no assurance" >&2
    exit 2 ;;
  *)
    echo "::error file=$LOCK::untested lockfile schema '$VERSION'; refusing to report on a shape this guard was not built for" >&2
    exit 2 ;;
esac

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# ── Parse dependency records: key, ref, commit, and whether a `uses:` list
#    follows (a reusable-workflow record carries one; a leaf usually does not).
#    \\x1f separates fields: a ref is legitimately allowed to be empty, and an
#    empty field must not swallow the next one.
awk '
  /^dependencies:/ { in_dep = 1; next }
  /^[a-z_]+:/      { in_dep = 0; cur = ""; next }
  !in_dep { next }
  /^    \x27[^\x27]+\x27:$/ {
    if (cur != "") print cur "\x1f" ref "\x1f" commit "\x1f" uses
    cur = $0; sub(/^    \x27/, "", cur); sub(/\x27:$/, "", cur)
    ref = ""; commit = ""; uses = 0
    next
  }
  /^        ref: /    { r = $0; sub(/^        ref: /, "", r); gsub(/^\x27|\x27$/, "", r); ref = r; next }
  /^        commit: / { c = $0; sub(/^        commit: /, "", c); gsub(/^\x27|\x27$/, "", c); commit = c; next }
  /^        uses:/   { uses = 1; next }
  END { if (cur != "") print cur "\x1f" ref "\x1f" commit "\x1f" uses }
' "$LOCK" > "$TMP/records"

if [ ! -s "$TMP/records" ]; then
  echo "::error file=$LOCK::no dependency records inspected; no assurance" >&2
  exit 2
fi

# ── Which owner/repo are called as REUSABLE WORKFLOWS anywhere in the tree?
#    An anchored match on `uses:` (comments and `run:` bodies are not `uses:`
#    lines); a quoted spelling matches too. This only CLASSIFIES a record, and a
#    classification miss cannot turn a bad leaf into a pass.
grep -rhoE '^[[:space:]]*-?[[:space:]]*uses:[[:space:]]*["'"'"']?[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/\.github/workflows/[^@[:space:]"'"'"']+@' \
  "${WORKFLOWS[@]}" 2>/dev/null |
  sed -E 's/.*uses:[[:space:]]*["'"'"']?//; s#/\.github/workflows/.*##' |
  tr 'A-Z' 'a-z' | sort -u > "$TMP/reusable_repos" || : > "$TMP/reusable_repos"

FAIL=0
COUNT=0
REUSABLE_COUNT=0

while IFS=$'\x1f' read -r key ref commit has_uses; do
  [ -n "$key" ] || continue
  COUNT=$((COUNT + 1))
  repo="${key%@*}"
  suffix="${key##*@}"
  repo_lc="$(printf '%s' "$repo" | tr 'A-Z' 'a-z')"
  is_reusable=0
  if grep -qxF "$repo_lc" "$TMP/reusable_repos" 2>/dev/null; then
    is_reusable=1
    REUSABLE_COUNT=$((REUSABLE_COUNT + 1))
  fi
  # NOT a fallback: a nested `uses:` list does NOT by itself make a record a
  # reusable call. actions/upload-pages-artifact is a composite action that uses
  # actions/upload-artifact and is written with a list, yet it is a leaf for the
  # purposes of the runner's pin check. Measured on fad242d: treating "has a
  # list" as "is a reusable" hid a real self-SHA leaf record from this guard.
  # The workflow call site is the only signal.

  if [ -z "$ref" ]; then
    echo "INVALID $key: no ref recorded"
    FAIL=1
    continue
  fi
  if ! printf '%s' "$commit" | grep -qE '^sha1-[0-9a-f]{40}$'; then
    echo "INVALID $key: commit must be sha1-<40 lowercase hex>, got '$commit'"
    FAIL=1
    continue
  fi
  if printf '%s' "$suffix" | grep -qE '^[0-9a-fA-F]{40}$'; then
    if [ "$commit" != "sha1-$(printf '%s' "$suffix" | tr 'A-F' 'a-f')" ]; then
      echo "INVALID $key: literal-SHA key disagrees with the recorded commit ($commit)"
      FAIL=1
    fi
    if [ "$is_reusable" -eq 0 ] && printf '%s' "$ref" | grep -qE '^[0-9a-fA-F]{40}$'; then
      # The measured startup-fatal shape. GitHub's runner rejects it with
      # "invalid lockfile pin" before any job exists.
      if [ "$ref" = "$suffix" ]; then
        echo "INVALID $key: ref repeats the pin's own SHA; a leaf entry must name the reviewed tag/branch (invalid lockfile pin at runner setup)"
      else
        echo "INVALID $key: ref is a 40-hex SHA that is not the pin; a leaf entry must name the reviewed tag/branch"
      fi
      FAIL=1
    fi
  else
    # Tag-keyed record (e.g. 'actions/setup-python@v2'). The key IS the ref the
    # tool resolved; a differing ref would key one spelling and record another.
    if [ "$ref" != "$suffix" ]; then
      echo "INVALID $key: tag-shaped key recorded ref '$ref'; expected '$suffix'"
      FAIL=1
    fi
  fi
done < "$TMP/records"

if [ "$REMOTE" -eq 1 ] && [ "$FAIL" -eq 0 ]; then
  : > "$TMP/unverified"
  while IFS=$'\x1f' read -r key ref commit has_uses; do
    [ -n "$key" ] || continue
    case "$ref" in
      ""|[0-9a-fA-F][0-9a-fA-F]*) continue ;;
    esac
    repo="${key%@*}"
    url="https://github.com/$repo.git"
    done_file="$TMP/remote.$(printf '%s' "$repo" | tr '/' '_')"
    if [ ! -s "$done_file" ]; then
      # shellcheck disable=SC2086
      $RESOLVE_CMD "$url" > "$done_file" 2>/dev/null
      if [ ! -s "$done_file" ]; then
        echo "UNVERIFIED $key: could not read remote refs for $repo (indeterminate, not a pass)"
        echo "$key" >> "$TMP/unverified"
        continue
      fi
    fi
    want="$(printf '%s' "$commit" | sed 's/^sha1-//')"
    got="$(awk -v want="$ref" '
      $2 == "refs/tags/" want "^{}" { peel = $1 }
      $2 == "refs/tags/" want        { tag = $1 }
      $2 == "refs/heads/" want       { head = $1 }
      END { if (peel != "") print peel; else if (tag != "") print tag; else print head }
    ' "$done_file")"
    if [ -z "$got" ]; then
      echo "INVALID $key: ref '$ref' does not resolve in $repo"
      FAIL=1
    elif [ "$got" != "$want" ]; then
      # Advisory only: measured NOT startup-fatal (333b06a / dtolnay v1).
      echo "DRIFT $key: ref '$ref' now resolves to $got, not the recorded pin $want (advisory: drift is not startup-fatal; see the header)"
    fi
  done < "$TMP/records"
fi

echo "inspected $COUNT dependency record(s) in $LOCK (schema $VERSION); $REUSABLE_COUNT reusable-workflow record(s); representation failures=$FAIL"
if [ -s "$TMP/unverified" ]; then
  echo "records whose remote refs could not be read: $(wc -l < "$TMP/unverified") (reported UNVERIFIED above)"
fi
if [ "$FAIL" -ne 0 ]; then
  echo "REPRESENTATION REJECTED — a lock carrying these records is not startup-valid for a caller pinned here."
  echo "Repair: name the reviewed tag/branch in ref:, keep the pin in the key and commit:. See"
  echo "  standards f335165 (#1271), cf8f912 (#1285); run scripts/relock-sha-keys.sh + close-lock.sh --check afterwards."
  exit 1
fi
echo "Representation accepted. This is NOT coverage or closure: also run check-lock-sync.sh and close-lock.sh --check (lock-selfcheck.sh does all three per commit)."
exit 0
