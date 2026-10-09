# {{Product name}} — High-level design

<!-- guide: design-hld template. Keep every `## ` heading exactly as written and in this order (14 numbered sections).
     Replace every {{placeholder}} and delete every guide comment when filling, from its opening line through its
     closing line. KEEP the three diagram placeholder lines (in §2, §3 and §11) exactly as written: the supervisor
     embeds each drawn diagram under its placeholder.
     Unknowns become `⚠ <question> (Q-n)` plus a Q-n row in §13, never inventions. An agent assumption is written
     `<value> (assumed, ⚠ Q-n)`.
     Boxes and lines only: no tables/columns, classes, endpoints, request fields or code (that is design-lld).
     Ids are permanent: never renumber, never reuse; retire with ~~ID~~ (removed <date>: reason).
     Local ids: CN-n container, L-n connection, TB-n trust boundary, TH-n threat, QA-n quality scenario,
     INV-n invariant, AR-n architecture risk, Q-n open question. D<n> continues the decision journal's numbering. -->

| Field | Value |
|---|---|
| PRD | `docs/product/prd.md` @ {{short sha approved at G1}} |
| Milestone | {{M<N>-slug, or "none — no brief"}} |
| Mode | {{greenfield / brownfield (audit: docs/audit/AUDIT.md @ sha)}} |
| Last updated | {{output of `date`}} |
| Written by | design-hld ({{harness}}, {{model id}}) |
| Approval | G2 — recorded in `.handoff/TRACKER.md ## Approvals` (never in this file); decisions in `docs/decisions/DECISION_JOURNAL.md` |

**How to read this HLD.** A *container* is something that runs or stores data on its own (an app, a database, a
queue). A *connection* is an arrow between two of them and how it talks (sync = the caller waits for the answer;
async = it hands off a message and moves on). A *trust boundary* is a line where data passes to a party with
different permissions. An *invariant* is a rule that must always hold, or data, money or trust is corrupted. A
*D<n>* is a decision put to you at G2: Type 1 = one-way door, expensive to undo; Type 2 = two-way door, cheap to
change later. Anything not known yet carries a warning sign and a Q-n id; §13 lists every one with a recommended
answer.

## Inputs read

<!-- guide: every file you opened, with its version. "Not read" lists files that exist and might matter but were not
     opened or not used (and why). Honesty here is what lets the reviewer trust the rest. -->

| Path | Version (sha or date) | Used for |
|---|---|---|
| `docs/product/prd.md` | {{sha}} | drivers, constraints, non-goals |
| `AGENTS.md` | {{sha}} | stack, commands, hosting |
| {{path}} | {{sha}} | {{what it informed}} |

**Not read:** {{paths — why, or "none"}}

## 1. Context & goals

<!-- guide: 2-4 plain sentences: what the system does, for whom, and the ONE quality that matters most and why.
     A driver is a requirement that changes a box or a line if it disappeared. Givens (PRD C-n, the stack and host
     in AGENTS.md "Project specifics", accepted journal D<n>) are never re-argued as a new D<n>. -->

{{What the system does, for whom, and the quality that matters most.}}

### Drivers

| Id | Requirement (short) | Kind | How it shapes the design |
|---|---|---|---|
| {{FR-001}} | {{short restatement}} | FR | {{e.g. needs a call to an external system on every page load}} |
| {{NFR-001}} | {{short restatement with the number}} | NFR | {{e.g. rules out a synchronous call to X on the hot path}} |

### Given constraints (fixed inputs, not decisions)

| Source (C-n, AGENTS.md:line or accepted D<n>) | Constraint | Design consequence |
|---|---|---|
| {{C-1 / AGENTS.md:58 / D2}} | {{e.g. stack or host mandated by the partner}} | {{what it forces or rules out}} |

### Non-goals carried from the PRD

- {{NG-1}} → {{what the design deliberately leaves out because of it}}

## 2. System context (C4 level 1)

<!-- guide: our system as ONE box, plus every person and external system it talks to. Include admins, identity
     providers, payment/email providers, host platforms. An external stubbed in-process this slice stays here,
     marked (stub). Data exchanged = nouns only. -->

<!-- diagram: hld-context -->

| Element | Kind | Interaction with our system | Data exchanged | Owner | Basis |
|---|---|---|---|---|---|
| {{Our system}} | our system | — | — | us | {{FR ids}} |
| {{Actor}} | person | {{uses it to ...}} | {{nouns}} | — | {{FR-001}} |
| {{External system}} | external system | {{we call it to ... / it calls us to ...}} | {{nouns}} | {{vendor or team}} | {{FR-002, R01}} |

## 3. Containers (C4 level 2)

A container is a separately running or deployable runtime boundary that runs code or stores data: a web app, an
API, a background worker, a database, a queue, a cache, an object store. It is not a Docker container.

<!-- guide: start from the simplest set that meets the drivers (often one app + one database). Every extra container
     needs a driver id in Basis. Data owned = nouns ("orders, payments"), never columns. Brownfield: suffix the
     name with (existing) / (changed) / (new) and cite file:line. -->

<!-- diagram: hld-container -->

| Id | Container | Technology | Responsibility | Data owned | Scaling unit | Basis |
|---|---|---|---|---|---|---|
| CN-1 | {{name}} | {{tech + version, from C-n / AGENTS.md / D<n>}} | {{one sentence}} | {{nouns}} | {{e.g. stateless process, add instances}} | {{FR/NFR/C/D ids}} |
| CN-2 | {{name}} | {{...}} | {{...}} | {{...}} | {{e.g. one primary, vertical}} | {{...}} |

## 4. Connections

<!-- guide: one row per arrow, including actors → containers and containers → external systems. Sync = the caller
     waits for the answer; async = the caller hands off a message and moves on. Payload = nouns, never fields.
     A stub's row says "in-process (stub)" and names the real protocol as "later: ...". -->

| Id | From → To | Protocol | Sync / async | Auth | Payload (nouns) | On failure | Basis |
|---|---|---|---|---|---|---|---|
| L-1 | {{Actor}} → {{CN-1}} | {{HTTPS}} | sync | {{e.g. session cookie / OAuth2 bearer / signed launch}} | {{nouns}} | {{what the user sees; timeout; retry?}} | {{FR-001}} |
| L-2 | {{CN-1}} → {{CN-2}} | {{e.g. SQL over TLS}} | sync | {{e.g. per-environment DB user}} | {{nouns}} | {{...}} | {{...}} |

## 5. Trust boundaries & threats

<!-- guide: a trust boundary is a line where data passes between parties with different privileges or owners
     (internet → app, app → third party, app → database, user role → admin role). Every TB-n has >= 1 TH-n.
     STRIDE: Spoofing, Tampering, Repudiation, Information disclosure, Denial of service, Elevation of privilege. -->

### Boundaries

| Id | Boundary | Less trusted side | More trusted side | Crossing connections |
|---|---|---|---|---|
| TB-1 | {{internet → app}} | {{browser / caller}} | {{CN-1}} | {{L-1}} |

### Threats per boundary

| Id | Boundary | STRIDE | Threat (an attacker could ...) | Design mitigation | Residual risk | Basis |
|---|---|---|---|---|---|---|
| TH-1 | TB-1 | {{S}} | {{...}} | {{design-level control, not code}} | {{low / med / high + why}} | {{NFR/AUDIT/R ids}} |

## 6. Quality-attribute scenarios

<!-- guide: one per architecture-relevant NFR, plus one degraded scenario per real (non-stub) external system and
     one for the host platform. Measure = number + unit + condition, or it is not a scenario. -->

| Id | NFR | Quality | Source | Stimulus | Environment | Response | Measure |
|---|---|---|---|---|---|---|---|
| QA-1 | {{NFR-001}} | {{performance}} | {{who/what triggers it}} | {{the event}} | {{normal / peak / degraded: X down}} | {{what the system does}} | {{e.g. p95 ≤ 2 s at 50 concurrent users}} |

## 7. Invariants

<!-- guide: things that must ALWAYS be true, or data/money/trust is corrupted. Pick the strongest enforcer that can
     hold it: DB constraint > transaction > code + test > code alone. Describe the enforcer in words; the exact
     constraint belongs to design-lld. -->

| Id | Invariant (always true) | What breaks if violated | Enforcer | Enforced in | Basis |
|---|---|---|---|---|---|
| INV-1 | {{e.g. an order is charged at most once}} | {{...}} | {{DB constraint / transaction / test / code}}: {{in words}} | {{CN-n}} | {{FR/NFR ids}} |

## 8. Scale budget

<!-- guide: the usage model comes first; every other number derives from it. Every budget line is followed by a
     `WHY:` line: the arithmetic from a cited input (PRD id, R/S id, brief line) or an answer the human gave. An
     agent assumption is written `<value> (assumed, ⚠ Q-n)` and gets its §13 row. -->

### Budget

- **Usage model:** {{one entry per role: role × count at 12 months × core actions per day, e.g. "providers 100 × 2 orders/day; patients 900 × 1 link opened per order"}}
  WHY: {{source per role: PRD id, brief line, research id or the human's answer}}
- **Users (total / daily active):** {{n}} / {{n}}
  WHY: {{sum of the usage model; DAU ≥ the distinct people the core actions need each day}}
- **Peak concurrent users:** {{n}}
  WHY: {{derivation + source}}
- **Peak request rate:** {{n}} req/s
  WHY: {{DAU × requests per user per day ÷ active seconds × peak factor = n}}
- **Data growth:** {{n}} records/year ≈ {{n}} GB/year
  WHY: {{usage-model actions/day × working days × records per action × bytes per record}}
- **User-facing latency budget (p95):** {{n}} ms = {{split per hop, e.g. app 150 + DB 50 + external 300}}
  WHY: {{derivation + source}}
- **Availability target:** {{99.x}} % ≈ {{n}} min downtime/month
  WHY: {{derivation + source}}
- **Recovery (RPO / RTO):** {{data loss tolerated}} / {{time to restore}}
  WHY: {{derivation + source}}
- **Monthly run-cost ceiling:** ${{n}}
  WHY: {{derivation + source}}

### What breaks first at 10×

| Rank | Component (CN/L id) | Why it breaks (the number) | First mitigation |
|---|---|---|---|
| 1 | {{CN-2}} | {{e.g. 10× = 70 req/s; connection pool of 20 saturates at ~40 req/s}} | {{...}} |
| 2 | {{...}} | {{...}} | {{...}} |

### How you'd know in prod

| Signal (metric or log) | Threshold | Watched where | Action |
|---|---|---|---|
| {{e.g. p95 latency of L-1}} | {{> 2 s for 5 min}} | {{dashboard / alert}} | {{...}} |

## 9. Key decisions

<!-- guide: one D<n> per open technology or pattern choice that changes a §3 box, a §4 line or a §7 enforcer, or
     costs >= 1 build-day or >= $5/month. Smaller choices are §10/§11 rows with a one-line why; §1 givens are never
     a D<n>. Always include "Do nothing / simplest" and your first proposal (a brief P-## when one was parked).
     Status stays proposed in this file forever; acceptance is recorded by log-decision in the journal, whose id
     may differ. Order by how much else depends on the decision. -->

### D{{n}} {{Title}}  [status: proposed]

- **Question:** {{the choice in one line}}
- **Forces:** {{FR / NFR / C ids}}
- **Reversibility:** {{Type 1 one-way | Type 2 two-way}} · **Confidence:** {{low | med | high}}

| Option | Pros | Cons | Cost (build + run) | Basis |
|---|---|---|---|---|
| Do nothing / simplest: {{...}} | {{...}} | {{...}} | {{...}} | {{ids or evidence}} |
| {{Option A}} | {{...}} | {{...}} | {{...}} | {{...}} |
| {{Option B}} | {{...}} | {{...}} | {{...}} | {{...}} |

- **Recommendation:** {{option}}
- **Why (Y-statement):** In the context of {{C}}, facing {{F}}, we choose {{X}} over {{Y}} to get {{Z}}, accepting {{W}}.
- **In plain words:** {{one sentence a beginner can follow}}
- **First proposal (instead of):** {{the option reached for first (cite P-## if parked in the brief) and why it lost, or "same as recommendation"}}
- **Revisit if:** {{observable trigger, ideally a §8 signal}}
- **Interview line:** "{{one sentence you would say out loud}}"

## 10. Cross-cutting concerns

<!-- guide: every row filled; "n/a — reason" is allowed, blank is not. Names of config/secrets only, never values. -->

| Concern | Design approach | Enforced in | Basis |
|---|---|---|---|
| Authentication | {{who proves identity how; where sessions/tokens live}} | {{CN ids}} | {{...}} |
| Authorization | {{who may do what; where the check happens; default deny}} | {{...}} | {{...}} |
| Errors | {{what users see vs what is logged; no internals leak}} | {{...}} | {{...}} |
| Logging & observability | {{structured logs, correlation id, metrics, alerts; what is never logged}} | {{...}} | {{...}} |
| Config & secrets | {{where config and secrets come from per environment (names only)}} | {{...}} | {{...}} |
| Idempotency | {{which operations can repeat (retry, double-click, webhook redelivery) and how duplicates are absorbed}} | {{...}} | {{...}} |
| Time | {{stored in UTC; display time zone; whose clock}} | {{...}} | {{...}} |
| Money | {{integer minor units + currency; rounding rule; who computes totals; source of truth}} | {{...}} | {{...}} |
| Sensitive data | {{PII/PHI classes, where they live, retention, what never leaves which boundary}} | {{...}} | {{...}} |

## 11. Deployment view

<!-- guide: where each container runs per environment. Detailed runbooks belong to ship-milestone. -->

<!-- diagram: deployment -->

| Environment | Runs on | Containers | Deployed by | Secrets from | Data | Basis |
|---|---|---|---|---|---|---|
| local | {{...}} | {{CN ids}} | {{developer command from AGENTS.md}} | {{e.g. .env, gitignored}} | {{fake/seed data}} | {{...}} |
| CI | {{...}} | {{...}} | {{...}} | {{...}} | {{...}} | {{...}} |
| staging | {{... or "none — reason"}} | {{...}} | {{...}} | {{...}} | {{...}} | {{...}} |
| production | {{...}} | {{...}} | {{human-only deploy}} | {{...}} | {{...}} | {{...}} |

- **Release & rollback:** {{one line: how a release goes out and how it is undone}}
- **Health:** {{how liveness and the running version are known — by purpose, no URL paths}}

## 12. Cost projection

<!-- guide: monthly USD per tier, derived from unit prices. Each price cites R/S ids or "pricing page checked <date>";
     otherwise mark it `⚠ estimate (Q-n)`. The last column is what the architecture must change to survive the tier. -->

| Tier (users) | Monthly cost (USD) | WHY | Architecture change needed at this tier |
|---|---|---|---|
| 100 | {{n}} | {{unit prices × quantities}} | none — baseline (§3 as drawn) |
| 1K | {{n}} | {{...}} | {{...}} |
| 10K | {{n}} | {{...}} | {{...}} |
| 100K | {{n}} | {{...}} | {{...}} |

## 13. Risks & open questions

<!-- guide: every inline ⚠ elsewhere in this file names its Q-n, and every Q-n has a row here whose Question cell
     starts with ⚠ while it is open. Risks are technical/architectural; product risks stay in the PRD. A PRD scope
     gap is answered by "clarify-spec docs/product/prd.md" (or a write-prd Revise + G1 re-approval). -->

### Risks

| Id | Risk | Likelihood | Impact | Mitigation | Basis |
|---|---|---|---|---|---|
| AR-1 | {{...}} | {{L/M/H}} | {{L/M/H}} | {{...}} | {{...}} |

### Open questions

| Id | Question | Blocks | Recommended answer | Who answers |
|---|---|---|---|---|
| Q-1 | ⚠ {{question}} | {{§8 / D<n> / INV-n}} | {{answer + why}} | {{human / partner / evidence / clarify-spec docs/product/prd.md}} |

## 14. Diagram requests

Each job is one `draw-diagrams` run. It writes `docs/architecture/diagrams/<type>.mmd` from the sections in "Draw
from" and nothing else; the supervisor then embeds each file under its placeholder line with
`scripts/embed-diagrams.sh`. A box or arrow missing from the section is missing from the diagram: fix the section,
never the picture.

| Job | Draw from | Must show | Placeholder line in |
|---|---|---|---|
| `draw-diagrams hld-context` | `docs/architecture/hld.md#2-system-context-c4-level-1` | our system as one box; every §2 row; arrows labelled with the interaction | §2 |
| `draw-diagrams hld-container` | `docs/architecture/hld.md#3-containers-c4-level-2`, `docs/architecture/hld.md#4-connections`, `docs/architecture/hld.md#5-trust-boundaries--threats` | every CN id; every L id labelled protocol + sync/async; TB ids as dashed boundaries | §3 |
| `draw-diagrams deployment` | `docs/architecture/hld.md#11-deployment-view` | each environment's runtime and which CN ids it hosts | §11 |

## Change log

| Date | Change | Ids affected | Approval |
|---|---|---|---|
| {{`date`}} | First draft | all | pending G2 |
