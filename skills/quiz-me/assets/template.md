# quiz-me output skeleton

<!-- Three parts. Part 1 is shown in chat, one card per message, and is never written to any file.
     Part 2 is the private file ~/software-factory-kit-private/{{repo}}/TOPICS_TO_REVIEW.md, created once, outside the repo.
     Part 3 is appended to that file once per session, under ## Sessions, newest last.
     Replace every {{placeholder}}. Ids: TR-<n> = topic row (one weak spot on the human's review list), numbered
     across all sessions, never reused or deleted; S<k> = session number; Q-<k>.<n> = question n of session k.
     Dates and times come from `date`. -->

## Part 1 — Chat cards (one per message, then wait)

### Teach card (step 4)

```
**Topic {{i}} of {{t}} · {{D<n> | element id}} · {{title}}** · {{one-way door (hard to undo) | two-way door (easy to undo) | ⚠ not recorded}} · how sure we were: {{low | med | high | ⚠ not recorded}}

What we chose: {{one sentence}}

In plain words: {{3-6 short sentences a middle-schooler could follow. One everyday analogy. Define every
technical term the first time it appears.}}

The tradeoff: we got {{Z, the benefit}}; we paid {{W, the cost accepted}}.

What we said no to:
- {{rejected option, "do nothing" included}}: lost because {{why, from the D-row}} | ⚠ not recorded
- {{rejected option}}: lost because {{why}}

What would make us change it: {{revisit-if trigger}} | ⚠ not recorded

In interview words: {{the same idea in the real terms an interviewer uses, 2-3 sentences}}

Interview line: "{{verbatim from D<n>}}" | ⚠ not recorded

Where it lives: {{D<n>}} · {{docs/architecture/hld.md §x (file:line)}} · {{docs/architecture/lld.md §y (file:line)}} · {{diagram path | none}}

Reply: next / ask me anything about it / stop
```

### Question card (step 5, sent only after its rubric is saved)

```
**Q-{{k}}.{{n}} · {{recall | why | 10x | what-if | diagram}} · {{topic id}}** · question {{n}} of {{≤12}}

{{The question, as an interviewer would ask it. It never contains a must-have point's key words.}}

Answer in your own words, as you would say it out loud: 2-5 sentences.
Reply: your answer / hint (caps this question at partial) / skip (counts as wrong) / stop
```

### Grade card (step 6, sent after the Q block and topic row are saved; verdict first)

```
**Q-{{k}}.{{n}}: {{CORRECT | PARTIAL | WRONG}}**

Hit: {{rubric points you made | none}}
Missed: {{rubric points you did not make | none}}
{{Wrong-if triggered: the claim that contradicts the source, quoted | omit this line}}
The missing piece: {{one plain sentence | none}}
Model answer: "{{interview line + the missing point, 2-3 sentences}}" ({{cite}})

{{partial or wrong only:}}
Logged: TR-{{n}} {{🔴 | 🟡}}, next review {{date}}. The follow-up below is practice and does not change that.
Follow-up {{1 | 2}} (new case): {{a transfer question: apply the missing piece to a situation the model answer did not mention}}
```

## Part 2 — The private file (create once if missing)

```markdown
# Topics to review — {{repo}}

<!-- Private. Lives at ~/software-factory-kit-private/{{repo}}/TOPICS_TO_REVIEW.md, outside the repo; never commit it.
     Written only by quiz-me. No credentials, keys or PHI, even inside quoted answers ([redacted: kind]).
     Rows are never deleted or renumbered; a resolved row stays as the record of what used to be shaky. -->

Status key: 🔴 needs review (main answer wrong) · 🟡 partly solid (main answer partial) ·
✅ resolved (answered correctly, unprompted, on two different days, with no miss in between)

Review spacing: 🔴 next day · 🟡 three days later · after one unprompted correct answer, seven days later.
A new miss on the same gap clears "Correct on" and reopens a ✅ row. Follow-up answers never change a row.

## Topics

<!-- Replace the "_none yet_" row with the first real row. Gap = the specific misunderstanding, never "D4 shaky".
     Correct on = dates of unprompted correct main answers on this gap since its last miss, comma-separated.
     Same topic + same misunderstanding = update the row; a different misunderstanding = a new row. -->

| TR | Topic | The specific gap | Status | First flagged | Last seen | Correct on | Next review | Resolved on | Source |
|---|---|---|---|---|---|---|---|---|---|
| _none yet_ | | | | | | | | | |

## Sessions

<!-- quiz-me appends one "### S<k>" block per session, newest last. Never edit an earlier block. -->
```

Row shape, for reference:

```markdown
| TR-{{n}} | {{D<n> or element id}} {{short title}} | {{what the human got wrong or left out, one line}} | {{🔴 | 🟡 | ✅}} | {{YYYY-MM-DD}} | {{YYYY-MM-DD}} | {{YYYY-MM-DD, … | none}} | {{YYYY-MM-DD | —}} | {{YYYY-MM-DD | —}} | {{D<n>; file:line}} |
```

## Part 3 — Session block (append under ## Sessions)

<!-- Write the header first. Write each Q block's Question/Type/Rubric lines BEFORE sending its question card;
     append Answer/Hint/Verdict/Missing/Dispute/Decision-doubt lines after grading, BEFORE sending the grade card;
     write each follow-up's question + rubric before sending it, its answer + verdict after grading it.
     Main verdict lines start "- Verdict:"; a partial or wrong verdict anywhere ends with "→ TR-<n>".
     The header line is written by the step-2 command (it carries the repo fingerprint) and is never edited;
     only "Taught: pending" is replaced after teaching. -->

```markdown
### S{{k}} · {{date '+%Y-%m-%d %H:%M %Z'}} · scope {{M<N> | D<a>,D<b> | review | TR-<a>,TR-<b>}} · base {{short sha}} · fp {{12 hex, from the step-2 command}} · quiz-me ({{harness}}, {{model id}})

Defense expectations: {{path#section or the assignment document | no defense rubric found; using the journal schema}}
Taught: {{D<n>, element ids | none (review)}}

#### Dispute of Q-{{j}}.{{n}}   <!-- only when this run opened with a dispute of a closed question; else omit -->
- Claim (verbatim): "{{the human's words}}"
- Source re-read: "{{quoted line}}" ({{file:line}})
- Outcome: {{kept | changed: TR-n updated (status, Correct on, Next review)}} · original Q-{{j}}.{{n}} block left untouched

#### Q-{{k}}.{{n}} · {{recall | why | 10x | what-if | diagram}} · {{topic id}}
- Question: {{exactly as asked}}
- Rubric: (1) {{must-have}} [{{cite}}] · (2) {{must-have}} [{{cite}}] · (3) {{optional must-have}} [{{cite}}] · wrong if: {{contradiction of the source | none}}
- Note: {{none | why: not asked — not recorded (journal gap)}}
- Answer (verbatim): "{{the human's words, trimmed past ~80 words with […] | [redacted: kind]}}"
- Hint used: {{no | yes: the category given}}
- Verdict: {{correct | partial → TR-n | wrong → TR-n}}
- Missing piece: {{one plain sentence | none}}
- Follow-up 1: {{transfer question: the missing piece applied to a new case}} · rubric: {{one line}} [{{cite}}] · answer: "{{verbatim}}" · Verdict: {{correct (practice) → TR-n | partial → TR-n | wrong → TR-n}} | none
- Follow-up 2: {{same shape | none}}
- Dispute: {{none | "verbatim" → kept | changed, because "{{quoted source line}}" ({{file:line}})}}
- Decision doubt: {{none | "verbatim words about D<n>"}}

#### Scorecard S{{k}}
- Main questions: {{q}} · correct {{c}} · partial {{p}} · wrong {{w}} · follow-ups {{f}}
- Ended: {{all planned questions asked | human said stop after Q-k.n | human said stop before any question | dispute only}}
- Disputes after close: {{Q-j.n kept | Q-j.n changed → TR-n | none}}
- By type: recall {{c/p/w}} · why {{c/p/w}} · 10x {{c/p/w}} · what-if {{c/p/w}} · diagram {{c/p/w | not asked: reason}}
- Rows: added {{TR ids | none}} · updated {{TR ids | none}} · resolved {{TR ids | none}}
- Not yet taught: {{ids | none}}
- Journal gaps (not invented): {{D<n>: missing field | none}}
- Uncovered expectations: {{assignment line the sources cannot answer | none}}
- Decision doubts (verbatim, not acted on): {{"words" about D<n> | none}}
- re-checked: {{yes (every main answer was correct) | n/a}}
```
