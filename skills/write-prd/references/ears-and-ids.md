# EARS, NFRs, success criteria, examples and ids

Load this at Step 5. Examples use a generic clinic store; they are patterns, not requirements.

## EARS patterns (Mavin et al., Rolls-Royce, 2009)

EARS = Easy Approach to Requirements Syntax: five fixed sentence shapes so every requirement has one trigger,
one condition and one testable response. Fixed shapes make gaps visible ("what happens *if* it fails?").

| Pattern | Shape | Example |
|---|---|---|
| Ubiquitous | The system shall `<response>`. | The system shall show each product's price including tax. |
| Event | When `<trigger>`, the system shall `<response>`. | When a clinician adds a product to a patient's order, the system shall show the updated order total. |
| State | While `<state>`, the system shall `<response>`. | While a patient's order is awaiting payment, the system shall show it as "Awaiting payment" to staff. |
| Unwanted | If `<unwanted condition>`, then the system shall `<response>`. | If a product goes out of stock after it was added, then the system shall tell the clinician before the order is placed. |
| Optional | Where `<feature is included>`, the system shall `<response>`. | Where home delivery is offered, the system shall ask for a delivery address before payment. |
| Complex | While `<state>`, when `<trigger>`, the system shall `<response>`. | While a patient chart is open, when the clinician opens the store, the system shall pre-select that patient. |

Rules:
- Exactly one "shall" per FR. "and" joining two responses → two FRs.
- Always "the system shall" (the Done-when grep relies on it). Actors appear in the trigger, not as the subject.
- The sentence must have its tag's exact shape: an [Unwanted] FR starts "If …, then the system shall", an [Event]
  FR "When …, the system shall", and so on. A tag on a ubiquitous sentence fails Done when.
- Observable response: something a person or a test can see. "shall process" / "shall handle" / "shall support"
  are not observable — say what the person sees or what changes.
- Every must-never-happen from the interview gets its own [Unwanted] FR. Other undesired conditions (invalid input,
  blocked actions such as an empty order or a negative payout) may also use [Unwanted].
- No vague words (Done-when greps them): fast, quick, easy, intuitive, user-friendly, robust, seamless,
  appropriate, optimal, as needed, etc., and/or. Vague quality → an NFR with a number.

## HOW → WHAT rewrites (the need hiding inside a solution idea)

| HOW leak (not allowed outside Constraints) | WHAT it is really asking for |
|---|---|
| "Store orders in MySQL" | FR: When a clinician places an order, the system shall show it in the patient's order history. |
| "Cache the catalog in Redis" | NFR: The catalog shows within 1 s at the 95th percentile with 50 concurrent users. |
| "POST /orders endpoint" | FR [Event]: When a clinician confirms an order, the system shall … |
| "Use Stripe" (not mandated) | FR: The system shall accept card payment. (If mandated → Constraints with source.) |
| "Their stack is PHP/Laravel" (stated, no "must") | Constraints row `⚠ Is PHP/Laravel mandated, or context only? — Recommended: … — Blocks: C-n`, Names `PHP, Laravel`. |
| "React dashboard" | FR: The system shall show staff the list of today's orders. |
| "Nightly cron job" | FR [Event]: When the clinic day ends, the system shall … |
| "JWT / OAuth login" | FR: The system shall show the store only to signed-in clinic staff. (Mandated mechanism → Constraints.) |

Anything left over that is purely HOW goes in the STOP message under "Parked for design-hld", not in the PRD.

## NFRs: number + unit + condition

| Category | Unit examples |
|---|---|
| Performance | seconds or ms at p95 / p99, under N concurrent users |
| Availability | % per calendar month; planned downtime window |
| Reliability | % of orders lost (target 0), max minutes of lost work (RPO), minutes to restore (RTO) |
| Privacy / security | number of people outside a role who can see X (target 0); days data is kept |
| Accessibility | named conformance level (e.g. WCAG 2.2 AA) for named screens/journeys |
| Capacity | items, users, orders per day at peak |
| Cost | currency per month at stated volume |
| Auditability | % of changes to X traceable to a person and time (target 100 %) |

Unknown number → keep your recommended value in the sentence (the Done-when unit grep needs it) and make the Source
`⚠ <question> — Recommended: <value> — Blocks: NFR-###`.

## Success criteria vs NFRs

- SC = did the product **work for people or the business**? Technology-free, observable without reading code.
  "≥ 80 % of clinicians place a supplement order in under 2 minutes in the first week."
- NFR = a **quality the system must have** while doing its job. "Order total updates within 1 s p95."
- Test: if the sentence still makes sense after swapping the whole tech stack, and a non-engineer could measure it,
  it is an SC.
- An SC never restates an FR or NFR. If an AE can prove it ("every paid order reconciles to the cent", "the patient
  pays $0 up front" when no payment step exists), it is a requirement, not a success criterion. An SC measures a
  change in a person's or the business's outcome: time saved, money no longer fronted, adoption, repeat use.

## Acceptance examples (Given/When/Then)

- Concrete values: "Given patient Ana Ruiz has 2 bottles of Vitamin D3 ($18.00 each) in her order" — never
  "Given valid data".
- One behaviour per example; cite every FR it exercises: `**AE-004** (FR-006, FR-007)`.
- Cover the happy path and each [Unwanted] FR. Every FR has ≥ 1 AE; every [Unwanted] FR has its own AE that cites
  it first: `**AE-007** (FR-009) Given …`.
- People and values are fictional (like Ana Ruiz here). Never a real patient, a real email or phone number, or a
  partner-confidential figure.

## User stories: independently testable

A story passes when, if it were the ONLY story shipped, a user gets value and someone could demo it. If US-2 only
works after US-1, either merge them or rewrite US-2 so it has its own start state.
P1 = must ship (the tracer-bullet journey) · P2 = should · P3 = could. At least one P1; P1 count ≤ what fits M1.

## Ids

| Id | Meaning | Format |
|---|---|---|
| JS-## | Job story (same id as in the brief; new ones continue from the brief's highest) | JS-01 |
| GOAL-n, NG-n, NOGO-n | Goal, non-goal, no-go | GOAL-1 |
| US-n | User story | US-1 |
| FR-### / NFR-### / SC-### / AE-### | Requirements, success criteria, acceptance examples | FR-001 (3 digits) |
| EC-n, A-n, RISK-n, C-n | Edge case, assumption, risk, constraint | EC-1 |
| REQ-## | Assignment requirement, defined in the brief's `## Spec is law`; cited, never created here | REQ-01 |
| Q<n> | Interview question, a row in `### Interview log`; cited as `(Q<n>)` | Q1 |

- Never renumber, never reuse. Next id = highest existing + 1:
  `grep -oE 'FR-[0-9]{3}' docs/product/prd.md | sort -u | tail -1`
- Retire, don't delete: `- ~~**FR-004**~~ retired <date>: <reason> (id never reused)` plus a Change log row.
- "GOAL-" not "G-": G0/G1/… are gate ids. "RISK-" not "R": R<NN> is research.

## Assumptions

- Any assumption that goes beyond what its cited line says gets `Basis: assumed by agent; confirm at G1`, whether
  the human delegated it ("you decide") or you inferred it to fill a gap. The STOP message lists every such A-n
  from a command, so none reaches design unconfirmed.
