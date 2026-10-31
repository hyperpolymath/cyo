# Prompt — hyperpolymath/gitbot-fleet

Paste into an Arena session attached to `hyperpolymath/gitbot-fleet`.

---

`gitbot-fleet` pins
`hyperpolymath/standards/.github/workflows/governance-reusable.yml@75bd5994470661a099df562d6d5ad2fe744dbd66`.

Measured on 2026-10-31 against that commit's own tree: representation pass (no leaf record repeats its
own SHA), `check-lock-sync.sh` in sync, `close-lock.sh --check` closed, and the commit is an ancestor
of standards `main`. So the pin is *plausibly* startup-valid and was **not** canaried in this
repository yet.

Tasks:
1. Record the current state of the governance workflow in this repository: last run ID, conclusion,
   and whether jobs were created (`gh run list --workflow Governance --limit 5`, then
   `gh api repos/hyperpolymath/gitbot-fleet/actions/runs/<id>/jobs --jq '.total_count'`). A run with
   `startup_failure` or `total_count == 0` means this repo is broken today regardless of the pin.
2. Canary the candidate `1725bebd3773ea25627479f813283abf1c497a85` on a scratch branch — a workflow
   whose only job calls the reusable at that SHA. Accept only if the run has jobs; record the run ID.
   Also canary the current pin `75bd599` as a control.
3. Note the coordinate change: the canonical repository is now `metadatastician/standards`; the
   `hyperpolymath/standards` spelling still resolves but new pins should use the canonical name.
4. If both canaries behave, decide with the owner between `75bd599` (454 commits of drift) and
   `1725bebd` (527) — both are policy upgrades relative to the broken baseline; list the job delta
   (15 → 19 jobs, new inputs, optional `HYPATIA_SCAN_PAT`).
5. Repin only after (2) and record the before/after job lists. Add the reusable ref plus its closure
   to `.github/workflows/actions.lock` if this repository carries one.

Do not disable or rename a required check, and do not edit the shared reusable to suit this repo.
