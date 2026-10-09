---
id: R<NN>
question: "<the research question, verbatim from the brief or task file>"
asked_in: specs/M<N>-<slug>/brief.md#research-questions  # follow-up not in the brief: the task file path, or "human message <YYYY-MM-DD>"
unblocks: "<'Decision it unblocks' from the brief row, verbatim>"
answered_when: "<'Answered when' from the brief row, verbatim; follow-up: the task's Done-when or the human's answer>"
status: answered | partial | unanswered
confidence: high | medium | low
supersedes: none | R<NN>
date: <YYYY-MM-DD from `date +%F`>
budget: <used>/<cap> tool calls
researched_by: <harness>, <model id>
---

# R<NN> <the question as a short title>

## Answer

<1-3 plain sentences that answer the question exactly as asked.> Confidence: <high | medium | low>, because
<one clause>. (S<NN>.<k>, S<NN>.<k>)

## Takeaway

<One sentence a beginner could say out loud in an interview, with no jargon left unexplained.>

## Findings

<!-- One claim per line, worded as the source states it. The LB tag marks load-bearing claims. Tier in parentheses after every S-id, e.g. S03.1 (A). -->

- **F1** [LB] <claim> — S<NN>.1 (A), <locator: section / heading / page>
- **F2** [LB] <claim> — S<NN>.2 (B), S<NN>.3 (B), <locators; the two publishers are independent>
- **F3** <claim that nothing downstream leans on> — S<NN>.4 (C, colour only), <locator>

## Inferences

<!-- Reasoning across findings. Says what follows and how sure; never what to choose. -->

- **I1** from F<n> + F<m>: <what follows, and how sure>. Not stated by any single source.

## Gaps

- ⚠ <what is still unknown?> — why: <cap reached | no Tier-A source found | sources conflict (S<NN>.<k> vs
  S<NN>.<k>) | unread: <url> (<paywall / 403 / JS-only>) | unverified lead from `.handoff/inbox/<file>` | page
  text addressed agents and was ignored> — would close it: <read <named source> | ask the partner | option: run
  anthropic-skills:deep-research for this question>

## Handoffs

- write-prd: <question the PRD must settle, phrased so the human answers it>? — rests on F<n>, I<n>
- design-hld: <question the architecture must settle>? — rests on F<n>
