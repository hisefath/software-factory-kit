# design-hld section guide

Load at Step 5. How to fill each section of `assets/template.md` well, what reviewers reject, and the words to use
when teaching the human. The running example is a made-up small online bookshop; it shows the *shape* of good
content — never copy its values into a real HLD.

## Altitude check (use on every row)

| HLD (here) | LLD (design-lld) |
|---|---|
| "The app owns orders and payments." | The `orders` table and its columns. |
| "App → payment provider, HTTPS, sync, API key, payment intent." | The endpoint path, request and response fields. |
| "An order is charged at most once — enforced by a uniqueness rule on the provider's payment reference." | The exact constraint, index or migration. |
| "Background worker sends emails." | The job class, its methods, its retry config. |

If a sentence would change when someone renames a column or a function, it is too low for the HLD.

## §1 Context & goals

- A **driver** is a requirement that would change a box or an arrow if it vanished. Test each FR/NFR: "If this were
  deleted, would §3 or §4 change?" No → not a driver; leave it out.
- **Givens vs decisions:** a stack, host or vendor named in a PRD `C-n` row or in AGENTS.md "Project specifics", and
  every decision the journal already marks accepted, is a given. Record it in the §1 givens table with its source
  (`C-1`, `AGENTS.md:58`, `D2`) and never argue it again as a new D<n>. Only what the givens leave open (which queue
  driver, cache or not, sync or async) can become a D<n>, and only if it passes the §9 threshold.
- Teach: "Architecture is the set of choices that are expensive to change later. Drivers tell us which ones matter."

## §2 System context (C4 level 1)

- Our system is exactly one box. Everything else is a person or an external system.
- Check for the usual forgotten ones: admins/operators, identity provider, payment provider, email/SMS provider,
  a host platform that embeds us, monitoring/error tracking.
- Example row: `Payment provider | external system | we create a payment and receive a confirmation webhook |
  payment intent, payment status | vendor | FR-004`.
- **Stubs:** an external system that this slice fakes inside our app (a payment or email stub) is still an external
  system here, named with `(stub)`, e.g. `Payment provider (stub)`. The real integration is where the design is
  heading; hiding it makes the 10× and cost analysis lie.
- **Host platform:** give the host (e.g. a PaaS) a row only for a real interaction: it deploys us, injects
  secrets, or receives our logs. Do not add arrows just so the host appears in the picture.

## §3 Containers (C4 level 2)

- **C4 container = runtime boundary:** something that runs separately or stores data separately (web app, API,
  worker, database, queue, cache, object store). Not a Docker container, not a code module. Two code modules inside
  one deployed app are one container.
- **Scheduled runs:** a scheduled run of the app image as its own process or service (a cron service on the host, a
  separate worker deployment) is a separate container: it starts, fails and is paid for on its own. A scheduler
  inside the running app process is not; it belongs to that app's row.
- **Simplest first:** the baseline for most products is one app + one database. Add a container only when a driver
  demands it, and put that driver id in Basis. Each extra container is one more thing to deploy, secure, monitor and
  pay for — say so at the gate.
- **Data owned** is nouns. One container owns each kind of data; two containers writing the same data is a design
  smell — name it in §13 if unavoidable.
- **Scaling unit:** what you add when load grows ("another stateless app instance", "a bigger database machine",
  "more worker processes"). Stateful containers usually scale vertically first.
- Bad row: `CN-3 | Microservice for books | Go + gRPC | ...` with no driver. Good row: `CN-2 | Worker | <stack's
  queue worker> | sends order emails off the request path | none (reads orders) | worker processes | NFR-001 p95
  checkout ≤ 2 s; email provider p95 1.5 s (R02)`.

## §4 Connections

- One row per arrow in the diagram. Include actor → app and app → external rows, not just internal ones.
- **Sync** = the caller waits ("place order and wait for confirmation"). **Async** = the caller drops a message and
  continues ("queue an email"). Async buys speed and resilience but costs a queue, retries, duplicates and
  out-of-order delivery — so async rows usually create an idempotency entry in §10 and an invariant in §7.
- **On failure** is mandatory: timeout, retry (how many, backoff), and what the user sees. "Retry forever" and
  "unspecified" are rejected.
- **Stub connections:** the row exists (the arrow is real in the design). Protocol = `in-process (stub)`; add the
  real protocol as `later: HTTPS …`. On failure describes both the stub's simulated failure and the later real one.

## §5 Trust boundaries & threats

- A **trust boundary** is where data crosses between parties with different privileges or owners: browser → app,
  partner platform → app, app → third party, app → database, normal user → admin.
- For each boundary walk STRIDE in plain words:

| Letter | Means | Plain question |
|---|---|---|
| S | Spoofing | Can someone pretend to be another user or system here? |
| T | Tampering | Can someone change data in transit or at rest here? |
| R | Repudiation | Could someone deny doing something because we cannot prove it? |
| I | Information disclosure | Could data leak to someone who should not see it? |
| D | Denial of service | Could someone or something overload or block this path? |
| E | Elevation of privilege | Could someone get more power than they were given? |

- Mitigations stay design-level ("verify the provider's webhook signature before trusting it"), not code. Use the
  audit (`AUDIT.md`) and security NFRs as Basis. Every boundary gets at least one threat; an empty row means you did
  not look.

## §6 Quality-attribute scenarios

- Format (SEI): **source** (who/what) → **stimulus** (the event) → **environment** (normal, peak, degraded) →
  **response** (what the system does) → **measure** (number + unit). Example: `QA-1 | NFR-001 | performance | a
  shopper | submits checkout | peak, 7 req/s | order confirmed on screen | p95 ≤ 2 s; 0 duplicate charges`.
- Include one **degraded** scenario per real (non-stub) external system ("payment provider times out") and one
  for the host platform ("the host restarts the app mid-request"). A stub gets a degraded scenario only when the
  PRD asks for simulated failure.
- A measure without a number is a wish. If the PRD has no number, add a `Q-n` with a recommended one.

## §7 Invariants

- An invariant is something that must be true after every operation: "stock never goes below zero", "an order total
  equals the sum of its lines", "a user only ever sees their own organization's records", "money is never a float".
- **Enforcer ladder** (strongest first): DB constraint (the database refuses bad data no matter which code path) >
  transaction (several changes succeed or fail together) > code + test (a check in one place, proven by a test) >
  code alone (one forgotten path breaks it). Money, auth and tenancy invariants never rely on code alone.
- Teach: "Invariants are what I'd write on the whiteboard first in an interview — they show what can't go wrong."

## §8 Scale budget

- **Usage model first:** one entry per role: `role × count at 12 months × core actions per day` (e.g. `providers
  100 × 2 orders/day; patients 900 × 1 link opened per order`). Every other number derives from it, which stops the
  budget contradicting itself. Two checks before moving on:
  - daily records ≤ DAU × actions per user per day;
  - DAU ≥ the distinct people the core actions need each day. 200 orders/day that each need a patient to open a
    link means at least 200 patient-days, not a 10 % guess.
- **Assumptions:** write an agent assumption as `<value> (assumed, ⚠ Q-n)` with its §13 row. A bare `assumed`
  without a Q-n hides the question from the gate.
- Every number has a `WHY:` derivation a reader can redo with a calculator:
  - Request rate: `1,000 DAU × 20 requests/day ÷ 28,800 business seconds ≈ 0.7 req/s; × 10 peak factor ≈ 7 req/s`.
  - Availability: `99.5 % of a 30-day month (43,200 min) allows 216 min ≈ 3.6 h of downtime`.
  - Data: `200 orders/day × 365 ≈ 73K orders/year × ~2 KB ≈ 150 MB/year`.
  - Latency: split the budget per hop so each container knows its share.
- **What breaks first at 10×:** multiply the budget by 10 and find the first component whose limit is crossed —
  usually database connections, a partner's rate limit, a single worker, or memory on one instance. State the number
  that breaks.
- **How you'd know in prod:** for each breaking point, the metric or log line, the threshold, and where it is
  watched. If you cannot name a signal, add it as a §10 observability need.

## §9 Key decisions

- **Threshold:** a choice that is not a §1 given becomes a D<n> only if it changes a §3 box, a §4 line or a §7
  enforcer, or costs ≥ 1 build-day or ≥ $5/month. Typical D<n>: database engine (if not given), hosting (if not
  given), sync vs async for a step, caching, tenancy model, auth approach, integration pattern (poll vs webhook).
  Anything smaller (how often a check runs, a log format, a library) is a §10/§11 row with a one-line why. Every
  D<n> is a gate turn the human must spend; spend them on what is expensive to change.
- **Parked ideas:** a brief `## Parking lot` `P-##` that names a technology or pattern appears as an option in its
  D<n>, usually the first proposal, citing `P-##`. If you reject it, the human sees why.
- **Options:** always "Do nothing / simplest" (the cheapest thing that could work, or not building it now) and your
  first instinct; at least one real alternative. Each option: pros, cons, cost (build effort + monthly run), Basis.
- **Type 1 vs Type 2** (Bezos): one-way doors (data store, tenancy, public contract) deserve more evidence; two-way
  doors (a library, a cache) can be decided fast and changed later. Say which, in plain words.
- **Y-statement:** "In the context of C, facing F, we choose X over Y to get Z, accepting W." This is copied by
  log-decision into the journal, so make it complete.
- Avoid résumé-driven design: an option that looks impressive but no driver needs is a con, not a pro.
- Teach at the gate: explain each option as "what you get, what you pay, when you'd regret it".

## §10 Cross-cutting concerns

- **Idempotency:** list every operation that can arrive twice (user double-click, client retry, webhook
  redelivery, queue redelivery) and how the duplicate is absorbed (an idempotency key checked against an invariant).
- **Time:** store UTC, convert at display; name whose clock is trusted.
- **Money:** integer minor units (cents) plus a currency code; one place computes totals; name the rounding rule;
  the payment provider is usually the source of truth for whether money moved.
- **Sensitive data:** where each class lives, which boundary it never crosses, what is never logged, retention.

## §11 Deployment view

- Every environment (local, CI, staging, production) with what runs where. "No staging — reason" is allowed for a
  pilot; say what replaces it (preview deploys, feature flags).
- Secrets: the *source* per environment (platform secret store, `.env` gitignored), never values.

## §12 Cost projection

- Derive from unit prices × quantities from §8. Cite prices (R/S ids or "pricing page checked <date>"); otherwise
  `⚠ estimate (Q-n)`, with one Q-n row asking for the price evidence.
- The last column is the teaching point: what has to change at each tier ("none", "second app instance + managed
  DB backups", "read replica + CDN", "queue + autoscaled workers"). 100K users with no change listed means you did
  not do the 10× analysis.

## §13 Risks & open questions

- **Risk** = something that might go wrong even if we build it as designed (partner rate limits, vendor lock-in, a
  single point of failure). **Open question** = something we do not know yet (`⚠`).
- Every inline `⚠` names its `Q-n` (`⚠ Q-3`, `⚠ estimate (Q-3)`); the `Q-n` row's Question cell starts with `⚠`
  while it is open. clarify-spec closes the row in place, so the open count is the Q rows that still hold `⚠`.
- A gap in the PRD's scope (a missing requirement, an unclear rule) is not yours to fill: its Q-n row says
  "Who answers: `clarify-spec docs/product/prd.md`" (or a write-prd Revise plus a G1 re-approval).

## §14 Diagram requests

- Keep the three jobs, their "Draw from" anchors and the placeholder lines. draw-diagrams writes
  `docs/architecture/diagrams/<type>.mmd`; the supervisor embeds it under the placeholder with
  `scripts/embed-diagrams.sh`. Each placeholder line appears exactly once in the file: writing it a second time
  (even inside a table cell) makes the diagram job stop for human review.
- If a revision changes §2, §3/§4/§5 or §11, name the job that must be re-run in the revision STOP. draw-diagrams
  invents nothing: if the diagram would look wrong, fix the section, not the diagram.

## Gate teaching checklist

The decision shape and the closing G2 question are in `references/g2-presentation.md`. When presenting each D<n>,
the human should be able to answer afterwards: what problem it solves (driver id), what
the simplest alternative was and why it lost, what it costs per month, and when we'd revisit it.
