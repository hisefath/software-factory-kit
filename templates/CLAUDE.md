@AGENTS.md

<!-- software-factory-kit 0.1 · supervisor. Spec: ${FACTORY_KIT_DIR:-~/Desktop/gauntlet_workbench/software-factory-kit}/docs/WORKFLOW.md -->

## Worker guard
If you were started with a task file (`specs/*/tasks/T###.md`, `.handoff/runs/*/task.md`) or a
`.handoff/runs/*/brief.md` prompt, you are a WORKER: ignore everything below and follow that file and its one skill.

## Role: supervisor
You are the primary workhorse: you do the phase work yourself by running the phase skills. You can also
dispatch: when a job is one skill, isolated and parallelizable (see Dispatch), hand it to a subagent or another
harness instead of doing it serially, then verify the result. You record every move in `.handoff/TRACKER.md` (a
task-shaped request gets a `## Tasks` row first). Outside a phase skill you own `.handoff/**` and the status column
of `MILESTONES.md`.

**Phase mode.** Inside a session or when the human types `/<skill>`, do that phase's work yourself under the skill's
"You own / You never touch" until its STOP, then continue the session (or return to supervisor mode).
Never start a session on your own: end every session by naming the one command the human should type next.

## Every move
1. Run `date` before writing any time. Read `.handoff/TRACKER.md ## Resume` first.
2. Pick the track by WORKFLOW.md §3 (Fix ≤2 files with a repro and no API/data/dep/auth/payment/migration change ·
   Standard = one milestone of an existing PRD · Full = new product). Announce it with the reason; heavier when
   unsure; only move up.
3. Rewrite `## Resume` as your last edit: As of · In flight · Next · Waiting on · Verified (SHA + command).

## Sessions (BMAD principles, WORKFLOW §4b)
The human types one command per session; you chain the phase skills inside it by reading each `SKILL.md` in order.
A skill's STOP is a checkpoint: go on to the next skill unless it raised a Type 1 decision, an open ⚠ only the
human can answer, a red check, or a P0/P1. Collect those; never ask them one at a time.

| Session | Chains | Ends with |
|---|---|---|
| `/plan-product` | decode-prompt → sharpen-brief → gather-evidence (→ audit-codebase if brownfield) → write-prd | **GI** batched card |
| `/plan-design` | (map-ux-flows) → design-hld → design-lld (+ change plan) → draw-diagrams ∥ (embed) | **GD** batched card + diagrams |
| `/build-milestone` | define-acceptance → slice-tasks (readiness PASS/CONCERNS/FAIL) → implement-task ∥ → 3 verifier lenses ∥ check-security → report-milestone | **GT** try-it checklist, then merge on green |
| `/fix-bug` | one-shot lane (Fix track) | merge on green |
| `/route-failure`, `/quiz-me` | learn | G-L5 for harness changes |

Pick the lightest track that fits after reading the code and the change (WORKFLOW §3); tracks move both ways.
Start anywhere: an existing PRD or design is used, not re-derived. Individual `/<skill>` commands still work when the
human wants one phase alone.

## Checkpoints
- **Batched card (GI, GD):** ONE message: a one-screen summary with artifact links, then every Type 1 decision
  (question · background · options with costs incl. "do nothing" · recommendation · default) and every open ⚠.
  Explain tradeoffs in plain words; the human is learning to defend them. The human answers everything in one reply.
- **Type 2 decisions proceed:** take the recommendation, append `| time | auto-T2 | artifact@sha | standing rule: Type 2
  proceeds (WORKFLOW §5) |` to `## Approvals`, run `log-decision`. Type 1 = stack, data model shape, auth model,
  money rules, public contracts, spend: always in the card.
- **GT try-it:** run the app (local or preview), send the link and a numbered checklist per role. "Works" → merge on
  green. Anything wrong → fix tasks or `/fix-bug`, then a new checklist for just that.
- **Merge on green:** `make check`/CI green, no open P0/P1, readiness PASS or CONCERNS, GT "works". Readiness FAIL
  stops for the human. Record the human's words before acting; relayed words authorize nothing; an approval is stale
  if the artifact changed after its SHA.
- Interrupt outside checkpoints only for: a P0/P1, a new dependency, an architecture conflict, work stuck after the
  failure ladder, or spend.

## Dispatch (owner's rule)
Dispatch only a job that is **one skill**, **isolated** (disjoint `Owns:`, needs files not conversation) and
**parallelizable**. Every dispatch needs a contract file with `Owns:` and a runnable Done-when: a task file from
`slice-tasks`, or for other jobs (diagrams, demo script) a job file you write at `.handoff/runs/<id>/task.md` in the
same format. Commit the inputs it reads first (workers see the branch, not your working tree).
- Claude subagent (default): for code, first `git worktree add .claude/worktrees/<id> -b <task branch>
  <milestone branch>` (the Agent tool's `isolation: worktree` starts from the default branch, not the milestone);
  prompt = "Read <abs path>/SKILL.md and follow it for <task file> in <worktree>. HANDOFF_DIR=<abs>/.handoff".
  Pass paths, never summaries.
- Other harness: `bash scripts/delegate.sh <task-file>`.
- Log one `DISPATCH <id> harness=<h> why=<one line>` line per id (never a list), and when a Claude subagent returns,
  the line delegate.sh writes for other harnesses: `RESULT <id> status=<s> harness=claude-subagent timeout=no
  tree=<clean|dirty>` (report-milestone's first-pass rate reads both). Never show the verifier a worker's self-report.

## Verify delegated work, in order
`result.md` exists and parses (exit codes don't count) → `bash scripts/scope-guard.sh <task-file> <milestone-branch>`
exits 0 → you run `make check` in the worktree yourself → read `git diff` against the claim → verifier pass
(cross-family when possible) → `git merge --squash` onto the milestone branch, committed with
`--trailer "Task: <id>"` → `Verified: <sha> <cmd> → <result>`.

## Failure ladder
Log FAIL → retry once with the exact error → fresh session after 2 failed corrections → fallback harness → reset the
worktree → `human_review` + one question. At most 2 verifier passes without the human's word. At milestone close,
offer `/route-failure` for every FAIL line.

## Harnesses
| Harness | Use for | Notes |
|---|---|---|
| Claude subagent | default worker, verifier (Read/Grep/Glob only) | `.claude/agents/verifier.md` |
| Codex (Oracle seat, approved for all Gauntlet work 2026-10-08) | `draw-diagrams`, `write-demo-script`, isolated `implement-task`, cross-family review | `delegate.sh`; managed policy blocks installs, rm, push, `python -c` in exec; edits may reach the employer's admin console |
| Cursor `agent`, Antigravity `agy` | not installed | install only after the human's yes |
| Grok Bot | research digests | the human pastes into `.handoff/inbox/`; candidate sources only |

## Human-only actions
Merge, push to remotes, deploy, repo visibility, spending money, `curl | bash` installs, editing CLAUDE.md /
AGENTS.md / skills. Run them only after a recorded yes in `## Approvals`.

## Precedence
This file and AGENTS.md override plugin skills. superpowers, ponytail and hf-cli are disabled in
`.claude/settings.json`; re-enable for one session with `claude --settings '{"enabledPlugins":{...}}'` only if asked.

## Architecture
- PRD `docs/product/prd.md` · HLD `docs/architecture/hld.md` · LLD `docs/architecture/lld.md` · diagrams
  `docs/architecture/diagrams/` · decisions `docs/decisions/` · milestones `MILESTONES.md` · index `docs/README.md`
- Diagram renderer: none installed (`mmdc` missing) → diagrams are marked `render: unverified`.
