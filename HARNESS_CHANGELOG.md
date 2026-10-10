# Harness changelog

Every adopted change to a skill, hook, template or supervisor rule, with the FINDINGS row that justified it.

| Date | Version | Change | F# | Approved by (exact words) |
|---|---|---|---|---|
| 2026-10-08 | 0.1 | Initial factory: WORKFLOW.md, skill standard, 22 skills, verifier, templates, scripts | — | "we are putting together the full ai native workflow today" |
| 2026-10-09 | 0.1 | H1: Add North Star metrics and partner lens (docs/METRICS.md, docs/WORKFLOW.md, skills/sharpen-brief, skills/gather-evidence, skills/write-prd) | F3 | "approved" |

## Proposals

<!-- Written by route-failure. One block per F per repo, status in the heading:
     proposed | approved | adopted | revise | rejected | stale | superseded by H<m>.
     A filed block's diff never changes; a changed diff is a new block that supersedes it.
     The human approves the exact diff bytes at G-L5; the approval binds to their hash, not to a commit:
     .handoff/TRACKER.md ## Approvals | time | G-L5 | H<n>@<diff-sha256> | exact words |
     (software-factory-kit mode: the block's Verdict line). Nothing here is applied before that record exists. -->

### H1 Add North Star metrics and partner lens  [status: adopted]

- F#: F3 · Layer: Skill · Reach: factory skill (sharpen-brief, gather-evidence, write-prd) + WORKFLOW.md + new docs/METRICS.md
- Proposed: 2026-10-09 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `docs/WORKFLOW.md`, `docs/METRICS.md` (new), `skills/sharpen-brief/SKILL.md`, `skills/sharpen-brief/assets/template.md`, `skills/sharpen-brief/references/question-bank.md`, `skills/gather-evidence/SKILL.md`, `skills/write-prd/SKILL.md`, `skills/write-prd/assets/template.md`
- Root cause: v1 picked metrics and stack by intuition → no phase asked "which number proves value, in the partner's terms?" or "who is this partner?" → the brief template had no section for either, so nothing forced it.
- Why this layer: §10 "Built the wrong thing → Spec / skill": an artifact section with a Done-when count is checkable; a sentence in AGENTS.md would be skimmed. One shared reference avoids three drifting copies.
- Rules: `skills/sharpen-brief/SKILL.md` 234 → 247 lines, `skills/gather-evidence/SKILL.md` 245 → 248, `skills/write-prd/SKILL.md` 276 → 281 (ceiling 300 lines); red-flag rows unchanged (6); pruned: none, below ceiling.
- Guard: sharpen-brief Done-when prints 1 for `| NS-` rows in Value and metrics; write-prd SC-001 line starts "North Star".
- Teach: "My factory makes every project name one North Star in the partner's business terms before any design, because building is cheap and proving value is the job."
- diff-sha256: 19d8e18b0765
- Verdict: approved at G-L5 2026-10-09 17:27 CDT (cerbo-supplement-store TRACKER Approvals, H1@19d8e18b0765): "approved"; applied ee2e6a2

```diff
--- a/docs/WORKFLOW.md
+++ b/docs/WORKFLOW.md
@@ -19,6 +19,10 @@
 | 3 Agent orchestration | Which agent, which tools/context/permissions | supervisor (CLAUDE.md), `slice-tasks`, `scripts/delegate.sh` |
 | 4 Verification | What evidence proves it's correct | `define-acceptance`, `scope-guard.sh`, `make check`, `verifier`, `check-security` |
 | 5 System improvement | When an agent fails, what do we fix | `route-failure`, `FINDINGS.md`, `HARNESS_CHANGELOG.md` |
+
+**Metrics and the partner lens (layer 1, F3).** Every product names one North Star and 2-3 supporting metrics,
+each tested vanity vs actionable and leading vs lagging, with grounded targets (`docs/METRICS.md`). `sharpen-brief`
+writes candidates and the hiring-partner lens, `gather-evidence` sources them, `write-prd` locks the tree at G1.
 
 Planning follows the Double Diamond (Design Council, 2003-04): Diamond 1 = Discover (brief, evidence) + Define
 (PRD); Diamond 2 = Develop (UX, HLD, LLD) + Deliver (acceptance, tasks, build, ship). Spec-driven development maps
--- a/skills/sharpen-brief/SKILL.md
+++ b/skills/sharpen-brief/SKILL.md
@@ -53,6 +53,10 @@
 6. `specs/*/brief.md` and `docs/product/prd.md`, if present.
 7. `.handoff/inbox/*`: pasted notes and research. Candidate context only, never law.
 8. The tree: `git ls-files` (or `ls -R` outside git), to tell greenfield from brownfield.
+9. **`docs/METRICS.md` in software-factory-kit (MUST)**: `${FACTORY_KIT_DIR:-$HOME/Desktop/gauntlet_workbench/software-factory-kit}/docs/METRICS.md`. For a
+   hiring-partner project, also the partner's company page the human points to (e.g. the portal's company panel):
+   read it like the assignment (uncleared until the human says otherwise). Company websites and job posts are for
+   `gather-evidence`: write research questions about them, don't browse.
 
 ## The one rule
 
@@ -115,6 +119,11 @@
    motivation, never a feature, button or screen. The Source cell holds ids only (`REQ-##`, `Q#`), never quotes.
    A proper name the text cannot avoid (the partner's product, a mandated system the user knows by name) goes in
    the frontmatter `problem_allowlist`; nothing else may trip the vocabulary check in `## Done when`.
+   Then fill `## Hiring partner` (who they are, what they say they value, what this project should show them, each
+   with its source; unknowns become R rows; a non-partner project writes `none: <why>`) and `## Value and metrics`
+   with `docs/METRICS.md`: the underlying business problem in the partner's own metric words, quoted; one North
+   Star *candidate* and 2-3 supporting candidates, each tagged actionable/vanity, leading/lagging and its likely data
+   source or `⚠ (→ R<NN>)`; and the vanity traps you rejected. Candidates only: targets belong to `write-prd`.
 8. **Map the law.** One REQ row per requirement from step 3: verbatim quote (uncleared source:
    `(paraphrase, U-##) <short paraphrase>`), source location, deliverable, owning
    phase/skill (the WORKFLOW.md §4 row whose Output column produces it), due date. The deliverable is the
@@ -138,7 +147,8 @@
     settle: the question, the decision it unblocks, what evidence would settle it, and where it came from (REQ, JS
     or a ⚠ line). Ask about people, domain rules, constraints, mandated systems and assignment ambiguities; name a
     technology only if the assignment or `AGENTS.md` mandates it. Aim for 8 or fewer; drop any that unblock
-    nothing. `gather-evidence` writes each answer to `docs/research/R<NN>-<slug>.md`.
+    nothing. Always include one on the data that could measure the North Star candidate, and for a hiring-partner
+    project one on the partner (product, customers, stack, what they hire for). `gather-evidence` writes each answer to `docs/research/R<NN>-<slug>.md`.
 12. **Fill the template, then self-check** against `## Done when`. Fix and re-run the checks until all pass, then
     send the STOP message.
 
@@ -181,6 +191,8 @@
       has a quote (uncleared source: `(paraphrase, U-##)`), a source location, a deliverable and an owner, or a
       `⚠ (→ G0)`. No local paths: `grep -nE '/Users/|/home/' "$B"` prints nothing.
 - [ ] Every deadline has a timezone and a local time produced by `date`, or `⚠ timezone? (→ G0)`.
+- [ ] Value and metrics is filled: `awk '/^## Value and metrics/{f=1;next} /^## /{f=0} f' "$B" | grep -c '^| NS-'`
+      prints 1, and every `| SM-` row there names a job (explains / guards).
 - [ ] Every job story has all three clauses and a source id (`REQ-##` / `Q#`); every `R<NN>` names the decision it unblocks.
 - [ ] Interview log has ≤5 new Q rows this pass, each answer verbatim (redacted) or `skipped → ⚠`.
 - [ ] No secrets or personal data. Value patterns print nothing:
@@ -199,6 +211,7 @@
 Brief ready for G0: specs/M<N>-<slug>/brief.md
 - Job stories: <grep -c '^| JS-'> · Assignment requirements mapped: <grep -c '^| REQ-'> · User-owned steps: <grep -c '^| U-'>
 - Research questions: <grep -c '^| R[0-9]'> · Parked solution ideas: <grep -c '^| P-'>
+- North Star candidate: <the NS-01 metric in plain words> · supporting candidates: <grep -c '^| SM-'>
 - Tech words allowed in Problem/Job stories (problem_allowlist): <value, or none>
 - Open ⚠ (grep -n '⚠'):
   <paste the lines, or "none">
--- a/skills/sharpen-brief/assets/template.md
+++ b/skills/sharpen-brief/assets/template.md
@@ -35,6 +35,28 @@
 |---|---|---|---|---|---|
 | JS-01 | {{situation}} | {{motivation, never a feature or screen}} | {{outcome}} | {{role}} | {{ids only: REQ-## / Q#}} |
 
+## Hiring partner
+
+Who we are building for and what should impress them (`docs/METRICS.md` §5). Facts with a source; unknowns go to
+Research questions. Not a partner project: one row `none: <why>`.
+
+| Aspect | What we know | Source | What the project should show them |
+|---|---|---|---|
+| {{who they are: product, customers, size, eng team, stack}} | {{fact, or ⚠ (→ R<NN>)}} | {{source name/§}} | {{how the build, docs or demo shows it}} |
+
+## Value and metrics
+
+Candidates for `write-prd`, not decisions (`docs/METRICS.md` §1-3). Targets are set in the PRD.
+
+- **Underlying problem in the business's terms:** {{what leaks or costs, in the partner's own metric words, quoted with source}}
+
+| ID | Candidate metric | Role | Actionable or vanity ("if bad, what would we fix?") | Leading or lagging | Data that would measure it |
+|---|---|---|---|---|---|
+| NS-01 | {{the one number that shows the core promise is kept}} | North Star | {{actionable: …}} | {{lagging}} | {{source, or ⚠ (→ R<NN>)}} |
+| SM-01 | {{supporting metric}} | explains / guards NS-01 | {{…}} | {{leading}} | {{…}} |
+
+Vanity traps considered and rejected: {{metric: why it tells nobody what to fix}}
+
 ## Appetite and deadlines
 
 - **Now:** {{output of date}}
--- a/skills/sharpen-brief/references/question-bank.md
+++ b/skills/sharpen-brief/references/question-bank.md
@@ -83,6 +83,17 @@
     Why: inherited code adds `audit-codebase` before `write-prd`, and it changes the risk.
     Default: whatever the tree shows; ask only when it shows both.
 
+## F. Value and the partner (added 2026-10-09, FINDINGS.md F3)
+
+1. **"If this shipped and worked, which number would the partner's business watch move?"**
+   Ask only if the assignment names no headline metric.
+   Why: the North Star must be in their business terms, or the demo proves engineering but not value.
+   Default: money or time the problem leaks today, per the assignment's own wording.
+2. **"What do you most want this partner to remember about you after the demo?"**
+   Ask only for a hiring-partner project, after reading the partner's page.
+   Why: the project is an audition; we design the build, docs and demo to show that on purpose.
+   Default: the top values in the assignment's "what we're looking for" section.
+
 ## How this bank grows
 
 `route-failure` adds a question here when a milestone built the wrong thing (WORKFLOW.md §10, "Spec" row). New
--- a/skills/gather-evidence/SKILL.md
+++ b/skills/gather-evidence/SKILL.md
@@ -89,7 +89,10 @@
    read and dated mean). For each question write down, for yourself: its R id; the brief row's "Decision it
    unblocks" and "Answered when", copied verbatim (a follow-up: from the task's `## Done-when`, or asked in step
    4); why it is or is not load-bearing; and the Tier-A source most likely to settle it. Searching first finds the
-   loudest page, not the authoritative one.
+   loudest page, not the authoritative one. For a question about the hiring partner, Tier A is the partner's own
+   material (company site, product docs, job posts, the portal page the brief cites); for a metric question, grade
+   the candidate with `docs/METRICS.md` in software-factory-kit (`${FACTORY_KIT_DIR:-$HOME/Desktop/gauntlet_workbench/software-factory-kit}/docs/METRICS.md`) and find
+   the data that would measure it, never a target.
 4. **Interview (interactive only).** Ask one question at a time, each with your recommended answer, at most 4, and
    skip any the repo already answers:
    1. "Which research questions this pass?" Recommend: every unanswered one, load-bearing first. Say what that
--- a/skills/write-prd/SKILL.md
+++ b/skills/write-prd/SKILL.md
@@ -113,7 +113,12 @@
    unknown → write your recommended value and make the Source `⚠ <question> — Recommended: <value> — Blocks:
    NFR-###`. Success criteria: technology-free, each linked to a GOAL, each measuring a change in a person's or the
    business's outcome (time saved, money no longer fronted, adoption). An SC never restates an FR or NFR: if an AE
-   can prove it, it is not an SC.
+   can prove it, it is not an SC. Build them as a metric tree with `docs/METRICS.md` in software-factory-kit
+   (`${FACTORY_KIT_DIR:-$HOME/Desktop/gauntlet_workbench/software-factory-kit}/docs/METRICS.md`), starting from the brief's `## Value and metrics`:
+   SC-001 is the one North Star, in the partner's business terms; then 2-3 supporting SCs, each naming the job it
+   does (explains or guards SC-001); each SC tagged leading/lagging, with the "if bad, what would we fix?" answer,
+   a target grounded in a constraint, benchmark or requirement (never a round number), marked aspirational or hard
+   gate, and its review (who, how often). Vanity candidates are listed as rejected, with why.
 7. **Give examples, edges and open questions.** Acceptance examples in Given/When/Then with concrete fictional names
    and values, each citing the FR ids it exercises; every FR has at least one AE, and every [Unwanted] FR has its own
    AE that cites it first. Edge cases (empty, maximum, duplicate, simultaneous, half-finished, permission denied,
--- a/skills/write-prd/assets/template.md
+++ b/skills/write-prd/assets/template.md
@@ -123,9 +123,15 @@
      free, each linked to a GOAL, with how and when it is measured in plain words. Never restate an FR or NFR: if an
      AE can prove it, it is not an SC. -->
 
-- **SC-001** {{≥ 80 %}} of {{persona}} {{complete the core job}} in under {{2}} minutes, measured by {{method}} by {{date}}. (GOAL-1)
-- **SC-002** {{Outcome metric with target}}, measured by {{method}}. (GOAL-2)
+<!-- Metric tree (software-factory-kit docs/METRICS.md): SC-001 is the North Star, in the partner's business terms;
+     each supporting SC explains or guards it. Targets: grounded (cite the constraint, benchmark or requirement),
+     aspirational or hard gate, with a review owner and cadence. -->
 
+- **SC-001** North Star: {{the one number that shows the core promise is kept}}. Target {{value}} ({{aspirational | hard gate}}), grounded in {{source}}; {{lagging}}; if bad we fix {{what}}; measured by {{method}}; reviewed by {{who}} every {{cadence}}. (GOAL-1)
+- **SC-002** Supporting ({{explains | guards}} SC-001): {{metric}}. Target {{value}} ({{aspirational | hard gate}}), grounded in {{source}}; {{leading}}; if bad we fix {{what}}; measured by {{method}}. (GOAL-1)
+
+Rejected as vanity: {{metric: why it tells nobody what to fix}}
+
 ## Acceptance examples
 
 <!-- Given/When/Then with concrete fictional values (names, amounts, counts), never "valid input". Every FR is cited
--- /dev/null
+++ b/docs/METRICS.md
@@ -0,0 +1,62 @@
+# Metrics: proving the product works, and that you know it
+
+Shared reference for `sharpen-brief`, `gather-evidence` and `write-prd` (WORKFLOW.md §1, layer 1). Source: Byron
+Mackay, "Defining Metrics", Gauntlet cohort session, 2026-09-15 (slides "Key Metrics: proving your product works -
+and that you know it", plus the session notes). Building is the cheap part now; defining success and telling its
+story with numbers is what hiring partners pay for.
+
+## 1. Two questions, both required
+
+| Question | Kind | Comes from |
+|---|---|---|
+| "Is it running?" | technical: uptime, latency, error rate, did the pipeline run | already in the logs; easy to instrument |
+| "Is it working, and worth it?" | business: would a skeptical stakeholder believe the proof? | you must decide what to measure; it never comes free |
+
+A metric set that leans only on the first kind proves the engineering works, not that the business promise is kept.
+
+## 2. Three tests for every candidate metric
+
+1. **Vanity or actionable?** "If this number were bad, would you know what to fix?" No → vanity (total requests
+   served, total tokens, downloads, orders since launch: up and to the right, nothing to change). Yes →
+   actionable (verification pass rate, tool failure rate). A ratio with a denominator usually beats a raw count.
+2. **Leading or lagging?** Leading = an early signal you can act on now (tool latency, retrieval confidence,
+   retries). Lagging = the outcome after the fact (did the physician save time, did a bad answer reach a user).
+   Pair them: the lagging metric proves success, the leading ones catch trouble before it gets there.
+3. **Measurable here?** Name the data that would produce it. No data source = not a metric yet, only a wish (and a
+   research question).
+
+## 3. Structure: one North Star, a few supporting metrics
+
+- **North Star:** the one number that most directly shows the product keeps its core promise (GoFundMe:
+  donations). Usually one, never more than a couple. Paying customers are a strong signal; watch for people who pay
+  without using.
+- **Supporting metrics (2-3):** each does one of two jobs: **explain movement** in the North Star, or **guard
+  against it being gamed**. A metric that does neither is noise: log it for context, never call it key.
+- Adoption alone does not prove the product is good; it may just be the only option.
+
+## 4. Targets
+
+- **Ground it:** trace each target to a workflow constraint, a benchmark or a requirement, never a round number that
+  felt right. If you don't know what "good" is yet, say so and say how you'll find out.
+- **Aspirational vs hard gate:** mark which target is "where we want to be" and which is "below this, we don't
+  ship"; they need different responses when missed.
+- **Review cadence:** who reviews the numbers, how often, and what would change the target versus change the product.
+
+## 5. Hiring-partner projects: the partner lens
+
+A partner project is an audition. The product is the medium; the audience is the partner's team. Capture, with
+sources:
+- who the partner is: what they sell, to whom, size, engineering team, stack (portal company page, company site,
+  job posts);
+- what they say they value: the assignment's grading words ("what we're looking for") and the portal's working-style
+  and interview signals;
+- the partner's own metric words, quoted (e.g. a headline metric and a leading indicator named in the brief): the
+  North Star should be expressed in *their* business terms;
+- how this project can show those values on purpose (in the build, the docs and the demo), not by accident.
+
+## 6. Questions to sit with before locking a set
+
+- Does the set lean too hard on what is easy to instrument?
+- If you could keep only three metrics, by what criteria?
+- Is each target reasonable, or a round number that felt right?
+- What would convince you a chosen metric is useless, and what would you do then?
```

### H2 Add market and ideal-customer research  [status: superseded by H3]

- F#: F4 · Layer: Skill · Reach: factory skill (sharpen-brief, gather-evidence) + WORKFLOW.md + new skills/gather-evidence/references/market-research.md
- Proposed: 2026-10-09 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `docs/WORKFLOW.md`, `skills/sharpen-brief/SKILL.md`, `skills/gather-evidence/SKILL.md`, `skills/gather-evidence/references/market-research.md` (new)
- Root cause: PRD success targets had no market to ground them → no research question asked for one → sharpen-brief step 11 required partner and North Star-data questions but never the customer market → and gather-evidence had no method for sizing a market without false precision.
- Why this layer: §10 "Built the wrong thing → Spec" and "Phase procedure botched → Skill": a required question plus a Done-when grep makes the gap loud at G0, and a reference loaded only for market questions keeps SKILL.md short; a sentence in AGENTS.md would not reach the brief.
- Rules: `skills/sharpen-brief/SKILL.md` 247 → 249 lines, `skills/gather-evidence/SKILL.md` 248 → 252 (ceiling 300 lines); red-flag rows unchanged (6); pruned: none, below ceiling.
- Guard: sharpen-brief Done-when `grep -ciE '^\| R[0-9]+ .*(ideal customer|market)' "$B"` prints ≥1; gather-evidence Done-when prints any market inference lacking `Formula:`, `Assumptions:`, `Range:`.
- Teach: "Before setting success targets, my factory sizes the market bottom-up with stated assumptions and a range, so every target traces to evidence instead of a round number."
- diff-sha256: 98f66b7c8c99
- Verdict: revise at G-L5 2026-10-09 19:40 CDT (cerbo-supplement-store TRACKER Approvals, H2@98f66b7c8c99): the human added competitors, user counts, share, usage timing and load profile; superseded by H3

```diff
--- a/docs/WORKFLOW.md
+++ b/docs/WORKFLOW.md
@@ -23,6 +23,8 @@
 **Metrics and the partner lens (layer 1, F3).** Every product names one North Star and 2-3 supporting metrics,
 each tested vanity vs actionable and leading vs lagging, with grounded targets (`docs/METRICS.md`). `sharpen-brief`
 writes candidates and the hiring-partner lens, `gather-evidence` sources them, `write-prd` locks the tree at G1.
+Targets need a market: every brief asks who the ideal customer is, how big the market is, what share is winnable
+and where customers cluster; `gather-evidence` answers with `references/market-research.md` (F4).
 
 Planning follows the Double Diamond (Design Council, 2003-04): Diamond 1 = Discover (brief, evidence) + Define
 (PRD); Diamond 2 = Develop (UX, HLD, LLD) + Deliver (acceptance, tasks, build, ship). Spec-driven development maps
--- a/skills/sharpen-brief/SKILL.md
+++ b/skills/sharpen-brief/SKILL.md
@@ -148,7 +148,8 @@
     or a ⚠ line). Ask about people, domain rules, constraints, mandated systems and assignment ambiguities; name a
     technology only if the assignment or `AGENTS.md` mandates it. Aim for 8 or fewer; drop any that unblock
     nothing. Always include one on the data that could measure the North Star candidate, and for a hiring-partner
-    project one on the partner (product, customers, stack, what they hire for). `gather-evidence` writes each answer to `docs/research/R<NN>-<slug>.md`.
+    project one on the partner (product, customers, stack, what they hire for), plus one on the market: the
+    ideal customer, market size and share the product could capture, and where customers cluster. `gather-evidence` writes each answer to `docs/research/R<NN>-<slug>.md`.
 12. **Fill the template, then self-check** against `## Done when`. Fix and re-run the checks until all pass, then
     send the STOP message.
 
@@ -191,6 +192,7 @@
       has a quote (uncleared source: `(paraphrase, U-##)`), a source location, a deliverable and an owner, or a
       `⚠ (→ G0)`. No local paths: `grep -nE '/Users/|/home/' "$B"` prints nothing.
 - [ ] Every deadline has a timezone and a local time produced by `date`, or `⚠ timezone? (→ G0)`.
+- [ ] A market question exists: `grep -ciE '^\| R[0-9]+ .*(ideal customer|market)' "$B"` prints 1 or more.
 - [ ] Value and metrics is filled: `awk '/^## Value and metrics/{f=1;next} /^## /{f=0} f' "$B" | grep -c '^| NS-'`
       prints 1, and every `| SM-` row there names a job (explains / guards).
 - [ ] Every job story has all three clauses and a source id (`REQ-##` / `Q#`); every `R<NN>` names the decision it unblocks.
--- a/skills/gather-evidence/SKILL.md
+++ b/skills/gather-evidence/SKILL.md
@@ -92,7 +92,9 @@
    loudest page, not the authoritative one. For a question about the hiring partner, Tier A is the partner's own
    material (company site, product docs, job posts, the portal page the brief cites); for a metric question, grade
    the candidate with `docs/METRICS.md` in software-factory-kit (`${FACTORY_KIT_DIR:-$HOME/Desktop/gauntlet_workbench/software-factory-kit}/docs/METRICS.md`) and find
-   the data that would measure it, never a target.
+   the data that would measure it, never a target. For a market question (ideal customer, market size, share,
+   where customers cluster), also load `references/market-research.md`: sizes are inferences with a formula,
+   assumptions and a low-base-high range, never findings.
 4. **Interview (interactive only).** Ask one question at a time, each with your recommended answer, at most 4, and
    skip any the repo already answers:
    1. "Which research questions this pass?" Recommend: every unanswered one, load-bearing first. Say what that
@@ -199,6 +201,8 @@
       `sed -n '/^## Handoffs/,$p' <file> | grep '^- ' | grep -vE '^- (none|(write-prd|design-hld): .+\?)'`
 - [ ] Every `[LB]` finding cites 1 `(A)` or 2 `(B)` from different publishers. Eyeball each line that
       `grep '\[LB\]' <file> | grep -v '(A)'` prints.
+- [ ] Every market-size or share inference shows its working:
+      `grep -E '^- \*\*I[0-9]+\*\*' <file> | grep -iE 'TAM|SAM|SOM|market size|share' | grep -vE 'Formula:.*Assumptions:.*Range:'`
 - [ ] Frontmatter `budget` shows used ≤ cap; `status` and `confidence` follow step 9's rules; `answered_when` is
       filled.
 - [ ] No secrets, credentials or PHI in anything you wrote.
--- /dev/null
+++ b/skills/gather-evidence/references/market-research.md
@@ -0,0 +1,51 @@
+# Market research: ideal customer, market size, share, clusters
+
+Loaded by `gather-evidence` at step 3 for any question about the ideal customer profile (ICP), market size, the
+share a company could capture, or where customers cluster. Same tiers and budget as every other question
+(`references/source-tiers.md`); these questions are broad, so they hit the cap more often.
+
+## 1. Ideal customer profile (ICP)
+
+Answer with the traits that make a customer most likely to buy and succeed, each sourced:
+- **Who:** practice or company type, specialty, size (people, locations), how they are paid (cash-pay vs
+  insurance), what they use today (tools, vendors, workarounds).
+- **Trigger and pain:** the moment they look for a fix, and what the problem costs them.
+- **Fit and disqualifiers:** who is a poor fit, and why.
+Tier A here is the partner's own material (who it says it serves, case studies, job posts), the brief, and public
+registries. Interviews and surveys you cannot read are gaps, not findings.
+
+## 2. Market size: TAM, SAM, SOM
+
+- **TAM** (total addressable market): everyone who could ever buy this. **SAM** (serviceable): the part this
+  company can actually reach (its segment, its country). **SOM** (obtainable): the part it can realistically win
+  in a stated period.
+- **Prefer bottom-up:** count of buyers × value per buyer per year (e.g. practitioners × patients per
+  practitioner × share of patients on the product × annual spend). Top-down (an analyst's total × a share) only as
+  a cross-check.
+- **Every input is a finding with its S-id**; the computed size is an **Inference**, never a Finding, written as:
+  `I<n> from F<a> + F<b>: Formula: <a> × <b> = <result>. Assumptions: <A-1 …>. Range: <low – high>, base <x>.`
+- **Ranges, not false precision:** give low, base and high, each changing one named assumption. Round to two
+  significant figures. State the year and currency of every money input.
+- A number from a paywalled report you could not open is unread: gap, not finding.
+
+## 3. Share the company could capture (SOM)
+
+Ground it in the company's own installed base and a cited adoption rate (a comparable product's published adoption,
+a pilot, a survey), never a round guess. No benchmark found → write the formula with the adoption rate as an open
+assumption and a `⚠` gap naming what would close it.
+
+## 4. Where customers cluster
+
+- **Count by place** from public registries: national provider or business registries (e.g. the US NPI registry
+  for clinicians, looked up by its official taxonomy codes), labour statistics by state, licensing boards.
+- Report counts **and per-capita rates** (count ÷ population from census data) by state or metro, top 10 with the
+  date of the data; per-capita shows density, raw counts show volume.
+- Note licensing differences that change who can practise where (some professions are licensed only in some states).
+
+## 5. Grading reminders
+
+- Government datasets and registries: Tier A. Trade associations and major industry analyses you read in full: B.
+  Vendor market claims, blogs, press releases and AI summaries: C, colour only.
+- Market figures date fast: record the "as of" year of every number.
+- Hand the choice back: Handoffs ask `write-prd` which segment to target first and which targets to set; never
+  pick the segment yourself.
```

### H3 Add market, competitor and load-profile research  [status: proposed]

- F#: F4 · Layer: Skill · Reach: factory skill (sharpen-brief, gather-evidence) + WORKFLOW.md + new skills/gather-evidence/references/market-research.md · Supersedes: H2
- Proposed: 2026-10-09 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `docs/WORKFLOW.md`, `skills/sharpen-brief/SKILL.md`, `skills/gather-evidence/SKILL.md`, `skills/gather-evidence/references/market-research.md` (new)
- Root cause: PRD targets and design sizing had no market or usage evidence → no research question asked for one → sharpen-brief step 11 never required competitor, market or usage questions → and gather-evidence had no method for sizing a market or a load profile without false precision.
- Why this layer: §10 "Built the wrong thing → Spec" and "Phase procedure botched → Skill": required questions plus Done-when greps make the gap loud at G0, and a reference loaded only for market and usage questions keeps SKILL.md short; load numbers stay inferences handed to design-hld, so research never picks machines or stacks.
- Rules: `skills/sharpen-brief/SKILL.md` 247 → 251 lines, `skills/gather-evidence/SKILL.md` 248 → 252 (ceiling 300 lines); red-flag rows unchanged (6); pruned: none, below ceiling.
- Guard: sharpen-brief Done-when greps print ≥1 R row naming ideal customer or market, and ≥1 naming usage, peak or load; gather-evidence Done-when prints any market, share or load inference lacking `Formula:`, `Assumptions:`, `Range:`.
- Teach: "Before design, my factory finds who already solves the problem, sizes the market and the expected load bottom-up with stated assumptions, so the PRD targets and the system sizing trace to evidence."
- diff-sha256: 255e96814097
- Verdict: pending G-L5

```diff
--- a/docs/WORKFLOW.md
+++ b/docs/WORKFLOW.md
@@ -23,6 +23,10 @@
 **Metrics and the partner lens (layer 1, F3).** Every product names one North Star and 2-3 supporting metrics,
 each tested vanity vs actionable and leading vs lagging, with grounded targets (`docs/METRICS.md`). `sharpen-brief`
 writes candidates and the hiring-partner lens, `gather-evidence` sources them, `write-prd` locks the tree at G1.
+Targets and sizing need a market: every brief asks who already solves the problem, who the ideal customer is, how
+big the market and winnable share are, where customers cluster, and when and how hard they will use the product;
+`gather-evidence` answers with `references/market-research.md` (F4), and `design-hld` sizes the system from that
+load profile.
 
 Planning follows the Double Diamond (Design Council, 2003-04): Diamond 1 = Discover (brief, evidence) + Define
 (PRD); Diamond 2 = Develop (UX, HLD, LLD) + Deliver (acceptance, tasks, build, ship). Spec-driven development maps
--- a/skills/sharpen-brief/SKILL.md
+++ b/skills/sharpen-brief/SKILL.md
@@ -148,7 +148,9 @@
     or a ⚠ line). Ask about people, domain rules, constraints, mandated systems and assignment ambiguities; name a
     technology only if the assignment or `AGENTS.md` mandates it. Aim for 8 or fewer; drop any that unblock
     nothing. Always include one on the data that could measure the North Star candidate, and for a hiring-partner
-    project one on the partner (product, customers, stack, what they hire for). `gather-evidence` writes each answer to `docs/research/R<NN>-<slug>.md`.
+    project one on the partner (product, customers, stack, what they hire for), plus one on the market (who
+    already solves this and how many users they have, the ideal customer, market size and winnable share, where
+    customers cluster) and one on usage (when and how much customers will use it: peak hours, volume, behaviour). `gather-evidence` writes each answer to `docs/research/R<NN>-<slug>.md`.
 12. **Fill the template, then self-check** against `## Done when`. Fix and re-run the checks until all pass, then
     send the STOP message.
 
@@ -191,6 +193,8 @@
       has a quote (uncleared source: `(paraphrase, U-##)`), a source location, a deliverable and an owner, or a
       `⚠ (→ G0)`. No local paths: `grep -nE '/Users/|/home/' "$B"` prints nothing.
 - [ ] Every deadline has a timezone and a local time produced by `date`, or `⚠ timezone? (→ G0)`.
+- [ ] Market and usage questions exist: `grep -ciE '^\| R[0-9]+ .*(ideal customer|market)' "$B"` and
+      `grep -ciE '^\| R[0-9]+ .*(usage|peak|load)' "$B"` each print 1 or more.
 - [ ] Value and metrics is filled: `awk '/^## Value and metrics/{f=1;next} /^## /{f=0} f' "$B" | grep -c '^| NS-'`
       prints 1, and every `| SM-` row there names a job (explains / guards).
 - [ ] Every job story has all three clauses and a source id (`REQ-##` / `Q#`); every `R<NN>` names the decision it unblocks.
--- a/skills/gather-evidence/SKILL.md
+++ b/skills/gather-evidence/SKILL.md
@@ -92,7 +92,9 @@
    loudest page, not the authoritative one. For a question about the hiring partner, Tier A is the partner's own
    material (company site, product docs, job posts, the portal page the brief cites); for a metric question, grade
    the candidate with `docs/METRICS.md` in software-factory-kit (`${FACTORY_KIT_DIR:-$HOME/Desktop/gauntlet_workbench/software-factory-kit}/docs/METRICS.md`) and find
-   the data that would measure it, never a target.
+   the data that would measure it, never a target. For a market or usage question (existing solutions, ideal
+   customer, market size, share, clusters, peak usage and load), also load `references/market-research.md`: sizes
+   and loads are inferences with a formula, assumptions and a low-base-high range, never findings.
 4. **Interview (interactive only).** Ask one question at a time, each with your recommended answer, at most 4, and
    skip any the repo already answers:
    1. "Which research questions this pass?" Recommend: every unanswered one, load-bearing first. Say what that
@@ -199,6 +201,8 @@
       `sed -n '/^## Handoffs/,$p' <file> | grep '^- ' | grep -vE '^- (none|(write-prd|design-hld): .+\?)'`
 - [ ] Every `[LB]` finding cites 1 `(A)` or 2 `(B)` from different publishers. Eyeball each line that
       `grep '\[LB\]' <file> | grep -v '(A)'` prints.
+- [ ] Every market-size, share or load inference shows its working:
+      `grep -E '^- \*\*I[0-9]+\*\*' <file> | grep -iE 'TAM|SAM|SOM|market size|share|per second|concurrent|peak' | grep -vE 'Formula:.*Assumptions:.*Range:'`
 - [ ] Frontmatter `budget` shows used ≤ cap; `status` and `confidence` follow step 9's rules; `answered_when` is
       filled.
 - [ ] No secrets, credentials or PHI in anything you wrote.
--- /dev/null
+++ b/skills/gather-evidence/references/market-research.md
@@ -0,0 +1,77 @@
+# Market research: competitors, ideal customer, market size, share, clusters, usage and load
+
+Loaded by `gather-evidence` at step 3 for any question about existing solutions, the ideal customer profile (ICP),
+market size, the share a company could capture, where customers cluster, or how and when they will use the
+product (the load the design must carry). Same tiers and budget as every other question
+(`references/source-tiers.md`); these questions are broad, so they hit the cap more often.
+
+## 1. Has it been built already? (competitive landscape)
+
+Before sizing anything, find who already solves this problem:
+- **Direct:** products that do the same job in the same place (e.g. the same feature built into a rival product).
+- **Indirect:** what customers use instead today (the workaround the brief names, standalone tools, marketplaces).
+For each: what it does, who it serves, its pricing or take rate, its stated user or customer count (with the "as
+of" date), and what it leaves unsolved. A company's own count of its users is Tier A for "what they claim" and Tier
+C for the market's true size; public filings or registries are Tier A. Nobody found → say so: an empty market is a
+finding to explain, not a win to assume.
+
+## 2. Ideal customer profile (ICP)
+
+Answer with the traits that make a customer most likely to buy and succeed, each sourced:
+- **Who:** practice or company type, specialty, size (people, locations), how they are paid (cash-pay vs
+  insurance), what they use today (tools, vendors, workarounds).
+- **Trigger and pain:** the moment they look for a fix, and what the problem costs them.
+- **Fit and disqualifiers:** who is a poor fit, and why.
+Tier A here is the partner's own material (who it says it serves, case studies, job posts), the brief, and public
+registries. Interviews and surveys you cannot read are gaps, not findings.
+
+## 3. Market size: TAM, SAM, SOM
+
+- **TAM** (total addressable market): everyone who could ever buy this. **SAM** (serviceable): the part this
+  company can actually reach (its segment, its country). **SOM** (obtainable): the part it can realistically win
+  in a stated period.
+- **Prefer bottom-up:** count of buyers × value per buyer per year (e.g. practitioners × patients per
+  practitioner × share of patients on the product × annual spend). Top-down (an analyst's total × a share) only as
+  a cross-check.
+- **Every input is a finding with its S-id**; the computed size is an **Inference**, never a Finding, written as:
+  `I<n> from F<a> + F<b>: Formula: <a> × <b> = <result>. Assumptions: <A-1 …>. Range: <low – high>, base <x>.`
+- **Ranges, not false precision:** give low, base and high, each changing one named assumption. Round to two
+  significant figures. State the year and currency of every money input.
+- A number from a paywalled report you could not open is unread: gap, not finding.
+
+## 4. Share the company could capture (SOM)
+
+Ground it in the company's own installed base, the competitors' installed bases (§1) and a cited adoption rate (a
+comparable product's published adoption, a pilot, a survey), never a round guess. No benchmark found → write the formula with the adoption rate as an open
+assumption and a `⚠` gap naming what would close it.
+
+## 5. Where customers cluster
+
+- **Count by place** from public registries: national provider or business registries (e.g. the US NPI registry
+  for clinicians, looked up by its official taxonomy codes), labour statistics by state, licensing boards.
+- Report counts **and per-capita rates** (count ÷ population from census data) by state or metro, top 10 with the
+  date of the data; per-capita shows density, raw counts show volume.
+- Note licensing differences that change who can practise where (some professions are licensed only in some states).
+- The clusters' time zones feed §6: they decide when peak and quiet hours fall.
+
+## 6. Usage and load profile (input to design, not a design)
+
+Turn the expected users into the numbers `design-hld` sizes the system with. Each is an Inference with the same
+`Formula: … Assumptions: … Range: …` form, built from cited findings:
+- **Who uses it, when:** each user role's working hours and moments (e.g. clinicians during clinic hours, patients
+  in the evening), across the clusters' time zones, plus weekly and seasonal swings. The quietest common window is
+  the candidate maintenance window.
+- **How many:** expected users = SOM customers × users per customer × share active per day.
+- **How hard:** peak requests per second = peak-hour active users × actions per user per hour × requests per action
+  ÷ 3600 × a stated burst factor; also average, and peak concurrent users.
+- **What they do that stresses it:** behaviours that create edge cases or load spikes (double submits, retries,
+  many orders at month end, refills on a schedule).
+Never pick machine sizes, languages or tools here: hand each number to `design-hld` as a question. A missing input
+is an assumption with its own range, not a silent default.
+
+## 7. Grading reminders
+- Government datasets and registries: Tier A. Trade associations and major industry analyses you read in full: B.
+  Vendor market claims, blogs, press releases and AI summaries: C, colour only.
+- Market figures date fast: record the "as of" year of every number.
+- Hand the choice back: Handoffs ask `write-prd` which segment to target first and which targets to set, and
+  ask `design-hld` how to size for the load profile; never pick the segment, the stack or the machines yourself.
```

