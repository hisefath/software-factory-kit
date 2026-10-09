# clarify-spec: ambiguity taxonomy

Loaded by `clarify-spec` step 1 and 11 (§6 count and add markers), step 3 (find candidates), step 5 (phase fit),
step 7 (write the card), step 9 (§6 close a question) and Done when (§7 HOW check). Every
candidate you keep must pass one test: **a different answer would change a design, a test, a task or a cost.**
If no answer would change anything, it is not worth the human's time.

## 1. Vague-word sweep (a fast first pass)

```bash
grep -niwE '(fast|quick|slow|instant|real-?time|secure|safe|scalable|robust|reliable|available|intuitive|easy|simple|user-friendly|seamless|flexible|appropriate|reasonable|sufficient|minimal|optimi[sz]ed?|efficient|etc|TBD|TODO|later|some|many|few|various|several|support|supports|handle|handles|manage|manages|as needed|if needed|where possible)' <target>
```

Each hit is a lead, not a question. Keep it only if two reasonable readers could build two different things from it.

## 2. The eight categories

### Scope
- **Look for:** features with no priority or milestone; "etc.", "and more", "later?"; no non-goals; an actor or
  partner the brief never mentioned; an FR that appears in no milestone row.
- **Question shape:** "Is `<X>` in M1, a later milestone, or a non-goal?"
- **Typical options:** in M<N> · later milestone · non-goal (explicitly not built).
- **Why it matters (say this to the human):** scope sets the size of everything downstream. Cutting here costs a
  sentence; cutting after design costs a redesign.
- **Phase fit:** every target. Never ask a question that *invites* new scope; only clarify scope the target raised.

### Data / entities
- **Look for:** a noun the system must remember with no fields, no identity (what makes two of them "the same"),
  no owner (who creates, edits, deletes), no lifecycle (states it moves through), no retention or deletion rule,
  no volume estimate; personal or health data with no handling rule.
- **Question shape:** "When a customer changes their address, do past orders keep the old one or show the new one?"
- **Typical options:** copy at the time (snapshot) · always point at the current value (reference) · ask the user.
- **Why it matters:** the data model is the hardest thing to change later; every change means migrating real data.
- **Phase fit:** brief/PRD ask what the data *means* (identity, lifecycle, retention, who may see it). Only the
  LLD asks its *shape* (tables, columns, keys).

### User flows / UX
- **Look for:** a story with no actor, trigger or end state; who-can-see-what left unsaid (roles); a screen with
  no empty, loading, error or permission-denied state; no accessibility expectation; an unclear "then".
- **Question shape:** "After the order is placed, where does the user land and what do they see?"
- **Typical options:** two or three concrete end states, each with what the user can do next.
- **Why it matters:** an unspecified state gets invented by whoever builds that screen, differently each time.
- **Phase fit:** PRD (journeys, roles), flows/screens (states, copy, a11y). Never component trees or state
  libraries (park for `design-lld`).

### NFR numbers
- **Look for:** quality words (fast, secure, reliable, scalable, available, accessible) with no number; a number
  with no unit, percentile, load condition or way of measuring it.
- **Question shape:** "What is the slowest acceptable time for `<thing the user waits for>` at `<load>`?"
- **Typical options:** two or three concrete tiers, e.g. p95 ≤ 1 s / ≤ 2 s / ≤ 5 s at 50 concurrent users,
  each with what it costs (caching, a queue, a bigger server).
- **Why it matters:** numbers drive architecture and hosting cost, and a word cannot be tested. Interviewers ask
  "how did you pick that number?"; the answer is this question and its options.
- **Phase fit:** PRD (targets), HLD (budget per container), acceptance (how it is measured).

### Edge cases / failure
- **Look for:** silence on invalid input, empty data, first use, maximums, duplicates (a double click),
  concurrency (two people editing one record), timeouts, partial failure (charged but order not saved),
  permission denied, a partner system that is slow or down.
- **Question shape:** "If the payment provider doesn't answer in 10 s, what does the user see and what state is the
  order in?"
- **Typical options:** fail safe and tell the user · retry automatically · queue and notify later.
- **Why it matters:** failure behaviour is a product decision (refund? retry? apologise?) that engineers otherwise
  guess, and guesses here become support tickets.
- **Phase fit:** PRD (expected behaviour per EC-n), LLD (state machines, retries), acceptance (one AE per case).

### Integration / external
- **Look for:** an outside system (EHR, payments, email, shipping, identity provider, LLM API) with no: direction
  (who calls whom), data exchanged, source of truth, auth method, rate or cost limits, sandbox availability,
  outage behaviour, data ownership.
- **Question shape:** "Is the partner system the source of truth for the patient's details, or do we keep our own
  copy?"
- **Typical options:** read live every time · keep a synced copy · copy once at checkout.
- **Why it matters:** you do not control an outside system; its limits, outages and contract changes become your
  bugs. Health and payment partners also bring legal duties.
- **Phase fit:** PRD (which partner is mandated, what data crosses, in Constraints), HLD (protocol, trust
  boundary), LLD (endpoints, payloads).

### Terminology
- **Look for:** two words for one thing (patient / customer / member), one word for two things (an "order" that
  is sometimes a cart and sometimes a paid order), undefined acronyms, terms that differ from the `AGENTS.md`
  glossary or an approved upstream artifact.
- **Question shape:** "Are a 'member' and a 'patient' the same person here? Which word do we use everywhere?"
- **Typical options:** term A everywhere · term B everywhere · two distinct terms, each defined.
- **Why it matters:** names leak into tables, APIs and screens; a muddled word here becomes two tables later.
- **Phase fit:** every target. Apply the chosen term in this file only; name other files in STOP.

### Completion signals
- **Look for:** a requirement with no SC or AE; a success measure with no baseline, target or time frame; "done"
  never defined; a task Done-when that cannot fail.
- **Question shape:** "What observable result proves FR-004 works, the thing a test would check?"
- **Typical options:** two or three concrete, checkable results.
- **Why it matters:** no signal means no test, and no test means nobody can say "done" with evidence.
- **Phase fit:** PRD (SC, AE), acceptance (checks). A task file's Done-when is never a target: clarify the
  acceptance.md it derives from, or Revise via `slice-tasks`.

## 3. Phase fit: what each target may ask

A question in the wrong phase gets parked for the skill that owns it, never asked here.

| Target | Ask about | Park (→ skill) |
|---|---|---|
| brief | problem, user, appetite, success, research questions | requirements → `write-prd`; stack → `design-hld` |
| PRD | scope, behaviour, data meaning, numbers, failure behaviour, mandated constraints | frameworks, databases, endpoints, tables → `design-hld` / `design-lld` |
| flows / screens | states, copy, roles, accessibility, variants | state libraries, props, endpoints → `design-lld` |
| HLD | containers, connections, trust boundaries, qualities, invariants, budgets | tables, classes, function names → `design-lld` |
| LLD / change plan | tables, keys, state owners, endpoints, sequences, state machines | product scope → `write-prd` |
| acceptance | observable checks, test data, expected result per edge case | new behaviour → `write-prd` |
| audit | which finding constrains the build, which risk is accepted | fixes → later tasks |
| demo script | each claim's evidence, audience, length | features the code can't back → `write-prd` |

## 4. Writing a card that teaches

- **Question:** one sentence, one decision, no "and".
- **Options:** 2-3, mutually exclusive, concrete, each one a reasonable engineer could pick (no strawmen).
- **Implication:** the concrete downstream effect and its cost: "adds a table", "adds a test per state", "a
  vendor bill", "one more screen", "support tickets when it fails".
- **Plain words:** define any term once in brackets, e.g. "idempotent (safe to repeat without double effects)".
- **Recommendation:** one option plus evidence (`file:line`, `D<n>`, `R<NN>`). No evidence: write "judgment:
  <reason>, low confidence".
- **Do nothing:** every card has a "Leave open (do nothing)" row: the `⚠` stays, the next skill works on the
  default, and the gate lists it as open. WORKFLOW.md §5 requires "do nothing" at every human gate, and 3b's gate
  is each question.
- **Default:** the assumption that is safest and cheapest to undo (out of scope, reject with a clear error, store
  no personal data, never move money twice), so a skipped question never quietly grows the product or its risk.
- **"Waive here, decide in `<skill>`"** is an option only for a HOW question on a WHAT artifact (a database in a
  PRD). Product behaviour, failure behaviour included, is decided in the PRD: never push it to design.

### Worked example (a generic online store PRD)

```
**CQ-4 · question 2 of 5 · [Edge cases / failure] · docs/product/prd.md › EC-2 (line 131)**

If the payment step times out, what happens to the order?

Why it matters: this decides whether the LLD needs a "pending payment" state and a reconciliation job, and which
AE tests we write. Touches FR-006, EC-2.

| # | Option | Implication |
|---|---|---|
| A | Cancel the order; ask the user to try again | Simplest: no extra state. Risk: if the charge went through anyway, the user pays twice until a human refunds it. |
| B | Keep it "pending"; confirm or cancel once the provider answers | One more order state and a background check; no lost or double charges. More to build and test. |
| C | Hold the order, never retry the charge, and email the user once staff check it with the provider | No automation to build; no double charge. Costs staff time per timeout and a slower answer for the user. |
| — | Leave open (do nothing) | The ⚠ stays; design-lld must assume C (no automatic retry, staff resolve by hand); G1 lists it as open. |

**Recommended: B**, because FR-006 says the user must never be charged twice (prd.md:88).
**Default if you skip:** Leave open. C is the assumption because it never charges twice and is the cheapest to
replace with B later.

Reply: A / B / C / "recommended" / your own words / skip / waive <reason> / stop
```

## 5. Decision candidate or plain clarification?

| Answer | Candidate? | Why |
|---|---|---|
| "Keep a copy of the shipping address on each order" | yes | Data model; hard to undo once real orders exist. |
| "p95 ≤ 2 s with 50 concurrent users" | yes | NFR target; drives architecture and hosting cost. |
| "Refund automatically when fulfilment fails" | yes | Payments; money that has moved is a one-way door. |
| "Call them 'customers' everywhere" | no (yes if the word is already in tables or an API) | Wording in docs is cheap to change. |
| "Show 'Try again' on timeout" | no | Copy; one-line change later. |
| "Bulk import is a non-goal" | yes | Scope; every later phase depends on it. |

## 6. Marker conventions per target

Each owner skill writes `⚠` its own way, and some write one question twice (an inline `⚠` plus a row that repeats
it). Count, close and add questions in the target's own form, or the count never reaches 0 and the same question
gets asked twice. The counts read the body only (above `## Clarifications`):

```bash
T=<target>; body() { sed '/^## Clarifications/,$d' "$T"; }
open_brief()  { body | grep -vF '<source> word for word' | grep -oE '⚠[^|⚠]*\(→ G0\)' | wc -l; }  # skips template boilerplate
parked_brief(){ body | grep -oE '⚠[^|⚠]*\(→ R[0-9]+\)' | wc -l; }                              # gather-evidence's, never asked
open_qrows()  { body | grep -E '^\| *(\*\*)?Q-?[0-9]+(\*\*)? *\|' | grep -c '⚠'; }              # Q rows still holding the marker
open_all()    { body | grep -v 'awaiting your pick' | grep -o '⚠' | wc -l; }                      # every marker except the G-ux pick
```

In the table, `\|` stands for a plain `|` (escaped only so the table renders).

| Target | One open question is | Count | Close it (step 9) | Add one (steps 3, 9, 11) |
|---|---|---|---|---|
| `specs/M<N>-<slug>/brief.md` | an inline `⚠ … (→ G0)`. A `⚠ … (→ R<NN>)` belongs to `gather-evidence`: never ask or count it; list it on the Parked line → `gather-evidence`. | `open_brief` | the answer replaces the marker where it sits, ` (CQ-<n>)` | `⚠ <question> (→ G0)` |
| `docs/audit/AUDIT.md` | a `## Questions` row `\| Q<n> \| ⚠ … \|`; every inline `⚠ Q<n>` is a pointer to it, not a second question | `open_qrows` | row: Question cell → `Resolved (CQ-<n>): <question> → <answer>`; each `⚠ Q<n>` pointer → the answer, ` (CQ-<n>)` | `⚠ Q<next>` inline + row `\| Q<next> \| ⚠ <question> \| <why it matters> \| <recommendation> \| <blocks> \|` |
| `docs/product/prd.md` | each `⚠`, inline or an `Open questions:` bullet. An inline marker and a bullet asking the same thing are one question: ask once, close both with one CQ. | `open_all` | inline → the answer, ` (CQ-<n>)`; bullet → `- Resolved (CQ-<n>): …` (template Part 2) | `⚠ <question> — Recommended: <answer> — Blocks: <ids>` at the spot |
| `docs/design/flows.md`, `docs/design/screens.md` | each `⚠`, inline or a `## Open questions` bullet (paired as in the PRD). `**Chosen:** ⚠ awaiting your pick` is the G-ux variant pick: never ask or count it. `⚠ scope request: …` asks keep or drop only: drop → waived; keep → scope change, Revise via `write-prd`, the marker stays. | `open_all` | as the PRD | `⚠ <question>` inline + the same line under `## Open questions` |
| `docs/architecture/hld.md` | a §13 `### Open questions` row `\| Q-<n> \| ⚠ … \|`; inline `⚠` lines asking the same thing are pointers | `open_qrows` (the header `\| Id \| ⚠ Question \|` is not a row) | as the audit row; pointers → the answer, ` (CQ-<n>)` | `⚠ <question> (Q-<next>)` inline + row `\| Q-<next> \| ⚠ <question> \| <blocks> \| <recommendation> \| human \|` |
| `docs/architecture/lld.md` | an `## Open questions` row `\| **Q-<n>** \| ⚠ … \|`; inline `⚠` lines name it | `open_qrows` | as the HLD; keep the bold id | as the HLD, id written `**Q-<next>**` |
| `specs/M<N>-<slug>/change-plan.md` | each inline `⚠` (its Q-n row lives in `lld.md`, which this pass never edits) | `open_all` | the answer, ` (CQ-<n>)`; name the `lld.md` Q-n row under "May now disagree" → `clarify-spec docs/architecture/lld.md` (it settles from this CQ) | `⚠ <question>`; name `lld.md` Open questions under "May now disagree" → `design-lld` |
| `specs/M<N>-<slug>/acceptance.md` | a `## Spec gaps and questions` row whose Status holds `⚠ open`; inline `⚠ … (→ Q-<n>)` and `⚠ Q-<n>` cells are pointers | `open_qrows` | row: Answer (verbatim) = `"<exact words>"`; Status = `answered → clarify-spec (CQ-<n>)` when the PRD must say it too (name the PRD under "May now disagree"), else `answered (CQ-<n>)`; waived → Status `waived (CQ-<n>)`. Pointers → the answer, ` (CQ-<n>)`; a cell that now needs a test → `pending define-acceptance (CQ-<n>)` | `⚠ <question> (→ Q-<next>)` inline + row `\| Q-<next> \| <question> \| <recommendation> \| not asked \| <blocks> \| ⚠ open (→ G4) \|` |
| `docs/demo/SCRIPT.md` | each `⚠`, inline or a `## Open questions` bullet (paired as in the PRD) | `open_all` | as the PRD | `⚠ <question>` inline + the same line under `## Open questions` |

Rules for every row:
- **Waived** uses the close form with `Waived (CQ-<n>): <question> — "<reason, verbatim>"` in place of `Resolved`
  (acceptance: its Status cell, as above).
- **Never delete or renumber** a Q row or its id: a closed row stays, marked Resolved or Waived.
- **Pairing (step 3):** match each inline `⚠` to its row or bullet by id, else by question text. An unpaired
  inline `⚠` on a Q-table target is still one question: if it stays open at step 11, add its row so the count
  sees it.
- **Template boilerplate** that holds a literal `⚠` (the HLD/LLD Open-questions header, the acceptance line
  "Unasked gaps stay here as ⚠", the brief's `<source> word for word` line) is never a question. The counts skip
  it; never edit it.

## 7. HOW-word check (brief, PRD, flows, screens)

Answers on a WHAT target must not smuggle in HOW. Set `HOW` to
`framework|library|database|db|table|column|schema|migration|orm|sql|json|endpoint|api|webhook|queue|cache|cron`
plus `|<name>` for every language, framework, database, host and partner-system name in `AGENTS.md`. Then

```bash
diff <(sed '/^## Clarifications/,$d' <base>) <(sed '/^## Clarifications/,$d' <target>) | grep '^>' | grep -iwE "$HOW"
```

prints nothing. Allowed hits: a line you added under PRD `## Constraints` because the human said the technology is
mandated (and by whom), and a word the users themselves use as domain vocabulary. List each hit in STOP.
