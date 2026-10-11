# software-factory-kit workflow (v0.1)

The canonical spec of the workflow. Skills, templates and scripts implement this file; when they disagree, this
file wins and the skill gets fixed. Names are the user's choices (2026-10-08): verb-object skills, `.handoff/`
state dir, `software-factory-kit` repo. The main Claude session's role is named **supervisor**.

## 1. Thesis

Human defines intent and constraints → agents investigate, plan, implement, test → the human reviews decisions and
risk at **human approval gates** → **automated quality gates** verify continuously → every failure improves the
system (**on-the-loop improvement**). Machines catch *broken*; the human catches *wrong*.

Five layers the factory is designed around:

| Layer | Question | Where it lives |
|---|---|---|
| 1 Product intent | What problem, what does success mean? | `decode-prompt`, `sharpen-brief`, `gather-evidence`, `write-prd`, `clarify-spec` |
| 2 System design | Architecture, interfaces, invariants | `design-hld`, `design-lld`, `draw-diagrams`, `map-ux-flows` |
| 3 Agent orchestration | Which agent, which tools/context/permissions | supervisor (CLAUDE.md), `slice-tasks`, `scripts/delegate.sh` |
| 4 Verification | What evidence proves it's correct | `define-acceptance`, `scope-guard.sh`, `make check`, `verifier`, `check-security` |
| 5 System improvement | When an agent fails, what do we fix | `route-failure`, `FINDINGS.md`, `HARNESS_CHANGELOG.md` |

**Metrics and the partner lens (layer 1, F3).** Every product names one North Star and 2-3 supporting metrics,
each tested vanity vs actionable and leading vs lagging, with grounded targets (`docs/METRICS.md`). `sharpen-brief`
writes candidates and the hiring-partner lens, `gather-evidence` sources them, `write-prd` locks the tree at G1.
Targets and sizing need a market: every brief asks who already solves the problem, who the ideal customer is, how
big the market and winnable share are, where customers cluster, and when and how hard they will use the product;
`gather-evidence` answers with `references/market-research.md` (F4), and `design-hld` sizes the system from that
load profile.

Planning follows the Double Diamond (Design Council, 2003-04): Diamond 1 = Discover (brief, evidence) + Define
(PRD); Diamond 2 = Develop (UX, HLD, LLD) + Deliver (acceptance, tasks, build, ship). Spec-driven development maps
onto it: Constitution = `AGENTS.md` (written by `scripts/init-repo.sh`), Specify = `write-prd`, Clarify =
`clarify-spec`, Plan = `design-hld` + `design-lld`, Tasks = `slice-tasks`, Implement = `implement-task`,
Validate = `define-acceptance` + verifier + `report-milestone`.

## 2. Roles and rules that never bend

1. **The supervisor is the primary workhorse that can also dispatch.** The main Claude session runs the phase
   skills itself (under each skill's boundaries), and additionally dispatches one-skill, isolated, parallel jobs to
   subagents or other harnesses (§6). It also verifies dispatched work and records every move in
   `.handoff/TRACKER.md`. Outside a phase skill it owns `.handoff/**` and the status column of `MILESTONES.md`.
2. **One skill = one phase = one declared output, then STOP.** A skill writes only its declared paths, ends by
   naming its gate question and the single next skill, and never starts the next phase itself.
3. **The human is the trigger between phases.** Phase skills are manual-only (`disable-model-invocation: true`
   for Claude/Cursor; `agents/openai.yaml` `allow_implicit_invocation: false` for Codex). That is a convenience,
   not a wall: Codex was observed following a hidden skill anyway. The walls are rules 4-5.
4. **Boundaries are code.** `scripts/scope-guard.sh` fails any task diff outside its `Owns:` paths;
   `make check` is the project's single green/red command; the pre-push hook runs both plus a secret scan.
5. **Nothing grades its own work.** The `verifier` subagent has Read/Grep/Glob only and never sees a worker's
   self-report. The supervisor re-runs `make check` itself and reads the diff; it never trusts a summary.
6. **Approvals are verbatim and bound to a commit.** Gate answers are Approve / Revise / Stop, written to
   `.handoff/TRACKER.md ## Approvals` as `| time | gate | artifact@sha | exact words |` *before* acting.
   Discussion is not approval; relayed words authorize nothing; an approval is stale once the artifact changes
   after that SHA.
7. **Decisions are recorded, never made, by `log-decision`.** Run after every gate.
8. **Human-only actions:** merge, push to remotes, deploy, repo visibility, spending money, `curl | bash`
   installs, editing CLAUDE.md / AGENTS.md / skills. The supervisor may run them only after a recorded yes.
9. **Clock:** run `date` before writing any time. **Secrets/PHI never go in `.handoff/`** (several harnesses read it,
   repos are public).
10. **Pass paths, not paraphrases.** Hand agents the approved artifact file, never a summary of it.

## 3. Tracks (the supervisor picks one, announces it, the human may override)

| Track | Rule | Phases |
|---|---|---|
| **Fix** | Diff fits in one sentence, ≤2 files, has a repro, touches no API / data model / dependency / auth / payment / migration | `fix-bug` → verifier → G5 |
| **Standard** | One milestone of a product whose PRD already exists | (`clarify-spec`) → `design-lld` delta → `draw-diagrams` → G3 → `define-acceptance` → `slice-tasks` → G4 → build → G5 |
| **Full** | New product, graded project, or capstone | Everything from `decode-prompt` |

Auth, payments, migrations and public contracts are never Fix. A task may move up a track mid-flight, never down.
Brownfield (inherited code) adds `audit-codebase` before `write-prd`, and `design-lld` writes a change plan.

## 4. Phase table

Paths are relative to the project repo. `M<N>` = milestone number, `T###` = task id.

| # | Skill | Single responsibility | Output (only these paths) | Must not | Gate / question |
|---|---|---|---|---|---|
| 0 | `scripts/init-repo.sh` | Scaffold the constitution | `AGENTS.md`, `CLAUDE.md`, `.claude/settings.json`, `.claude/agents/verifier.md`, `.handoff/TRACKER.md`, `.handoff/{inbox,runs,reviews}/.gitkeep`, `MILESTONES.md`, `docs/README.md`, `docs/decisions/DECISION_JOURNAL.md`, `specs/_templates/task.md`, `specs/_templates/result.md`, `.githooks/pre-push` (+ `git config core.hooksPath .githooks`), `.gitlab/merge_request_templates/Default.md`, `scripts/scope-guard.sh`, `scripts/delegate.sh`, `scripts/embed-diagrams.sh`, `Makefile` (from `Makefile.example`; written as `Makefile.example` when a `Makefile` without `check:` exists), `.gitignore` lines (`.handoff/runs/*/events.jsonl`, `.handoff/runs/*/stderr.log`, `docs/demo/raw/`) | Overwrite an existing file | **G-init** "Are these the rules every agent here must obey?" |
| 0.5 | `decode-prompt` | Find the question behind the question and the traps a one-shot build would fall into | `specs/M<N>-<slug>/decode.md` | Design a solution, write the brief, state a hypothesis as fact | **G-decode** "Is this the question behind the question, and do I accept these trap guards?" |
| 1 | `sharpen-brief` | Turn the ask into a brief; plan *with* the human | `specs/M<N>-<slug>/brief.md` | Propose solutions/stack (park them), write requirements, guess | **G0** (Full only) "Right problem, appetite, track?" |
| 2 | `gather-evidence` | Answer the brief's research questions with cited evidence | `docs/research/R<NN>-<slug>.md`, `docs/research/sources.md` | Recommend product/architecture, cite unread sources | none (feeds G1) |
| 2b | `audit-codebase` | Brownfield: what risk do we inherit? | `docs/audit/AUDIT.md` | Modify code, run the target's toolchain on the host | **G-audit** "Which findings constrain the build, which do I accept?" |
| 3 | `write-prd` | WHAT and WHY, no HOW. **Hard stop.** | `docs/product/prd.md` | Name frameworks/DBs/endpoints outside Constraints; write tasks/code | **G1** "Right problem, scope, non-goals, success measure; every ⚠ resolved or waived?" |
| 3b | `clarify-spec` | Resolve open `⚠` markers in ONE artifact | that artifact + its `## Clarifications` log | Add scope, edit other files, decide for the human | per question |
| 4 | `map-ux-flows` | Screens, flows, states, copy, a11y, demo layout | `docs/design/flows.md`, `docs/design/screens.md` | Mention state libraries, props, endpoints; add screens no story needs | **G-ux** "Which variant? Every state covered?" |
| 5 | `design-hld` | Boxes, how they talk, qualities, trust boundaries, invariants, scale budget | `docs/architecture/hld.md` (+ diagram specs for `draw-diagrams`) | Design tables/classes; change scope; write code | **G2** "Do these containers, connections, trust boundaries and invariants match my intent? Approve D<n>?" |
| 6 | `design-lld` | Tables + relationships, BE components, FE components + state ownership, API, sequences, state machines; brownfield change plan | `docs/architecture/lld.md`, `docs/architecture/contracts/openapi.yaml`, brownfield: `specs/M<N>-<slug>/change-plan.md` | Write function bodies or edit `src/` | **G3** "Could I defend every table, state owner, endpoint and sequence in an interview?" |
| 6b | `draw-diagrams` | Render ONE diagram type from an approved design doc (delegatable, parallel) | `docs/architecture/diagrams/<type>.mmd` (+ embed in the doc section it illustrates) | Change the design; invent boxes/fields not in the doc | reviewed inside G2/G3 |
| 7 | `define-acceptance` | Define done as checks before code; think of every edge case | `specs/M<N>-<slug>/acceptance.md`, failing tests under `tests/acceptance/**` | Write product code; write tests that cannot fail | folded into G4 |
| 8 | `slice-tasks` | Vertical, ownable, checkable tasks | `specs/M<N>-<slug>/tasks/T###.md` (one file per task), a `MILESTONES.md` row | Change decisions, write code, horizontal layer tasks, put `tests/acceptance/**` in any `Owns:` | **G4** "Approve slices, order (tracer bullet first), Owns, harness per task, acceptance coverage?" |
| 9 | `implement-task` | Make ONE task's Done-when pass inside its `Owns:` | commits on `m<N>/t###-<slug>`, `.handoff/runs/<id>/result.md` (id = `M<N>-T###`) | Edit outside Owns, touch tests/specs/decisions, install/push/merge, claim done without fresh `make check` | automated: scope-guard + `make check` |
| F | `fix-bug` | One-shot lane: failing repro first, smallest fix | `specs/bugs/<slug>.md`, one `fix(...)` commit with its regression test | Fix without a red repro; refactor neighbours; ignore the Fix-track entry rule | rides G5 |
| 10 | `verifier` (subagent) | Find gaps between code and approved artifacts; report only | `.handoff/reviews/M<N>-pass<k>.md` | Fix, approve, read the worker's self-report | human sets each row fix / file / keep / discard |
| 11 | `check-security` | Baseline security evidence | `docs/security/CHECKLIST.md` | Write fixes; log secrets | inside G5 "Zero unaccepted high/critical; accept listed risks?" |
| 12 | `report-milestone` | Shipped vs planned, with evidence; fills the MR body | `docs/milestones/M<N>.md` | Round confidence up, hard-code counts, merge | **G5** "Evidence pasted, dispositions done, nothing graded its own work, one-revert rollback? Merge / Revise / Stop" |
| 13 | `ship-milestone` | Get the merged SHA live, verified, watched | `docs/runbooks/deploy.md`, `docs/ops/HEALTH.md`, `scripts/smoke.sh` | Write secret values; declare live from `/health` alone | **G-live** "/version = merged SHA, smoke green with TLS verified?" |
| X | `log-decision` | Record a decision the human just made | append to `docs/decisions/DECISION_JOURNAL.md`; Type-1 → `docs/decisions/NNNN-<slug>.md` | Mark accepted without quoted human words; renumber/delete; drop rejected options | none (it IS the record) |
| 14 | `garden-docs` | Keep docs findable, in sync, not overclaiming | `docs/README.md`, `README.md`, `ARCHITECTURE.md` summary, `docs/archive/` | Change decisions or code; hard-code numbers | rides the MR |
| 15 | `route-failure` | Turn a failure into a proposed harness change in the owning layer | rows in software-factory-kit `FINDINGS.md`; proposed diff in `HARNESS_CHANGELOG.md`; `docs/learnings/<slug>.md` only if durable | Edit CLAUDE.md/AGENTS.md/skills without approval of the exact diff; freeze a one-off quirk | **G-L5** "Which layer owns this, adopt this fix?" |
| 16 | `quiz-me` | Make the human able to defend every decision | private: `~/software-factory-kit-private/<repo>/TOPICS_TO_REVIEW.md` | Edit the repo; grade generously | self-check |
| 17 | `write-demo-script` | Script, storyboard, shot list, post copy (grade-6 reading level) | `docs/demo/SCRIPT.md` (`status: draft`), `docs/demo/POSTS.md` | Record, post, claim what the code can't back | **G-demo** "Would a 12-year-old follow it, and is every claim true?" (human flips `status: approved`) |
| 18 | `record-demo` | Verified recording from an approved script | `docs/demo/SMOKE.md`, `docs/demo/RECORDING.md`, `docs/demo/out/*` (`docs/demo/raw/` gitignored) | Rewrite the script; post; show secrets/PHI | human uploads and posts |

`docs/README.md` is the index: one line per artifact type → path. HLD = `docs/architecture/hld.md`, LLD =
`docs/architecture/lld.md`, diagrams = `docs/architecture/diagrams/`, decisions = `docs/decisions/`, milestones =
`MILESTONES.md` + `docs/milestones/M<N>.md`, living PRD = `docs/product/prd.md`, per-milestone specs =
`specs/M<N>-<slug>/` (immutable after merge).

**Milestone close chain (each STOP names exactly this one next skill):** tasks landed → `garden-docs` (pre-G5 run)
→ `check-security` (the supervisor starts the `verifier` subagent alongside it, §6 G5 prep) → `report-milestone` →
G5 → merge → `ship-milestone` → G-live → `garden-docs` (first commit of the next milestone branch) →
`route-failure` if the closed milestone's `.handoff/TRACKER.md ## Log` holds a FAIL or ESCALATE line, else
`quiz-me` → G-L5 → `quiz-me`.

## 5. Gate protocol (every human approval gate)

The agent **diverges**: 2-3 options plus "do nothing", each with cost and a recommendation, one decision per reply,
format: *question · background · options with costs · recommendation · default*. The human **converges**: Approve /
Revise / Stop. Before acting on Approve the supervisor writes the Approvals row, then calls `log-decision`.
At G2 and G3 the presenter also states: the hardest decision, the rejected alternatives, and the part it is least
confident about. Interrupt the human only for: a gate, a P0/P1 finding, a new dependency, an architecture conflict,
work stuck after the failure ladder, or spend.

## 6. Dispatch policy (the user's rule, 2026-10-08)

The Claude supervisor dispatches to another harness (or a subagent) **only** when the job is:
- **one skill** — the dispatched worker runs exactly one phase skill, nothing else;
- **isolated** — it owns disjoint paths (`Owns:`) and needs only files, not conversation;
- **parallelizable** — something else can proceed at the same time.

Canonical fan-outs:
- **After G1:** `map-ux-flows` (if UI-critical) ∥ `gather-evidence` follow-ups.
- **After `design-hld` drafts:** `draw-diagrams hld-context`, `draw-diagrams hld-container`,
  `draw-diagrams deployment` in parallel → G2.
- **After `design-lld` drafts:** `draw-diagrams erd`, `draw-diagrams be-class`, `draw-diagrams fe-components` (only
  when the LLD has a UI), `draw-diagrams sequence-<journey>` (one per core journey), `draw-diagrams state-<entity>`
  (one per `SM-n` state machine) in parallel → G3. Default harness: Codex (`codex exec --sandbox workspace-write`).
- **After G4:** `implement-task` for every task whose `Owns:` is disjoint and whose `after:` deps are done, each in
  its own worktree; harness per the task file.
- **At G5 prep:** `verifier` ∥ `check-security` ∥ `report-milestone` facts.

Harness table (who does what by default):

| Harness | Invocation | Default jobs | Limits |
|---|---|---|---|
| Claude Code (Max) | interactive supervisor; subagents; `claude -p` | supervisor, all design/gate-facing skills, verifier | none for our use |
| Codex (Oracle seat; approved for all Gauntlet work 2026-10-08) | `scripts/delegate.sh` → `codex exec --sandbox workspace-write -C <worktree> -o <result>` | `draw-diagrams`, `write-demo-script`, isolated `implement-task`, cross-family review (`codex review`) | managed policy: no installs, rm, push, `python -c` in exec; edits may be visible to the employer's admin console |
| Cursor `agent` / Antigravity `agy` | not installed yet | v2 workers | install needs the human's yes |
| Grok Bot | no CLI | research digests pasted into `.handoff/inbox/` (candidate sources only) | manual |

## 7. Shared state: `.handoff/`

```
.handoff/
  TRACKER.md            committed. ## Resume / ## Tasks / ## Approvals / ## Log  (single source of truth)
  inbox/                committed. pasted outputs from Grok Bot / browser research (candidate sources only)
  runs/<id>/            one dir per task or job; <id> = M<N>-T### (task) or a job id such as M<N>-D## (draw-diagrams)
    task.md             committed. supervisor job file, for a job with no specs/.../tasks/T###.md (stays put across attempts)
    brief.md            committed. the dispatch prompt, derived from the task file
    cmd.txt             committed. exact command + harness version
    answers.md          committed. supervisor-written: the human's verbatim answers to a run's questions, written
                        before a relaunch; survives dispatch (delegate.sh copies it into the archive, never moves it)
    result.md           committed. worker result contract (below)
    last-message.md     committed. the harness's final message (codex exec -o)
    events.jsonl        GITIGNORED (may contain file contents)
    stderr.log          GITIGNORED. harness stderr
  runs/<id>.attempt-<ts>/ committed. a previous attempt's files, archived by delegate.sh before each dispatch
  reviews/M<N>-diff.patch committed. milestone diff written by the supervisor; verifier input
  reviews/M<N>-pass<k>.md committed. verifier output
```

`## Resume` (rewritten as the last edit of every supervisor move): As of (`date`) · In flight · Next · Waiting on ·
Verified (SHA + command). `## Log` lines: `<date> ROUTE|DISPATCH|RESULT|VERIFY|FAIL|ESCALATE T### harness=… why=… evidence=…`.
Task states: `todo | working | input-required | done | human_review | failed`.

**Task contract** — `specs/M<N>-<slug>/tasks/T###.md`, one file per task, the worker's only input:

```
---
id: M1-T003   milestone: M1   skill: implement-task   covers: [FR-004, AE-002]   after: [M1-T001]
harness: claude   mode: workspace-write   hitl: false   parallel: true   budget: 1 run, 20 min
---
Owns: app/Services/Payment.php, tests/Unit/PaymentTest.php
## Ask
## Done-when      (a pass/fail command written before dispatch; can't state it = don't dispatch)
## Must not change
## Consumes / Produces   (exact interfaces with neighbouring tasks)
## Context manifest      give: <paths#sections> ; never give: other runs/, worker self-reports
## Return         write $HANDOFF_DIR/runs/M1-T003/result.md
```

**Job file** — `.handoff/runs/M<N>-D##/task.md`, written by the supervisor for each §6 diagram fan-out job (one per
design-hld §14 row or design-lld §10 row); same shape as a task contract, copied from `specs/_templates/task.md`:
- **id** `M<N>-D##`: the design milestone's number, `D` (diagram job, never `T`), two digits numbered in dispatch
  order within the milestone. One id per diagram type per milestone: a Revise re-dispatch reuses the id (edit and
  re-commit the file; `delegate.sh` archives the previous attempt). Branch `m<N>/d##-<slug>`, trailer `Task: M<N>-D##`.
- **frontmatter** `id`, `milestone`, `skill: draw-diagrams`, `covers: []`, `after: []`, `harness: codex` (§6
  default), `mode: workspace-write`, `hitl: false`, `parallel: true`, `budget: 1 run, 15 min`, `slug: <type>`,
  `milestone_branch: milestone/m<N>-<slug>`.
- **`Owns:`** exactly the one output path `docs/architecture/diagrams/<type>.mmd` (draw-diagrams refuses anything
  else; the embed into hld.md/lld.md is the supervisor's, not the job's).
- **sections** `## Ask` names the type and the doc (`Draw <type> from docs/architecture/<hld|lld>.md.`);
  `## Done-when` = draw-diagrams' own checks pass and `scripts/scope-guard.sh <this file> <milestone_branch>` exits
  0; `## Must not change` = every other path, above all `docs/architecture/*.md`; `## Consumes / Produces` = none;
  `## Context manifest` `give:` the row's `Draw from` reference(s), verbatim; `## Return` write
  `$HANDOFF_DIR/runs/M<N>-D##/result.md`.
- **Commit it on `milestone_branch`** (together with the hld.md/lld.md it draws from) before `scripts/delegate.sh
  .handoff/runs/M<N>-D##/task.md`; delegate.sh dispatches only the committed version and scope-guard reads `Owns:`
  from that branch.

**Result contract** — `.handoff/runs/<id>/result.md` (e.g. `.handoff/runs/M1-T003/result.md`):

```
---
task: M1-T003   harness: codex   model: <id>   status: done | human_review | relaunch   reason: <one line>
base_sha: <sha>   head_sha: <sha>   changes: [paths]   tests: "make check -> 0 (42 passed)"   not_verified: [...]
---
## Changes
## Tests run      (command + pasted output)
## Questions
```

Missing/invalid result, timeout, or a dirty tree after "done" ⇒ `human_review`.

**Supervisor verification of delegated work, in order:** result exists and parses (exit codes don't count) →
`scripts/scope-guard.sh <task-file> <milestone-branch>` exits 0 → supervisor runs `make check` in the worktree itself
→ reads `git diff` against the claim → verifier pass (cross-family where available) → `git merge --squash` onto the
milestone branch → `Verified: <sha> <cmd> → <result>` in Resume.

**Correlation id:** `M<N>-T###` appears in the task file, run dir, branch `m<N>/t###-<slug>`, commit trailer
`Task: M<N>-T###`, MR body and milestone report.

**Failure ladder:** log FAIL → retry once with the exact error → fresh session after 2 failed corrections → fallback
harness → reset the worktree → `human_review` + one question. At most 2 verifier passes without the human's word.

## 8. Git: one MR per milestone

- Canonical remote: Gauntlet GitLab (`origin`, fetch) with two push URLs (GitLab + GitHub mirror). Never open PRs
  on the GitHub mirror.
- **Every merged branch is a milestone, and on the Full track each planning phase is its own milestone** (owner's
  rule, 2026-10-08), so each phase is reviewable, citable and revertible on its own:
  - **M1 Research** — `brief.md` + `docs/research/` (cited evidence for the problem statement).
  - **M2 Product** — `docs/product/prd.md` (+ clarifications).
  - **M3 Design** — HLD, LLD, DB design, API contract, all diagrams (may split into M3 HLD / M4 LLD when large).
  - **Then implementation milestones**, smaller and more granular (tracer bullet first), each with its own
    acceptance + tasks. Standard track starts at the design-delta milestone.
- **Redo in the same repo:** branch from `main`, delete the old implementation on that branch, rebuild milestone by
  milestone; the old code stays in `main`'s history (owner's choice for Cerbo v2).
- Branches: `milestone/m<N>-<slug>` per milestone (draft MR from day one); `m<N>/t###-<slug>` per task in its own
  worktree; squash each task onto the milestone branch (`feat(m1/t003): …` + `Task: M1-T003`); merge the milestone
  with a merge commit (semi-linear), so `git log --first-parent main` reads as a list of milestones and one
  `git revert -m 1 <merge>` rolls a milestone back.
- Stage files explicitly; never `git add -A`.
- **Commits read as decisions and results** (owner's rule, 2026-10-10): one commit per decision or result (an
  approved artifact, a squashed task, a set of review fixes), grouping small related edits; never one per tool
  step. The subject is one line (at most 72 characters) saying what changed; the body names the D, FR and task ids.
- **The MR is opened when the milestone branch is first pushed**, and its description fills
  `.gitlab/merge_request_templates/Default.md`: the one-line TL;DR first, then every section answered, citing the
  D-ids and the spec paths the milestone delivers.
- **Auto-merge only on a standing yes:** when `## Approvals` holds the human's standing yes to auto-merge, the
  supervisor merges the MR once G5 is approved (merge commit, TL;DR as its message) and pushes `main` to the
  mirror; without that row, merging stays human-only (§2 rule 8).
- **CI checks every push** (owner's rule, 2026-10-10): `.gitlab-ci.yml` runs `make check` on the human's own
  shell runner (tag `macbook-shell`; no Docker executor, so CI never grows the container VM). When a project's
  GitLab repo is created, the supervisor enables that runner for it (`glab api -X POST projects/<id>/runners -f
  runner_id=<id>`; no new token). After every push it reads the pipeline and reports the job's test counts; an MR
  merges only on a green pipeline. A job stuck at `pending` means the runner is offline: say so, and never merge on
  a local run alone.
- **Every deploy ends with a review link** (owner's rule, 2026-10-10): once `/version` shows the deployed SHA, the
  human gets the URL and a numbered walkthrough per demo user (ship-milestone STOP A).
- Done = merged **and** `make check` run on main, SHA recorded in `MILESTONES.md` and Resume.

## 9. Decision journal schema (`docs/decisions/DECISION_JOURNAL.md`, committed)

```
### D<n> <title>  [status: proposed | accepted | superseded-by D<m> | rejected]
- Date (`date`) · phase · milestone · Decided by: human · Proposed by: <skill> (<harness>, <model>) · artifact@<sha>
- Context and forces (FR/NFR ids)
- Options: always includes "do nothing" and the agent's first proposal ("instead of")
- Choice · Why (Y-statement: in context C, facing F, we chose X over Y to get Z, accepting W)
- Cost accepted · Reversibility (Type 1 one-way / Type 2 two-way) · Confidence (low/med/high)
- Revisit if · Evidence (file:line, R/S ids) · Interview line (one sentence you'd say out loud)
- Review: Topic <from the journal's Topics: line> · Weight ●●● critical / ●●○ important / ●○○ minor · One-liner (≤ 15 words)
```

The journal is the chronological ledger, for reviewing how AI was used. `scripts/decision-views.sh` generates
`docs/decisions/REVIEW.md` from it for project review: decisions by topic and weight, how the workflow improved,
and decisions by day (standups); `make check` fails when it is stale. Topics start from the factory default
(Product, Data, Security, Money, Infrastructure, Process); changing the list is a decision. A project that adopts
this mid-stream may tag older entries in `docs/decisions/backfill-tags.md` instead of rewriting them.

Private reflections and quiz notes live outside the repo in `~/software-factory-kit-private/<repo>/`.

## 10. Failure routing (layer 5)

Fix the narrowest durable layer that would have stopped the failure; prefer earlier rows; fix environment and tools
before rewording prompts; no new skill/hook/lint/eval without a `FINDINGS.md` row describing a real occurrence;
prune before adding (~20-rule ceiling per file).

| Symptom | Layer | Fix |
|---|---|---|
| Mechanically checkable behaviour broke | Tests/types | failing test first |
| Layering/architecture rule broken | Lint / structural test | rule whose message says how to fix |
| Wrote outside its phase/task | Policy (hard) | tighten `Owns:`, scope-guard in CI, subagent tool allowlist |
| "Done" claimed but broken | Verification/hooks | Stop hook running `make check`; evidence in result.md |
| Built the wrong thing | Spec | sharper EARS/AE; add a question to `sharpen-brief`'s bank |
| Wrong command/API repeatedly | AGENTS.md | one line or a script + pointer |
| Phase procedure botched | Skill | edit the recipe + red-flags row |
| Wrong skill fired / domain drift | Skill description/routing | "Use when… Do NOT use for…"; supervisor routing table |
| Mechanical step done wrong (time, counts) | Script | move it into a script the prompt calls |
| Flaky setup / missing tool | Environment | init script, Makefile target, runbook gotcha |
| Wrong harness/model for the job | Agent policy | a row in the harness table |
| Design decision turned out wrong | Architecture | new D-row superseding the old |
| Plugin hijack | Settings | `enabledPlugins: false` per repo |
| Corrected twice in one session | Session hygiene | `/clear`, restart from the task file |
| One-off model quirk | nothing durable | log it only |

Factory metrics: north star = first-pass acceptance rate per task and per MR; supporting = fix loops per task,
gate Revise rate, scope-guard blocks, rework after merge. Never lines of code or agent counts.

## 11. Terminology

- **Human approval gates (HITL)** — PRD, HLD, LLD, tasks, merge, go-live, demo, harness changes.
- **Automated quality gates** — `make check`, scope-guard, secret/dependency scans, CI, prompt evals.
- **On-the-loop improvement** — `route-failure` retros changing the harness from outside the run.
- "Evaluation"/"evals" means automated measurement; don't call human gates "evaluation gates".
