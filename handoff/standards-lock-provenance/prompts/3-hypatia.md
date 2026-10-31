# Prompt — hyperpolymath/hypatia (healthy pin; first canary for anything newer)

Paste into an Arena session attached to `hyperpolymath/hypatia`.

---

`hypatia` pins
`metadatastician/standards/.github/workflows/governance-reusable.yml@333b06a01db1874ffedb2de1bfabb195640927c7`,
and that pin demonstrably works: runs 41196238803 (push) and 41196138008 (PR) on 2026-10-31 both
started jobs and executed policy steps (`governance / UUID v7 conformance` success,
`governance / Actions lockfile verify` success). **Do not change this pin blindly** — it is currently
the estate's proof that `333b06a` is executable, and the reference control for every other repo's
canary.

Your job is only to answer: should `hypatia` move to `1725bebd3773ea25627479f813283abf1c497a85`
(current standards `main`)?

1. Compare the delta: 461 → 527 commits behind the broken baseline. Read the governance-reusable
   change: 15 → 19 jobs (`js-runtimes-provision`, `js-runtimes`, `uuid-v7-conformance`,
   `uuid-v8-conformance` added), new inputs `runs-on` / `baseline-strict` / pinned `hypatia-ref`, new
   optional secret `HYPATIA_SCAN_PAT`. Note `hypatia` passes `hypatia-ref: ${{ github.event.pull_request.base.sha || github.sha }}`
   today — check that still behaves as intended with the new reusable.
2. Canary on a scratch branch: a workflow whose only job calls the reusable at `1725bebd` and does
   nothing else. Accept only if the run has jobs. Record the run ID.
3. If accepted, repin, then verify the full job set: all four new jobs should appear
   (uuid-v7/v8 conformance will need to be acceptable for this repository's UUID usage — if they fail
   on real findings, that is a policy decision for the owner, not a reason to pin back).
4. If the new jobs would break `hypatia`'s required contexts, stop and report; keep `333b06a`.
5. Report the SARIF/baseline behaviour before and after: the new reusable changed the Hypatia verdict
   gating (8d1a2aa), so compare finding counts, not just job colours.

Never widen an allow-list, disable a check or add a local copy of a shared gate to make this work.
