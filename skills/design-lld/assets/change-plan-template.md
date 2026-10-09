# Change plan — {{M<N>-slug}}

<!-- guide: design-lld brownfield change plan -> specs/M<N>-<slug>/change-plan.md. Written only when the mode is
     brownfield: inherited code (WORKFLOW §3), for every milestone of that product. Never for greenfield, including
     later milestones of a product built in this workflow (those are lld.md deltas only).
     Keep every `## ` heading exactly as written and in this order. Replace every {{placeholder}} and delete every
     `<!-- guide:` comment. Unknowns become `⚠ <question>` and a Q-n row in lld.md "Open questions".
     Cite existing code as file:line. No code, no migration bodies: describe steps in words.
     This file is immutable after the milestone merges. -->

| Field | Value |
|---|---|
| Milestone | {{M<N>-slug}} |
| LLD | `docs/architecture/lld.md` @ {{short sha}} (delta rows marked (new) / (changed)) |
| Audit | `docs/audit/AUDIT.md` @ {{short sha}} (required in brownfield) |
| Base | `main` @ {{short sha}} · production runs {{short sha from MILESTONES.md / `/version`}} |
| Last updated | {{output of `date`}} |
| Approval | G3 — recorded in `.handoff/TRACKER.md ## Approvals` (never in this file) |

## Implementation approach

<!-- guide: 3-6 sentences: the shape of the change in the order it should land. Name the LLD ids it realises and the
     pattern (e.g. expand-then-contract, strangler, feature flag). Say why this order keeps main shippable. -->

{{Approach.}} Realises {{BE-n, EP-n, tables}}.

## Files likely to change

| Path | Change | Why | LLD id |
|---|---|---|---|
| `{{app/Services/OrderService.php}}` | {{modify}} | {{add placeOrder idempotency}} | {{BE-1}} |
| `{{database/migrations/<new>}}` | {{add}} | {{expand: new nullable column}} | `{{orders}}` |

## Dependencies

<!-- guide: other tasks/milestones/MRs this waits on; packages (a new or upgraded package is ask-first per AGENTS.md:
     raise it at G3); services, infra, partner sandboxes, feature flags. "none" is allowed per line. -->

- **Code / milestones:** {{M<k> merged; open MR !n}} | none
- **Packages:** {{none new}} | {{name@version — new, needs the human's yes}}
- **Services / infra:** {{...}} | none

## API changes

| Endpoint | Change | Breaking? | Consumers affected | Contract diff |
|---|---|---|---|---|
| {{EP-1}} `{{POST /orders}}` | {{new header Idempotency-Key, optional for one release}} | {{no}} | {{web client}} | {{openapi.yaml: parameters + 409/422}} |

## Data model impact and migration

<!-- guide: one row per table change. Every destructive change (drop, rename, type narrowing, NOT NULL on existing
     rows) goes through expand → migrate/backfill → contract across releases. Say whether each step locks a large
     table and how long the backfill runs at current row counts (count from the schema/DB, never memory). -->

| Table | Change | Step (expand / backfill / contract) | Reversible? | Lock / runtime risk |
|---|---|---|---|---|
| `{{orders}}` | {{add `idempotency_key` nullable + unique}} | {{expand}} | {{yes: drop column}} | {{index build on n rows}} |

- **Migration order:** {{1. expand migration · 2. deploy code that writes both · 3. backfill · 4. contract in M<N+1>}}
- **Backfill:** {{what, how batched, how verified}} | none

## Testing strategy

- **Must stay green:** {{existing test paths that cover touched code}}
- **Characterisation first:** {{untested behaviour we change gets a test that pins today's behaviour before the change}} | none needed
- **New tests by level:** {{unit: ...; feature: ...; acceptance: written by define-acceptance}}
- **Seams used:** {{SEAM ids from lld.md §9}}
- **Migration test:** {{up and down run against a copy of the production engine with representative data}}

## Backward compatibility

- **Old clients / callers:** {{what still works unchanged and for how long}}
- **Existing data:** {{rows created before this change: how they behave}}
- **In-flight work during deploy:** {{requests, queued jobs, sessions spanning the deploy}}
- **Flag / toggle:** {{name and default}} | none

## Security implications

- **Authorization:** {{new or changed checks; default deny}}
- **New input at a trust boundary:** {{TB-n: field → validation}}
- **Data exposure:** {{new PII/PHI fields in responses or logs}} | none
- **Secrets / config:** {{names only, never values}} | none
- **Audit trail:** {{what is recorded, by whom}}

## Rollout, migration risks and rollback

| Risk | Likelihood | Impact | Mitigation | Rollback step |
|---|---|---|---|---|
| {{backfill slower than the deploy window}} | {{L/M/H}} | {{L/M/H}} | {{batch + resume}} | {{stop backfill; expand column is harmless}} |

- **Rollout order:** {{...}}
- **Rollback:** {{`git revert -m 1 <merge>` of the milestone + which migration steps reverse, and which must not (data loss)}}
- **Point of no return:** {{the step after which rollback needs a data fix}} | none

## Must not change

<!-- guide: things other people, systems or data depend on. Each is a scope-guard hint for slice-tasks and a check for
     the verifier. Cite where it lives and who depends on it. -->

| What | Where (file:line) | Why (who depends on it) |
|---|---|---|
| {{public route / response field / column read by another system / behaviour users rely on}} | `{{path:line}}` | {{...}} |

## Deployed / in-flight / designed

<!-- guide: one row per element this milestone touches. Deployed = what production runs now (sha). In flight = open
     branches, MRs, `working` tasks in .handoff/TRACKER.md touching the same element. Designed = this LLD's target.
     Any "yes" in Conflict is an architecture conflict: raise it at G3. -->

| Element (table / EP / BE / FE) | Deployed (prod @ sha) | In flight (branch / MR / task) | Designed (this LLD) | Conflict? |
|---|---|---|---|---|
| `{{orders}}` | {{no idempotency column @ abc1234}} | {{none}} | {{+ idempotency_key, uq_orders_idempotency}} | {{no}} |
