---
name: slice-tasks
description: Use when define-acceptance has written specs/M<N>-<slug>/acceptance.md for a milestone whose PRD, HLD and LLD are approved, and the milestone must be cut into dispatchable tasks before any build starts, or when G4 asked for the slices to be revised. Produces specs/M<N>-<slug>/tasks/T###.md (one file per task) and the milestone's MILESTONES.md row. Do NOT use for writing acceptance checks or tests (use define-acceptance), changing a table, interface or decision (use design-lld), or building a task (use implement-task).
disable-model-invocation: true
metadata:
  factory-kit: "0.1"
  phase: "8"
  gate: "G4"
---

# slice-tasks

**Outcome:** `specs/M<N>-<slug>/tasks/T001.md … T0kk.md` (at most 10), each a complete WORKFLOW.md §7 task contract
filled from `assets/template.md`, plus one `MILESTONES.md` row, with the analyze pass at `RESULT: PASS` and G4
presented with its coverage matrix.

## You own / You never touch

- You own `specs/M<N>-<slug>/tasks/T###.md` fully (create them, revise them on a Revise answer); you never edit
  `acceptance.md`, `brief.md`, `change-plan.md` or anything else under `specs/`.
- You own adding this milestone's row to `MILESTONES.md` with status `planned`; you never edit another row, and
  never change a status cell after creating it (the supervisor owns that column).
- You own the slicing: which behaviour goes in which task, the order, `Owns:` globs, Done-when commands and the
  harness per task; you never change a requirement, table, interface, acceptance case or decision. A gap becomes a
  `⚠` for design-lld, define-acceptance or clarify-spec.
- You own naming each task's interfaces exactly as `lld.md` / `openapi.yaml` name them (BE-n, EP-n, FE-n, SEQ-n,
  operationId); you never invent an interface and never write code, function bodies, migrations, SQL or tests
  (implement-task and define-acceptance own those).
- You own giving tasks only work an implementer may do; you never assign an install, a dependency manifest or
  lockfile, or the stack skeleton (implement-task never installs; a new package is an Ask-first `⚠` for the human).
- You own reading every input, the tree and git history (read-only) and two snapshot files under `${TMPDIR:-/tmp}`;
  you never write `.handoff/**`, `docs/**`, `tests/**` or source, and you never commit, push, install, dispatch a
  task or start the build.

## Inputs

**Mode:** the `Mode` row of `lld.md`. If it has none: brownfield when `specs/M<N>-<slug>/change-plan.md` or
`docs/audit/AUDIT.md` exists, otherwise greenfield (no product code yet; the framework skeleton must still exist).

Check **every** row, in this order (phase order). A row that fails does not stop the check: collect them all. If
any fails, write nothing and send the **Inputs failed** message under STOP. Anything that exists but you did not
open goes on the **Not read** line, with why.

| Path | Needed | Fails when → message |
|---|---|---|
| `AGENTS.md` | always | Missing, or its Commands table lacks `make check` or a Tests-only command → "AGENTS.md is missing or names no make check / tests-only command. Run scripts/init-repo.sh, then the human fills the Commands table." `make check` and the tests-only command come from here. |
| `MILESTONES.md` | always | Missing, or no table whose header starts with `id` → "No MILESTONES.md table. Run scripts/init-repo.sh first." |
| `docs/product/prd.md` | always | Missing → "No PRD. Run write-prd first." Check P prints 0 → "PRD milestone-cut row for M<N> has no FR-### ids. Run clarify-spec on docs/product/prd.md." That row's Scope and Proves cells give the scope; its `Exit demo` cell picks the tracer bullet. |
| `docs/architecture/hld.md` | always | Missing → "Run design-hld and hold G2 first." |
| `docs/architecture/lld.md` | always | Missing → "Run design-lld and hold G3 first." Check L prints 0 → "lld.md has no interfaces to cite. Run design-lld." Its `## Requirement trace` maps each FR to tables, BE-n, EP-n, FE-n/ST-n, SEQ-n, SM-n. |
| `.handoff/TRACKER.md ## Approvals` | always | Rows hold time · gate · `artifact@sha` · exact words. For G1 `docs/product/prd.md`, G2 `docs/architecture/hld.md`, G3 `docs/architecture/lld.md`, take the last row with that gate and `<file>@<sha>`. None → "No <gate> approval recorded for <file>." Check A1 fails → "Approved sha <sha> for <file> is not in this repo." Check A2 fails → "<file> changed after <gate> (approved <sha>). Re-approve it first." |
| `specs/M<N>-<slug>/change-plan.md` | brownfield | Missing → "Brownfield milestone without a change plan. Run design-lld first." Its "Must not change" list goes into every task. |
| Stack skeleton and `make check` | always | Check K fails → "Scaffold the stack first: the human runs the framework install and AGENTS.md's Setup, fills the Makefile's check recipes, and commits. slice-tasks cannot assign installs." |
| `specs/M<N>-<slug>/acceptance.md` | always | Missing → "No acceptance for M<N>. Run define-acceptance first." `## How these tests run` has no `Run one test` row → "acceptance.md names no single-test command. Re-run define-acceptance." Read: `## Traceability` (AT → Covers → Level → test), the Suites note, every `## Spec gaps and questions` row whose status says `open` (G4 questions), every `EDGE-###` row whose disposition starts `not tested:` (waivers; `BLOCKS G4` marked). |
| `tests/acceptance/**` | always | Never fails here. An in-scope id with no test path is an analyze WARN → `⚠` for define-acceptance. |
| `docs/architecture/contracts/openapi.yaml` | if present | Name endpoints by operationId; without it, cite the `lld.md` EP-n row. |
| `docs/design/flows.md`, `docs/design/screens.md` | if present | Name screens by S-id in Asks; the demo spine story backs the tracer bullet. |
| `docs/decisions/DECISION_JOURNAL.md` | always | Never fails; missing → "journal missing" on Not read. Accepted D-rows become Must-not-change lines and the row's D-ids cell. |
| `specs/M<N>-<slug>/brief.md` | if present | Its appetite caps the total budget. |
| `specs/M<N>-<slug>/tasks/` | if present | Revision mode: change only what the Revise answer names (Step 12). |
| The tree | always | `git ls-files` (brownfield: `Owns:` uses real paths; greenfield: the paths the LLD and the stack's conventions name). |

The checks the table names (run from the project root):

```sh
grep -E '^\| M<N>( |\|)' docs/product/prd.md | awk -F'|' '{print $4}' | grep -cE 'FR-[0-9]{3}'   # P: Scope cell
grep -cE '^## (1\. Data model|2\. Backend components|4\. API design)' docs/architecture/lld.md      # L
git cat-file -e '<sha>^{commit}'                       # A1, per approved file: must exit 0
git diff --quiet <sha> -- <file>                       # A2, per approved file: must exit 0
make -n check                                          # K: must exit 0 and its output must not say "not configured"
```

## The one rule

Cut thin vertical slices that each make a user-visible behaviour pass a check that already exists, starting with a
tracer bullet, so every task is ownable (disjoint `Owns:`), checkable (a pass/fail Done-when) and changes no
decision.

## Steps

1. **Clock, milestone, snapshot.** Run `date` and keep it for the STOP line. `M<N>`: the milestone the human named
   wins; else the one `specs/M<N>-*/` that has `acceptance.md` and no `tasks/`. None → Inputs-failed STOP: "No
   specs/M<N>-*/acceptance.md without tasks/. Run define-acceptance first." Two or more → ask which (recommend the
   lowest `N`). `<slug>` is that directory's name, never invented. Before reading anything else, save
   `git status --porcelain --untracked-files=all > "${TMPDIR:-/tmp}/slice-M<N>-status.txt"` and
   `cp MILESTONES.md "${TMPDIR:-/tmp}/slice-M<N>-MILESTONES.md"`. Then check every Inputs row.
2. **Map the scope.** In scope = the FR and AE ids in the PRD `## Milestone cut` row for `M<N>` (Scope and Proves
   cells) plus the ids in the Covers column of acceptance.md `## Traceability`. Never scan all of `acceptance.md`:
   its `Out of scope this milestone:` line names later milestones' FRs. For each id note its AT ids, their Level
   and test path, and the LLD parts its `## Requirement trace` row names. An id with no AT, or one that needs an
   interface the LLD lacks, still gets a task: a **blocked** one (Step 10), never one you fill with a guess.
3. **Interview the gaps.** Ask only what the inputs do not answer, **one question per reply, each with a
   recommended answer and why**, at most 5 this pass:
   - "Which journey is the tracer bullet? Recommended: <the `Exit demo` cell of the PRD `## Milestone cut` row for
     M<N> / the flows.md demo spine>, because it is the path a reviewer will watch first."
   - Codex is pre-approved for Gauntlet work (factory-kit docs/WORKFLOW.md §6). Ask only when AGENTS.md or
     TRACKER.md marks the repo or a path partner-confidential or private: "Is <paths> partner-confidential?
     Recommended: yes (keep those tasks on Claude) unless the repo is already public."
   Unanswered → use the recommendation and list it under Assumed answers.
4. **Cut the tracer bullet: T001.** The thinnest path that crosses every layer the HLD and LLD name for the spine
   journey (entry point → logic → storage → back to the screen) and turns one happy-path AE green. It owns only the
   app paths of that journey (its route, controller, service, model, migration, view, unit tests), never the
   skeleton, which exists already. Everything off that path is hard-coded or left out. `after: []`,
   `parallel: false`, `harness: claude`: every later task copies its patterns, so build it where you can watch it.
   It is the only task in wave 1.
5. **Slice the rest vertically.** One task per user-visible behaviour (an FR and the AE that proves it), owning every
   file that behaviour needs across layers: its migration, model, service, controller or handler, view, and its own
   unit tests. Test each slice: "If only this task landed on top of its `after:` tasks, could someone watch
   something new work, and would an existing acceptance test say so?" Never a layer task ("all the DB work",
   "the API", "the frontend"). Order the riskiest or least certain slice right after T001, so it fails early.
6. **Name the joins.** Where two slices touch the same file or one consumes the other's output, choose: make one
   `after:` the other (serial), or add a **seam task** that is `after:` both and owns only the join (route
   registration, navigation, provider or event wiring). A seam needs checks on both sides: each slice's Done-when
   runs the FR-level ATs for its own FR (unit or integration rows whose Covers names that FR) and the seam's
   Done-when runs the AE's end-to-end AT. No FR-level AT for a slice → make it serial instead of joining by a seam.
   Cite an AE in `covers:` on the task whose landing turns its test green; earlier tasks in that chain cover the FR
   only. A hot shared file has one owner per wave.
7. **Write `Owns:`.** One line, comma-separated, no spaces or backticks (scope-guard splits and matches it).
   Exact file paths first; a directory glob only for a directory the task creates alone. Never anything matching
   `tests/acceptance/**` (so never `tests/*` or `*`), and never a dependency manifest or lockfile: a slice that
   needs a new package gets a `⚠ Ask-first: <package> for <why>` for G4 (the human adds it and commits before
   dispatch). Mark `parallel: true` only when the task's `Owns:` is disjoint from every other `parallel: true`
   task; otherwise `parallel: false`, and the supervisor runs it alone.
8. **Write Done-when before the rest of the body.** One `sh` line: the AT filter for this task, then
   `&& make check`. The filter command is a make target that passes a filter through (e.g.
   `make test FILTER=M1_AT_001`) when AGENTS.md or the Makefile has one; else acceptance.md's `Run one test`
   command, filtered to this task's `M<N>_AT_###` ids. Everything it calls (the tests, the runner, `make check`)
   exists before dispatch; that is what the Inputs check guarantees. Never let the implementer write the check it
   is graded by: no existing check can tell this task is done → merge it into a neighbour or make it serial.
   - **Suites.** If acceptance.md raised the "does `make check` run tests/acceptance?" Q-n, write every Done-when
     assuming its recommendation (acceptance joins `make check` only when the milestone lands). Put that Q-n under
     G4 questions and say the Done-when lines change if G4 picks otherwise (implement-task stops when base
     `make check` is red). If acceptance.md gives the joining config line to a task, give its file to one task that
     is `after:` every other task, whose Done-when runs all of `tests/acceptance/M<N>` then `make check`.
   - **Runner outside make.** If a Done-when calls the runner directly, add an Open `⚠`: "scripts/delegate.sh's
     default claude allow-list runs only make/git/date: dispatch claude tasks as Agent-tool subagents, or extend
     DELEGATE_CLAUDE_ALLOWED_TOOLS with the runner (supervisor's call)."
   - Never tell a task to skip or weaken a test.
9. **Choose harness, hitl and budget per task** (factory-kit docs/WORKFLOW.md §6, inlined here).
   - `codex` only when the task is one skill (`implement-task`), isolated (disjoint `Owns:`, needs only the files in
     its manifest, no conversation) and parallelizable (`parallel: true`), **and** it deletes no files (the Oracle
     seat's policy blocks installs, `rm`, push and `python -c`), needs no secret or partner-confidential context and
     has `hitl: false`. Bonus: a Claude verifier then reviews it cross-family.
   - `claude` for everything else: the tracer bullet, seams, HITL tasks, auth, payment and migration-heavy slices
     you will want to watch.
   - `hitl: true` only when the task needs one human answer or act mid-run (set a secret, click a console, look at a
     screen); name it on the Ask's HITL line. Everything else is AFK (`false`).
   - `budget: 1 run, <m> min`, with `m` ≤ 120 (about 1-2 hours of agent time). Bigger → split by behaviour (happy
     path vs error path, one AE each), never by layer.
   - Put the one-line reason on the Ask's `Why <harness>:` line.
10. **Fill each file and the row.** Fill FILE 1 of `assets/template.md` per task. The first line under `## Ask` is a
    title of at most 6 words: delegate.sh and implement-task turn it into the branch name. Copy FR and AE text
    verbatim; list in Must not change the fixed lines, every interface a neighbour consumes, the accepted D-rows the
    slice must respect and (brownfield) every change-plan "Must not change" item; name Consumes / Produces exactly,
    with their LLD id; keep the context manifest to the smallest set of `path#section` entries.
    **Blocked task** (Step 2): first Ask bullet `- ⚠ BLOCKED: <question> → <define-acceptance | design-lld>. Not
    dispatchable until resolved and G4 re-approved.`; write the Done-when as far as it is known, with
    `⚠ <what is missing>` in place of the missing part. Then add FILE 2 to `MILESTONES.md`. If the Step 1 copy
    already has a `| M<N> |` row: in revision mode it is your earlier draft, so replace it; otherwise leave it
    untouched and add an Open `⚠`: "MILESTONES.md already had an M<N> row; I did not change it."
11. **Analyze.** Load `references/analyze.md` and run its script from the project root:
    ``awk '/^```sh$/{f=1;next} /^```$/{f=0} f' <this skill's dir>/references/analyze.md | sh -s -- specs/M<N>-<slug>``.
    Fix every `FAIL` in the task files or your row (never in an input) and re-run until `RESULT: PASS`. Every
    `WARN` becomes a `⚠` in the STOP message. Then run the Done when checks and send the STOP message.
12. **Handle the G4 answer, one per reply.**
    - **Approve** → write nothing. The supervisor records the approval, runs log-decision and dispatches.
    - **Revise** → re-take Step 1's two snapshots, then change only the tasks the answer names; never renumber,
      never reuse an id. A dropped task's draft file is deleted (it was never approved) and listed as
      `retired: <reason>` in the next STOP message. Re-run Step 11, then send the STOP message again.
    - **Stop** → stop. The task files stay unapproved drafts; nothing may be dispatched from them.

## Output

- `specs/M<N>-<slug>/tasks/T###.md`, one per task, T001 first, from FILE 1 of `assets/template.md`: frontmatter
  keys exactly `id milestone skill covers after harness mode hitl parallel budget` (one per line, that order), one
  `Owns:` line, then the six `## ` sections in template order. Every `{{…}}` replaced, every `<!-- guide:` comment
  deleted. Unknowns are `⚠ <question>`, never invented values. No `slug:` or `milestone_branch:` key: the branch
  slug is the `## Ask` title line, and the supervisor dispatches from `milestone/m<N>-<slug>` (the project's
  `specs/_templates/task.md` is a reference copy of the same FILE 1 shape).
- One row in `MILESTONES.md` from FILE 2, in the 10-column table `scripts/init-repo.sh` created.
- Ids: tasks `M<N>-T###` (file `T###.md`), numbered from T001 in wave order on the first pass; a revision gives a
  new task the next free number. FR/NFR/AE ids are copied from the PRD.
- Nothing else is written in the repo (the Step 1 snapshots live under `${TMPDIR:-/tmp}`).

## Done when

Run from the project root; `D=specs/M<N>-<slug>`, `S="${TMPDIR:-/tmp}/slice-M<N>-status.txt"`,
`M="${TMPDIR:-/tmp}/slice-M<N>-MILESTONES.md"`.

- [ ] `ls $D/tasks/T*.md | wc -l` prints 1-10, and `$D/tasks/T001.md` exists.
- [ ] The analyze script prints `RESULT: PASS` with `uncovered=0 empty_covers=0 parallel_overlaps=0 unknown_after=0
      cycles=0 acceptance_in_owns=0` on its `Analyze:` line (`blocked` may be non-zero; each one is in the STOP).
- [ ] Every acceptance path named in a task exists:
      `for p in $(grep -ohE 'tests/acceptance/[A-Za-z0-9_./-]+' $D/tasks/*.md | sort -u); do test -e "$p" || echo "missing $p"; done`
      prints nothing.
- [ ] Every FR/AE quoted in a task exists in the PRD:
      `for id in $(grep -ohE '(^|[^N])(FR|AE)-[0-9]{3}' $D/tasks/*.md | grep -oE '(FR|AE)-[0-9]{3}' | sort -u); do grep -q "$id" docs/product/prd.md || echo "unknown $id"; done`
      prints nothing.
- [ ] You wrote nothing else: `comm -13 <(sort "$S") <(git status --porcelain --untracked-files=all | sort) | grep -vE "^.. ($D/tasks/|MILESTONES\.md$)"`
      prints nothing (and your own list of written paths agrees).
- [ ] Only your row changed: `diff "$M" MILESTONES.md | grep -E '^[<>]' | grep -vE '^[<>] \| M<N> \|'` prints
      nothing, and `grep -cE '^\| M<N> \|' MILESTONES.md` prints 1.
- [ ] No secret values in any task file — config and secret *names* only:
      `grep -nEi '(password|secret|token|api[_-]?key)[[:space:]]*[:=][[:space:]]*[^[:space:]<{⚠]|sk-[A-Za-z0-9]{16,}|BEGIN [A-Z ]*PRIVATE KEY' $D/tasks/*.md`
      prints nothing, or only lines you read and can name as names, not values; no real personal data or PHI.

## STOP

Send exactly one of these, then stop.

### Inputs failed

```
slice-tasks stopped before slicing (<date>). Milestone: M<N>-<slug> | not chosen.
Missing or stale (phase order):
- <path>: <that row's message>
Not read: <paths and why> | none
Next: <the remedy of the first line above>. I wrote nothing and will not start the next phase.
```

### Slices ready (G4)

Fill the brackets from the analyze output (paste its tables verbatim) and from acceptance.md:

```
slice-tasks wrote specs/M<N>-<slug>/tasks/T001.md … T0<k>.md (<k> tasks) and the M<N> row in MILESTONES.md (<date>).
Tracer bullet: M<N>-T001 — <the end-to-end path it proves, in plain words> (turns <AE-###> green).
<waves> waves · <p> parallel · <c> claude / <x> codex · <h> HITL · <budget_min> min total (from analyze)
Words: wave = tasks that can start together · seam = a small task that wires two slices together · HITL = the task
pauses for you · harness = which AI tool runs it · Owns = the only files that task may change.

<plan table from analyze>

Coverage matrix (every in-scope FR/AE → task → acceptance test):
<coverage table from analyze>
<Analyze: line from analyze>

Gate G4 — "Approve slices, order (tracer bullet first), Owns, harness per task, acceptance coverage?"
- Why this order: T001 fires one thin round through every layer first (a tracer bullet), so wiring and deploy
  problems show up on day one, not at the end; then the riskiest slice, then the rest.
- Hardest slicing call: <task or join> — <why, in plain words>
- Seams: <seam task ids and what each joins> | none
- Least confident about: <task or estimate> — <why>; it would firm up with <evidence>
- Blocked tasks (never dispatched until resolved): <M<N>-T### — question → skill> | none
- Acceptance questions for you (from define-acceptance): <Q-n — question — its recommendation> | none
- Untested edge cases needing your waiver: <EDGE-### — why untested, BLOCKS G4 where marked> | none
- Open ⚠: <each other ⚠ and WARN, with the skill or person that resolves it> | none
- Assumed answers: <question → assumed answer> | none
- Not read: <paths and why> | none

Options:
a) This plan — <k> vertical slices, <p> in parallel. You get early end-to-end proof and small diffs to review;
   you pay <s> seam task(s) and a merge per parallel slice. Cost: <budget_min> min of agent time.
b) Same tasks, all serial on Claude — zero merge conflicts and the simplest to watch on a first run; you pay
   wall-clock time (about <sum of budgets> min end to end).
c) Fewer, bigger tasks — less seam overhead; you pay larger diffs that are harder to verify, and a failure
   throws away more work.
d) Do nothing — build M<N> in one session without task files. Fastest to start; you lose scope-guard, parallel
   work and a pass/fail check per step, so "done" rests on one long self-report.
Recommendation: a), because <reason tied to the deadline and the riskiest slice>. (Revise while an edge case
BLOCKS G4.)
Default if you don't answer: nothing is dispatched.
Interview line: "<one sentence on why you sliced vertically with a tracer bullet first>"

Reply Approve / Revise (name the task and what to change) / Stop.
Next skill: implement-task. After Approve, type: go M<N> — the supervisor records your words, runs log-decision,
dispatches wave 1 (M<N>-T001), then each later task as its after: tasks finish. I will not start the next phase.
```

## Red flags

| Thought you might have | What to do instead |
|---|---|
| "T001 can create every table and model so the later tasks go faster." | That is a horizontal layer. T001 owns only what the spine journey touches; each later slice owns its own migration, model, logic and view. |
| "Greenfield: T001 can run the framework install and own composer.json." | Implementers never install. Stop with Inputs failed: the human scaffolds the stack and fills `make check` first; a new package is an Ask-first `⚠` at G4. |
| "Two parallel tasks both need the routes file; the merge will sort it out." | Overlapping `Owns:` means merge conflicts and a scope-guard that can't tell who broke what. Serialize with `after:`, or give the shared file to a seam task. |
| "No acceptance test or LLD interface covers this; the implementer can write one or pick a signature." | Nothing grades its own work and interfaces are decisions. Write a blocked task with `⚠ BLOCKED → define-acceptance / design-lld`. |
| "Codex is faster; give it every task." | Only one-skill, isolated, parallel leaf slices with no deletions, secrets or HITL. The tracer bullet and seams stay on Claude. |
| "G4 is approved, I'll dispatch T001." | STOP. The supervisor records the approval and dispatches implement-task; this skill never chains. |
