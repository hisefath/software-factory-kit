# design-hld question bank

Load at Step 4. Ask only what the PRD, brief, research, UX docs, audit and `AGENTS.md` do not already answer — if
they do, cite where (`prd.md` NFR-002, `brief.md:14`) instead of asking. Pick the highest-impact unanswered
questions, at most 5 per pass, one per reply. Recommended answers below are pilot-sized defaults; replace them with
a better one when the inputs point elsewhere, and always say *why* you recommend it.

Reply shape (one question per reply):

```
Q<k> of <≤5> — <question>
Why it matters: <one or two plain sentences: which section/number/decision changes with the answer>
Recommended: <answer> — because <basis: FR/NFR id, evidence, or "pilot default">
If you don't know: I'll use the recommendation, write it as `<value> (assumed, ⚠ Q-n)`, and list it in §13.
```

## Ranked by how much of the design moves

| # | Question | Why it matters (plain words) | Recommended answer (pilot default) | Feeds |
|---|---|---|---|---|
| 1 | For each role (e.g. providers, patients, ops): how many at launch and at 12 months, how often does each do the core action, and when are they busiest? | The usage model: every number in the scale budget and cost projection derives from it, so the numbers agree with each other. Most over-engineering comes from imagined scale. | Derive from the PRD personas and success criteria; else ≤ 100 users at launch and 1K at 12 months, split by role as the PRD's journeys imply, busiest in local business hours. | §8, §12 |
| 2 | If it is down for an hour on a weekday, what happens to the people using it? | Each extra "nine" of availability roughly multiplies cost and complexity. | 99.5 % (≈ 3.6 h/month) unless downtime blocks money or a clinical/safety workflow; then 99.9 %. | §6, §8, D<n> on redundancy |
| 3 | Which outside system is the source of truth for each important thing (people, products, payments, records), and what should we do when it is down? | Decides what we store vs fetch, where the sync/async lines go, and what the user sees on failure. | The external system stays the source of truth; we keep references (ids), not copies; degrade to read-only or "try again" with a clear message. | §2, §4, §7 |
| 4 | What is the most sensitive data that passes through or is stored, and must any of it never leave its source system? | Sets trust boundaries, encryption, logging bans and hosting limits. Regulated data (PHI/PII/card data) changes the design more than any feature. | Store the minimum; never store card data (use the payment provider); keep regulated data in its source system and reference it by id. | §5, §10, §11 |
| 5 | Where must this run, and who pays for the hosting? | Picks the deployment view and the cost baseline. A host named in a PRD `C-n` or AGENTS.md "Project specifics" is a given, not a decision: cite it and skip this question. | The host `AGENTS.md` or the PRD Constraints name; else one managed platform-as-a-service region. | §11, §12, D<n> hosting (only if not given) |
| 6 | What monthly running cost would make you switch it off? | Gives the cost ceiling that rejects expensive options early. | The appetite in the brief; else $50/month for a pilot. | §8, §12, every D<n> cost column |
| 7 | How much recent data could you afford to lose, and how long could a restore take? | RPO/RTO decide backups vs replication. | RPO 24 h (daily managed backups), RTO 4 h for a pilot; money events rely on the payment provider as the ledger (RPO ≈ 0 there). | §8, §11 |
| 8 | Must the user wait for <slow step> to finish, or can it finish in the background? | Background work adds a queue + worker container and duplicate/ordering problems. Waiting adds latency. | Wait (synchronous) unless the step regularly exceeds the latency budget or calls an unreliable partner. | §3, §4, D<n> sync vs async |
| 9 | Does one deployment serve several organizations, and must their data be strictly separated? | Decides tenancy model and an authorization invariant. | One deployment, one database, every row scoped to its organization, enforced by an invariant + test; separate databases only if a contract demands it. | §7, §10, D<n> tenancy |
| 10 | Who must be able to see who did what, and for how long? | Audit trails are an invariant plus a storage/retention cost. | Record who/what/when for money and permission changes; keep for the legally required period, else 1 year. | §7, §10 |

## After the pass

- Write each answer into the section it feeds, with the human's words as the source in the `WHY:` line or Basis.
- Unanswered → the recommended answer, written `<value> (assumed, ⚠ Q-n)`, plus that `Q-n` row in §13.
- Never ask about tables, endpoints or class design — those are design-lld questions.
