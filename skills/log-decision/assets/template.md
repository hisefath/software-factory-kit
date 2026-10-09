# log-decision output skeleton

<!-- guide: four parts. Part 1 is appended to docs/decisions/DECISION_JOURNAL.md (one block per decision). Part 2 is a
     new file docs/decisions/{{NNNN}}-{{slug}}.md, only for an accepted Type 1 decision. Part 3 is appended to
     ~/factory-kit-private/{{repo}}/REFLECTIONS.md, only when the human offered a reflection. Part 4 is a chat card,
     never written to a file. Replace every {{placeholder}}, choose one value where a placeholder lists `a | b`, and
     delete every `<!-- guide:` comment. Unknown → `⚠ <question>`, never an invention. Times come from `date`. -->

## Part 1 — journal entry (WORKFLOW.md §9 schema, six bullet lines, in this order)

<!-- guide:
     - Heading: the choice in ≤ 8 words ("Use SQLite for M1 orders"), never the question. D{{n}} = last journal id + 1,
       recomputed with grep right before writing. Status: accepted or rejected only with a quote from the
       .handoff/TRACKER.md ## Approvals row (a CQ also needs its Answer (verbatim) at the sha); otherwise proposed with
       the `pending` text exactly as written below.
     - Decided by: one quote, `<gate id> <row time>: "<words>"`, where gate id is the Approvals gate cell verbatim
       ("G-audit A3" — audit-codebase record mode joins on it). A CQ quotes both:
       `<target>@<sha> #### CQ-<n>: "<answer>"; <gate id> <row time>: "<approval words>"`.
     - artifact: the Approvals artifact cell (`<path>@<short sha>`; G-L5: `HARNESS_CHANGELOG.md H<n>@<hash>`).
     - Options: the do-nothing row first, then every option shown, in the order shown, one sub-bullet each (repeat
       the Option line per option). Each ends with `chosen` or `rejected: <why>` (the human's words when they gave a
       reason, else the table's cons). A do-nothing option shown under another label ("Stop", "accept", "skip",
       "c) don't know") keeps the `Do nothing / simplest` start and adds `(shown as "<label>")`; a gate that never
       showed one gets `Do nothing — ⚠ not offered at the gate`.
     - Tags: `(agent's recommendation)` on the recommended row. `(agent's first proposal)` on the row the artifact's
       `First proposal (instead of)` line names (one row may carry both). That line names an option not shown → add
       `- {{option}} (agent's first proposal) — not shown at the gate — cost: {{from that line | ⚠ not recorded}} —
       rejected: {{why it lost, copied from that line}}`. No such line → tag the recommended row
       `(agent's first proposal — no instead-of recorded)`; never make one up.
     - Y-statement for the option actually chosen. If the human picked a non-recommended option, rebuild it:
       Z = their reason quoted, else the chosen option's pros marked "(from the options table)".
     - Status `rejected`: Choice is `none`; Why is the human's reason; Cost accepted is what stays unsolved.
     - Evidence: add `; ADR: docs/decisions/NNNN-slug.md` only for an accepted Type 1. An older entry flipped from
       proposed gets the ADR pointer appended to its new quote instead (the only line a flip may change). -->

### D{{n}} {{Title — the choice in ≤ 8 words}}  [status: {{accepted | rejected | proposed}}]
- Date {{YYYY-MM-DD HH:MM TZ}} · phase {{phase # and skill, e.g. 5 design-hld}} · milestone {{M<N>}} · Decided by: human, {{accepted/rejected: <gate id> <Approvals row time>: "<exact words, verbatim>" | CQ: <target>@<sha> #### CQ-<n>: "<answer>"; <gate id> <row time>: "<approval words>" | proposed, exactly: pending — no quoted words yet}} · Proposed by: {{skill}} ({{harness}}, {{model id | ⚠ not recorded}}) · artifact: {{path}}@{{short sha}}
- Context and forces: {{2-3 sentences: the problem and the forces pulling each way}} ({{FR-### / NFR-### / C-n / INV-n ids}}){{ — Supersedes D<k>: "<why, quoted>"}}
- Options:
  - Do nothing / simplest{{ (shown as "<label>")}}: {{what it means}} — cost: {{build + run}} — {{chosen | rejected: why}}
  - {{Option A}} {{(agent's first proposal)}} — cost: {{build + run}} — {{chosen | rejected: why}}
  - {{Option B}} {{(agent's recommendation)}} — cost: {{build + run}} — {{chosen | rejected: why}}
- Choice: {{option | none}} · Why: In the context of {{C}}, facing {{F}}, we chose {{X}} over {{Y}} to get {{Z}}, accepting {{W}}.
- Cost accepted: {{W in plain words}} · Reversibility: {{Type 1 one-way | Type 2 two-way}} — {{why, in plain words}} · Confidence: {{low | med | high}}
- Revisit if: {{observable trigger, ideally a metric or signal | ⚠ <question>}} · Evidence: {{file:line; R<NN>/S ids}}; {{proposed as <path> D<k>; }}approval {{gate id}} {{Approvals row time}}{{; ADR: docs/decisions/NNNN-slug.md}} · Interview line: "{{one sentence ≤ 30 words: what you chose, why, what it cost}}"

## Part 2 — one-way decision record `docs/decisions/{{NNNN}}-{{slug}}.md` (MADR 4)

<!-- guide: only for an accepted Type 1 entry. NNNN = the D number zero-padded to 4 digits (D7 → 0007), so one id
     space covers both files; slug = the title in kebab-case. Every heading below is required and stays exactly as
     written. Copy content from the journal entry and the artifact at its sha; add nothing new. When this record is
     later superseded, change only the `status:` line to `superseded by {{MMMM}}`. -->

```markdown
---
status: accepted
date: {{YYYY-MM-DD}}
decision-makers: human (exact words in journal D{{n}})
journal: D{{n}}
---

# {{NNNN}}. {{Title}}

## Context and Problem Statement

{{2-4 sentences from the entry's Context and forces, ending with the question that had to be answered.}}

## Decision Drivers

* {{FR / NFR / C / INV id}} — {{the force in one line}}
* {{...}}

## Considered Options

* Do nothing / simplest{{ (shown as "<label>")}}: {{...}}
* {{Option A}} {{(agent's first proposal)}}
* {{Option B}} {{(agent's recommendation)}}
* {{one line per further option, in the journal entry's order, untabled first proposal included}}

## Decision Outcome

Chosen option: "{{option}}", because {{Z from the Y-statement; the human's reason quoted when they gave one}}.

### Consequences

* Good, because {{what the choice buys}}
* Bad, because {{the cost accepted, W}}

### Confirmation

{{How anyone can check the decision is implemented and still holds: a named test or `make check` step, a review
item, a metric with its threshold. Include the Revisit-if trigger.}}

## Pros and Cons of the Options

### Do nothing / simplest

* Good, because {{...}}
* Bad, because {{...}}

### {{Option A}}

* Good, because {{...}}
* Bad, because {{...}}

### {{Option B}}

* Good, because {{...}}
* Bad, because {{...}}

<!-- guide: repeat one `### <option>` block per option in Considered Options, chosen one included, so no option's
     pros and cons are dropped. Copy them from the artifact's options table; a pro or con it never stated is
     `⚠ not stated in <path>@<sha>`, never invented. -->

## More Information

Journal: D{{n}} in `docs/decisions/DECISION_JOURNAL.md` · Approval: `.handoff/TRACKER.md ## Approvals`, {{gate id}}
{{Approvals row time}}, "{{exact words}}" · Artifact: `{{path}}@{{short sha}}` · Revisit if: {{trigger}}
```

## Part 3 — private reflection, appended to `~/factory-kit-private/{{repo}}/REFLECTIONS.md`

<!-- guide: only when the human offered a reflection with their answer. Their words verbatim; never summarized,
     never prompted for, never written inside the repo, never containing secrets or PHI. -->

```markdown
## {{YYYY-MM-DD HH:MM TZ}} · D{{n}} {{Title}} · {{gate id}} · {{repo}}@{{short sha}}

{{the human's reflection, verbatim}}
```

## Part 4 — question card (chat only, one per message, at most 3 per run)

```
Question {{i}} (max 3) — {{field: reversibility | supersedes | phase/milestone/gate}} for D{{n}} {{Title}}
{{the question in one line}}
Why it matters: {{one plain sentence: what changes in the record, e.g. "Type 1 gets its own ADR and more evidence"}}
Options: A) {{...}} — {{what it means}} · B) {{...}} — {{what it means}}
Recommended: {{A | B}}, because {{evidence: file:line, the Type 1 list, D<k>}}
If you skip: the field reads "⚠ {{question}}" and the STOP message lists it.
```
