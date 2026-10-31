# Prompt — hyperpolymath/cyo (the consumer that is actually red)

Paste into an Arena session attached to `hyperpolymath/cyo`.

---

`hyperpolymath/cyo` pins `.github/workflows/governance.yml` at
`hyperpolymath/standards/.github/workflows/governance-reusable.yml@fad242d35291de1898242d6737ba02b74a59a2f2`,
which is not startup-valid. Two separate things are wrong; a repin fixes only one.

**Blocker 1 — caller-side, must be fixed first.** Canary runs on 2026-10-31 returned
**zero jobs for every cross-repo governance pin tried**, including
`metadatastician/standards@333b06a01db1874ffedb2de1bfabb195640927c7`, which runs successfully in
`hyperpolymath/hypatia` today (runs 41196238803, 41196138008). Runs: 41198958192 (`startup_failure`),
41199027418 / 41199027407 (`failure`, 0 jobs), 41199108037 (control, `startup_failure`). So the
defect is in `cyo`'s own Actions configuration, not in the source pin.

1. Open Settings → Actions → General and record, verbatim: whether Actions is enabled, whether
   "Allow all actions and reusable workflows" / "Allow OWNER actions" / "Allow select" is set, and
   the exact allow-list entries. API reads return `403` without repository Administration read, so
   read it in the UI and paste the result into the session.
2. Compare against a repository where cross-repo reusables work (`hyperpolymath/hypatia`).
3. Fix by *adding* the required permission or allow-list entry. Do not disable a check, do not widen
   the allow-list beyond what is needed, and do not replace the shared reusable with local copies.

**Blocker 2 — the broken pin.** Only after a canary shows `jobs > 0`:
1. Re-run the canary at the candidate pin on a scratch branch. Accept the candidate only if the run
   has jobs. Keep a second canary at `333b06a` as a control.
2. Then update `uses:` in `.github/workflows/governance.yml` to the tested commit. Candidates and the
   policy delta are in `docs/audits/audit-2026-10-31-governance-startup-lock-repair.adoc`; note that
   *every* valid candidate is ≥452 commits of policy change away from `fad242d` (jobs 15 → 19), so
   describe it as a policy upgrade, not a minimal repin.
3. `cyo` has an `actions.lock` with no entry for `governance.yml` today; add the reusable ref plus its
   closure (`scripts/complete-job-refs.sh`, `scripts/close-lock.sh`) if the repository is under the
   lock regime — check `.github/workflows/actions.lock` and the governance gate's expectation before
   deciding.
4. Do not push a canary workflow to `main`; use a scratch branch and delete it afterwards. Report the
   run IDs, not prose.

If `cyo` cannot be unblocked this session, say so plainly and leave the pin unchanged — a broken pin
that reports nothing is bad, but a repin that still reports nothing adds churn without evidence.
