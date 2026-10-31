# Regression evidence — standards governance startup-lock repair

Measured 2026-10-31 against a local clone of `metadatastician/standards`
(`main` = `1725bebd3773ea25627479f813283abf1c497a85`). Rebuilt after a sandbox reset
destroyed the first set of scratch artifacts; every number below was re-measured.

## 1. The failure, from the field (read-only API)

```
$ gh api repos/hyperpolymath/cyo/actions/runs/39007442235 --jq .referenced_workflows
[{"path":"hyperpolymath/standards/.github/workflows/governance-reusable.yml@fad242d3529…",
  "sha":"fad242d35291de1898242d6737ba02b74a59a2f2"}]

$ gh api repos/hyperpolymath/cyo/actions/runs/39007442235/jobs --jq '.jobs[] | [.name,.conclusion,(.steps|length)] | @tsv'
governance / Guix packaging policy (Nix retired)   failure  1     # step 1 = "Set up job"
… 14 of 14 jobs, every one failing in "Set up job"

$ gh api repos/hyperpolymath/cyo/check-runs/117322683200/annotations --jq '.[].message'
Unable to resolve action `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1`:
invalid lockfile pin. Run `gh actions-lock` to update the lockfile
```

Same immutable pin, 14 days earlier — 13 jobs succeeded:

```
$ gh api repos/hyperpolymath/cyo/actions/runs/37113819760/jobs --jq '.jobs[] | [.name,.conclusion] | @tsv'
governance / Language / package anti-pattern policy   success
governance / Actions lockfile verify                  failure
governance / Validate Hypatia Baseline                success
…
```

## 2. Reproduction on an immutable canary (2026-10-31)

| Run | Pin | Result |
| --- | --- | --- |
| cyo 41198958192 | metadatastician/standards@fad242d | `startup_failure`, 0 jobs |
| cyo 41199027418 | hyperpolymath/standards@fad242d | `failure`, 0 jobs, `referenced_workflows: []` |
| cyo 41199027407 | hyperpolymath/standards@1725beb | `failure`, 0 jobs |
| cyo 41199108037 (control) | metadatastician/standards@333b06a + closed caller lock | `startup_failure`, 0 jobs |

The control is decisive: `333b06a` runs in `hyperpolymath/hypatia` today
(runs 41196238803, 41196138008 — `UUID v7 conformance` success, `Actions lockfile verify` success).
So `cyo` has a caller-side blocker independent of the source pin. Administration API reads return
`403 Resource not accessible by integration`, so it could not be diagnosed further here.

## 3. Source matrix — one tool version across all revisions

Representation = `scripts/check-lock-pin-provenance.sh`; coverage = `scripts/check-lock-sync.sh`;
closure = `scripts/close-lock.sh --check`. All three taken from `main` and pointed at each tree, so
the tool version is held fixed (older trees ship older, differently-flagged script versions).

| Commit | Records | Representation | Coverage | Closure |
| --- | --- | --- | --- | --- |
| fad242d | 22 | **FAIL** (10 leaf self-SHA records) | **FAIL** — `mirror.yml` → `hyperpolymath/standards@571cc734` unrecorded | OK |
| 75bd599 | 26 | pass | in sync | closed |
| 333b06a | 28 | pass | in sync | closed |
| 8d1a2aa | 30 | pass | in sync | closed |
| 1725beb | 30 | pass | in sync | closed |

fad242d's ten offending records: `actions/cache`, `actions/checkout`, `actions/configure-pages`,
`actions/deploy-pages`, `actions/upload-artifact`, `actions/upload-pages-artifact`,
`dtolnay/rust-toolchain`, `erlef/setup-beam`, `swatinem/rust-cache`, `webfactory/ssh-agent`.

Remote provenance (`--remote` on main) reports exactly one drift:
`hyperpolymath/cicd-squabbler@1ab1507a… ref: main` now resolves to `193349090e…`. Advisory, because
`333b06a` records `dtolnay/rust-toolchain@e2a55d2f… ref: v1` (now `683b588c…`) and its jobs still run.

## 4. Guard test suite

```
$ bash scripts/tests/check-lock-pin-provenance-test.sh
check-lock-pin-provenance-test: 18 passed, 0 failed
```

Covers: historical self-SHA leaf (fail), corrected tag+commit (pass), non-pin SHA ref (fail), empty
ref (fail), key/commit disagreement (fail), missing `sha1-` (fail), tag-keyed record with own key
(pass) and with another tag (fail), reusable record pinned by SHA (pass) and by tag (pass), missing
lock / unknown schema / empty population / no workflows (exit 2 = uninspected), and four `--remote`
cases with a stubbed resolver (peel match, drift advisory, unresolvable ref, unreadable remote).

## 5. Consumer pins, 2026-10-31

| Repository | Pin | Ancestor of main | State |
| --- | --- | --- | --- |
| hyperpolymath/cyo | hyperpolymath/standards@fad242d | yes | broken source **and** 0 jobs for valid pins |
| hyperpolymath/hypatia | metadatastician/standards@333b06a | yes | valid; jobs execute |
| hyperpolymath/gitbot-fleet | hyperpolymath/standards@75bd599 | yes | valid by measurement; not yet canaried in-repo |
| metadatastician/burble | hyperpolymath/standards@01c9b0c9 | yes | predates the fix; needs measurement |

## 6. Commits behind the broken baseline

```
75bd599  2026-10-19  454 commits after fad242d
333b06a  2026-10-19  461        (live consumer proof)
8d1a2aa  2026-10-29  519
1725beb  2026-10-29  527        (current main)
```

No startup-valid commit exists within a policy-neutral distance of the broken baseline.
Policy delta fad242d → 1725beb: 72 workflow files, +8497/−847; governance-reusable 1445 → 1903 lines,
15 → 19 jobs; new inputs `runs-on`, `baseline-strict`, pinned `hypatia-ref`; new optional secret
`HYPATIA_SCAN_PAT`; coordinates → `metadatastician/standards`; lock schema `v0.0.2 → v0.0.3`.

## 7. Things that could not be run here

| Tool | Why | Substitute |
| --- | --- | --- |
| `gh actions-lock --verify-local` | extension install fails downloading the release asset (EOF) | the three repo-owned checks |
| `scripts/lock-selfcheck.sh` end-to-end | mikefarah yq v4 absent | ran its three components |
| Actions/Administration settings reads | `403` on every repository | documented as a blocker |
| Writing to metadatastician/standards | `403` on push, ref creation, `createPullRequest` | patch series + bundle |
