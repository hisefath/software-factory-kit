# design-lld rules and interview angles

Load the section a step names. Each rule is a default; breaking one needs a reason in the row's Notes/Basis or a
`D<n>`. An approved HLD choice or accepted journal D row beats any default here: keep it, cite it, and raise the
risk it carries as a Q-n or LINV-n. Each section ends with the questions an interviewer is most likely to ask, so the human can rehearse them
at G3. Examples use a generic clinic store; they are patterns, not requirements. Follow the stack's own conventions
from `AGENTS.md` wherever they are stricter.

## Data model

- **One table per entity noun** the HLD says a container owns (`CN-n` "data owned"). Names follow the framework
  convention (e.g. plural snake_case). A join table `a_b` for every N—M, with a composite unique key on its two FKs.
- **Every column states type, null, default, constraint.** Null is "no" by default; a nullable column says why
  (unknown at creation, optional by FR, expand step of a migration).
- **Primary key:** a surrogate id. Auto-increment integers are small and fast but guessable and leak volume; UUID v7 /
  ULID are unguessable and sortable but larger. If the framework convention does not settle it, it is a `D<n>`.
- **Natural keys get UNIQUE** (SKU, email per tenant, external id from a partner system).
- **Foreign keys name their ON DELETE rule.** RESTRICT by default (history must not vanish); CASCADE only for
  children that mean nothing without the parent (order lines); SET NULL only on a nullable column.
- **Index** every FK column and every filter/sort a §4 endpoint or §5 journey performs. Composite order: equality
  columns first, then the range or sort column. An index you cannot tie to a query is a cost with no reader.
- **CHECK constraints** for enums (status values), ranges (`quantity > 0`), non-negative money. Note engine support
  (e.g. MySQL enforces CHECK only from 8.0.16; MySQL has no partial indexes, PostgreSQL does).
- **Money** is integer minor units + an ISO 4217 currency column, unless the PRD fixes a single currency (then no
  column; cite that PRD assumption id in Notes). Never floats: 0.1 + 0.2 ≠ 0.3 in binary floating point.
- **Time** is stored in UTC; the display time zone is a presentation concern (HLD §10).
- **Snapshot what can change:** an order line copies the product name and unit price at purchase time; a later price
  change must not rewrite history.
- **Soft delete only with a reason** (audit, legal retention). It forces every unique index and every query to
  account for deleted rows.
- **Sensitive columns** (PII/PHI) are listed per table; the HLD decides where they may flow, the LLD shows where they
  sit.
- **Enforcement ladder** for every invariant: DB constraint > transaction or row lock > code + test > code alone.
  Pick the highest rung the engine supports and write down which.

Interview angles: Why this primary key type? What stops two orders with the same idempotency key? What happens to
orders when a product is deleted? Which query does this index serve? Why integer cents?

## Backend components

- **One responsibility sentence without "and".** Two responsibilities = two components.
- **Layering follows the framework** (e.g. Laravel: route → controller → action/service → Eloquent model;
  validation in Form Requests; authorization in Policies). Controllers translate HTTP, services hold rules, models
  hold persistence.
- **Public methods only:** full signature in the project language (parameter types, return type) plus the problem
  types it can raise. Behaviour is described by the §5 sequence, never by a body.
- **Dependencies are named collaborators** (BE ids, framework services). Every external system is reached through
  exactly one adapter component; that adapter is the §9 seam.
- **Table ownership:** each table has one owning (writing) component; a second writer needs a reason.
- **Transaction boundary:** name the method that opens it and what it covers. Side effects that must survive a
  rollback (emails, partner calls) happen after commit, ideally via a queued job or an outbox row.
- **No speculative abstraction:** no interface with one implementation unless it is a seam; no base class for one
  child; no config for a value that never changes.

Interview angles: Why is this logic in a service, not the controller or model? Where is the transaction, and what
happens if the partner call fails after commit? How do you test this without the partner?

## Frontend components and state ownership

- **Tree from `docs/design/screens.md`:** one node per screen, plus a component wherever there is reuse or owned
  state. Every screen state (loading, empty, error, success, permission denied) maps to a rendering component.
- **Props in, events out.** Children never mutate parent state directly; they emit an event the owner handles.
- **Classify every piece of state first:**

| Kind | Examples | Owner | How passed |
|---|---|---|---|
| Server state | orders, catalog, cart stored in the DB | the server; the client holds a cache | fetched by the lowest component that needs it, then props; invalidated after mutations |
| URL state | filters, sort, page cursor, selected tab | the URL | read from the query string; survives reload and sharing |
| Local UI state | modal open, input draft, hover | the lowest component that uses it | none (local) |
| Shared client state | multi-step form in progress, selected patient across panels | the lowest common ancestor of its consumers | lifted + props; context only when drilling ≥ 3 levels; a store only for unrelated subtrees, with a `D<n>` |

- **Never copy server state into a client store**: two copies drift. Re-fetch or invalidate instead.
- **Persisted?** none / URL / browser storage / server. Browser storage never holds PHI or tokens.
- **Server-rendered UIs** (Blade, Livewire, Inertia, Rails views) use the same table: "How passed" is `server` when
  the controller renders it, and component properties count as local state.
- **Data fetching rows** say who fetches which EP, when (mount, event, interval), what invalidates it, and which
  screen state shows during loading, empty and error.

Interview angles: Who owns the cart, and why not a global store? What happens to the filter on reload? How does the
list know a new order was placed?

## API

- **Resources are plural nouns;** actions that are not CRUD are sub-resources (`POST /orders/{id}/cancel`).
- **Method semantics (RFC 9110):** GET/HEAD safe; PUT and DELETE idempotent; POST is neither.
- **Errors are RFC 9457 problem details** (`application/problem+json`; obsoletes RFC 7807): `type` (URI reference
  naming the problem, default `about:blank`), `title`, `status`, `detail`, `instance`, plus extension members.
  Validation failures list each field in `errors[]` with a JSON `pointer` and a `detail`. One problem-type registry in
  §4, and `type` is always the full registry path `/problems/<slug>`; never leak stack traces, SQL or internal ids. HTML form routes show the same problem type as a screen state, so
  the web UI and JSON clients share one error vocabulary.
- **Status codes:** 400 malformed · 401 not signed in · 403 signed in but not allowed · 404 not found (also for
  "exists but not yours" when existence itself is sensitive) · 409 conflict (illegal state transition, version
  clash, key in flight) · 412 precondition failed (`If-Match` mismatch) · 422 validation, and a business rule
  rejecting a well-formed request (out of stock, idempotency key reused with a different body) · 429 rate limited.
  Only the validation problem carries `errors[]`, so the contract's 422 is `anyOf [ValidationProblem, Problem]`.
- **Idempotency:** every mutation a client can repeat (double submit, network retry, webhook redelivery) needs a
  key: an `Idempotency-Key` header for JSON clients (IETF httpapi draft "The Idempotency-Key HTTP Header Field"); for
  HTML form posts, which cannot set headers, a hidden form field minted on the GET that renders the form; or a
  natural unique key. Store key + request fingerprint + response; same key + same body → replay; same key +
  different body → 422; same key still processing → 409; missing key where required → 400.
- **Pagination:** every list has a max page size. Cursor (opaque, keyed on a unique sort such as
  `created_at, id`) stays correct while rows are inserted and stays fast deep into the list; offset is fine for small
  admin lists but skips or repeats rows under inserts.
- **Concurrent edits:** where two people can edit the same row, use a version column or ETag + `If-Match` (412 on
  mismatch) instead of last-write-wins.
- **Auth per endpoint:** the scheme from HLD §10 plus the exact permission/policy; default deny.
- **Versioning:** none until a second consumer exists, unless the HLD says otherwise.
- **OpenAPI 3.1** uses JSON Schema 2020-12 (`type: [string, "null"]`, `examples`), supports top-level `webhooks` for
  inbound partner calls, and allows `x-` extensions such as `x-lld-id`.

Interview angles: What happens if the client retries POST /orders after a timeout? Why 409 and not 422 here? Why
cursor pagination? What does a client see when validation fails?

## Sequences

- **Participants** are things that already exist: actors and external systems (HLD §2), FE-n, BE-n, the database.
  A participant that exists nowhere means a missing component; add it to §2/§3 or raise a Q-n.
- **Messages** are numbered: `n. From → To: message (EP-n | BE-n.method)`. Mark `[tx begin]`, `[tx commit]`,
  `[tx rollback]`, the idempotency check, and `(async)` for queued work.
- **Every journey has ≥ 1 `**alt <condition>**` branch**: the most likely failure (validation, out of stock, partner
  down, not authorised). Each branch ends at what the user sees and which problem type caused it.
- Postconditions say which rows exist and which state was reached; "Invariants touched" names INV ids.

Interview angles: Walk me through placing an order. Where does it fail, and what is left in the database when it
does?

## State machines

- **A status column means a state machine.** States = exactly the CHECK constraint values.
- **Transitions** name the trigger (EP-n, BE-n.method, scheduler), guard, side effects and the error when illegal.
  Nothing leaves a terminal state.
- **One place enforces transitions**, with a conditional update ("change to `paid` only where the status is still
  `placed`" and check the affected-row count), so two racing requests cannot both succeed.

Interview angles: Can a cancelled order be paid? What stops two webhooks from marking it paid twice?

## Failure modes

- One row per outbound call and per multi-step write: timeout value, detection, retry policy (only idempotent
  operations; exponential backoff + jitter; capped attempts), what the user sees, what data is left, and the
  alert or log line.
- Prefer leaving data in a known intermediate state that a reconcile step can finish over a half-written mess.
- Never log secrets, tokens or PHI; log the correlation id instead.

Interview angles: The partner API times out after you charged the card; what happens? How would you find out in
production?

## Test seams

- A **seam** (Michael Feathers, *Working Effectively with Legacy Code*) is a place where a test can change behaviour
  without editing the code under test. List one per nondeterministic or external dependency: clock, ids/randomness,
  outbound HTTP, payments, mail/notifications, queue, auth/session, filesystem, feature flags.
- Name the swap mechanism of this stack (container binding, framework fake, env var) and the test levels using it.
- **Never fake** the database engine in constraint/transaction tests (SQLite-in-memory does not enforce what
  MySQL/PostgreSQL enforce), nor the component under test. If the HLD makes another engine the default test run,
  keep that default and add a SEAM row naming the production-engine run that covers constraint and transaction
  tests.

Interview angles: How do you test the out-of-stock branch? Why not SQLite in tests?

## Change plan (brownfield)

- **Expand → migrate → contract:** add the new shape alongside the old, move data and readers, remove the old shape
  in a later release. Each step deploys and rolls back alone.
- **Characterisation tests** pin today's behaviour of untested code before it changes.
- **Deployed / in-flight / designed** shows what production runs, what other branches are changing, and what this
  design adds; overlap between in-flight and designed is an architecture conflict to raise at G3.
- **Must not change** lists public routes, response fields, columns other systems read, and behaviours users rely
  on, each with `file:line`; slice-tasks turns them into each task's `## Must not change`.

Interview angles: How do you roll this back after the migration ran? What breaks for an old client?
