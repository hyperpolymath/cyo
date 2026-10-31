#!/usr/bin/env bash
# SPDX-License-Identifier: MPL-2.0
# SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# check-lock-pin-provenance-test.sh — fixture suite for
# scripts/check-lock-pin-provenance.sh.
#
# The two cases that matter are transcribed from real sources:
#   * metadatastician/standards fad242d35291de1898242d6737ba02b74a59a2f2 —
#     leaf `ref:` repeating the pin's own SHA. Every cross-repo caller of the
#     shared reusables died at runner setup ("invalid lockfile pin") from
#     2026-10-17 (hyperpolymath/cyo run 39007442235).
#   * metadatastician/standards 1725bebd3773ea25627479f813283abf1c497a85 —
#     the same record corrected to `ref: v7.0.1`.
# They are REPRESENTATIONS, not whole immutable snapshots: the guard's contract
# is about the record's shape, and coverage/closure are other scripts' jobs.
#
# Run: bash scripts/tests/check-lock-pin-provenance-test.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GUARD="${GUARD:-$SCRIPT_DIR/../check-lock-pin-provenance.sh}"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

SHA=3d3c42e5aac5ba805825da76410c181273ba90b1
OTHER=1111111111111111111111111111111111111111

pass=0
fail=0

fresh() {
  rm -rf "$WORK/repo"
  mkdir -p "$WORK/repo/.github/workflows"
  printf 'name: ci\non: push\njobs:\n  a:\n    runs-on: ubuntu-latest\n    steps:\n      - uses: actions/checkout@%s\n' "$SHA" \
    > "$WORK/repo/.github/workflows/ci.yml"
}

lock() { cat > "$WORK/repo/.github/workflows/actions.lock"; }

expect() {
  local label=$1 want=$2 needle=${3:-} out rc
  out="$(cd "$WORK/repo" && LOCK_RESOLVE_CMD="${RESOLVE:-false}" bash "$GUARD" .github/workflows/actions.lock 2>&1)"
  rc=$?
  if [ "$rc" != "$want" ]; then
    printf 'FAIL %s: wanted exit %s, got %s\n%s\n' "$label" "$want" "$rc" "$out"
    fail=$((fail + 1))
    return
  fi
  if [ -n "$needle" ] && ! printf '%s' "$out" | grep -qF "$needle"; then
    printf 'FAIL %s: output does not mention %s\n%s\n' "$label" "$needle" "$out"
    fail=$((fail + 1))
    return
  fi
  printf 'ok: %s\n' "$label"
  pass=$((pass + 1))
}

leaf_record() { # leaf_record <ref> <commit>
  printf "version: 'v0.0.3'\nworkflows:\n    '.github/workflows/ci.yml':\n        - 'actions/checkout@%s'\ndependencies:\n    'actions/checkout@%s':\n        ref: '%s'\n        commit: '%s'\n" \
    "$SHA" "$SHA" "$1" "$2"
}

# ── representation ─────────────────────────────────────────────────────────

fresh
leaf_record "$SHA" "sha1-$SHA" | lock
expect 'historical: leaf ref repeats the pin SHA (fad242d shape)' 1 'ref repeats the pin'

fresh
leaf_record "$OTHER" "sha1-$SHA" | lock
expect 'leaf ref is a 40-hex SHA that is not the pin' 1 'ref is a 40-hex SHA that is not the pin'

fresh
leaf_record v7.0.1 "sha1-$SHA" | lock
expect 'corrected: reviewed tag and matching commit (main shape)' 0 'Representation accepted'

fresh
leaf_record "" "sha1-$SHA" | lock
expect 'empty ref rejected' 1 'no ref recorded'

fresh
leaf_record v7.0.1 "sha1-$OTHER" | lock
expect 'literal-SHA key disagrees with the recorded commit' 1 'disagrees with the recorded commit'

fresh
leaf_record v7.0.1 "$SHA" | lock
expect 'commit without the sha1- algorithm rejected' 1 'commit must be sha1-'

fresh
printf "version: 'v0.0.3'\nworkflows: {}\ndependencies:\n    'actions/setup-python@v2':\n        ref: 'v2'\n        commit: 'sha1-%s'\n" "$SHA" | lock
expect 'tag-keyed record whose ref is its own key' 0 'Representation accepted'

fresh
printf "version: 'v0.0.3'\ndependencies:\n    'actions/setup-python@v2':\n        ref: 'v3'\n        commit: 'sha1-%s'\n" "$SHA" | lock
expect 'tag-keyed record whose ref is a different tag' 1 'tag-shaped key'

# ── reusable-workflow records ──────────────────────────────────────────────
# A reusable call site is what licenses a SHA ref: the caller pins the callee's
# commit, and close-lock.sh writes the callee's own `uses:` union under it.

reusable_fixture() { # reusable_fixture <ref> <commit>
  printf 'name: ci\non: push\njobs:\n  g:\n    uses: metadatastician/standards/.github/workflows/governance-reusable.yml@%s\n' "$SHA" \
    > "$WORK/repo/.github/workflows/ci.yml"
  printf "version: 'v0.0.3'\nworkflows:\n    '.github/workflows/ci.yml':\n        - 'metadatastician/standards@%s'\ndependencies:\n    'metadatastician/standards@%s':\n        ref: '%s'\n        commit: '%s'\n        uses:\n            - 'actions/checkout@%s'\n    'actions/checkout@%s':\n        ref: 'v7.0.1'\n        commit: 'sha1-%s'\n" \
    "$SHA" "$SHA" "$1" "$2" "$SHA" "$SHA" "$SHA"
}

fresh
reusable_fixture "$SHA" "sha1-$SHA" | lock
expect 'reusable record may pin its ref by SHA' 0 'Representation accepted'

fresh
reusable_fixture v7.0.1 "sha1-$SHA" | lock
expect 'reusable record with a tag ref is accepted (drift is a --remote question)' 0 'Representation accepted'

# ── inspection-not-performed is never a pass ──────────────────────────────

fresh
expect 'missing lockfile' 2 'lockfile missing'

fresh
printf "version: 'v99'\ndependencies:\n    'actions/checkout@%s':\n        ref: 'v7.0.1'\n        commit: 'sha1-%s'\n" "$SHA" "$SHA" | lock
expect 'unknown schema is uninspected, not clean' 2 'untested lockfile schema'

fresh
printf "version: 'v0.0.3'\ndependencies: {}\n" | lock
expect 'empty population gives no assurance' 2 'no dependency records inspected'

fresh
rm -f "$WORK/repo/.github/workflows/ci.yml"
leaf_record v7.0.1 "sha1-$SHA" | lock
expect 'no workflow files beside the lock' 2 'no workflow files'

# ── --remote (stubbed resolver; no network in this suite) ─────────────────

# LOCK_RESOLVE_CMD is expanded into words: the earlier words are the command,
# the final word is the repository URL. The stub therefore reads its mode first
# and the URL last.
stub() {
  cat > "$WORK/resolve" <<STUB
#!/usr/bin/env bash
mode="\${1:-}"; url="\${2:-}"
case "\$url" in
  *actions/checkout*)
    case "\$mode" in
      pin)   printf '%s\trefs/tags/v7.0.1\n%s\trefs/tags/v7.0.1^{}\n' "$SHA" "$SHA" ;;
      drift) printf '%s\trefs/tags/v7.0.1\n%s\trefs/tags/v7.0.1^{}\n' "$OTHER" "$OTHER" ;;
      gone)  printf '%s\trefs/tags/v7.0.0\n' "$OTHER" ;;
    esac ;;
esac
STUB
  chmod +x "$WORK/resolve"
}

remote_case() { # remote_case <label> <mode|none> <want-rc> <needle>
  local label=$1 mode=$2 want=$3 needle=$4 out rc cmd
  if [ "$mode" = none ]; then cmd="false"; else cmd="$WORK/resolve $mode"; fi
  out="$(cd "$WORK/repo" && LOCK_RESOLVE_CMD="$cmd" bash "$GUARD" .github/workflows/actions.lock --remote 2>&1)"
  rc=$?
  if [ "$rc" != "$want" ]; then
    printf 'FAIL %s: wanted exit %s, got %s\n%s\n' "$label" "$want" "$rc" "$out"
    fail=$((fail + 1))
    return
  fi
  if [ -n "$needle" ] && ! printf '%s' "$out" | grep -qF "$needle"; then
    printf 'FAIL %s: output does not mention %s\n%s\n' "$label" "$needle" "$out"
    fail=$((fail + 1))
    return
  fi
  printf 'ok: %s\n' "$label"
  pass=$((pass + 1))
}

stub
fresh
leaf_record v7.0.1 "sha1-$SHA" | lock
remote_case '--remote: tag peels to the recorded pin' pin 0 'Representation accepted'

fresh
leaf_record v7.0.1 "sha1-$SHA" | lock
remote_case '--remote: drift is advisory, not startup-fatal' drift 0 'DRIFT actions/checkout'

fresh
leaf_record v9.9.9 "sha1-$SHA" | lock
remote_case '--remote: a ref that does not resolve is invalid' gone 1 'does not resolve'

fresh
leaf_record v7.0.1 "sha1-$SHA" | lock
remote_case '--remote: an unreadable remote is UNVERIFIED, never a silent pass' none 0 'UNVERIFIED actions/checkout'

echo "------------------------------------------------------------"
echo "check-lock-pin-provenance-test: ${pass} passed, ${fail} failed"
[ "$fail" -eq 0 ] || exit 1
