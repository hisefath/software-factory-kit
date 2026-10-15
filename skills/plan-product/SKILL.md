---
name: plan-product
description: Use when a new project prompt or a new product milestone needs its problem, evidence and PRD worked out in one sitting, ending in one batched Intent check (GI). Produces specs/M<N>-<slug>/decode.md, brief.md, docs/research/*, docs/product/prd.md and .handoff/checkpoints/GI-M<N>.md. Do NOT use for design (use plan-design) or for building (use build-milestone).
disable-model-invocation: true
metadata:
  software-factory-kit: "0.2"
  phase: "session: analyst + pm (WORKFLOW §4b)"
  gate: "GI"
---

# plan-product

**Outcome:** the problem, evidence and PRD for one milestone, drafted in one sitting, and one batched card that lets
the human settle every Type 1 decision and open question in a single reply (Intent check, GI).

## You own / You never touch

- You own running, in order, `decode-prompt` → `sharpen-brief` → `gather-evidence` (→ `audit-codebase` when the repo
  inherits code) → `write-prd`, each under its own "You own / You never touch"; you never write a path none of them
  declares, except the card at `.handoff/checkpoints/GI-M<N>.md` (supervisor-owned state).
- You own deciding Type 2 questions on the recommendation (WORKFLOW §5, `auto-T2` Approvals row + `log-decision`);
  you never decide a Type 1 question or an open ⚠ only the human can answer: they go in the card.
- You own continuing past each skill's STOP; you never start `plan-design`.

## Inputs

1. The project prompt / assignment (MUST: missing → ask once, then stop).
2. `AGENTS.md` (MUST: missing → "run `scripts/init-repo.sh` first").
3. Everything each chained skill lists as its inputs. "Start anywhere": if `decode.md`, `brief.md`, research or
   `prd.md` already exist and are not stale, reuse them and skip that skill (say so in the card).

## The one rule

Ask the human the few things only they can answer, all at once, at the end; decide everything reversible yourself
and write down why.

## Steps

1. Run `date`; read `.handoff/TRACKER.md ## Resume`; pick N and the slug the way `sharpen-brief` does.
2. Run each chained skill by reading its `SKILL.md` and following it. Where a skill would interview the human, use its
   recommended answer for Type 2 questions (log them) and park Type 1 questions and human-only ⚠ for the card. Where
   a skill's STOP names a gate (G-decode, G0, G1), treat it as a checkpoint and continue.
3. Stop early only for: a missing MUST input, a red check, or a question whose answer would change which skill runs
   next (e.g. brownfield vs greenfield). Ask it in one message, then continue.
4. Write the card from `assets/card.md` to `.handoff/checkpoints/GI-M<N>.md` and send it as one message.

## Output

`.handoff/checkpoints/GI-M<N>.md` from `assets/card.md`, plus each chained skill's own outputs. Every Type 1 item
has options incl. "do nothing", costs, a recommendation and a default.

## Done when

- [ ] Every chained skill's own Done-when passed (or the skill was skipped as reused, named in the card).
- [ ] Each Type 2 decision taken has an `auto-T2` Approvals row and a journal entry.
- [ ] The card lists every Type 1 decision and every human-only ⚠ from all chained artifacts:
      `grep -c '⚠' <artifacts>` matches the card's ⚠ count.

## STOP

> **Intent check (GI), M<N>.** <one-screen summary: the real ask (QB), the problem, North Star, scope cut> ·
> Type 2 decided for you: <n> (see `docs/decisions/REVIEW.md`) · **Your decisions (<k>):** <numbered Type 1 cards
> and ⚠ questions>. Reply with your picks in one message (e.g. "1A 2 default 3B"), or Revise / Stop.
> Next after your answer: `/plan-design`.

## Red flags

| Thought | Do instead |
|---|---|
| "I'll ask this one now, it's quick." | Park it; one card at the end. |
| "This choice feels big, but it's reversible." | Type 2: decide, log, move on. |
| "The PRD can name the framework, it's obvious." | write-prd's rule still holds: tech only in Constraints. |
| "The human approved the brief earlier, skip the PRD card." | The card covers all artifacts of this session. |
