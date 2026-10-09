---
name: define-acceptance
description: Use when a milestone's PRD (G1) and LLD (G3) are approved and "done" must be written down as failing checks before any task is sliced or code is written, or when G4 came back Revise on acceptance coverage, or an implementer reports an acceptance test as wrong. Produces specs/M<N>-<slug>/acceptance.md and failing tests under tests/acceptance/**. Do NOT use for slicing work into tasks (use slice-tasks), a one-bug repro and fix (use fix-bug), or checking finished code against the spec (use verifier).
disable-model-invocation: true
metadata:
  factory-kit: "0.1"
  phase: "7"
  gate: "G4"
---

# define-acceptance

**Outcome:** `specs/M<N>-<slug>/acceptance.md` traces every in-scope AE, FR, NFR, SC and invariant to a concrete
check, lists every edge case by test-design technique with a test or a reason it is untested, and pastes a red run
proving every new test under `tests/acceptance/M<N>/` fails today for the right reason, ready for the human to judge
"acceptance coverage" at G4.

## You own / You never touch

- You own `specs/M<N>-<slug>/acceptance.md` and everything under `tests/acceptance/**` (the tests plus the fixtures
  and helpers they need, kept in that tree); you never write any other path: not product code, migrations,
  factories, seeders, routes, runner or build config (`phpunit.xml`, `tests/Pest.php`, `jest.config.*`,
  `pyproject.toml`, `Makefile`), `AGENTS.md`, the PRD, HLD, LLD, screens, or `.handoff/` (the supervisor owns it).
- You own being the evaluator; you never become the generator: no product code, no stub, no "temporary" route that
  turns a test green. A test you made pass proves nothing.
- You own choosing checks, techniques and test levels; you never invent behaviour. Every expected result cites an
  approved artifact (FR, AE, EC, INV, LINV, an LLD state table, `screens.md` copy) or the human's verbatim answer;
  anything else is a `⚠` spec gap.
- You own naming only what approved artifacts name: endpoints and problem types in `openapi.yaml`; tables,
  components and method signatures (`BE-n.method`) in `lld.md`; copy in `screens.md`. You never introduce a class,
  method, signature, route, table, message or `data-testid` in a test; browser tests find elements by role, label or
  `screens.md` copy. A name a test calls is a contract the implementer must honour, and design closed at G3: a check
  that needs an unnamed thing moves up a level (unit → integration) or becomes `⚠ Q-n` for `design-lld`.
- You may run the project's tests-only command (from `AGENTS.md`) on `tests/acceptance/`, only after step 3 shows
  they use a test database; you never install or upgrade a dependency, migrate or reset a non-test database, deploy,
  or run a git command that changes state. A missing test tool is an "Ask first" `⚠`.
- You own synthetic test data (`Test Patient Ana Ruiz`, `@example.test` emails); you never put real patient,
  customer or partner data, or any secret, in a fixture or in the doc. Repos are public.
- You recommend which edge cases stay untested and why; you never waive one. The human does that at G4.

## Inputs

Run `date '+%Y-%m-%d %H:%M %Z (UTC%z)'`, `git rev-parse --short HEAD` and
`git status --porcelain --untracked-files=all` first; keep all three outputs. Then read, in order. A MUST that is
missing or unapproved → stop and name it; never test against a guess.

1. `AGENTS.md` (MUST): tests-only command, `make check`, stack, test conventions. No tests-only command → stop:
   "AGENTS.md names no test command; the human adds one before define-acceptance can run." It puts acceptance tests
   anywhere but `tests/acceptance/` (`tests/Acceptance`, `tests/Feature/Acceptance`) → stop: "⚠ AGENTS.md puts
   acceptance tests at <path>; WORKFLOW.md §4 fixes tests/acceptance/**, and QA ownership (slice-tasks, scope-guard,
   the AGENTS.md Never rule) depends on that exact path. Change WORKFLOW.md first, or align AGENTS.md."
2. `.handoff/TRACKER.md ## Approvals` (MUST): a G1 row for `docs/product/prd.md@<sha>`, G3 for
   `docs/architecture/lld.md@<sha>`, G2 for `hld.md`, G-ux for `docs/design/screens.md` when the milestone has a
   UI. An approval is stale when `git diff --quiet <sha> -- <path>` exits non-zero (working tree against that
   commit, so uncommitted edits count, as in slice-tasks) → stop: "<path> changed after its <gate> approval at
   <sha>; it needs re-approval first."
3. `docs/product/prd.md` (MUST): the `## Milestone cut` row for M<N> (its Scope and Proves columns), and the FR,
   NFR, AE, EC and SC rows it reaches.
4. `docs/architecture/lld.md` (MUST) and `docs/architecture/contracts/openapi.yaml`: tables and constraints,
   `BE-n` method signatures, API and problem types, §5 sequences, §6 state machines, §7 Invariants → enforcement
   (INV-n, LINV-n and their "Proven by"), §8 failure modes (FM-n), §9 test seams (SEAM-n and "Never faked").
   Brownfield: also `specs/M<N>-<slug>/change-plan.md`.
5. `docs/design/screens.md` and `docs/design/flows.md` (MUST when an in-scope story has a UI): states, copy, a11y.
6. `docs/architecture/hld.md`: `## 7. Invariants` (INV-n), quality scenarios (QA-n), trust boundaries.
7. `docs/decisions/DECISION_JOURNAL.md`; `docs/audit/AUDIT.md` (findings whose Downstream is `define-acceptance`);
   `MILESTONES.md`; `specs/M<N>-<slug>/` (an existing `acceptance.md` means this is a re-run).
8. The test tree, read only: existing `tests/**`, the runner config and its env overrides, any test env file
   (`.env.testing`), how the database is reset between tests, which fakes exist, and whether a browser or
   contract-validation tool is installed.
9. `references/edge-cases.md` (load at step 5) and `references/silent-success.md` (load at step 7).

## The one rule

Done is a set of checks written before the code by someone who will not write the code: every check comes from an
approved artifact, can fail, and fails now because the feature is missing.

Why, in interview words: when one agent writes both the code and its tests, the tests describe what the code does
instead of what the spec asked, and both are wrong together. Splitting the generator (the implementer) from the
evaluator (this skill) and locking `tests/acceptance/**` against implementers is a separate QA team, at agent speed.

## Steps

1. **Check you are the right skill.** A one-bug repro is `fix-bug`; a review of built code is `verifier`. If the
   inputs are not approved (Inputs 2), write nothing and send the stop line from Inputs.
2. **Fix the scope.** M<N> is the human's argument, else the milestone in the `Next` line of `.handoff/TRACKER.md
   ## Resume`, else ask one question recommending the first Milestone-cut row with no `specs/M<N>-*/acceptance.md`.
   Folder: the existing `specs/M<N>-*/`, else create `specs/M<N>-<slug>/` with a 2-4 word kebab slug from the
   Milestone cut name. In scope: the FRs in the M<N> row; the SC and AE ids in its Proves column; every AE and EC
   that cites an in-scope FR; NFRs whose subject is an in-scope journey (unclear → `⚠ Q-n`, recommend including
   it); INV-n and LINV-n whose Basis cites an in-scope FR; the screens and states of in-scope stories; the LLD state
   machines and sequences they touch. Fill `## Scope`; every count comes from a command listed under the table.
3. **Learn how tests run here, safely.** From `AGENTS.md`, the runner config and the existing tests: framework,
   file naming, the flag that runs one test (`--filter`, `-k`, `-t`), database reset, fakes, browser and contract
   tools, lld.md §9 seams. Tests always go in `tests/acceptance/M<N>/` (WORKFLOW.md §4). Settle three things,
   citing file:line:
   - **Test database.** If tests reset a database (refresh, migrate fresh, truncate) and the one they reach is not
     plainly a test database (in-memory, a name containing `test`, a throwaway container), never run step 10: it
     would wipe someone's data. Write `⚠ Q-n` quoting the setting. A test engine that differs from production while
     lld.md §9 lists the database as "Never faked" is also `⚠ Q-n`: constraint and race tests would prove nothing.
   - **Suites.** Read the `Makefile` and the runner's suite config (never edit them): does `make check` reach
     `tests/acceptance/`? Either answer gets `⚠ Q-n (→ G4)`. Yes: every task's `make check` stays red until the
     last task lands. No: these tests never guard against regressions. Recommend: excluded while M<N> is built,
     each task's Done-when runs its own AT ids, and one config line adds them to `make check` at merge (in the last
     task's Owns via slice-tasks, or by the human). Interview line: keep progress tests apart from regression tests,
     or the team learns to ignore red (Freeman & Pryce, *Growing Object-Oriented Software, Guided by Tests*, 2009).
   - **Bootstrap.** If the runner binds base classes only to some folders (Pest's `->in('Feature')`), bind them
     inside each acceptance file. Helper classes need a namespace spelled exactly like the lowercase path
     (`Tests\acceptance\M1\Support`), or use plain functions instead: Linux CI is case-sensitive.
4. **Trace every AE first** (specification by example). One AT row per AE: the cited FR's EARS sentence verbatim,
   the AE rewritten as one line of **Given / When / Then** with its concrete values, technique `example`, status
   `planned` until step 10. Then add a row for every in-scope FR, INV and LINV still uncovered (the "Proven by"
   column of lld.md §7 says how). Choose the **level** as the lowest one where the Then is observable through an
   interface an approved artifact names:
   - `unit`: only a pure rule (price, tax, rounding, date maths) reached through a `BE-n.method` signature as the
     LLD states it; no stated signature → `integration`.
   - `integration`: a request, command or job through the framework, real test database, external systems faked.
   - `contract`: a response checked against `openapi.yaml` (needs a validator the project already has).
   - `e2e`: a browser drives a `screens.md` screen by role, label and copy (needs a browser tool the project has).
   - Tool missing → status `planned: no <tool> ⚠ Q-n (→ G4)`; the demo smoke covers it meanwhile.
5. **Hunt edge cases.** Load `references/edge-cases.md`. For every in-scope FR walk all nine groups: partitions,
   boundaries, state transitions, decision tables, error guessing (expected behaviour from lld.md §8 FM-n),
   concurrency/idempotency/double-submit, authorization/abuse, money/rounding/time zones, empty/huge/unicode data.
   Each `EDGE-###` row has a concrete input, the expected behaviour with its source, and a disposition: `AT-###`, or
   `not tested: <why>` for the human to waive at G4. **Always tested:** money, authorization, lost or duplicated
   data, patient or customer data, every INV and LINV; one of these left untested reads
   `not tested: <why> · BLOCKS G4`. Fill the coverage matrix: every FR × every group holds EDGE ids or
   `n/a: <why>`, never blank. No artifact says what should happen → a spec gap: add a `Q-n` row and rank it with
   the reference's cost order.
6. **Interview the spec gaps: one question per message.** Ask the top-ranked gaps the artifacts and the decision
   journal do not answer, at most 5 per pass, in this shape, then wait:

   ```
   Q-<n> (<k> of ≤5) <question>
   Edge: EDGE-<###> (<FR id>): <the concrete case>
   Why it matters: <one plain sentence: what goes wrong for a person if we guess>
   My recommendation: <answer>, because <source or reason>
   Reply in your own words, "yes" to take the recommendation, or "skip" (it stays ⚠ and the edge stays untested).
   ```

   Record the answer verbatim in `## Spec gaps and questions`. An answer that settles an edge of an in-scope FR may
   now get a test citing `Q-n`; status `answered → PRD catch-up after G4`. An answer that adds behaviour no
   in-scope FR covers is a scope change: record it, test nothing, status `scope change → write-prd`, EDGE row
   `not tested: scope change`. Skipped or unasked gaps stay `⚠ open (→ G4)`; their EDGE rows read
   `not tested: ⚠ Q-n open` (plus `· BLOCKS G4` for an always-tested kind). The PRD waits: editing it now stales
   G1 and slice-tasks refuses to run, so answers live here, are approved at G4, and `write-prd` adds them after.
7. **Guard against silent success.** Load `references/silent-success.md`. For every automated AT run the
   laziest-stub check (would a hard-coded value, always-200 or always-allow stub pass?), triangulation (a second
   example with different numbers) and the **live-path rule**: a refusal or no-effect test (403, 404, "nothing
   saved", count stays 0) first makes its allowed twin (one condition different) succeed in the same test, then
   asserts the refusal; an exact refusal body (`openapi.yaml` problem type, `screens.md` copy) may replace the twin
   only when a missing route could not produce it. Otherwise it passes today, since every unknown route is a 404.
   Strengthen each test until no stub passes; record each pattern guarded as an `SS-##` row (ATs at risk, guard).
8. **Plan NFR and SC checks and the demo smoke.** One `## NFR and SC checks` row per in-scope NFR: threshold
   verbatim, how measured, when it runs (`make check`, a G5 measurement, or `ship-milestone` at G-live). Automate
   only what is deterministic: a privacy rule is a test; a p95 latency is a measurement (timing asserts are flaky).
   An NFR with no number → `⚠ Q-n`. One row per in-scope SC: how and when it is measured (often `report-milestone`
   at G5, or after launch), or `n/a: <why>`. Then 5-10 demo smoke steps: the P1 journey on the running app as a
   person does it, one unhappy path, one access-denied check, each with what the person sees and the ATs it re-checks.
9. **Write the tests** under `tests/acceptance/M<N>/` in the project's framework and naming convention, one file
   per user story:
   - Each test name starts with `M<N>_AT_###` (`test_M1_AT_007_double_submit_creates_one_order`,
     `it('M1_AT_007 …')`). Each file opens with the comment: `QA-owned by define-acceptance
     (specs/M<N>-<slug>/acceptance.md). Do not edit; report a wrong test in result.md ## Questions.`
   - Arrange through public interfaces or LLD-named tables; act through the interface its Level names, calling
     only LLD-stated signatures; assert the Then's exact values and the persisted state, read fresh after the act.
   - Fake only what is outside the system, through the lld.md §9 seams and fakes the project already has; never
     fake what §9 lists as "Never faked". Helpers and fixtures stay under `tests/acceptance/`; data is synthetic.
   - Refusal and no-effect tests follow step 7's live-path rule. No skip, todo, incomplete, xfail, only,
     no-assertion or snapshot markers; no assertion inside an `if`, an uncounted loop, or a `catch`.
10. **Run them red** (skip, with `## Red run` reading `not run: ⚠ Q-n`, if step 3 found an unsafe database).
    `out="${TMPDIR:-/tmp}/M<N>-acceptance-red.txt"; <tests-only command> tests/acceptance/M<N> >"$out" 2>&1; echo "exit=$? out=$out"`.
    The file path is printed so a later shell can read it; record it in `## Red run`. Classify every failure:
    - `assertion`: it reached its Then (or the live-path twin) and got the wrong value. Best.
    - `missing: <name>`: it stopped at something an approved artifact names that does not exist yet
      (`POST /orders → 404`, table `orders` missing, `BE-1.placeOrder` not found). Fine.
    - `env`: dependencies not installed, database or service unreachable, a missing env value. Editing tests cannot
      fix it: mark the affected ATs `planned: env ⚠ Q-n` with the exact error and stop correcting.
    - `wrong red`: anything else (syntax error, a name no artifact defines, broken fixture, timeout). Fix the test,
      never product code: retry once with the exact error; after 2 failed corrections of the same test, mark it
      `planned: wrong red ⚠ Q-n` (WORKFLOW.md §7 failure ladder). Never loop.

    A new test that **passes** now: apply the live-path rule first. If it still passes it cannot fail for this
    feature: delete it, and its EDGE rows read `not tested: passes before the feature exists (<why>)`, plus
    `· BLOCKS G4` for an always-tested kind (brownfield only: a test pinning existing behaviour may stay
    `green: pins <behaviour>`). If the runner cannot reach `tests/acceptance/M<N>` without a config change, write
    the exact line it needs as `⚠ Q-n (→ G4)` and mark those ATs `planned: runner config`; never edit the config.
    **Prove the single-test command** a task's Done-when will use: run it with `tests/acceptance/M<N>` and one real
    id (the output must name that test), then with `M<N>_AT_999` (it must exit non-zero). Exit 0 on the missing id
    → add the runner's fail-on-empty option if its `--help` lists one (PHPUnit `--fail-on-empty-test-suite`) and
    retry; none → `⚠ Q-n (→ G4)`, because a Done-when could then pass with zero tests. Paste the command, date, SHA,
    exit code, output path, summary line, each failing test's name with its first failure line, and both proofs
    (≤ 80 lines, `|` replaced by `/`, no env values or secrets). Set each failing AT's status to `red @ <sha>`.
11. **Fill the template, then self-check** against `## Done when`, at most 2 correction rounds; a box still false
    goes in the STOP's ⚠ lines with Revise recommended. Files the runner created outside your paths
    (`.phpunit.result.cache`, `.phpunit.cache/`, `.pytest_cache/`, coverage output) are listed by name in the STOP,
    never deleted or edited. Then send the STOP message.

**On a re-run** (G4 Revise, or an implementer's `result.md ## Questions` says a test is wrong): read the existing
`acceptance.md` and the exact words; change only the named AT and EDGE rows and their tests; never renumber. A test
changes only when an approved artifact or the human's words show the test, not the code, is wrong; never loosen an
assertion to fit the code. Log each change in `## Change log` with those words, run step 10 again, and record
honestly any test already green because its task landed.

## Output

- `specs/M<N>-<slug>/acceptance.md`, made by filling this skill's `assets/template.md`; and the test files under
  `tests/acceptance/M<N>/`. Nothing else.
- Keep every `##` and `###` heading verbatim, in template order, and replace every `{{…}}`. A section with nothing
  to say keeps one row reading `none: <why>`. No `|` inside a table cell.
- Unknowns are `⚠ <question> (→ Q-n)` where the answer belongs, never an invented value.
- Ids never renumbered or reused: `AT-###` acceptance test, `EDGE-###` edge case, `SS-##` silent-success pattern,
  `Q-n` question. Inputs keep their own ids (FR-###, NFR-###, SC-###, AE-###, EC-n, INV-n, LINV-n, FM-n, SEAM-n, D<n>).
- `status: draft` in frontmatter; approval lives in `.handoff/TRACKER.md ## Approvals` at G4, never in this file.

## Done when

Let `$A` = `specs/M<N>-<slug>/acceptance.md`, `$T` = `tests/acceptance/M<N>`, `$S` = this skill's folder,
`$out` = the output path printed at step 10 and recorded in `## Red run`, `$TG` = the test-file glob from step 3
(`*Test.php`, `*.test.ts`, `test_*.py`) and `ID='(FR|AE|NFR|SC)-[0-9]{3}|(EC|L?INV)-[0-9]+'`. Every box must be true.

- [ ] Only owned paths changed: `git status --porcelain --untracked-files=all | grep -vE ' (specs/M<N>-[^/]+/acceptance\.md|tests/acceptance/)'`
      prints only lines already in the Inputs baseline, plus runner-created files you list by name in the STOP.
- [ ] Headings match: `diff <(grep -E '^#{2,3} ' "$S/assets/template.md") <(grep -E '^#{2,3} ' "$A")` prints nothing.
- [ ] No placeholders: `grep -n '{{' "$A"` prints nothing.
- [ ] Ids unique (the Red run table repeats AT ids by design, so it is left out):
      `awk '/^## Red run/{r=1;next} /^## /{r=0} !r' "$A" | grep -oE '^\| (AT-[0-9]{3,}|EDGE-[0-9]{3,}|SS-[0-9]{2,}|Q-[0-9]+) ' | sort | uniq -d`
      prints nothing.
- [ ] Every in-scope AE, FR, INV and LINV is in the Covers column of a Traceability row:
      `comm -23 <(awk '/^## Scope/{f=1;next} /^## /{f=0} f && /^\| (AE|FR|INV)/' "$A" | grep -oE "$ID" | sort -u) <(awk -F'|' '/^## Traceability/{f=1;next} /^## /{f=0} f && $2 ~ /AT-[0-9]/ {print $3}' "$A" | grep -oE "$ID" | sort -u)`
      prints nothing.
- [ ] Every in-scope id appears in a check:
      `comm -23 <(awk '/^## Scope/{f=1;next} /^## /{f=0} f && /^\| /' "$A" | grep -oE "$ID" | sort -u) <(awk '/^## (Traceability|Edge cases|NFR and SC checks)/{f=1;next} /^## /{f=0} f' "$A" | grep -oE "$ID" | sort -u)`
      prints nothing.
- [ ] Every edge case is decided: `awk -F'|' '$2 ~ /EDGE-[0-9]+/ && $6 !~ /AT-[0-9]{3}|not tested:/' "$A"` prints
      nothing, and the matrix has no blank cell:
      `awk '/^## Edge-case coverage matrix/{f=1;next} /^## /{f=0} f && /^\| FR-/ && /\|[[:space:]]*\|/' "$A"` prints nothing.
- [ ] Every automated AT exists as a test, and every one expected red failed. With
      `AT=$(awk -F'|' '/^## Traceability/{f=1;next} /^## /{f=0} f && $2 ~ /AT-[0-9]{3}/ && $9 !~ /planned/ {gsub(/ /,"",$2); print $2}' "$A" | sort -u)`
      and `RED` the same command with `/planned|green: pins/` in place of `/planned/`,
      `comm -23 <(grep . <<<"$AT") <(grep -rhoE 'M<N>[-_]AT[-_][0-9]{3}' "$T" | sed -E 's/.*AT[-_]/AT-/' | sort -u)`
      prints nothing, and so does the same command with `"$RED"` for `"$AT"` and `"$out"` for `"$T"`.
- [ ] Every failure is the right red:
      `awk -F'|' '/^## Red run/{f=1;next} /^## /{f=0} f && $2 ~ /AT-[0-9]{3}/ && $4 !~ /assertion|missing:/' "$A"`
      prints nothing; the pasted exit code is non-zero (or Red run reads `not run: ⚠ Q-n`); no new test passed;
      both single-test proofs are pasted (or their `⚠ Q-n` is).
- [ ] Every test file carries the QA header: `grep -rL 'QA-owned by define-acceptance' "$T" --include="$TG"` prints nothing.
- [ ] No test can pass by not running or not asserting:
      `grep -rnE 'markTest(Skipped|Incomplete)|DoesNotPerformAssertions|expectNotToPerformAssertions|#\[Requires|->(skip|todo|only)\(|->skip[A-Z][A-Za-z]*\(|\btodo\(|\b(it|test|describe)\.(skip|todo|only|fixme)\(|\bx(it|test|describe)\(|pytest\.(mark\.)?(skip|xfail)|unittest\.skip|t\.Skip\(|@(Disabled|Ignore)\b|assume(True|That)\(|assertTrue\(true\)|expect\(true\)|toMatchSnapshot' "$T"`
      prints nothing, or only hits you read and can name as non-markers (a collection's `->skip(2)`).
- [ ] Every NFR and SC row has a number, a ⚠ or an n/a:
      `awk -F'|' '/^## NFR and SC checks/{f=1;next} /^## /{f=0} f && $2 ~ /(NFR|SC)-/ && $3 !~ /[0-9]|⚠|n\/a:/' "$A"` prints nothing.
- [ ] Demo smoke has 5-10 steps: `awk '/^## Demo smoke/{f=1;next} /^## /{f=0} f && /^\| [0-9]+ \|/' "$A" | wc -l`.
- [ ] No secrets or real data:
      `grep -rnE 'AKIA[0-9A-Z]{16}|sk_(live|test)_|-----BEGIN [A-Z ]*PRIVATE KEY|xox[abprs]-|gh[pousr]_[A-Za-z0-9]{20,}|eyJ[A-Za-z0-9_-]{10,}\.' "$A" "$T"`
      prints nothing, and every person, email and phone in `$T` is synthetic.
- [ ] You wrote no product code this session (check your own list of written paths, not your memory of it).

## STOP

Send exactly this message (fill every `<…>`; counts come from the Done-when commands), then stop. Never start
`slice-tasks` yourself.

```
Acceptance defined for M<N> (judged at G4 together with the tasks): specs/M<N>-<slug>/acceptance.md
- Failing tests: tests/acceptance/M<N>/ (<f> files, <k> automated ATs, all red: <a> on an assertion, <m> on a named missing piece, 0 wrong red), or "not run: <reason> ⚠ Q-n"; <p> planned (tool missing, environment, manual)
- Traced: AE <x>/<y> · FR <x>/<y> · NFR <x>/<y> · SC <x>/<y> · INV and LINV <x>/<y>
- Edge cases: <e> across 9 techniques; <t> tested, <w> not tested, <b> of them BLOCK G4
- Silent-success guards (ways a test could pass while the feature is broken): <s> · Demo smoke: <d> steps
- Spec gaps: <n> answered, <c> scope changes, <o> still open:
  <paste the ⚠ lines, or "none">
- Files the test runner created outside my paths (left untouched): <names, or "none">

Gate G4, acceptance part: "Approve slices, order (tracer bullet first), Owns, harness per task, acceptance coverage?"
Decision now: is this M<N>'s definition of done?
- Approve: continue to slice-tasks; these tests become the contract once G4 is approved. slice-tasks gives each AT (acceptance test) to one task's Done-when, no task may edit tests/acceptance/**, and G5 needs every one green. Cost: changing a test later takes a define-acceptance re-run and your words.
- Revise: name tests or edge cases to add, drop, re-level (test it as unit, integration or browser instead) or test instead of waive. Cost: one more pass before slicing.
- Stop: nothing gets sliced or built against a "done" you have not agreed. Cost: the milestone waits.
Default if no answer: Stop (nothing is sliced).
Recommendation: <option>, because <reason>. (Revise while anything blocks G4.)
Blocking G4 (always-tested kinds left untested): <EDGE-### · money, access, lost or duplicated data, patient or customer data, or an invariant · why untested · what could go wrong for a person>, or "none".
Waivers I recommend: <EDGE-### · why untested · what could go wrong for a person, in plain words>, or "none".
PRD catch-up after G4 (re-opens G1 for these lines): <Q-n: the answer in one line; scope changes marked>, or "none". Run write-prd (Revise) for them after G4, never before slice-tasks: slice-tasks refuses a PRD changed since G1. Cost: the PRD is silent on these answers until then, and you re-approve G1 for just these lines.
Least sure about: <one line: a level choice, an untested edge, or a gap answer>.
Words: red = fails today, as it must before the code exists · wrong red = fails for a reason unrelated to the feature (typo, broken setup) · planned = written down, not automated yet · INV / LINV = a rule that must always hold, from the HLD / LLD.

Reply Approve, Revise (say what to change), or Stop. Final approval is recorded at G4, after slice-tasks, in .handoff/TRACKER.md ## Approvals.
Next skill: slice-tasks.
```

## Red flags

| Thought you might have | Do this instead |
|---|---|
| "The PRD doesn't say what a double-click does; I'll assert the obvious." | It is a spec gap. Add `Q-n`, ask it one at a time with a recommendation, and test only the human's answer. |
| "It fails with a syntax error / missing import, so it's red. Good enough." | That is a wrong red. Fix it (twice at most) until it fails on an assertion or on a missing piece an approved artifact names. |
| "The 'other clinic's order → 404' test already passes; the rule says delete it." | It passes because the route does not exist yet. Make the allowed twin succeed first in the same test, then assert the refusal. |
| "I'll add a tiny route or stub so the test reaches its assertion." | That is generator work. `POST /orders → 404` is already a valid red; leave product code alone. |
| "I'll mark it skipped so `make check` stays green." | Never skip or xfail. Raise the progress-versus-regression suite question as `⚠ Q-n (→ G4)`. |
| "The implementer says the test is wrong; I'll loosen it to match." | Change a test only when an approved artifact or the human's words say the test is wrong, and log it. |
