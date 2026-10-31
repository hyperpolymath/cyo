# Guard governance lock pins and prove source provenance before a commit is pinnable

Target: `metadatastician/standards`, branch `fix/lock-pin-provenance-guard`, based on
`1725bebd3773ea25627479f813283abf1c497a85`. Apply with `git am patches/000*.patch`.

## Summary

- Adds `scripts/check-lock-pin-provenance.sh`: the **representation + provenance** layer of
  `actions.lock` verification — a leaf record must name the reviewed tag/branch in `ref:`
  (`ref:` repeating its own 40-hex pin is rejected by the runner at *Set up job*), reusable-workflow
  records may pin by SHA, `commit:` must be `sha1-<40 hex>` and agree with a SHA-shaped key,
  tag-keyed records must record their own key. Optional `--remote` resolves refs with
  `git ls-remote` (drift advisory, unresolvable ref fatal, unreadable remote `UNVERIFIED`).
- Adds `scripts/tests/check-lock-pin-provenance-test.sh`, 18 fixture cases, including the exact
  `fad242d` (fails) and `1725beb` (passes) record shapes.
- Runs it inside the existing `lock-selfcheck` job — **same job, same check name**
  (`Lockfile self-consistency`), so no required context changes.
- Adds `docs/audits/audit-2026-10-31-governance-startup-lock-repair.adoc`: field evidence, the
  timeline showing enforcement (not the source) changed, the candidate matrix, the
  source-resolution expression audit, the 527-commit policy delta, migration and rollback.

## Not a duplicate of the main fix

`main` already corrected the record (f335165 #1271, cf8f912 #1285); nothing here rewrites it. What was
missing: a check that fails on the shape **before** a commit becomes pinnable for ~340 consumers,
including records no workflow uses, and a written record of why the shape is fatal and what a consumer
must do. Coverage stays in `check-lock-sync.sh`, closure in `close-lock.sh --check`;
`lock-selfcheck.sh` composes all three. `cicd-suite` PR #66's guard is a sibling invariant, not a
substitute for closure or provenance.

## Evidence

| What | Measurement |
| --- | --- |
| Field failure | cyo 39007442235 (2026-10-17): 14/14 jobs fail at *Set up job*, `invalid lockfile pin` |
| Same immutable pin earlier | cyo 37113819760 (2026-10-03): 13 jobs success — source unchanged, enforcement changed |
| Broken source | `fad242d`: guard exit 1 (10 leaf self-SHA records) **and** `check-lock-sync.sh` OUT OF SYNC |
| Corrected sources | `75bd599`, `333b06a`, `8d1a2aa`, `1725beb`: guard exit 0, in sync, closed |
| Live consumer execution | hypatia 41196238803 / 41196138008 at `333b06a`: policy jobs execute |
| Canary reproduction | cyo 41198958192 at `fad242d`: `startup_failure`, 0 jobs |
| Test suite | 18/18 pass |

## Boundaries

No required check disabled, renamed or bypassed; no allow-list widening; no de-pinning; no job removed;
no consumer edits in this PR. Consumers repin only after a canary in *their* repository shows
`jobs > 0`.

## Why there is no policy-neutral repin

`fad242d` is immutable and a branch-tip repair commit is not callable (a called reusable must be
reachable from the callee default branch). Every startup-valid commit is far from the baseline:
`75bd599` 454, `333b06a` 461, `1725beb` 527 commits, 72 workflow files, 15 → 19 governance jobs.

## Blockers recorded, not worked around

- `gh actions-lock --verify-local` unavailable (extension asset download fails); the three repo-owned
  checks were run instead.
- Mikefarah `yq` v4 absent, so `lock-selfcheck.sh` ran as its three components.
- Administration API reads return `403`.
- `hyperpolymath/cyo` returns zero jobs for *every* cross-repo pin, including `333b06a` which runs in
  hypatia — a caller-side blocker there, independent of this change.

## Checklist

- [x] Guard + tests added; 18/18 pass; `bash -n` clean.
- [x] Run against `main` (pass), `fad242d` (fail), and four corrected sources (pass).
- [x] `check-lock-sync.sh` and `close-lock.sh --check` green on the target commit.
- [x] Additive only; no check disabled or renamed; no admission broadening.
- [ ] Commits signed (`git commit -S`) — sign on rebase; no key in the authoring environment.
