# Prompt — metadatastician/burble

Paste into an Arena session attached to `metadatastician/burble`.

---

`burble` pins
`hyperpolymath/standards/.github/workflows/governance-reusable.yml@01c9b0c9f2646ebea0b30a9588462642ac94aee9`.

That commit is an ancestor of standards `main`, but it **predates** the lock-representation repair
(f335165 / cf8f912, 2026-10-16 to 10-19) and it was not measured in the audit that produced this
handoff. Treat it as unverified rather than safe.

Tasks:
1. Measure the pin before touching anything. Set both directories up explicitly — the archive
   target must exist before `tar` writes into it, and the scripts must come from current `main`
   (older trees ship older tool versions):
   [source,sh]
   ----
   rm -rf /tmp/std /tmp/b && mkdir -p /tmp/b
   git clone --filter=blob:none https://github.com/metadatastician/standards /tmp/std
   git -C /tmp/std archive 01c9b0c9f2646ebea0b30a9588462642ac94aee9 | tar -x -C /tmp/b
   cd /tmp/b
   bash /tmp/std/scripts/check-lock-pin-provenance.sh .github/workflows/actions.lock
   bash /tmp/std/scripts/check-lock-sync.sh .github/workflows
   bash /tmp/std/scripts/close-lock.sh --check .github/workflows/actions.lock
   ----
   The clone is filtered, so `git archive` of that older commit fetches the blobs it needs on demand;
   it requires network access.
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
