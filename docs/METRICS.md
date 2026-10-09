# Metrics: proving the product works, and that you know it

Shared reference for `sharpen-brief`, `gather-evidence` and `write-prd` (WORKFLOW.md §1, layer 1). Source: Byron
Mackay, "Defining Metrics", Gauntlet cohort session, 2026-09-15 (slides "Key Metrics: proving your product works -
and that you know it", plus the session notes). Building is the cheap part now; defining success and telling its
story with numbers is what hiring partners pay for.

## 1. Two questions, both required

| Question | Kind | Comes from |
|---|---|---|
| "Is it running?" | technical: uptime, latency, error rate, did the pipeline run | already in the logs; easy to instrument |
| "Is it working, and worth it?" | business: would a skeptical stakeholder believe the proof? | you must decide what to measure; it never comes free |

A metric set that leans only on the first kind proves the engineering works, not that the business promise is kept.

## 2. Three tests for every candidate metric

1. **Vanity or actionable?** "If this number were bad, would you know what to fix?" No → vanity (total requests
   served, total tokens, downloads, orders since launch: up and to the right, nothing to change). Yes →
   actionable (verification pass rate, tool failure rate). A ratio with a denominator usually beats a raw count.
2. **Leading or lagging?** Leading = an early signal you can act on now (tool latency, retrieval confidence,
   retries). Lagging = the outcome after the fact (did the physician save time, did a bad answer reach a user).
   Pair them: the lagging metric proves success, the leading ones catch trouble before it gets there.
3. **Measurable here?** Name the data that would produce it. No data source = not a metric yet, only a wish (and a
   research question).

## 3. Structure: one North Star, a few supporting metrics

- **North Star:** the one number that most directly shows the product keeps its core promise (GoFundMe:
  donations). Usually one, never more than a couple. Paying customers are a strong signal; watch for people who pay
  without using.
- **Supporting metrics (2-3):** each does one of two jobs: **explain movement** in the North Star, or **guard
  against it being gamed**. A metric that does neither is noise: log it for context, never call it key.
- Adoption alone does not prove the product is good; it may just be the only option.

## 4. Targets

- **Ground it:** trace each target to a workflow constraint, a benchmark or a requirement, never a round number that
  felt right. If you don't know what "good" is yet, say so and say how you'll find out.
- **Aspirational vs hard gate:** mark which target is "where we want to be" and which is "below this, we don't
  ship"; they need different responses when missed.
- **Review cadence:** who reviews the numbers, how often, and what would change the target versus change the product.

## 5. Hiring-partner projects: the partner lens

A partner project is an audition. The product is the medium; the audience is the partner's team. Capture, with
sources:
- who the partner is: what they sell, to whom, size, engineering team, stack (portal company page, company site,
  job posts);
- what they say they value: the assignment's grading words ("what we're looking for") and the portal's working-style
  and interview signals;
- the partner's own metric words, quoted (e.g. a headline metric and a leading indicator named in the brief): the
  North Star should be expressed in *their* business terms;
- how this project can show those values on purpose (in the build, the docs and the demo), not by accident.

## 6. Questions to sit with before locking a set

- Does the set lean too hard on what is easy to instrument?
- If you could keep only three metrics, by what criteria?
- Is each target reasonable, or a round number that felt right?
- What would convince you a chosen metric is useless, and what would you do then?
