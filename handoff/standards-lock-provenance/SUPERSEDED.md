# SUPERSEDED — do not publish the patch series in this directory (2026-10-31)

`metadatastician/standards` `main` moved while this handoff was being prepared, and the repair
landed there first. Commit **`7e9b1de272dc110f9653836b9a2f6cd43000bfe7`** — *"fix(ci): repair shared
governance startup -- lock pin contract, third pins, floating helper checkouts (#1381)"* — covers this
handoff's scope and more.

**Action: do not open a PR from `patches/`.** It would be a second, competing implementation of the
same contract — exactly what the estate's coordination rule forbids. The artifacts are kept for
provenance and as an independent check, not as a submission.

## What #1381 landed, measured against this handoff

| Concern | This handoff | Standards `main` after #1381 |
| --- | --- | --- |
| Leaf `ref:` repeating its own pin | `check-lock-pin-provenance.sh` | `check-lock-pin-contract.sh` — **adopted from cicd-suite #66 and extended**: closure in the same gate, commit↔key conjugation, tag-keyed records refused, caller-side exemption bounded, uninspectable states exit 2 |
| Helper checkouts floating on `main` | flagged as a finding, not changed | **repaired**: `changelog-reusable.yml`, `readme-derive-reusable.yml`, `fork-governance-reusable.yml` all default to the reusable's own commit |
| Stale literal helper pins (`317101e03b8f`) | not covered | **repaired** to `ref: ${{ job.workflow_sha }}` with a 40-hex assertion per job (GHES resolves it empty) |
| Guard against re-committing the class | proposed | `check-lock-pin-contract.sh` wired into the required `uses ⊆ actions.lock` gate, plus `check-standards-helper-pins.sh` in Self Test |
| Canary (startup **and** policy execution) | protocol described, executed by hand in `cyo` | `scripts/tests/governance-canary-test.sh` — 11/11, executes the shipped gates on a digest-pinned consumer, refuses `fad242d3` |
| Consumer census | cyo, hypatia, gitbot-fleet, burble | svalinn, odraz, cadastra, lintel, burble, marid, main |
| `burble` at `01c9b0c9` | "predates the fix, needs measurement" | **answered**: 0 violations, green, 21 jobs with policy executed |

Independent cross-check, run today against `main` (`ae8492ae`) in a fresh clone:

```
scripts/check-lock-pin-provenance.sh .github/workflows/actions.lock   → exit 0, 30 records, 0 failures
scripts/close-lock.sh --check .github/workflows/actions.lock          → closed
```

No disagreement between the two implementations on the current lock.

## Delta that the estate still does not cover

These are the only items from this investigation that survive #1381. They are findings for the
standards thread, not a patch:

1. **Recorded-ref drift is unguarded.** `actions.lock` records
   `hyperpolymath/cicd-squabbler@1ab1507a…` with `ref: main`, and `main` now resolves to
   `193349090edb…`. `check-action-pins-resolve.sh` proves existence and ancestry, not
   ref→commit conjugation, so nothing reports the mismatch. Measured **not** startup-fatal
   (`333b06a` records `dtolnay/rust-toolchain … ref: v1` while `v1` moved, and its jobs run), so this
   is advisory — this handoff's `--remote` flag is the only thing that reports it.
2. **`hyperpolymath/cyo` is absent from the census and still broken.** Pinned at `fad242d`, and it
   returns **zero jobs for every cross-repo pin tried**, including `333b06a`, which executes policy in
   `hyperpolymath/hypatia`. Caller-side blocker; Administration/Actions API reads return 403.
3. **`hyperpolymath/gitbot-fleet` at `75bd599`** is also absent from the census and was never
   canaried in-repo.

## What remains useful here

* `scripts/check-lock-pin-provenance.sh` needs **no YAML parser**, so it can inspect a lock where
  mikefarah `yq` v4 is missing (the standards contract correctly exits 2 there instead). Useful as a
  cross-check, not as a second gate.
* `docs/audit-2026-10-31-governance-startup-lock-repair.adoc` — the timeline showing the same
  immutable pin starting on 2026-10-03 and failing from 2026-10-17, i.e. that enforcement changed
  under a fixed source. That argument is independent of who implements the guard.
* `EVIDENCE.md` — run IDs and raw outputs for the `cyo` and `hypatia` observations above.
