# Prompt — metadatastician/standards (the repair itself)

Paste into an Arena session attached to `metadatastician/standards`.

---

You are landing a reviewed change in `metadatastician/standards`. Do not re-diagnose it from scratch;
the diagnosis and measurements are attached.

Context: a caller pinned to `fad242d35291de1898242d6737ba02b74a59a2f2` fails at runner setup with
`invalid lockfile pin`, because ten leaf records in that commit's `actions.lock` repeat their own
40-hex SHA as `ref:`. `main` (`1725bebd3773ea25627479f813283abf1c497a85`) already carries the
corrected records — f335165 (#1271) and cf8f912 (#1285). **Do not rewrite those records again.**

Task:
1. Apply `handoff/standards-lock-provenance/patches/0001-*.patch` and `0002-*.patch` on
   `1725bebd` (or `git fetch <bundle> fix/lock-pin-provenance-guard`). Verify `git apply --check`
   is clean first.
2. Run: `bash scripts/tests/check-lock-pin-provenance-test.sh` (expect 18/18) and
   `bash scripts/check-lock-pin-provenance.sh .github/workflows/actions.lock` (expect exit 0).
3. Regression: `bash scripts/check-lock-sync.sh .github/workflows` and
   `bash scripts/close-lock.sh --check .github/workflows/actions.lock` must both stay green.
   If mikefarah yq v4 is available, also `bash scripts/lock-selfcheck.sh "$(git rev-parse HEAD)"`.
   If `gh actions-lock --verify-local` is available, run it too — it was unavailable in the
   session that wrote this change, and say so if it is still unavailable.
4. Sign the commits (`git commit -S`) and open the PR against `main` using
   `handoff/standards-lock-provenance/PR-BODY.md` as the body, attaching
   `docs/audits/audit-2026-10-31-governance-startup-lock-repair.adoc`.
5. Confirm what the PR does NOT do, in the body: no required check disabled or renamed, no
   allow-list widening, no de-pinning, no consumer edits, no duplicate record fix.

Then leave two follow-ups as issues, not changes in this PR:
- `changelog-reusable.yml:126` uses `ref: main` (the last floating helper checkout). Moving it to
  `${{ job.workflow_sha }}` is consumer-visible and needs its own canary.
- `hyperpolymath/cicd-squabbler@1ab1507a… ref: main` drift in `actions.lock` (advisory; fix when the
  record is next touched).
