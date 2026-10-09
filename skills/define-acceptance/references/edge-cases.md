# Edge-case hunting guide

Load at `define-acceptance` step 5. For **every in-scope FR**, walk all nine groups in this order. Examples use a
generic clinic supplement store: they are patterns to copy the shape of, not requirements.

Sources: groups 1-4 are the black-box techniques and group 5 the experience-based one in the ISTQB Certified Tester
Foundation Level syllabus v4.0 (2023), §4.2 and §4.4. Groups 6-9 are the factory's checklists for failure classes
that most often ship broken. Group 7 follows OWASP Top 10:2021 A01 (Broken Access Control).

## Rules for every group

- **Concrete input, always.** "quantity 11 when the limit is 10", never "too many".
- **Expected behaviour comes from an approved artifact** (FR, AE, EC, INV, LLD, `openapi.yaml`, `screens.md`) or
  from the human's verbatim answer. If none says, it is a **spec gap**: write `⚠ Q-n`, never a guess.
- **`n/a: <why>` is an answer; a blank cell is not.** "n/a: FR-004 takes no user input" is fine.
- **One cause per test.** Change one thing from a passing case, so a failure points at exactly one cause.
- **Always tested:** money, authorization, lost or duplicated data, patient or customer data, every INV-n and
  LINV-n. One left untested is marked `· BLOCKS G4` and listed first in the STOP; it is never an ordinary waiver.
- **Refusals prove the path is live.** A refusal or no-effect test makes its allowed twin succeed first, in the same
  test; otherwise it passes on a greenfield app just because the route is missing (every unknown route is a 404).

## 1. partition: Equivalence partitions

**What:** split each input into classes the system must treat the same way; one test per class is enough. Test
invalid classes one at a time.
**Ask of the FR:** what does it take in (fields, query values, the user's role, the record's state, the time)?
Which values must behave the same? Which classes are invalid?
**Example:** quantity → valid {1 … stock}, invalid {0}, {-1}, {2.5}, {"two"}, {missing}.
**Expected from:** `[Unwanted]` FRs, LLD validation rules and column types, `openapi.yaml` (`required`,
`minimum`, `maxLength`, `enum`).

## 2. boundary: Boundary values

**What:** bugs cluster at the edges of partitions (`<` written as `<=`, off by one). Use 3-value boundary analysis
for anything that touches money or limits: just below, on, just above.
**Ask:** what numeric, length, date or count limits exist, and is each one inclusive?
**Example:** max 10 bottles per order → 9, 10, 11. Name max 120 characters → 119, 120, 121. Stock 1 → order 1
succeeds, the next order of 1 is refused.
**Expected from:** FR/NFR numbers, LLD column sizes, `openapi.yaml` limits. A limit with no inclusive/exclusive
wording is a spec gap.

## 3. state: State transitions

**What:** list the states and the events. Test every valid transition once, every invalid (state, event) pair a
user can reach, and doing the same thing twice in the same state.
**Ask:** which states does the main record pass through (LLD state machine)? Which events move it? What must each
state refuse? Which states are terminal?
**Example:** order `draft → placed → paid → fulfilled`, plus `cancelled`. Pay a draft → refused. Cancel a
fulfilled order → refused. Pay a paid order → no second charge.
**Expected from:** the LLD state table. A (state, event) cell the LLD leaves empty is a spec gap.

## 4. decision-table: Decision tables

**What:** when the outcome depends on a combination of conditions, list the conditions as rows; each rule (column)
is one test. Merge rules where a condition does not matter.
**Ask:** does the response depend on two or more conditions (role, stock, payment state, consent, a setting)?
**Example:** signed-in clinician? · patient active? · item in stock? → 8 combinations, merged to 4 rules: not a
clinician → denied; patient inactive → "Patient is inactive"; out of stock → "Out of stock"; otherwise → order
placed.
**Expected from:** FRs and LLD rules. A combination no artifact decides is a spec gap.

## 5. error-guess: Error guessing

**What:** an experience-based list of what usually breaks. Start from `docs/audit/AUDIT.md`, factory
`FINDINGS.md` rows and known bugs in this domain.
**Checklist:**
- External or partner system down, slow (timeout), returning 500, or returning malformed or partial data.
- A retry after a request that actually succeeded; a network drop after the commit.
- Partial failure across two writes (payment taken, order save fails).
- Missing config or env value at startup.
- A queued job fails and retries.
- Session expires mid-flow; the browser back button after submit; a stale page (data changed since it loaded).
- A referenced record deleted or archived meanwhile (product discontinued after it was added).
**Expected from:** `[Unwanted]` FRs, LLD §8 failure modes (FM-n: detection, timeout, what the user sees, what data
is left), LLD §5 sequence error branches.

## 6. concurrency: Concurrency, idempotency, double-submit

**What:** the same action arriving twice, or two people acting at once.
**Checklist:** double-click on submit; a retry with the same idempotency key; a webhook delivered twice or out of
order; two staff editing the same record (lost update); two orders racing for the last unit; a job running twice.
**How to test:** first the deterministic version (the same request twice in a row → exactly one record and the same
response). True parallelism only with separate processes or connections: a test wrapped in one database
transaction cannot see a race (silent-success pattern). Assert the database-level guard through the row count.
**Expected from:** INV-n and LINV-n ("an order is charged at most once") with the enforcer lld.md §7 names, LLD
constraints, idempotency rules in `openapi.yaml`. Use the database engine lld.md §9 says is never faked.

## 7. authz: Authorization and abuse

**What:** who may do what, and what someone with bad intent will try.
**Checklist:**
- The role × action matrix (a decision table); not signed in; signed in with the wrong role.
- Another clinic's or another patient's record reached by changing an id in the URL or body (IDOR).
- Expired or revoked session.
- Extra fields in the body (`price`, `status`, `clinic_id`, `is_admin`): mass assignment.
- A price or total sent by the client: the server must recompute it.
- Negative or huge quantity; free text containing `<script>` (must render escaped).
- Replaying a captured request; telling "exists" from "forbidden" (403 versus 404 leaks existence).
- Rate limits, only if an NFR states one.
**Test shape:** every refusal has an allowed **twin** that differs in exactly one condition (same patient, same
item, different role), so the refusal can be blamed on that condition. Run the twin first, in the same test: it
proves the route exists, so the refusal cannot pass just because nothing is built yet.
**Expected from:** FRs, privacy NFRs, HLD trust boundaries and threats, LLD authorization rules. An unstated
refusal response (403 or 404, which message) is a spec gap.

## 8. money-time: Money, rounding, time zones

**Money checklist:** integer minor units (cents), never floats; the rounding mode and where it happens (per line or
per order); quantity and price both ≠ 1, so the multiplication shows; non-zero tax; a discount larger than the
price; a zero-price item; the displayed lines add up to the displayed total; a refund never exceeds what was paid.
**Time checklist:** the stored instant versus the displayed local time; the clinic's zone versus the server's UTC;
daylight-saving changes (US: 2026-11-01 and 2027-03-14, at 02:00 local); 23:59 and 00:00 local around any "today"
cut-off; month ends and the leap day 2028-02-29; an expiry exactly at its instant. Freeze the clock to a stated
instant with the project's clock fake; never sleep.
**Expected from:** FRs, LLD column types, decisions (D<n>). Rounding or zone not stated → spec gap, ranked high.

## 9. data-shape: Empty, huge and unicode data

**Checklist:**
- Empty list (first use, no products, no orders yet); exactly one; page size and page size + 1.
- Many rows (1,000): pagination works, nothing times out.
- Empty string versus whitespace-only versus missing field versus null.
- Max length and max + 1; one very long word in the UI.
- Names: `José Núñez`, `李小龙`, `O'Brien`, an emoji; the same name precomposed (NFC) and decomposed (NFD);
  right-to-left text; a zero-width space; leading and trailing spaces; case-insensitive matching.
- Numbers at integer limits; a CSV export cell starting with `=` (formula injection), if anything is exported.
**Expected from:** LLD column types and lengths, `screens.md` empty states and copy.

## Ranking spec gaps (step 5)

Cost of a wrong guess, highest first: money wrong → someone sees another person's data → data lost or duplicated →
patient-visible clinical or safety information wrong → a user stuck with no way forward → wrong error copy →
cosmetic. Ask the top 5 at most; the rest stay `⚠ open (→ G4)`.

## Recommended answers for common spec gaps

Offer these as the recommendation in the step-6 question, adjusted to what the artifacts already say. The human
decides; a recommendation is never written as the expected behaviour until they answer.

| Gap | Recommended answer | Why, in plain words |
|---|---|---|
| Double submit of a create action | Exactly one record is created; the repeat shows the first result | People double-click; two orders or two charges cost money and trust |
| Rounding rule not stated | Integer cents; round half-up per line; the total is the sum of the displayed lines | The receipt always adds up on paper |
| Whose "today" | The clinic's time zone; store UTC instants | Staff think in local days; servers count in UTC |
| Another clinic's or patient's record | Answer as if it does not exist (404); the test opens the clinic's own record first (200) | Does not reveal that the record exists; the twin proves the 404 is a refusal, not a missing route |
| Item becomes unavailable after it was added | Block at confirm with a message naming the item | Never take an order that cannot ship |
| Max length not stated | The LLD column size; over-length is refused with a field message | A database error is not a message for a person |
| Price or total sent by the browser | Ignored; the server recomputes from the catalog | The browser is outside the trust boundary |
