# Prompt — metadatastician/burble

Paste into an Arena session attached to `metadatastician/burble`.

---

`burble` pins
`hyperpolymath/standards/.github/workflows/governance-reusable.yml@01c9b0c9f2646ebea0b30a9588462642ac94aee9`.

That commit is an ancestor of standards `main`, but it **predates** the lock-representation repair
(f335165 / cf8f912, 2026-10-16 to 10-19) and it was not measured in the audit that produced this
handoff. Treat it as unverified rather than safe.

Tasks:
1. Measure the pin before touching anything. In a local standards clone:
   `git archive 01c9b0c9 | tar -x -C /tmp/b`, then from `/tmp/b`:
   `bash /tmp/std/scripts/check-lock-pin-provenance.sh .github/workflows/actions.lock`
   (use the current `main` versions of the scripts — older trees ship older tool versions),
   `bash /tmp/std/scripts/check-lock-sync.sh .github/workflows`,
   `bash /tmp/std/scripts/close-lock.sh --check .github/workflows/actions.lock`.
   Any representation failure means every cross-repo caller pinned there — including `burble` — is
   dying at runner setup.
2. Record what `burble`'s Governance runs actually do today: last 5 runs, conclusion, and
   `total_count` of jobs per run. Zero jobs = broken now, not "maybe broken later".
3. Canary the candidate `1725bebd3773ea25627479f813283abf1c497a85` on a scratch branch — a workflow
   whose only job calls the reusable at that SHA — and accept only if jobs exist. Record the run ID.
4. Repin only after (3). `burble`'s own `actions.lock` carries entries for the standards reusable; add
   the new ref and its closure, then run the repo's lock gate.
5. Report the policy delta honestly: 15 → 19 governance jobs, new inputs, canonical coordinate change
   to `metadatastician/standards`.

Do not paper over a startup failure by removing the governance workflow or dropping it from required
contexts.
