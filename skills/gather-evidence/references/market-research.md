# Market research: competitors, ideal customer, market size, share, clusters, usage and load

Loaded by `gather-evidence` at step 3 for any question about existing solutions, the ideal customer profile (ICP),
market size, the share a company could capture, where customers cluster, or how and when they will use the
product (the load the design must carry). Same tiers and budget as every other question
(`references/source-tiers.md`); these questions are broad, so they hit the cap more often.

## 1. Has it been built already? (competitive landscape)

Before sizing anything, find who already solves this problem:
- **Direct:** products that do the same job in the same place (e.g. the same feature built into a rival product).
- **Indirect:** what customers use instead today (the workaround the brief names, standalone tools, marketplaces).
For each: what it does, who it serves, its pricing or take rate, its stated user or customer count (with the "as
of" date), and what it leaves unsolved. A company's own count of its users is Tier A for "what they claim" and Tier
C for the market's true size; public filings or registries are Tier A. Nobody found → say so: an empty market is a
finding to explain, not a win to assume.

## 2. Ideal customer profile (ICP)

Answer with the traits that make a customer most likely to buy and succeed, each sourced:
- **Who:** practice or company type, specialty, size (people, locations), how they are paid (cash-pay vs
  insurance), what they use today (tools, vendors, workarounds).
- **Trigger and pain:** the moment they look for a fix, and what the problem costs them.
- **Fit and disqualifiers:** who is a poor fit, and why.
Tier A here is the partner's own material (who it says it serves, case studies, job posts), the brief, and public
registries. Interviews and surveys you cannot read are gaps, not findings.

## 3. Market size: TAM, SAM, SOM

- **TAM** (total addressable market): everyone who could ever buy this. **SAM** (serviceable): the part this
  company can actually reach (its segment, its country). **SOM** (obtainable): the part it can realistically win
  in a stated period.
- **Prefer bottom-up:** count of buyers × value per buyer per year (e.g. practitioners × patients per
  practitioner × share of patients on the product × annual spend). Top-down (an analyst's total × a share) only as
  a cross-check.
- **Every input is a finding with its S-id**; the computed size is an **Inference**, never a Finding, written as:
  `I<n> from F<a> + F<b>: Formula: <a> × <b> = <result>. Assumptions: <A-1 …>. Range: <low – high>, base <x>.`
- **Ranges, not false precision:** give low, base and high, each changing one named assumption. Round to two
  significant figures. State the year and currency of every money input.
- A number from a paywalled report you could not open is unread: gap, not finding.

## 4. Share the company could capture (SOM)

Ground it in the company's own installed base, the competitors' installed bases (§1) and a cited adoption rate (a
comparable product's published adoption, a pilot, a survey), never a round guess. No benchmark found → write the formula with the adoption rate as an open
assumption and a `⚠` gap naming what would close it.

## 5. Where customers cluster

- **Count by place** from public registries: national provider or business registries (e.g. the US NPI registry
  for clinicians, looked up by its official taxonomy codes), labour statistics by state, licensing boards.
- Report counts **and per-capita rates** (count ÷ population from census data) by state or metro, top 10 with the
  date of the data; per-capita shows density, raw counts show volume.
- Note licensing differences that change who can practise where (some professions are licensed only in some states).
- The clusters' time zones feed §6: they decide when peak and quiet hours fall.

## 6. Usage and load profile (input to design, not a design)

Turn the expected users into the numbers `design-hld` sizes the system with. Each is an Inference with the same
`Formula: … Assumptions: … Range: …` form, built from cited findings:
- **Who uses it, when:** each user role's working hours and moments (e.g. clinicians during clinic hours, patients
  in the evening), across the clusters' time zones, plus weekly and seasonal swings. The quietest common window is
  the candidate maintenance window.
- **How many:** expected users = SOM customers × users per customer × share active per day.
- **How hard:** peak requests per second = peak-hour active users × actions per user per hour × requests per action
  ÷ 3600 × a stated burst factor; also average, and peak concurrent users.
- **What they do that stresses it:** behaviours that create edge cases or load spikes (double submits, retries,
  many orders at month end, refills on a schedule).
Never pick machine sizes, languages or tools here: hand each number to `design-hld` as a question. A missing input
is an assumption with its own range, not a silent default.

## 7. Grading reminders
- Government datasets and registries: Tier A. Trade associations and major industry analyses you read in full: B.
  Vendor market claims, blogs, press releases and AI summaries: C, colour only.
- Market figures date fast: record the "as of" year of every number.
- Hand the choice back: Handoffs ask `write-prd` which segment to target first and which targets to set, and
  ask `design-hld` how to size for the load profile; never pick the segment, the stack or the machines yourself.
