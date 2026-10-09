# {{Product name}} — Low-level design

<!-- guide: design-lld template. Keep every `## ` heading exactly as written and in this order.
     Replace every {{placeholder}} and delete every `<!-- guide:` comment when filling.
     KEEP every diagram placeholder line (the `diagram: <type>` comments below): draw-diagrams renders <type>.mmd
     and the supervisor's scripts/embed-diagrams.sh embeds it there. One placeholder per §10 job, no more, no fewer.
     §3 n/a → delete the fe-components placeholder and omit its §10 row.
     Shapes and signatures only: no function bodies, no SQL/DDL, no migration code, and no code fences except the
     mermaid blocks embed-diagrams.sh inserts between a placeholder and its `/diagram` end marker; never edit or
     remove those.
     Unknowns become `⚠ <question>` plus a Q-n row in "Open questions", never inventions.
     A section that does not apply says "n/a — <reason>"; blank is never allowed.
     Ids are permanent: never renumber, never reuse; retire with ~~ID~~ (removed {{date}}: reason).
     An id is DEFINED in exactly one place: a `### ID` heading (BE, SEQ, SM) or a **bold** first cell (FE, ST, EP,
     LINV, FM, SEAM, Q). Everywhere else it is plain text.
     Local ids: BE-n backend component, FE-n frontend component, ST-n piece of state, EP-n endpoint, SEQ-n journey
     sequence, SM-n state machine, LINV-n invariant found during LLD, FM-n failure mode, SEAM-n test seam,
     Q-n open question. Carried ids: FR/NFR/US/AE/EC (PRD), CN/L/TB/INV/D (HLD and journal).
     Delta (a later milestone; brownfield too): edit only the rows this milestone adds, changes or removes; suffix
     them (new) / (changed); strike removed ones; add a Change log row. Never rewrite untouched rows.
     Revise (G3 said Revise): change only the ids the Approvals row names; add (new)/(changed) only on a delta;
     add a Change log row citing that row's time. -->

| Field | Value |
|---|---|
| HLD | `docs/architecture/hld.md` @ {{short sha approved at G2}} |
| PRD | `docs/product/prd.md` @ {{short sha}} |
| UX | `docs/design/screens.md`, `docs/design/flows.md` @ {{short sha}} \| n/a — {{no UI in scope}} |
| Milestone | {{M<N>-slug}} |
| Mode | {{greenfield \| brownfield — change plan: `specs/M<N>-slug/change-plan.md`}} — from {{brief.md ## Track \| WORKFLOW §3}} |
| Pass | {{first \| delta on M<k> \| revise per G3 row <time>}} |
| Stack | {{language + framework + DB engine + version, from AGENTS.md / HLD CN rows}} |
| Contract | `docs/architecture/contracts/openapi.yaml` (OpenAPI 3.1) |
| Last updated | {{output of `date`}} |
| Written by | design-lld ({{harness}}, {{model id}}) |
| Approval | G3 — recorded in `.handoff/TRACKER.md ## Approvals` (never in this file); decisions in `docs/decisions/DECISION_JOURNAL.md` |

## Inputs read

<!-- guide: every file you opened, with its version. Brownfield code is cited file:line where it shaped a row.
     "Not read" lists files that exist and might matter but were not opened, and why. -->

| Path | Version (sha or date) | Used for |
|---|---|---|
| `docs/architecture/hld.md` | {{sha}} | containers, invariants, cross-cutting rules |
| `docs/product/prd.md` | {{sha}} | milestone scope, stories, AE/EC |
| `AGENTS.md` | {{sha}} | stack, conventions, commands |
| {{path}} | {{sha}} | {{what it informed}} |

**Not read:** {{path — why not read}} | none

## Requirement trace

<!-- guide: one row per FR in this milestone's PRD row (and each NFR/INV that shapes a table, endpoint or seam).
     Every cell names the ids that realise the requirement, or "—" when that layer is not involved.
     A row with every cell "—" means the design misses the requirement: fix the design or raise a Q-n. -->

| Requirement | Tables | Backend | Endpoints | Frontend / state | Journey | State machine |
|---|---|---|---|---|---|---|
| {{FR-001}} | `{{orders}}` | {{BE-1}} | {{EP-1}} | {{FE-2, ST-1}} | {{SEQ-1}} | {{SM-1}} |
| {{NFR-001}} | — | {{BE-1}} | {{EP-2}} | — | — | — |

## 1. Data model

<!-- guide: one block per table this milestone needs (delta: only new/changed tables plus the tables they reference).
     Types in the project's DB dialect. Null = "no" unless a reason is written in Notes. Money = integer minor units
     + currency column (omit it only when the PRD fixes one currency; cite that id); time = UTC (follow HLD §10). Name every constraint and index: reviewers and migrations refer to
     names. Rules: references/design-rules.md §Data model. -->

<!-- diagram: erd -->

### Tables

#### `{{orders}}` — {{what one row is}} · owner {{BE-n}} · {{new \| changed \| existing}}

| Column | Type | Null | Default | Constraint | Notes |
|---|---|---|---|---|---|
| `id` | {{bigint identity}} | no | {{generated}} | PK | |
| `{{customer_id}}` | {{bigint}} | no | — | FK `{{fk_orders_customer}}` | |
| `{{status}}` | {{varchar(20)}} | no | `'{{draft}}'` | CHECK `{{ck_orders_status}}` | state machine {{SM-1}} |
| `{{total_amount}}` | {{bigint}} | no | `0` | CHECK `{{ck_orders_total_nonneg}}` | money, minor units |
| `{{currency}}` | {{char(3)}} | no | `'{{USD}}'` | — | ISO 4217 |
| `created_at` | {{timestamp, UTC}} | no | {{now}} | — | |

- **Primary key:** `id` — {{surrogate; id type per D<n> or framework convention}}
- **Foreign keys:** `{{fk_orders_customer}}`: `{{customer_id}}` → `{{customers}}.id` ON DELETE {{RESTRICT}} — {{why this delete rule}}
- **Indexes:** `{{ix_orders_customer_created}}` ({{customer_id, created_at}}) — serves {{EP-2 list, newest first}}
- **Unique:** `{{uq_orders_idempotency}}` ({{customer_id, idempotency_key}}) — {{INV-n}} | none
- **Checks:** `{{ck_orders_status}}`: `{{status IN ('draft','placed','paid','cancelled')}}` — {{SM-1}}; `{{ck_orders_total_nonneg}}`: `{{total_amount >= 0}}`
- **Sensitive data:** {{columns holding PII/PHI and their class}} | none
- **Basis:** {{FR ids, HLD CN-n data owned, file:line for existing tables}}

### Relationships

| From | To | Cardinality | Via | Required? | Basis |
|---|---|---|---|---|---|
| `{{customers}}` | `{{orders}}` | {{1 — 0..N}} | `{{orders.customer_id}}` (FK) | {{every order has a customer}} | {{FR-001}} |
| `{{orders}}` | `{{products}}` | {{N — M}} | `{{order_lines}}` (join table) | {{an order has ≥ 1 line}} ⚠ {{or enforced in BE?}} | {{FR-002}} |

### Invariants the database enforces

<!-- guide: every constraint above that carries an invariant. Anything the engine cannot enforce moves to §7 with its
     code + test enforcer. Note engine limits (e.g. partial unique indexes, CHECK support by version). -->

| Constraint | Table | Enforces | Engine note |
|---|---|---|---|
| `{{uq_orders_idempotency}}` | `{{orders}}` | {{INV-1}} | {{supported}} |

## 2. Backend components

<!-- guide: one `### BE-n` block per class/module this milestone adds or changes, grouped by HLD container.
     Signatures in the AGENTS.md language with parameter and return types; NO bodies. One responsibility sentence
     without "and". Every external system is reached through exactly one adapter component (that is its test seam).
     No interface with a single implementation unless §9 lists it as a seam. Rules: references/design-rules.md. -->

<!-- diagram: be-class -->

**Layering:** {{e.g. route → controller → action/service → model; validation in request objects; authorization in policies — from AGENTS.md / framework convention}}

### BE-2 {{OrderController}} · {{controller}} · {{CN-1}} · {{new \| changed}}

- **Responsibility:** {{translate EP-1 and EP-2 HTTP requests into BE-1 calls and problem responses}}
- **Depends on:** {{BE-1; PlaceOrderRequest validation; OrderPolicy}}
- **Tables:** none (BE-1 owns them) · **Transactions:** none
- **Basis:** {{FR-002, FR-003}}

| Public method (signature only) | Called by | Returns | Raises (problem type) | Covers |
|---|---|---|---|---|
| `{{store(PlaceOrderRequest $request): JsonResponse}}` | {{router via EP-1}} | {{201 Order}} | {{`/problems/validation`}} | {{FR-002}} |

### BE-1 {{OrderService}} · {{service}} · {{CN-1}} · {{new \| changed}}

- **Responsibility:** {{one sentence}}
- **Depends on:** {{BE-n ids, framework services, adapters}}
- **Tables:** reads {{`products`}}; writes {{`orders`, `order_lines`}}
- **Transactions:** {{`placeOrder` opens one around the order + lines insert}} | none
- **Basis:** {{FR ids; file:line when changing existing code}}

| Public method (signature only) | Called by | Returns | Raises (problem type) | Covers |
|---|---|---|---|---|
| `{{placeOrder(PlaceOrderData $data, string $idempotencyKey): Order}}` | {{BE-2.store via EP-1}} | {{Order}} | {{`/problems/out-of-stock`, `/problems/idempotency-mismatch`}} | {{FR-002}} |

## 3. Frontend components

<!-- guide: n/a — <reason> only when no screen is in this milestone's scope; then delete the fe-components
     placeholder below and omit its §10 row. Tree from docs/design/screens.md; every FE id in the tree has a
     Components row and every row is in the tree. Every screen state there (loading, empty, error, success,
     permission denied) is rendered by some component. "Owns state" names ST ids or "none (stateless)" for every
     component (draw-diagrams treats a blank as a gap). One ST row per piece of state that more than one component
     reads OR that survives a reload. Kind: server | URL | local UI | shared client. How passed: props | lifted |
     context | store | server | url. A store needs a D<n>. Rules: references/design-rules.md §Frontend. -->

<!-- diagram: fe-components -->

**Rendering model:** {{SPA \| server-rendered \| hybrid — per HLD CN-n and D<n>}}

### Component tree

- {{FE-1 AppShell}} ({{screen id}})
  - {{FE-2 OrderPage}} ({{screen id}})
    - {{FE-3 LineItemList}}

### Components

| Id | Component | Screen | Props in | Events out | Owns state | Screen states rendered |
|---|---|---|---|---|---|---|
| **{{FE-1}}** | {{AppShell}} | {{screen id}} | {{none}} | {{none}} | {{none (stateless)}} | {{permission denied}} |
| **{{FE-2}}** | {{OrderPage}} | {{screen id}} | {{patientId: string}} | {{orderPlaced(orderId)}} | {{ST-1 (fetches), ST-2}} | {{loading, empty, error, success}} |
| **{{FE-3}}** | {{LineItemList}} | {{screen id}} | {{lines: OrderLine[]}} | {{none}} | {{none (stateless)}} | {{empty}} |

### State ownership

| Id | State | Kind | Owner | Consumers | How passed | Persisted? | Why this owner |
|---|---|---|---|---|---|---|---|
| **{{ST-1}}** | {{cart lines}} | {{server}} | {{server (`order_lines`), fetched by FE-2}} | {{FE-2, FE-3}} | {{props}} | {{server}} | {{lowest common owner; never copied into a store}} |
| **{{ST-2}}** | {{list filter + page cursor}} | {{URL}} | {{FE-2}} | {{FE-2}} | {{url}} | {{URL}} | {{survives reload and sharing}} |

### Data fetching

| Component | Endpoint | Trigger | Cache and invalidation | Loading | Empty | Error |
|---|---|---|---|---|---|---|
| {{FE-2}} | {{EP-2}} | {{mount; cursor change}} | {{invalidate after EP-1 succeeds}} | {{skeleton}} | {{"No orders yet"}} | {{problem title + retry}} |

## 4. API design

<!-- guide: every HTTP route this milestone adds or changes, including server-rendered pages and form posts
     (response = view name / 303 redirect). Every EP row is an operation in openapi.yaml with `x-lld-id: EP-n`.
     Errors are RFC 9457 problem details (`application/problem+json`) for JSON clients; HTML routes show the same
     problem type as a screen state. A problem type is always its full registry path `/problems/<slug>`, and every
     one used anywhere in this file has a registry row. Only `/problems/validation` carries `errors[]`; other 422s
     (business rules, idempotency mismatch) are plain problems. Rules: references/design-rules.md §API. -->

- **Contract:** `docs/architecture/contracts/openapi.yaml` (OpenAPI 3.1)
- **Base path · media types:** {{/api}} · {{application/json; errors application/problem+json}}
- **Auth:** {{scheme from HLD §10, e.g. session cookie + per-route policy}} · default deny
- **Versioning:** {{none until a second consumer exists \| D<n>}}

### Endpoints

| Id | Method | Path | Auth | Request schema | Response schema | Errors (status → problem type) | Idempotency | Pagination | Covers |
|---|---|---|---|---|---|---|---|---|---|
| **{{EP-1}}** | {{POST}} | `{{/orders}}` | {{session + OrderPolicy create}} | `{{PlaceOrderRequest}}` | {{201 `Order`}} | {{400 `/problems/idempotency-key-missing`; 409 `/problems/idempotency-in-flight`; 422 `/problems/validation`, `/problems/out-of-stock`, `/problems/idempotency-mismatch`}} | {{`Idempotency-Key` required}} | — | {{FR-002}} |
| **{{EP-2}}** | {{GET}} | `{{/orders}}` | {{session + OrderPolicy viewAny}} | {{query: cursor, limit}} | {{200 `OrderPage`}} | {{401 `/problems/unauthenticated`}} | n/a (safe) | {{cursor, default 25, max 100}} | {{FR-003}} |

### Problem types (RFC 9457)

| type | title | status | When | Extension members |
|---|---|---|---|---|
| `{{/problems/validation}}` | {{Some fields are invalid}} | 422 | {{request fails validation}} | `errors[]` (`pointer`, `detail`) |
| `{{/problems/out-of-stock}}` | {{An item is out of stock}} | {{422}} | {{...}} | {{`productId`}} |
| `{{/problems/idempotency-mismatch}}` | {{This key was used for a different request}} | 422 | {{same key, different body}} | none |
| `{{/problems/idempotency-key-missing}}` | {{Idempotency-Key is required}} | 400 | {{mutation sent without its key}} | none |
| `{{/problems/idempotency-in-flight}}` | {{This request is still being processed}} | 409 | {{same key, first request not finished}} | none |
| `{{/problems/invalid-transition}}` | {{This order can't do that now}} | 409 | {{SM transition not allowed from the current state}} | {{`from`, `event`}} |
| `{{/problems/unauthenticated}}` | {{Please sign in}} | 401 | {{no valid session}} | none |
| `{{/problems/pending}}` | {{We're still checking this}} | {{504}} | {{outbound call timed out; status unknown (FM-1)}} | none |

### Idempotency

- **Mutations a client can repeat:** {{EP-1 (double submit, network retry)}} → {{`Idempotency-Key` header (JSON clients) \| hidden `idempotency_key` form field minted on the GET that renders the form (HTML form posts)}}, scoped to {{customer}}, stored in {{table}} with a request fingerprint and the response, kept {{24 h}}.
- **Replays:** same key + same body → stored response; same key + different body → 422 `/problems/idempotency-mismatch`; same key still processing → 409 `/problems/idempotency-in-flight`; key missing → 400 `/problems/idempotency-key-missing`.
- **Safe without a key:** {{EP ids + why (GET; PUT/DELETE are idempotent; natural unique key `uq_...`)}}

### Pagination

- {{cursor \| offset}} ({{D<n> or reason}}) · default {{25}}, max {{100}} · order {{created_at DESC, id DESC}} (unique tie-breaker) · response carries {{`next_cursor`, null on the last page}}

## 5. Core journeys

<!-- guide: one `### SEQ-n` per core journey: every P1 user story and every docs/design/flows.md flow this milestone
     ships. Participants must exist in HLD §2/§3 or this file (actors, FE-n, BE-n, tables/DB, external systems).
     Messages are numbered and ordered: `n. From → To: message (EP-n | BE-n.method)`; append `(async)` for
     fire-and-forget. Mark `[tx begin]` / `[tx commit]` and the idempotency check. Every journey has at least one
     `**alt <condition>**` error branch naming the problem type and what the user sees. draw-diagrams draws only
     what is written here. -->

### SEQ-1 {{Place an order}} · `sequence-{{place-order}}` · covers {{US-1, FR-002, AE-001}}

<!-- diagram: sequence-{{place-order}} -->

- **Trigger:** {{clinician presses "Place order" on screen X}}
- **Participants:** {{Clinician (actor)}}, {{FE-2 OrderPage}}, {{BE-2 OrderController}}, {{BE-1 OrderService}}, {{DB}}
- **Preconditions:** {{signed in; cart has ≥ 1 line}}

1. {{Clinician → FE-2: presses Place order}}
2. {{FE-2 → BE-2: POST /orders with Idempotency-Key (EP-1)}}
3. {{BE-2 → BE-1: placeOrder(data, key)}}
4. {{BE-1 → DB: look up idempotency key — none found}}
5. {{BE-1 → DB: [tx begin] insert order + lines; [tx commit]}}
6. {{BE-2 → FE-2: 201 Order}}
7. {{FE-2 → Clinician: shows confirmation (screen state "success")}}

**alt {{an item is out of stock}}** (replaces steps {{5-7}})

- a1. {{BE-1 → DB: [tx rollback]}}
- a2. {{BE-2 → FE-2: 422 `/problems/out-of-stock`}}
- a3. {{FE-2 → Clinician: shows "An item is out of stock" with the item named}}

- **Postconditions:** {{one `orders` row in `placed`; no duplicate on retry}}
- **Invariants touched:** {{INV-1}}

## 6. State machines

<!-- guide: one `### SM-n` per table with a status/state column. States = exactly the CHECK constraint values in §1.
     Every transition names its trigger (EP-n / BE-n.method / scheduler), guard, side effects and the error when it
     is illegal. No transition leaves a terminal state. n/a — <reason> only when no entity has a lifecycle. -->

### SM-1 {{Order lifecycle}} · `{{orders}}.{{status}}` · `state-{{order}}`

<!-- diagram: state-{{order}} -->

- **Initial:** `{{draft}}` · **Terminal:** `{{paid}}`, `{{cancelled}}` · **Stored in:** CHECK `{{ck_orders_status}}`
- **Enforced in:** {{BE-1.transition}} with a conditional update (only from the expected current state), so two racing requests cannot both win

| State | Meaning |
|---|---|
| `{{draft}}` | {{lines can change}} |
| `{{placed}}` | {{submitted, awaiting payment}} |

| From | Event (trigger) | Guard | To | Side effects | If illegal |
|---|---|---|---|---|---|
| `{{draft}}` | {{place (EP-1 → BE-1.placeOrder)}} | {{≥ 1 line; all in stock}} | `{{placed}}` | {{reserve stock; audit row}} | {{409 `/problems/invalid-transition`}} |

## 7. Invariants → enforcement

<!-- guide: every HLD INV-n (plain id) plus every invariant found while designing (bold **LINV-n**, flagged for G3:
     the HLD may need to catch up via design-hld). Primary enforcer is exact: a constraint name, a transaction in a
     named method, a lock, a policy. Strongest first: DB constraint > transaction/lock > code + test > code alone. -->

| Id | Invariant (always true) | Primary enforcer (exact) | Backup layer | Proven by | Basis |
|---|---|---|---|---|---|
| {{INV-1}} | {{an order is charged at most once}} | {{`uq_orders_idempotency` UNIQUE}} | {{BE-1.placeOrder key check}} | {{feature test against the real DB engine; AE-00n}} | HLD §7 |
| **{{LINV-1}}** | {{found while designing}} | {{...}} | {{...}} | {{...}} | {{new in LLD — confirm at G3}} |

## 8. Error handling & failure modes

<!-- guide: one FM row per outbound call (each HLD L-n we initiate) and per multi-step write. Retry only idempotent
     operations, with backoff + jitter and a cap. Never log secrets or PHI. -->

### Error policy

- **User sees:** {{problem title + a recovery action; never stack traces, SQL or internal ids}}
- **Logged:** {{problem type, correlation id, cause, actor id; never secrets/PHI}}
- **Correlation id:** {{header name; generated at the edge; echoed in problem `instance`}}
- **Unexpected errors:** {{500 with a generic problem type and the correlation id}}
- **Validation:** {{where it runs (e.g. request objects) and its 422 `errors[]` shape}}

### Failure modes

| Id | Failure | Where | Detection | Timeout / retry | User sees | Data left | Alert / log |
|---|---|---|---|---|---|---|---|
| **{{FM-1}}** | {{external API timeout}} | {{L-3 / BE-n adapter}} | {{timeout 10 s}} | {{no blind retry (not idempotent); query status by key}} | {{`/problems/pending` → "We're checking..."}} | {{order stays `placed`; reconciled by ...}} | {{warn log + metric}} |

## 9. Test seams

<!-- guide: a seam is a place where a test can swap behaviour without editing the code under test. One row per
     nondeterministic or external dependency: clock, ids/randomness, outbound HTTP, payment, mail/notifications,
     queue, auth/session, filesystem. Name how it is swapped in THIS stack. -->

| Id | Seam (what varies) | Real implementation | Fake in tests | Swapped where | Test levels |
|---|---|---|---|---|---|
| **{{SEAM-1}}** | {{clock}} | {{system clock}} | {{frozen clock}} | {{framework time helper / DI binding}} | {{unit, feature}} |
| **{{SEAM-2}}** | {{external API (BE-n adapter)}} | {{HTTP client}} | {{recorded fake responses}} | {{container binding of the BE-n adapter}} | {{feature, acceptance}} |

**Never faked:** {{the database engine in constraint and transaction tests (same engine as production)}}; {{the component under test}}; {{...}}

## 10. Diagram requests

<!-- guide: one row per diagram placeholder above, in document order: erd, be-class, fe-components (only if §3 has a
     UI), one sequence-<slug> per SEQ, one state-<entity> per SM. draw-diagrams renders each job to
     docs/architecture/diagrams/<type>.mmd; the supervisor's scripts/embed-diagrams.sh embeds it at the placeholder.
     "Draw from" is the job's [source] argument and must resolve to exactly one heading: the anchor of a numbered
     section, or the heading text after `### ` through the title for a SEQ/SM (a bare "SEQ-1" also matches SEQ-10).
     draw-diagrams draws only what that section says; missing from the section = missing from the diagram. -->

| Job | Draw from | Must show | Placeholder in |
|---|---|---|---|
| `draw-diagrams erd` | `docs/architecture/lld.md#1-data-model` | every table; PK/FK columns; cardinality from Relationships | §1 |
| `draw-diagrams be-class` | `docs/architecture/lld.md#2-backend-components` | every BE id with its public methods; dependency arrows | §2 |
| `draw-diagrams fe-components` | `docs/architecture/lld.md#3-frontend-components` | the component tree; each node's owned state; props/events arrows | §3 |
| `draw-diagrams sequence-{{place-order}}` | `docs/architecture/lld.md#SEQ-{{1 Place an order}}` | participants and messages in order; every alt branch | §5 SEQ-{{1}} |
| `draw-diagrams state-{{order}}` | `docs/architecture/lld.md#SM-{{1 Order lifecycle}}` | every state; transitions labelled event [guard]; terminal states | §6 SM-{{1}} |

## Decisions

<!-- guide: one D<n> per low-level choice NOT already fixed by the HLD or an accepted journal row (id type, soft vs
     hard delete, pagination style, where shared state lives, sync vs queued side effect). D<n> continues the
     journal's numbering (highest D<n> in the journal or hld.md §9, plus 1). Always "Do nothing / simplest" plus
     at least two real options, one of them your first proposal (WORKFLOW §5). Status stays proposed here;
     log-decision records acceptance. -->

### D{{n}} {{Title}}  [status: proposed]

- **Question:** {{the choice in one line}}
- **Forces:** {{FR / NFR / INV / C ids}}
- **Reversibility:** {{Type 1 one-way \| Type 2 two-way}} · **Confidence:** {{low \| med \| high}}

| Option | Pros | Cons | Cost (build + run) | Basis |
|---|---|---|---|---|
| Do nothing / simplest: {{...}} | {{...}} | {{...}} | {{...}} | {{...}} |
| {{Option A}} | {{...}} | {{...}} | {{...}} | {{...}} |
| {{Option B}} | {{...}} | {{...}} | {{...}} | {{...}} |

- **Recommendation:** {{option}}
- **Why (Y-statement):** In the context of {{C}}, facing {{F}}, we choose {{X}} over {{Y}} to get {{Z}}, accepting {{W}}.
- **In plain words:** {{one sentence a beginner can follow}}
- **First proposal (instead of):** {{the option reached for first and why it lost}} | same as recommendation
- **Revisit if:** {{observable trigger}}
- **Interview line:** "{{one sentence you would say out loud}}"
- **Default if you don't answer:** stays proposed; nothing downstream may build on it.

## Open questions

<!-- guide: every ⚠ anywhere in this file appears here. "HLD conflict" questions block G3 and route to design-hld.
     A question whose answer adds or changes observable product behaviour says Who answers = clarify-spec on
     docs/product/prd.md (define-acceptance tests only what the PRD says). Answered in this run: keep the row, replace
     ⚠ with ✓ and put the human's exact words in "Recommended answer", plus "PRD follow-up: clarify-spec" if it
     changes behaviour. -->

| Id | ⚠ Question | Blocks | Recommended answer | Who answers |
|---|---|---|---|---|
| **{{Q-1}}** | ⚠ {{question}} | {{table / EP / ST / SM id}} | {{answer + why}} | {{human / partner / design-hld}} |

## Change log

| Date | Change | Ids affected | Approval |
|---|---|---|---|
| {{`date`}} | {{First draft \| delta for M<N> \| revise per G3 row <time>}} | {{all \| ids}} | pending G3 |
