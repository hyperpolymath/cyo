# standards governance startup-lock repair — handoff package

> **SUPERSEDED — do not publish `patches/`.** Standards `main` landed this repair first in
> `7e9b1de` (#1381), which covers this scope and more. See `SUPERSEDED.md`. This directory is kept
> for provenance and as an independent check, not as a submission.

Source of the change: `metadatastician/standards`. Nothing here modifies a consumer repository.

## Revision note

*Revision 2 (2026-10-31, post-review).* The first revision was merged into `cyo` `main` as
4764ac80 (PR #54). This revision closes the review findings:

* `--remote` skipped any ref whose first two characters were hex (`2026.1`), and reported the record
  as verified without resolving it. Fixed, with a regression case that fails on the old guard.
* A reusable-workflow record could pin one commit in `ref:` and another in its key; now rejected.
* `patches/000*.patch` also selected the cover letter and stopped `git am`; the documented command
  names both patch files.
* `prompts/1-standards.md` now fetches the artifacts (which live in `cyo`, not `standards`) and
  checks out `FETCH_HEAD` after a bundle fetch, which does not integrate by itself.
* `prompts/5-burble.md` creates the extraction directory and defines the scripts clone before use.

The patch series in `patches/` is regenerated from these sources and re-verified: `git am` applies
both commits on `1725bebd` and the suite passes at the applied state.

## What is in here

| Path | What it is |
| --- | --- |
| `scripts/check-lock-pin-provenance.sh` | The guard: lock-record representation + optional ref provenance |
| `scripts/tests/check-lock-pin-provenance-test.sh` | 20 fixture cases (20/20 pass) |
| `docs/audit-2026-10-31-governance-startup-lock-repair.adoc` | Evidence, candidate matrix, migration, rollback |
| `patches/0001…`, `patches/0002…` | The two commits, `git am`-ready on `1725bebd` |
| `patches/fix-lock-pin-provenance-guard.bundle` | Same commits as a git bundle |
| `PR-BODY.md` | Ready-to-use PR description |
| `EVIDENCE.md` | Commands and raw outputs behind every claim |
| `prompts/*.md` | One self-contained prompt per repository, for sessions I cannot reach |

## Status of the handoff

Two independent facts, both verified on 2026-10-31:

1. **This session cannot write to `metadatastician/standards`.** `git push` returns
   `403 Permission denied to hyperpolymath`, ref creation returns
   `403 Resource not accessible by integration`, and `createPullRequest` fails the same way — even
   though the repository reports `admin: true` on read. The Arena GitHub App being installed is not
   the same thing as this session's token carrying `contents: write` for that repository.
   So the change ships as a patch series; someone with write access (or a session whose token has it)
   applies it.
2. **`hyperpolymath/cyo` has its own caller-side blocker.** Every cross-repo governance pin returns
   zero jobs there — including `333b06a`, which runs in `hypatia` today. Repinning `cyo` will not turn
   it green. Details in `prompts/2-cyo.md`.

## The canary, in plain terms

A **canary** is one throwaway workflow in a consumer repository that does nothing except call the
shared governance reusable at **one exact commit**:

```yaml
jobs:
  governance:
    uses: metadatastician/standards/.github/workflows/governance-reusable.yml@1725bebd3773ea25627479f813283abf1c497a85
```

Two outcomes, and only one is good:

* the run **creates jobs** → runner setup accepted that source pin from that repository. Now you may
  repin the real workflow and judge the policy results.
* the run has **zero jobs** (`startup_failure`, or `failure` with `total_count: 0`) → the pin is not
  usable *from that repository*. Do not repin. If a control canary at a pin that works elsewhere
  (`333b06a` in `hypatia`) also shows zero jobs, the blocker is the repository, not the source.

Why it is needed at all: GitHub validates the callee against the callee's `actions.lock` **at the
pinned commit**, and resolves the called workflow only if that commit is reachable from the callee's
default branch. That is why "push a fix to a branch and point at it" cannot work, and why the check
must be run per repository rather than reasoned about once.

## Recommended order

1. `prompts/1-standards.md` — land the guard (needs write access).
2. `prompts/3-hypatia.md` — already healthy at `333b06a`; use it as the control and decide whether to
   advance to `1725bebd`.
3. `prompts/4-gitbot-fleet.md`, `prompts/5-burble.md` — measure, canary, then repin.
4. `prompts/2-cyo.md` — unblock the caller side first; repin last.
