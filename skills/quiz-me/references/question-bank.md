# quiz-me question bank and grading calibration

Read before writing the first rubric. Stems are starting points: fill the `<…>` from the project's own sources and
reword so the question never contains a must-have point's key words.

## Question types (mix them every session)

| Type | Stem | Must-have points come from |
|---|---|---|
| recall | "What did we choose for `<problem>`, and what was the runner-up?" | D-row Choice + Options |
| why | "Why `<choice>` and not `<rejected option>`? Convince a skeptical senior engineer." | Y-statement (facing F → to get Z) + why the rejected option lost |
| why (cost) | "What did we give up by choosing `<choice>`, and why was that acceptable?" | Cost accepted + the W in the Y-statement |
| 10× | "Traffic and data grow 10×. What breaks first, how would you see it in production, and what would you change?" | HLD §8 "What breaks first at 10×", "How you'd know in prod", Revisit if |
| what-if | "What would you change if `<revisit-if trigger, or a constraint flipping: a second clinic, a new payment provider, half the budget>`?" | Revisit if + Reversibility (one-way or two-way door, and what undoing costs) |
| diagram | "Walk me through `<SEQ-n journey>` from `<trigger>` to `<end state>`: each box, each call, and where it can fail." | The diagram's participants and steps in order, the failure branch, the trust boundary crossed |

At least one why-question per topic **that has a recorded rationale** (a Why / Options / Cost field, or a reason the
LLD states). A topic with none gets a recall or walk-through question instead, and its Q block's Note says
`why: not asked — not recorded (journal gap)`. In scopes `M<N>` and `D-list`, at least one 10× and one diagram
question per session, each on an in-scope topic that has that source; otherwise write the reason in the scorecard
("not asked: no §8 in hld.md"). Scopes `review` and `TR-…` ask only about their rows.

## Stems by design element (G3: "defend every table, state owner, endpoint and sequence")

| Element | Stem |
|---|---|
| Table | "Why is `<table>` its own table? What identifies a row, and which constraint stops bad data getting in?" |
| Relationship | "Why is `<A>` to `<B>` one-to-many and not many-to-many? What would change if it were?" |
| State owner | "Which component owns `<state>`? What goes wrong if two components each keep a copy?" |
| Endpoint | "What does `<METHOD /path>` do, who may call it, and what happens if it is called twice?" |
| State machine | "Which transitions of `<entity>.status` are illegal, and what stops them?" |
| Invariant | "Name one thing that must never happen in this system, and the line of defence that stops it." |
| Trust boundary | "Where does untrusted data enter `<container>`, and what is checked right there?" |
| Superseded decision | "We first chose `<D old>`, then replaced it with `<D new>`. What changed your mind?" |
| Defense expectation | The assignment's own wording, verbatim, when it lists interview or defense questions. |

An element with no D-row: drop the "why" half of its stem unless the LLD states the reason (cite it); ask the
"what / who / what happens if" half only.

## Follow-up (transfer) questions

The grade card has already shown the missing piece and the model answer, so a follow-up that asks for them again
only tests copying. Ask the human to **apply** the missing piece to a case the model answer did not mention, and
write its one-line rubric to the Q block first.

| Stem | Example (missing piece: "the provider retries, so one event can arrive twice") |
|---|---|
| "Same idea, new place: `<another endpoint, job, provider or table>`. What goes wrong without it, and what do you do?" | "The shipping company also re-sends its 'delivered' callback. What breaks if we don't guard it, and what do we store?" Rubric: a repeat would mark or notify twice; store the event's id and skip repeats. |
| "Change one fact: `<the guard is removed, a step is skipped, a limit doubles>`. What happens now?" | "We drop the stored keys to save space. The provider sends one payment event three times. What does the customer get?" Rubric: three shipments (or emails) for one payment, because nothing spots the repeats. |

A follow-up answer is graded and recorded, but it is practice: it never changes the main verdict, the topic row's
status or its next review date.

## Writing a rubric (before the question is sent)

- 2-4 **must-have** points. Each is one fact from a source, with its cite (`D<n>`, `file:line`, `R<NN>`), and each
  can be said in plain words. If a point needs jargon, the rubric accepts the plain-word version too.
- **Wrong if:** any claim that contradicts the source. Always list the dangerous ones: a trust boundary, an
  invariant, security, money or data loss.
- Nice-to-have points earn nothing extra. They never lift partial to correct.
- Never a must-have that the question already states, and never one the sources do not support.
- A topic whose D-row lacks the field (no rejected option, no revisit-if): do not ask about that field; it is a
  journal gap.

## Grading calibration (grade these the same way every time)

Worked example. Question: "Why does the server keep a key for each incoming payment webhook?"
Rubric: (1) the payment provider can send the same event more than once (it retries) [D7]; (2) the key lets the
server spot the repeat and do nothing the second time, so an order is not paid or shipped twice [lld.md §4
Idempotency]. Wrong if: says repeats cannot happen; says the key proves who sent the webhook (that is the signature
check, a trust-boundary job).

| Answer | Verdict | Why |
|---|---|---|
| "The provider retries, so one event can arrive twice. We store its key and skip any repeat, so nothing ships twice." | correct | Both points, own words, unprompted. |
| "For reliability. It's best practice." | wrong | No must-have point. Buzzwords earn nothing. |
| "So we don't process stuff twice." | partial | Point 2 is vague; point 1 (why repeats happen) is missing. |
| "Retries happen, and the key also proves the webhook really came from the provider." | wrong | Point 1 hit, but the second claim confuses the key with the signature check: a trust-boundary misconception triggers "wrong if". |
| After a hint: "Oh, because the provider retries." | partial (capped) | A hint was used. |
| "I don't know." / skip | wrong | Recorded as a gap; the grade card's model answer teaches it, then a transfer follow-up. |
| A long, confident answer about queues and scaling that never mentions repeats | wrong | Length and confidence are not points. |

Rules the table shows:
- Grade the points, never the tone. "Mostly right" is not a verdict.
- One dangerous wrong claim outweighs correct points.
- A point counts only if the human said it before any hint or follow-up.
- Say the verdict first, then the missing piece. No "great job" on partial or wrong.

## Plain-language check for teach cards

- Sentences under about 20 words. One idea per sentence.
- One everyday analogy per topic (a ticket stub torn once = an idempotency key; a bouncer at the door = a trust
  boundary check; a single source of truth = one person keeping the class attendance sheet).
- Define each term the first time ("a foreign key, a column that points at a row in another table").
- Then repeat the idea in interview words, so the human can say it both ways.
