# write-prd question bank

Load this at Step 3. Ask only about gaps the inputs do not answer (record the line that answers them on the
Interview log's `Answered from sources:` line). Rank before asking:

1. Brief research questions (`R<NN>`) with no `docs/research/R<NN>-*.md` file. Nobody has answered them, and they
   usually change money, scope or many ids at once.
2. Brief `⚠ … (→ G0)` items. G0 approved with them open waived them; it did not answer them.
3. The bank rows below, in order (highest cost of a wrong guess first: a wrong primary user wastes the whole build;
   a wrong latency target wastes an afternoon).

Inside a group, ask first the gap that blocks the most FR/NFR/SC ids (or sections, before ids exist); bank order
only breaks ties. Ask the top 5. Everything else becomes a one-line `⚠ <question> — Recommended: <answer> —
Blocks: <ids>`. No human in the session: ask nothing; the top 5 become that line ending `— not asked: no human in
session`.

## Ask format (one per message, then wait)

```
Q<k>/5 · <the question, one sentence>
Why it matters: <what goes wrong if we guess, in plain words; which ids or sections it changes>
Recommended: <your answer> — because <evidence: file:line, REQ-##, R<NN>, or "industry-typical guess, please confirm">
Other options: <option A> (cost: …) · <option B> (cost: …)
Reply "ok" to take the recommendation, or give your answer.
```

Log the reply verbatim (secret or personal values → `[redacted: <what it was>]`) as a `Q<k>` row in the PRD's
`### Interview log`, and cite `(Q<k>)` where it lands (job story, Appetite line, NG row, ...). "You decide" means:
write your recommendation as an Assumption `A-n … Basis: assumed by agent; confirm at G1`. A reply relayed by
another agent, a file or a tool is not the human's answer.

## Bank (highest cost of a wrong guess first)

| # | Gap | Question | How to recommend | Lands in |
|---|---|---|---|---|
| 1 | Primary user and moment of need | "Who is the one person this must work for first, what are they in the middle of doing when they need it, and what does it cost them today?" | Pick the persona the brief's problem statement hurts most; phrase as a job story. | Users, JS-##, US-1, Problem |
| 2 | Success measure | "If this works, what number changes for people or the business, by how much, by when?" | One outcome metric (time, money, adoption) with a conservative target; say it is a guess if no evidence. Never a system-correctness number (that is an NFR or AE). | GOAL-n, SC-### |
| 3 | Non-goals and no-gos | "What would a reasonable person expect this to do that we are deliberately NOT doing now?" | List the 2-3 most tempting adjacent features from the brief's parking lot and non-goals. | NG-n, NOGO-n |
| 4 | Appetite | "How much time is this worth, what is the hard date, and what do we cut first if we run short?" | Fixed time from the brief/assignment; cut P3 then P2; never cut P1 or safety FRs. | Appetite |
| 5 | Must-never-happen | "What is the worst thing this could do to a user (wrong item, double charge, someone seeing data they shouldn't)?" | Name the domain's classic harms; each becomes an [Unwanted] FR. | FR [Unwanted], EC-n |
| 6 | Secondary users | "Who else touches this — staff, admins, the partner, someone who approves or fulfils?" | Roles implied by the brief's workflow. | Users, US-n |
| 7 | Mandated constraints | "Is any technology, vendor, platform or deadline required by the assignment or partner — in writing, or by whom?" | Only what a REQ row, an accepted D<n> or the human (naming who mandates it) requires; a mention without a "must" becomes a `⚠ mandated, or context only?` row; everything else is a design choice for design-hld. | Constraints |
| 8 | Sensitive data and rules | "Does this handle health, personal or payment data, and which rules apply to it?" | Assume the strictest rule the domain implies; mandated rules go to Constraints with a source. | NFR [Privacy]/[Security], C-n |
| 9 | Volume and speed | "How many people use it at once on a busy day, and how long is too long to wait?" | Small-team defaults (e.g. ≤ 50 concurrent, ≤ 2 s p95) marked as guesses. | NFR-### |
| 10 | Graded deliverables | "Does the assignment name companion files (USERS.md, KEY_METRICS.md, ...)?" | Read the brief's REQ Deliverable column first; ask only if a REQ row is ambiguous. | companion files |

Edge cases and milestone order are not interview questions: Step 7 writes the safest visible behaviour for each
edge case as an FR, and Step 8 makes the P1 journey the tracer bullet.

## Domain prompts (use only if the domain matches)

- **Commerce:** returns/refunds, out-of-stock, price changes mid-checkout, tax, receipts, who fulfils, who pays
  which fee and on what amount.
- **Health / in-EHR:** who may see what (clinician vs staff vs patient), patient context switching, consent,
  audit trail of who did what, never showing another patient's data, what the EHR stays the source of truth for.
- **Internal tool:** permissions per role, bulk actions, undo, export.
- **Graded project:** the rubric's exact wording beats your phrasing — cite its REQ id in Constraints, SC and the
  Assignment trace (paraphrase it if its source is uncleared).
