<!--
slice-tasks output template. It holds TWO parts:
  FILE 1 — the task contract (WORKFLOW.md §7). Copy it once per task to specs/M<N>-<slug>/tasks/T###.md,
           starting at its first `---` line. T001 is always the tracer bullet. Ids: M<N>-T001, M<N>-T002, …
  FILE 2 — one row for the MILESTONES.md table that scripts/init-repo.sh created.
Replace every {{placeholder}} and delete every `<!-- guide:` comment when filling.
Keep every `## ` heading exactly as written, in this order; add no other `## ` heading.
Frontmatter: exactly these 10 keys, one per line, this order. No slug:, milestone_branch: or other key (the branch
slug comes from the ## Ask title line; the supervisor runs delegate.sh from milestone/m<N>-<slug>, and the pre-push
hook uses the single milestone/m<N>-* branch). The project's specs/_templates/task.md is a reference copy of FILE 1.
Unknown → `⚠ <question>` (and list it in the STOP message), never an invented value.
No code anywhere: no function bodies, migrations, SQL or tests. The only fenced block allowed is the `sh` Done-when.
Interfaces are named exactly as docs/architecture/lld.md (BE-n, EP-n, FE-n, ST-n, SEQ-n) or
contracts/openapi.yaml (operationId) name them, with the section.
-->

<!-- ======================== FILE 1: specs/M<N>-<slug>/tasks/T###.md ======================== -->

---
id: M{{N}}-T{{###}}
milestone: M{{N}}
skill: implement-task
covers: [{{FR-###}}, {{AE-###}}]
after: [{{M<N>-T###, … — empty [] only for T001}}]
harness: {{claude | codex}}
mode: workspace-write
hitl: {{false | true}}
parallel: {{false | true}}
budget: 1 run, {{minutes, at most 120}} min
---
Owns: {{path/to/file.ext}}, {{path/to/dir-this-task-creates/*}}

<!-- guide: Owns is ONE line, comma-separated, no spaces inside an entry, no backticks (scripts/scope-guard.sh
     splits it on commas and spaces and matches each entry as a shell case pattern, where * also crosses /).
     Prefer exact file paths; use a directory glob only for a directory this task creates alone.
     Never an entry that matches tests/acceptance/** (so never tests/*, tests/** or *), specs/**, docs/**,
     .handoff/**, .claude/**, .githooks/**, AGENTS.md, CLAUDE.md, MILESTONES.md or scripts/scope-guard.sh.
     Never a dependency manifest or lockfile (composer.json, package.json, *.lock, go.mod, …): implementers never
     install; a needed package is an Ask-first ⚠ at G4 that the human resolves before dispatch.
     The implementer's own unit tests for this slice DO belong here (e.g. tests/Unit/<Thing>Test.<ext>). -->

## Ask

{{Title of at most 6 words, no bullet — e.g. "Clinician places a supplement order"}}

<!-- guide: the title line above is the FIRST non-empty line under ## Ask. scripts/delegate.sh and implement-task
     slugify it into the branch name m<N>/t###-<title-slug>, so keep it short, plain and unique per task. -->

{{One sentence: the behaviour a user can watch work when this lands, in the PRD's words.}}

- Slice: {{tracer bullet | vertical slice | seam}} — {{the end-to-end path, named as the LLD names it: entry (EP-n / screen) → BE-n → table → what the user sees}}
- {{FR-###}}: "{{the requirement sentence, copied verbatim from docs/product/prd.md}}"
- {{AE-###}}: "{{the Given/When/Then, copied verbatim}}"
- Out of this task: {{the nearest thing the implementer might be tempted to build, and which task owns it}}
- HITL: {{none | the one question or human act, and the moment to ask for it}}
- Why {{claude | codex}}: {{one line from WORKFLOW.md §6 — one skill, isolated, parallelizable; or why it stays with Claude}}

<!-- guide: BLOCKED task (an in-scope id with no acceptance test, or an interface the LLD lacks): make this the
     FIRST bullet above "Slice:":
     - ⚠ BLOCKED: <question> → <define-acceptance | design-lld>. Not dispatchable until resolved and G4 re-approved.
     and write the Done-when as far as it is known, with `⚠ <what is missing>` in place of the missing part. -->

## Done-when

<!-- guide: Written before dispatch. One line that exits 0 only when the task is done: the AT filter for THIS task's
     acceptance tests, then `&& make check`. Filter = a make target that passes a filter through (e.g.
     `make test FILTER=M1_AT_001`) when AGENTS.md or the Makefile has one; else the `Run one test` command from
     acceptance.md `## How these tests run`, filtered to this task's M<N>_AT_### ids. A slice joined by a seam runs
     its FR-level ATs; the seam runs the AE's end-to-end AT. Never let the implementer write the check it is graded by. -->

```sh
{{make test FILTER=M<N>_AT_### | Run-one-test command from acceptance.md, filtered to this task's AT ids}} && make check
```

- Turns green: {{tests/acceptance/<path> (AT-###, AE-### / FR-###), …}}
- Still red afterwards, expected: {{tests/acceptance/<path> — owned by M<N>-T###}} | none

## Must not change

- `tests/acceptance/**` — read-only. Never edit, skip, delete or weaken a test to get green; if one looks wrong,
  stop and write it under Questions in result.md.
- `specs/**`, `docs/**`, `.handoff/**` (except your own result.md), `AGENTS.md`, `CLAUDE.md`, and every dependency
  manifest or lockfile: a new or upgraded package is an Ask-first question; write it under Questions and stop.
- {{interface a neighbouring task consumes, exactly as named in its Consumes line — e.g. "EP-1 POST /orders (lld.md §4), consumed by M<N>-T###"}} | none
- {{accepted decision this slice must respect: D<n> <title>}} | none
- {{brownfield: each item from specs/M<N>-<slug>/change-plan.md "Must not change"}} | n/a — greenfield

## Consumes / Produces

<!-- guide: Exact interfaces at the task's edges. A task id named on a Consumes line must also be in after:.
     An interface the LLD does not define is a ⚠ for design-lld (a blocked task), never an invented signature. -->

- Consumes: {{interface exactly as lld.md / openapi.yaml names it}} — from {{M<N>-T### | existing path:line}} ({{lld.md BE-n / EP-n §n | openapi.yaml operationId}})
- Produces: {{interface exactly as named}} — for {{M<N>-T### | the user via <screen id>}} ({{lld.md BE-n / EP-n §n | openapi.yaml operationId}})

## Context manifest

- give: this file; `AGENTS.md`; {{docs/architecture/lld.md#<section>}}; {{docs/architecture/contracts/openapi.yaml#<operationId> | n/a}}; {{tests/acceptance/<path> (read-only)}}; {{docs/design/screens.md#S<n> | n/a}}; {{existing source paths the slice extends}}
- never give: other tasks' `runs/`, any worker's self-report or result.md, `.handoff/TRACKER.md`, verifier reviews,
  `.env` or any secret, PHI or real personal data

## Return

- Commit on the branch your worktree was started on (the dispatcher created it from this task's id and the title
  line under ## Ask); never create a second branch. Every commit carries the trailer `Task: M{{N}}-T{{###}}`.
- write `$HANDOFF_DIR/runs/M{{N}}-T{{###}}/result.md` in the WORKFLOW.md §7 result contract (status
  done | human_review | relaunch, base/head sha, changed paths, the Done-when command with its pasted output,
  questions). Missing evidence means `human_review`, never `done`.

<!-- ======================== FILE 2: one row in MILESTONES.md ======================== -->

<!-- guide: Append ONE row to the existing 10-column table (header: id | goal | tasks | D-ids | MR | status |
     gate SHAs | merge SHA | main-check SHA | tag). Never add or change a header, never touch another row.
     id      = M<N>
     goal    = the Goal cell of the PRD `## Milestone cut` row for M<N>, verbatim
     tasks   = "<k> tasks: T001–T<k>" (k from `ls specs/M<N>-<slug>/tasks/T*.md | wc -l`)
     D-ids   = the accepted D-rows the task files cite in Must not change, comma-separated, or —
     MR      = — (the supervisor fills it when the draft MR exists)
     status  = planned (the supervisor owns this cell from now on)
     gate SHAs = the approvals you checked: G1@<sha> G2@<sha> G3@<sha> (G4 is added after approval, not by you)
     merge SHA, main-check SHA, tag = — (report-milestone and the human fill them) -->

| M{{N}} | {{goal from the PRD milestone cut}} | {{k}} tasks: T001–T{{k}} | {{D-ids, or —}} | — | planned | G1@{{sha}} G2@{{sha}} G3@{{sha}} | — | — | — |
