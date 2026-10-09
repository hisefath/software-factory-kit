# clarify-spec output skeleton

<!-- Three parts. Part 1 is shown in chat, one card per message, and is never written to the target.
     Parts 2 and 3 are written into the target file only. Replace every {{placeholder}}; delete nothing else (except a
     CQ entry's "Revises:" line when it is not a revision).
     Never write the warning-sign character inside ## Clarifications: the open-marker count must only see open markers.
     Ids: CQ-<n> = clarification question, numbered across all passes of this file, never reused. -->

## Part 1 — Question card (chat only, one per message, then wait)

```
**CQ-{{n}} · question {{i}} of {{≤5}} · [{{category}}] · {{target}} › {{section or id}} (line {{L}})**

{{The question in one sentence, answerable by picking a row.}}

Why it matters: {{Plain words: what in design, tests, tasks or cost changes depending on the answer.
Cite the ids it touches (FR-###, NFR-###, EC-n, D<n>) or file:line.}}

| # | Option | Implication |
|---|---|---|
| A | {{option}} | {{what it means downstream and what it costs, in words a beginner could repeat}} |
| B | {{option}} | {{...}} |
| C | {{optional third option, or "waive here, decide in <later skill>" only for a HOW question on a WHAT artifact}} | {{...}} |
| — | Leave open (do nothing) | The ⚠ stays; {{next skill}} must assume {{the conservative assumption}}; {{gate id}} lists it as open. |
| Your words | {{anything else}} | Applied only as far as it answers this question; anything extra is logged as a scope change (new scope) or parked (HOW on a WHAT artifact). |

**Recommended: {{A | B | C}}**, because {{one line with evidence: file:line, D<n>, R<NN>}}.
**Default if you skip:** Leave open. {{Why that assumption is the safest and cheapest to undo.}}

Reply: A / B / C / "recommended" / your own words / skip (= leave open) / waive <reason> / stop
```

## Part 2 — Inline edits in the target body

<!-- Each answer lands where its question pointed, in the target's own form, tagged (CQ-<n>) once.
     Q-table targets (AUDIT.md, hld.md, lld.md, acceptance.md) close the row AND its inline pointers: use the
     close and add forms in clarify-spec references/taxonomy.md §6 for this target. -->

| Outcome | The `⚠ {{question}}` text becomes |
|---|---|
| resolved | The answer as the artifact's normal content, keeping the existing id, ending in ` (CQ-{{n}})`. Examples: `- **NFR-002** [Performance] Checkout confirmation shows in ≤ 2 s at the 95th percentile with 50 concurrent users. (CQ-{{n}})` (every number, unit and condition as the human stated it) · `- **EC-3** Payment provider times out → order stays pending and the user sees a retry message (FR-007). (CQ-{{n}})` |
| resolved, from an "Open questions" list item | `- Resolved (CQ-{{n}}): {{one-line answer}} → {{ids where the answer now lives}}` |
| waived | `Waived (CQ-{{n}}): {{question}} — "{{the human's reason, verbatim}}"` |
| skipped | unchanged: `⚠ {{question}}` |
| from-source | Same as resolved, tagged ` (CQ-{{n}}, from {{file:line}})` |
| resolved, Q row (Q-table target) | Question cell: `Resolved (CQ-{{n}}): {{question}} → {{one-line answer}}` (acceptance: Answer and Status cells, taxonomy §6) |
| revised (`Revises: CQ-{{old}}`) | The body text tagged `(CQ-{{old}})` is replaced and re-tagged `(CQ-{{n}})`; the old log entry is never edited |
| found, not asked this pass | a new marker in the target's add form (taxonomy §6), e.g. `⚠ {{question}} (→ G0)` in a brief |

Rules: new items take the next free id under the target's own id rules; retire ids only as the target's rules say;
a chosen term replaces its synonyms in this file only; text the answer contradicts in this file is removed; a unit,
condition or measurement method goes in only as the human stated it, and a missing one becomes a new marker.

## Part 3 — The log, appended at the end of the target

<!-- If ## Clarifications is missing, create it as the last section. If it holds "None yet.", replace that line.
     Keep its HTML comment. Append one "### Pass" block per run, newest last. Never edit an earlier pass. -->

```markdown
## Clarifications

### Pass {{k}} · {{output of `date '+%Y-%m-%d %H:%M %Z'`}} · clarify-spec ({{harness}}, {{model id}}) · base {{short sha}}

Open questions before: {{n}} · after: {{n}} (this target's count in clarify-spec references/taxonomy.md §6)
Markers added, not asked: {{line refs | none}}
Parked for a later phase: {{"question or verbatim HOW words" → skill, one per line | none}}

#### CQ-{{n}} · [{{category}}] · {{section or id the answer changed}}
- Revises: {{CQ-<old> — only on a revision; delete this line otherwise}}
- Question: {{exactly as asked}}
- Options: A {{option}} · B {{option}} · C {{option | none}} · do nothing: leave open · recommended {{letter}}
- Answer (verbatim): "{{the human's exact words | [redacted: kind]}}"
- Status: {{resolved | waived | skipped | from-source}}
- Applied: {{what the body now says, and where (ids, section) | not applied (skipped)}}
- Decision candidate: {{no | yes — one plain sentence why (scope / data model / API / dependency / auth / payments / PHI / NFR / Type 1)}}
- Scope change: {{none | "verbatim extra words" → Revise via {{owner skill}}}}
```

<!-- For a from-source entry: Options = "none (settled by source)", Answer (verbatim) = the quoted source line
     followed by its file:line and, for an approved artifact, @<sha>. It does not count toward the 5 questions.
     The CQ entry is the per-question gate's verbatim record. The supervisor copies "Answer (verbatim)" into each
     decision candidate's .handoff/TRACKER.md ## Approvals row; a pass-level "Approve" never replaces it. -->
