# {{Product name}} — Product Requirements

<!-- write-prd template. Fill every section; keep every `## ` heading exactly as written and in this order.
     Delete every HTML comment and every {{placeholder}} when filling.
     Open questions: write each one ONCE as `⚠ <question> — Recommended: <answer> — Blocks: <ids>`, one per line,
     at the spot it affects (or under Open questions when it spans sections). Elsewhere refer to it by its wording or
     the ids it blocks; never repeat the ⚠ glyph (the open count counts glyphs).
     WHAT and WHY only. Technology names appear ONLY in ## Constraints: with a mandate, or as a ⚠ "mandated?" row.
     Ids are permanent: never renumber, never reuse. Retire with strikethrough (see ## Change log).
     Examples use fictional people and values only; never real patient data, partner-confidential text or secrets. -->

| Field | Value |
|---|---|
| Source brief | `specs/{{M<N>-slug}}/brief.md` @ {{short sha of the G0 approval}} |
| Track | Full |
| Last updated | {{output of `date`}} |
| Context names | {{proper names allowed in Problem, Job stories and Users: the brief's problem_allowlist plus the partner or host platform name, comma-separated, or none}} |
| Approval | G1 — recorded in `.handoff/TRACKER.md ## Approvals` (never in this file) |

## Problem

<!-- 3-6 sentences: who hurts, when, how badly, what it costs today, why now. Cite evidence ids (R<NN>, REQ-##, Q<n>)
     or brief lines. No solution words. If no source says how much or why now, write "Not in the sources" in plain
     text; use ⚠ only when that gap blocks an id. An uncleared source is paraphrased, never quoted. -->

{{Problem statement.}} Evidence: {{R01 §2, REQ-01, brief.md:14}}.

### Job stories

<!-- In the users' own words. Reuse the brief's JS-## ids and wording verbatim; a new story from this interview
     takes the next free id and cites (Q<n>).
     Format: When <situation>, I want to <motivation>, so I can <expected outcome>. -->

- **JS-01** When {{situation}}, I want to {{motivation}}, so I can {{outcome}}. — Source: brief JS-01 ({{REQ-## / Q#}})
- **JS-02** When {{situation}}, I want to {{motivation}}, so I can {{outcome}}. — Source: {{brief JS-02 | (Q<n>)}}

## Users and personas

<!-- Primary first. "Not for" names who we deliberately do not serve in this appetite. -->

| Persona | Who they are | Context of use | What they need | How often |
|---|---|---|---|---|
| {{P-1 name}} (primary) | {{role}} | {{where/when they meet the product}} | {{need}} | {{daily / per visit / ...}} |
| {{P-2 name}} | {{role}} | {{context}} | {{need}} | {{frequency}} |

Not for: {{persona or segment}} — because {{reason}}.

## Goals

<!-- Outcomes, not features. Each goal is measured by at least one SC. -->

- **GOAL-1** {{Outcome in plain words}}. Measured by: {{SC-001}}.
- **GOAL-2** {{Outcome}}. Measured by: {{SC-002}}.

## Non-goals and no-gos

<!-- Non-goals: reasonable things we are choosing not to do now (may come later).
     No-gos: things we refuse to do or rabbit holes we will not enter in this appetite. -->

Non-goals:
- **NG-1** {{Not doing X}} — because {{reason}}; revisit {{when / never}}.

No-gos:
- **NOGO-1** {{Rabbit hole or forbidden behaviour}} — because {{reason}}.

## Appetite

<!-- Fixed time, variable scope. How much time this problem is worth, the hard date, and what gets cut first.
     Cite where each fact came from (REQ-##, (Q<n>), D<n>). -->

- Time box: {{e.g. 1 day for the M4 tracer bullet, 1 week total}}; hard date: {{date + time zone}}. Source: {{REQ-## | (Q<n>)}}.
- If time runs short, cut in this order: {{US-3 → US-2 → ...}}. Never cut: {{US-1 and the Unwanted-behaviour FRs}}.

## User stories

<!-- P1 = must ship (the tracer-bullet journey), P2 = should, P3 = could. Each story must be independently
     testable: if ONLY this story shipped, a user gets value and you could demo it. -->

### US-1 {{Short title}} (P1)

As a {{persona}}, I want {{capability}}, so that {{benefit}}.

- Why this priority: {{one line}}
- Independent test: {{how someone could demo this story alone, in plain words}}
- Requirements: {{FR-001, FR-002}} · Examples: {{AE-001, AE-002}}

### US-2 {{Short title}} (P2)

As a {{persona}}, I want {{capability}}, so that {{benefit}}.

- Why this priority: {{one line}}
- Independent test: {{...}}
- Requirements: {{FR-003}} · Examples: {{AE-003}}

## Functional requirements

<!-- EARS, one "shall" per line, always "the system shall". Tag the pattern; the sentence must have that tag's
     exact shape (Done when greps each one). Link the story.
     [Ubiquitous] The system shall <response>.
     [Event]      When <trigger>, the system shall <response>.
     [State]      While <state>, the system shall <response>.
     [Unwanted]   If <unwanted condition>, then the system shall <response>.
     [Optional]   Where <feature is included>, the system shall <response>.
     [Complex]    While <state>, when <trigger>, the system shall <response>.
     Retired: - ~~**FR-004**~~ retired {{date}}: {{reason}} (id never reused) -->

- **FR-001** [Event] (US-1) When {{trigger}}, the system shall {{observable response}}.
- **FR-002** [Unwanted] (US-1) If {{unwanted condition}}, then the system shall {{observable response}}.
- **FR-003** [State] (US-2) While {{state}}, the system shall {{observable response}}.

## Non-functional requirements

<!-- A number with a unit and a condition, or it is not an NFR. Category in brackets. Cite the source of the number;
     an unconfirmed number keeps your recommended value in the sentence and a ⚠ question as its Source. -->

- **NFR-001** [Performance] {{What the user waits for}} completes in ≤ {{2}} s at the 95th percentile with {{50}} concurrent users. Source: {{REQ-## | (Q<n>) | ⚠ Is 2 s at p95 acceptable while a patient waits? — Recommended: 2 s — Blocks: NFR-001}}.
- **NFR-002** [Availability] {{Capability}} is available ≥ {{99.5}} % of each calendar month. Source: {{...}}.
- **NFR-003** [Privacy] {{Sensitive data}} is visible to {{0}} users outside {{the allowed role}}. Source: {{...}}.

## Success criteria

<!-- A change in a person's or the business's outcome (time saved, money no longer fronted, adoption), technology-
     free, each linked to a GOAL, with how and when it is measured in plain words. Never restate an FR or NFR: if an
     AE can prove it, it is not an SC. -->

- **SC-001** {{≥ 80 %}} of {{persona}} {{complete the core job}} in under {{2}} minutes, measured by {{method}} by {{date}}. (GOAL-1)
- **SC-002** {{Outcome metric with target}}, measured by {{method}}. (GOAL-2)

## Acceptance examples

<!-- Given/When/Then with concrete fictional values (names, amounts, counts), never "valid input". Every FR is cited
     by at least one AE; every [Unwanted] FR has its own AE that cites it first. These seed define-acceptance; they
     are examples, not test code. -->

- **AE-001** (FR-001) Given {{concrete starting state}}, When {{concrete action}}, Then {{concrete observable result}}.
- **AE-002** (FR-002) Given {{state}}, When {{unwanted event}}, Then {{safe observable result}}.
- **AE-003** (FR-003) Given {{state}}, When {{action}}, Then {{result}}.

## Edge cases

<!-- Empty, first-use, maximums, duplicates, concurrency, partial failure, permission denied, slow or absent
     partner system. Each names the FR that states its safest visible behaviour. Use ⚠ only when the choice
     changes scope or money and no FR states it yet. -->

- **EC-1** {{Case}} → expected: {{behaviour}} ({{FR-002}})
- **EC-2** {{Case}} → ⚠ {{question}} — Recommended: {{answer}} — Blocks: {{ids}}

## Assumptions and open questions

<!-- Assumptions are things we treat as true without proof; say who/what could confirm them. Any assumption that goes
     beyond what its cited line says — delegated ("you decide") or inferred by the agent — has
     Basis: assumed by agent; confirm at G1.
     Open questions: questions that span sections, in the one-line ⚠ form. A brief research question nobody
     answered adds (→ R<NN>) after the question. -->

Assumptions:
- **A-1** {{Assumption}} — Basis: {{source | assumed by agent; confirm at G1}}.

Open questions:
- ⚠ {{Question}} — Recommended: {{answer}} — Blocks: {{FR-/NFR-/SC- ids}}

### Interview log

<!-- The gap list and the verbatim record of this interview. Every (Q<n>) cited anywhere resolves to a row here.
     Replies verbatim, with secret or personal values replaced by [redacted: <what it was>]. No human in the session:
     no rows; the top gaps are ⚠ lines marked "not asked: no human in session". This subsection is exempt from the
     technology-name check because it quotes people; HOW ideas in it are parked in the STOP message. -->

Answered from sources: {{section or bank # → file:line | REQ-## | R<NN>, ...}}

| Q# | Question | Recommended (and evidence) | Reply (verbatim) | Landed in |
|---|---|---|---|---|
| Q1 | {{question}} | {{answer — because file:line / R<NN> / guess}} | {{"exact words" (redacted)}} | {{ids or section}} |

## Risks

<!-- Product risks, not technical design: value (will they want it), usability (can they use it),
     feasibility (can we build it in the appetite), viability (does it work for the partner/business/law).
     A risk that depends on an open question names it by wording or blocked ids; never repeat the ⚠ glyph here. -->

| Id | Risk | Type | Likelihood | Impact | Mitigation in this PRD |
|---|---|---|---|---|---|
| RISK-1 | {{risk}} | {{value / usability / feasibility / viability}} | {{L/M/H}} | {{L/M/H}} | {{scope cut, AE, NFR, or the open question it waits on}} |

## Milestone cut

<!-- Full track (WORKFLOW.md §8): M1 Research, M2 Product, M3 Design are planning milestones (docs only, no FRs);
     a large design may split into M3 HLD + M4 LLD, shifting the build rows up by one. The first implementation
     milestone (M4 here) = tracer bullet: the thinnest end-to-end slice of the P1 journey that a user could watch
     work. Each implementation milestone gets its own acceptance + tasks. Every FR id appears in exactly one row (a milestone or Later). One MR per milestone. -->

| Milestone | Goal (one line) | Scope (FR ids) | Proves (SC / AE ids) | Exit demo (one sentence) |
|---|---|---|---|---|
| M1 Research | Approved brief + cited research | none (docs only) | G0 approval | {{Reviewer reads the brief and every R<NN> note}} |
| M2 Product | Approved PRD (+ clarifications) | none (docs only) | G1 approval | {{Reviewer reads docs/product/prd.md}} |
| M3 Design | Approved HLD, LLD, DB design, API contract, diagrams | none (docs only) | G2-G3 approvals | {{Reviewer can read every design doc from docs/README.md}} |
| M4 Tracer bullet | {{Thinnest end-to-end P1 journey}} | {{FR-001, FR-002}} | {{AE-001, AE-002}} | {{A persona does X and sees Y}} |
| M5 {{Name}} | {{...}} | {{FR-003}} | {{AE-003, SC-001}} | {{...}} |
| Later | Not in this appetite | {{FR ids or none}} | — | — |

## Constraints

<!-- The ONLY section that may name technology, vendors, platforms or protocols — and only with a mandate:
     a brief REQ row (it cites the assignment, partner or law), an accepted D<n>, or the human's interview answer
     naming who mandates it (Q<n>). No mandate = a design choice for design-hld, not a constraint.
     A source that names a technology without clearly requiring it → a ⚠ row ("mandated, or context only?").
     Names: every technology, vendor or platform word in the row, comma-separated, or none (Done when greps them).
     Source: REQ-## (with the brief's location: path:line, or <source name> p.N/§N), D<n>, or (Q<n>).
     Never a local path such as /Users/...; never a word-for-word quote of an uncleared source.
     Non-technical constraints (deadline, budget, legal) also live here. -->

| Id | Constraint | Names | Mandated by | Source |
|---|---|---|---|---|
| C-1 | {{Must run inside the partner's platform / must use stack X}} | {{X, Y, or none}} | {{assignment / partner / law / human}} | {{REQ-## (path:line or source p.N), or D<n>, or (Q<n>)}} |
| C-2 | ⚠ {{Is <name> mandated, or context only?}} — Recommended: {{treat as mandated, or context only}} — Blocks: C-2 | {{<name>}} | unconfirmed | {{REQ-## (path:line)}} |

### Assignment trace

<!-- One row per brief REQ row owned by write-prd, delivered under docs/product/, naming a companion file, or cited
     by a C row. Covered by = the PRD ids or companion file that satisfy it. -->

| REQ | What it asks (short) | Covered by |
|---|---|---|
| {{REQ-01}} | {{plain paraphrase}} | {{FR-001, SC-001, C-1, or USERS.md}} |

## Change log

<!-- Living document. One row per write-prd run (the first is "First draft"), plus one per clarify-spec pass once an
     approval exists. Retired ids are listed here and struck through above. Gate = the gate that must approve this
     change; whether and when it was approved lives only in .handoff/TRACKER.md ## Approvals. -->

| Date | Change | Ids affected | Gate |
|---|---|---|---|
| {{`date`}} | First draft | all | G1 |

## Clarifications

<!-- Written by clarify-spec only. write-prd leaves existing entries untouched. -->

None yet.
