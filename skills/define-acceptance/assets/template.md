---
milestone: M{{N}}
slug: {{kebab-case-outcome}}
artifact: acceptance
status: draft
written_by: define-acceptance (software-factory-kit 0.1)
written_at: {{output of date '+%Y-%m-%d %H:%M %Z (UTC%z)'}}
base_sha: {{git rev-parse --short HEAD when the skill started}}
inputs: "{{docs/product/prd.md@<sha> (G1), docs/architecture/lld.md@<sha> (G3), docs/architecture/hld.md@<sha> (G2), docs/design/screens.md@<sha> (G-ux) or screens n/a (no UI this milestone)}}"
tests: tests/acceptance/M{{N}}/
gate: G4
---

# M{{N}} acceptance: {{milestone name in plain words}}

<!-- define-acceptance template. Keep every ## and ### heading verbatim and in this order. Replace every {{…}} and
     delete these guide comments. A section with nothing to say keeps one row reading `none: <why>`.
     Unknowns are `⚠ <question> (→ Q-n)`, never inventions. No `|` inside a table cell.
     Ids are never renumbered or reused: AT-### acceptance test · EDGE-### edge case · SS-## silent-success pattern ·
     Q-n question. Input ids keep their PRD/HLD/LLD form: FR-### NFR-### SC-### AE-### EC-n INV-n LINV-n FM-n SEAM-n D<n>.
     Technique (Traceability column and matrix headers): example · partition · boundary · state · decision-table ·
     error-guess · concurrency · authz · money-time · data-shape.
     Level: unit · integration · contract · e2e.
     Status: red @ <sha> · planned: <why, ⚠ Q-n> (no <tool>, env, wrong red, runner config, not run) ·
     green: pins <existing behaviour> (brownfield only).
     Words for the human: red = fails today, as it must before the code exists · wrong red = fails for a reason
     unrelated to the feature · planned = written down, not automated yet · BLOCKS G4 = an always-tested kind
     (money, access, lost or duplicated data, patient or customer data, an invariant) left untested. -->

## Scope

In-scope ids for M{{N}}, from the `## Milestone cut` row of `docs/product/prd.md` (Scope and Proves columns) and
what those FRs reach. Every count comes from the command listed under the table for that kind.

| Kind | Ids | Count |
|---|---|---|
| FR | {{FR-001, FR-002}} | {{n}} |
| AE | {{AE-001, AE-002}} | {{n}} |
| EC (PRD edge cases) | {{EC-1, or none: why}} | {{n}} |
| NFR | {{NFR-001}} | {{n}} |
| SC (Proves column) | {{SC-001, or none: this milestone proves no success criterion}} | {{n}} |
| INV (hld.md §7) and LINV (lld.md §7) | {{INV-1, LINV-1}} | {{n}} |
| Screens and states | {{screen names from screens.md, or none: no UI}} | {{n}} |
| State machines and sequences | {{lld.md SM-n and SEQ-n names, or none: why}} | {{n}} |

Counted with (one command per kind; pipes are fine here, never inside the table):

```sh
{{one line per kind, e.g. FR: grep '^| M1 ' docs/product/prd.md | grep -oE 'FR-[0-9]{3}' | sort -u}}
```

Out of scope this milestone: {{FR ids cut to later milestones, or none}}.

## How these tests run

| Item | Value | Source |
|---|---|---|
| Framework | {{test framework and version}} | {{AGENTS.md:line}} |
| Run all M{{N}} acceptance tests | `{{tests-only command}} tests/acceptance/M{{N}}` | {{AGENTS.md:line}} |
| Run one test (for a task's Done-when) | `{{tests-only command}} tests/acceptance/M{{N}} {{filter flag and any fail-on-empty option}} M{{N}}_AT_007` | {{runner docs; proven in Red run}} |
| Test database (safe to reset?) | {{connection and database name the tests reach; yes, or no → not run, ⚠ Q-n}} | {{runner config or test env file:line}} |
| Database between tests | {{reset strategy, e.g. migrate fresh per test, transaction rollback}} | {{config file:line}} |
| Fakes at external boundaries | {{SEAM-n from lld.md §9 → the fake the project already has, or none}} | {{lld.md §9; file:line}} |
| Never faked (lld.md §9) | {{e.g. the database engine in constraint and race tests}} | {{lld.md §9}} |
| Browser tool (e2e) | {{name, or none → e2e rows are planned, ⚠ Q-n}} | {{file:line}} |
| Contract validator | {{name, or none → contract rows are planned, ⚠ Q-n}} | {{file:line}} |
| `make check` runs `tests/acceptance/` | {{yes or no; either way see Suites below, ⚠ Q-n (→ G4)}} | {{Makefile:line, runner suite config:line}} |

- **QA-owned.** Only `define-acceptance` edits `tests/acceptance/**`. `slice-tasks` never lists it in an `Owns:`.
  An implementer who believes a test is wrong writes that under `## Questions` in its `result.md` and stops.
- **Suites (recommendation, → Q-{{n}} at G4, until WORKFLOW.md settles it).** While M{{N}} is built these tests
  measure progress, so `make check` should not run them (every task would stay red); each task's Done-when runs
  only its own AT ids. When M{{N}} merges they should join the regression suite `make check` runs. Today `make check`
  {{does / does not}} reach `tests/acceptance/` ({{Makefile:line, runner suite config:line}}). The change that adds
  them: {{the exact config line}}, made by {{the last task, in its Owns via slice-tasks, or the human}}.
- **Test data.** Synthetic only: {{naming convention, e.g. "Test Patient" prefix, @example.test emails, 555-01xx phones}}.

## Traceability

<!-- guide: one row per test case. Every AE gets a row first (technique `example`), then every FR, INV and LINV
     not yet in any Covers cell, then the edge cases chosen for testing. Requirement = the FR's EARS sentence copied
     verbatim. Unit tests call only BE-n.method signatures lld.md states; e2e tests find elements by role, label or
     screens.md copy. Refusal and no-effect tests make their allowed twin succeed first, in the same test.
     Given/When/Then on one line with concrete values (names, amounts, counts, times), never "valid data".
     Test = path::test name; the name starts with M<N>_AT_###. -->

| AT | Covers | Requirement (EARS, verbatim) | Given / When / Then (concrete values) | Technique | Level | Test (path::name) | Status |
|---|---|---|---|---|---|---|---|
| AT-001 | {{AE-001, FR-001}} | {{FR-001: When …, the system shall …}} | **Given** {{…}} **When** {{…}} **Then** {{…}} | example | {{integration}} | `{{tests/acceptance/M1/<File>::test_M1_AT_001_<behaviour>}}` | {{red @ <sha>}} |

## Edge cases

<!-- guide: walk all nine groups for every in-scope FR (references/edge-cases.md). Case = a concrete input, never
     "invalid input". Expected = the behaviour plus its source (FR, AE, EC, INV, lld.md section, screens.md copy,
     Q-n answer, lld.md §8 FM-n for error guessing), or ⚠ Q-n when no artifact says. Disposition = AT-###, or
     `not tested: <why>` (the human waives it at G4). Money, authorization, lost or duplicated data,
     patient/customer data and every INV and LINV are always tested; one left untested reads
     `not tested: <why> · BLOCKS G4`. Several EDGE rows may share one AT (a data provider / parametrised test). -->

### Equivalence partitions

| EDGE | FR | Case (concrete) | Expected (source) | Disposition |
|---|---|---|---|---|
| EDGE-001 | {{FR-001}} | {{e.g. quantity 0}} | {{behaviour (FR-002), or ⚠ Q-1}} | {{AT-004, or not tested: why}} |

### Boundary values

| EDGE | FR | Case (concrete) | Expected (source) | Disposition |
|---|---|---|---|---|
| EDGE-002 | {{FR-001}} | {{below, on and above each limit, e.g. 9 / 10 / 11 bottles}} | {{…}} | {{…}} |

### State transitions

| EDGE | FR | Case (concrete) | Expected (source) | Disposition |
|---|---|---|---|---|
| EDGE-003 | {{FR-003}} | {{event in a state where it is not allowed, or repeated in the same state}} | {{… (lld.md state table)}} | {{…}} |

### Decision tables

| EDGE | FR | Case (concrete) | Expected (source) | Disposition |
|---|---|---|---|---|
| EDGE-004 | {{FR-002}} | {{one rule: condition values → action}} | {{…}} | {{…}} |

### Error guessing

| EDGE | FR | Case (concrete) | Expected (source) | Disposition |
|---|---|---|---|---|
| EDGE-005 | {{FR-001}} | {{e.g. partner system times out after 10 s}} | {{…}} | {{…}} |

### Concurrency, idempotency, double-submit

| EDGE | FR | Case (concrete) | Expected (source) | Disposition |
|---|---|---|---|---|
| EDGE-006 | {{FR-001}} | {{e.g. the same confirm sent twice within 1 s}} | {{… (INV-1)}} | {{…}} |

### Authorization and abuse

| EDGE | FR | Case (concrete) | Expected (source) | Disposition |
|---|---|---|---|---|
| EDGE-007 | {{FR-001}} | {{e.g. another clinic's order id in the URL}} | {{…}} | {{… plus its allowed twin}} |

### Money, rounding, time zones

| EDGE | FR | Case (concrete) | Expected (source) | Disposition |
|---|---|---|---|---|
| EDGE-008 | {{FR-002}} | {{e.g. 3 × $7.25 with 8.25 % tax; order placed 23:59 clinic time on a DST change day}} | {{…}} | {{…}} |

### Empty, huge and unicode data

| EDGE | FR | Case (concrete) | Expected (source) | Disposition |
|---|---|---|---|---|
| EDGE-009 | {{FR-001}} | {{e.g. no products yet; 121-character name; "José Núñez" in NFD form}} | {{…}} | {{…}} |

## Edge-case coverage matrix

Every in-scope FR against every group: EDGE ids, or `n/a: <why>`. No blank cell.

| FR | partition | boundary | state | decision-table | error-guess | concurrency | authz | money-time | data-shape |
|---|---|---|---|---|---|---|---|---|---|
| {{FR-001}} | {{EDGE-001}} | {{EDGE-002}} | {{n/a: FR-001 changes no state}} | {{…}} | {{…}} | {{…}} | {{…}} | {{…}} | {{…}} |

## Silent-success guards

Ways a test could pass while the feature is wrong (`references/silent-success.md`), and how these tests stop it.

| SS | How a test could pass while the feature is wrong | Tests at risk | Guard used in those tests |
|---|---|---|---|
| SS-01 | {{e.g. only the status code is asserted, so an empty 201 stub passes}} | {{AT-001, AT-002}} | {{asserts total "$36.00" and exactly one new order row; second example 3 × $7.25 → $21.75 (triangulation)}} |
| SS-02 | {{e.g. a refusal passes because the route does not exist yet (every unknown route is a 404)}} | {{AT-007}} | {{the allowed twin (own clinic's order) returns 200 first in the same test, then the other clinic's order returns 404}} |

Laziest-stub check (reasoned test by test at step 7, not executed): {{k}} automated tests reasoned against a
hard-coded, always-200 and always-allow stub. Refusal or no-effect tests whose allowed twin runs first in the same
test (or that assert an exact refusal body): {{n}} of {{n}}.

## NFR and SC checks

One row per in-scope NFR and per SC this milestone's Proves column claims.

| Id | Threshold (verbatim) | How measured | Level | When it runs | Status |
|---|---|---|---|---|---|
| {{NFR-001}} | {{e.g. p95 ≤ 2 s at 50 concurrent users}} | {{AT-### or tool and command}} | {{integration, measurement or manual}} | {{every make check, a G5 measurement, or ship-milestone at G-live}} | {{red @ <sha>, planned: why, or ⚠ Q-n}} |
| {{SC-001}} | {{e.g. ≥ 80 % of clinicians place an order in under 2 minutes}} | {{method from the PRD}} | measurement | {{report-milestone at G5, or after launch}} | {{planned: measured after launch, or n/a: why}} |

## Demo smoke

5-10 steps a person can do on the running app in under 10 minutes, with synthetic data: the P1 journey, one
unhappy path and one access-denied check. `ship-milestone` turns it into `scripts/smoke.sh`; `write-demo-script`
builds on it.

| # | Step (as a person does it) | Expected (what they see) | Re-checks |
|---|---|---|---|
| 1 | {{e.g. Open Test Patient Ana Ruiz's chart and open the store}} | {{e.g. the catalog shows, the patient is preselected}} | {{AT-001, AE-001}} |

## Red run

<!-- guide: the table lists only ATs now `red @ <sha>` (assertion or missing:); an AT moved to planned (env, wrong
     red after 2 corrections) is named in its Q-n instead. If step 3 found an unsafe test database, replace the
     bullets, table and block with one line: `not run: <reason> ⚠ Q-n`. -->

- Command: `{{exact command}}`
- Run at: {{output of date}} on {{git rev-parse --short HEAD}} · exit code: {{non-zero code}}
- Output file: `{{the path step 10 printed, e.g. $TMPDIR/M1-acceptance-red.txt}}`
- Runner summary: {{summary line, e.g. Tests: 14 failed (31 assertions)}}
- Single-test proof: `{{command with a real id}}` → {{names that test, exit code}} · `{{the same command with M<N>_AT_999}}` → exit {{non-zero}}, or {{⚠ Q-n: exits 0 on no tests}}

| AT | Test | Why it fails (assertion, or missing: <name from an approved artifact>) | First failing line |
|---|---|---|---|
| AT-001 | `{{test name}}` | {{assertion, or missing: POST /orders (openapi.yaml)}} | {{first failure line, pipes replaced by /}} |

```text
{{pasted output: summary plus each failing test's name and first failure lines, then both single-test proofs; at most 80 lines; no env values or secrets}}
```

## Spec gaps and questions

Pass {{k}}, {{date}}. One question at a time, each with a recommendation; at most 5 asked per pass, highest cost
of a wrong guess first. Unasked gaps stay here as ⚠.

| Q | Question | Recommended (and why) | Answer (verbatim) | Blocks | Status |
|---|---|---|---|---|---|
| Q-1 | {{question}} | {{answer, because …}} | {{"exact words", skipped, or not asked}} | {{EDGE-###, AT-###}} | {{answered → PRD catch-up after G4, scope change → write-prd, ⚠ open (→ G4), or in PRD}} |

## Change log

| Date | Change | Ids | Why (approved artifact, or the human's exact words) |
|---|---|---|---|
| {{output of date}} | First draft | all | {{G1/G3 approvals at the SHAs in frontmatter}} |
