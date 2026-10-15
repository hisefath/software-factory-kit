---
name: decode-prompt
description: Use when a new project prompt, assignment, partner brief or checkpoint doc has just arrived and nobody has written its brief yet, or when G-decode came back Revise. Produces specs/M<N>-<slug>/decode.md. Do NOT use for writing the brief, job stories or track (use sharpen-brief) or for researching answers (use gather-evidence).
disable-model-invocation: true
metadata:
  software-factory-kit: "0.1"
  phase: "0.5"
  gate: "G-decode"
---

# decode-prompt

**Outcome:** one file, `specs/M<N>-<slug>/decode.md`, that states the question behind the question (what the
graders, partner or instructor are really testing), the traps a one-shot build would fall into, and the guard for
each trap, ready for the human to approve at G-decode before `sharpen-brief` starts.

## You own / You never touch

- You own `specs/M<N>-<slug>/decode.md` fully (create the folder); you never write any other path: not the brief,
  `docs/`, code, `AGENTS.md`, `CLAUDE.md`, `MILESTONES.md` or `.handoff/` (the supervisor owns those).
- You own reading the prompt like an examiner would; you never design a solution, pick a stack, or write
  requirements. Solution ideas go verbatim into `## Parking lot`.
- You own naming hypotheses about the hidden ask, each with the evidence that suggests it and how sure you are; you
  never state a hypothesis as fact. Unconfirmable ones become `⚠ <question> (→ G-decode)` or `(→ R<NN>)`.
- You own proposing a guard for each trap; you never apply it. Later phases apply guards once the human accepts them.
- You own paraphrasing uncleared partner documents with page/section refs; you never quote them word for word or
  copy secrets or personal data (repos are public).

## Inputs

Read these first. If a MUST is missing, stop and name it.

1. **The project prompt (MUST):** every page, rubric, checkpoint list, appendix, FAQ, and any instructor or partner
   message the human points to. Missing → ask "Paste the prompt or give me its path." Note each source by
   repo-relative path or the name the human gives it.
2. **Course context (SHOULD):** the syllabus week, lecture notes and "is law" notes in
   `/Users/mastershefu/Desktop/gauntlet_workbench/lectures/` and any memory or notes the human names: what this
   week teaches tells you what the project is testing.
3. **Partner context (SHOULD, partner projects):** the partner's portal page or company panel the human points to,
   then search the web freely: the partner's live product, job posts, and what the field already knows about the
   problem. Cite each URL as a source; deep sourced research still goes to `gather-evidence`.
4. `docs/decisions/DECISION_JOURNAL.md` and earlier `specs/*/decode.md` if present: never re-ask what's decided.
5. `software-factory-kit/FINDINGS.md`: past traps the factory already fell into (e.g. F3: never read the partner
   portal; F4: success targets with no market evidence).

## The one rule

Every prompt answers "what should I build?" on the surface and "what are you proving you can do?" underneath; write
down the second answer and the ways a fast, literal build would miss it, before anyone plans the first.

## Steps

1. Read every input in full. List each explicit requirement in one line with its source (page/section).
2. **Find the question behind the question.** Ask of the prompt, and write 1-3 hypotheses with evidence and
   confidence (low/med/high):
   - What skill does this week of the course teach, and how does this project make me prove it?
   - What will the graders or partner actually look at first (demo, docs, a metric, a live URL, the interview)?
   - Which words are doing heavy lifting ("production-ready", "auditable", "at scale", "defend", "real users")?
   - What is conspicuously unsaid (scale, users, security, cost, data source) and why might it be left out?
   - For a hiring partner: what does their business need, and what would make them want to hire the builder?
   - What does the field already know here: a known-impossible result (e.g. Byzantine fault limits in distributed
     computing), a standard trade-off, or a product the partner already ships that answers part of it?
3. **Find the traps.** Check every category in the table below; write each trap that applies as: trap, why it's
   tempting, what it would cost, evidence in the prompt, and the guard (which later phase or check catches it).
4. Mark ambiguities that only the human, an instructor or the partner can answer as `⚠ … (→ G-decode)`, and ones
   research can answer as research questions for `gather-evidence`.
5. Interview the human: at most 5 questions, one at a time, each with your recommended answer, only for the
   highest-impact unknowns ("Is the real ask X or Y? I recommend X because …"). Record answers verbatim.
6. Fill `assets/template.md`, run the Done-when checks, then STOP.

| Trap category | Ask yourself |
|---|---|
| Literal reading | Does building exactly the words miss the intent (e.g. "a store" when the test is auditable money)? |
| Hidden grading criteria | Rubric lines, checkpoint docs or interview questions not in the main prompt? |
| Unstated non-functional bar | Security, scale, observability, cost, accessibility, data integrity expected but unsaid? |
| Wrong stack / partner mismatch | Does the partner's stack, portal or product contradict an "obvious" choice? |
| Demo vs depth | Would a flashy demo hide missing fundamentals, or deep work have no visible proof? |
| Deliverable gaps | Every required file, exact filename, video, URL, log, deadline (with timezone)? |
| Scope creep / gold-plating | What looks impressive but isn't asked for and burns the timebox? |
| Unverifiable success | Is there a metric with a data source, or only a vibe (see docs/METRICS.md)? |
| Domain landmines | Money rounding, PHI/PII, time zones, idempotency, compliance words in this domain? |
| Copying v1 / prior work | Is a past build or a template being reused where the prompt wants something new? |

## Output

`specs/M<N>-<slug>/decode.md`, filling `assets/template.md`. N = the milestone `sharpen-brief` will use (M1 on a new
project; otherwise the lowest open milestone in `MILESTONES.md`). Every section required; unknowns as `⚠`.

## Done when

- [ ] Only `specs/M<N>-<slug>/decode.md` changed: `git status --porcelain --untracked-files=all` shows one path.
- [ ] Every template heading is present; 1-3 `QB-n` hypotheses, each with evidence and confidence.
- [ ] Every trap category in the table appears in `## Traps` as a `T-n` row or as "n/a: <reason>".
- [ ] Every `T-n` row has a guard naming a phase, skill or check.
- [ ] No solution vocabulary outside `## Parking lot`: no framework, database, endpoint or schema names.
- [ ] No absolute home paths, secrets or personal data: `grep -nE '/Users/|/home/|api[_-]?key|password' <file>`
      prints nothing.

## STOP

Say exactly this, filled in, then stop. Never start `sharpen-brief` yourself.

> Wrote `specs/M<N>-<slug>/decode.md`: <n> hypotheses about the real ask, <n> traps with guards, <n> open ⚠.
> **G-decode:** "Is this the question behind the question, and do I accept these trap guards?"
> Options: **Approve** (the brief is built on QB-<best>, guards carry forward) · **Revise** (tell me which
> hypothesis or trap is wrong) · **Stop**. My recommendation: <one line, plain words>.
> Next: `/sharpen-brief`.

## Red flags

| Thought | Do instead |
|---|---|
| "The prompt is clear, there's no hidden question." | Every graded prompt tests something. Write the hypothesis with low confidence. |
| "I'll suggest the architecture while I'm here." | Put it in `## Parking lot`; design-hld decides that. |
| "This trap is obvious, no need to write a guard." | Obvious traps are the ones one-shot builds fall into. Write the guard. |
| "I'm sure the graders want X." | State it as a hypothesis with evidence and confidence, and ask the human. |
| "The partner doc says it, so I'll quote it." | Paraphrase with a page ref until the human clears it. |
