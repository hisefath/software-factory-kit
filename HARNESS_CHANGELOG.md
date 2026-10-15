# Harness changelog

Every adopted change to a skill, hook, template or supervisor rule, with the FINDINGS row that justified it.

| Date | Version | Change | F# | Approved by (exact words) |
|---|---|---|---|---|
| 2026-10-08 | 0.1 | Initial factory: WORKFLOW.md, skill standard, 22 skills, verifier, templates, scripts | — | "we are putting together the full ai native workflow today" |
| 2026-10-09 | 0.1 | H1: Add North Star metrics and partner lens (docs/METRICS.md, docs/WORKFLOW.md, skills/sharpen-brief, skills/gather-evidence, skills/write-prd) | F3 | "approved" |
| 2026-10-14 | 0.2 (branch) | H31: BMAD principles: sessions, batched checkpoints (GI, GD, GT), Type 2 auto-proceed, readiness check, 3-lens review, merge on green, two-way tracks (WORKFLOW §2-§5, templates/CLAUDE.md, skills/plan-product, plan-design, build-milestone, log-decision, agents/verifier.md, README) | F48 | "lets shift to b-mad principals, and put those changes on a different branch" |
| 2026-10-14 | 0.1 | H30: Measure tokens, human touches and wall-clock per milestone (scripts/measure-usage.sh, report-milestone, WORKFLOW §10, templates) | F47 | "approve" |
| 2026-10-11 | 0.1 | H19: Add `decode-prompt` (phase 0.5, gate G-decode) before sharpen-brief (skills/decode-prompt, skills/sharpen-brief, docs/WORKFLOW.md, templates/CLAUDE.md, README.md) | F28 | "build a skill for this, and this should be before the sharpen brief stage" |
| 2026-10-09 | 0.1 | H3: Add market, competitor and load-profile research (docs/WORKFLOW.md, skills/sharpen-brief, skills/gather-evidence) | F4 | "approve, then /gather-evidence" |
| 2026-10-10 | 0.1 | H6: Add a TL;DR to this project's MR template (cerbo-supplement-store .gitlab/merge_request_templates/Default.md) | F6 | "Approve, adopt H5 and H6" |
| 2026-10-10 | 0.1 | H14: Add the review view and D1-D64 backfill here (cerbo-supplement-store Makefile, docs/decisions/DECISION_JOURNAL.md, docs/decisions/backfill-tags.md, scripts/decision-views.sh) | F25 | "Approve, adopt H13 and H14" |
| 2026-10-10 | 0.1 | H17: Add a pipeline line to this MR template (cerbo-supplement-store .gitlab/merge_request_templates/Default.md) | F27 | "Approve, adopt H18 and H17" |

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

### H3 Add market, competitor and load-profile research  [status: adopted]

- F#: F4 · Layer: Skill · Reach: factory skill (sharpen-brief, gather-evidence) + WORKFLOW.md + new skills/gather-evidence/references/market-research.md · Supersedes: H2
- Proposed: 2026-10-09 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `docs/WORKFLOW.md`, `skills/sharpen-brief/SKILL.md`, `skills/gather-evidence/SKILL.md`, `skills/gather-evidence/references/market-research.md` (new)
- Root cause: PRD targets and design sizing had no market or usage evidence → no research question asked for one → sharpen-brief step 11 never required competitor, market or usage questions → and gather-evidence had no method for sizing a market or a load profile without false precision.
- Why this layer: §10 "Built the wrong thing → Spec" and "Phase procedure botched → Skill": required questions plus Done-when greps make the gap loud at G0, and a reference loaded only for market and usage questions keeps SKILL.md short; load numbers stay inferences handed to design-hld, so research never picks machines or stacks.
- Rules: `skills/sharpen-brief/SKILL.md` 247 → 251 lines, `skills/gather-evidence/SKILL.md` 248 → 252 (ceiling 300 lines); red-flag rows unchanged (6); pruned: none, below ceiling.
- Guard: sharpen-brief Done-when greps print ≥1 R row naming ideal customer or market, and ≥1 naming usage, peak or load; gather-evidence Done-when prints any market, share or load inference lacking `Formula:`, `Assumptions:`, `Range:`.
- Teach: "Before design, my factory finds who already solves the problem, sizes the market and the expected load bottom-up with stated assumptions, so the PRD targets and the system sizing trace to evidence."
- diff-sha256: 255e96814097
- Verdict: adopted 2026-10-10 (Approvals 2026-10-09 19:42 CDT, H3@255e96814097, "approve, then /gather-evidence"); applied 071beeb

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

### H4 Read a bracket in Owns literally  [status: adopted]

- F#: F5 · Layer: Policy (hard) · Reach: factory script
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `scripts/scope-guard.sh`, `scripts/test.sh`
- Root cause: Owns named Nuxt route folders → scope-guard matches Owns as shell case patterns → `[orderId]` became a character class that no path matches → every route-folder file was out of scope.
- Why this layer: §10 "Wrote outside its phase/task → Policy (hard)": the wall itself misread a legal path; a slice-tasks sentence ("avoid brackets") would fight the framework's own folder names.
- Rules: `scripts/scope-guard.sh` and `scripts/test.sh`: no rule count; `bash scripts/test.sh` 119 → 120 passed; pruned: none.
- Guard: `bash scripts/test.sh` prints `ok   scope-guard: a [ in Owns is literal (route folders)`; on today's scope-guard that case fails (checked in a scratch copy).
- Teach: "The boundary check had to understand the framework's file names, because a wall that blocks legal work teaches people to go around it."
- diff-sha256: 85c575806b75
- Verdict: pending G-L5

```diff
--- a/scripts/scope-guard.sh
+++ b/scripts/scope-guard.sh
@@ -17,6 +17,7 @@
 
 Owns: line(s) in the task file hold comma/space separated globs. `*` matches across `/` (shell case
 pattern), so `app/Services/**` and `app/Services/*` both cover every file below app/Services/.
+`[` is literal, so route folders like `server/api/orders/[orderId]/**` work (no character classes).
 A rename counts as delete + add, so both paths must be owned.
 
 Exit: 0 every changed path is owned · 1 a path is out of scope · 2 usage error, unknown ref, or no Owns:
@@ -62,8 +63,9 @@
   [ -n "$f" ] || continue
   n=$((n + 1)) ok=0
   for p in $owns; do
-    # shellcheck disable=SC2254 # $p is deliberately a pattern
-    case $f in $p) ok=1; break ;; esac
+    q=${p//\[/\\[} # a literal [ (Nuxt/Next route folders), never a character class
+    # shellcheck disable=SC2254 # $q is deliberately a pattern
+    case $f in $q) ok=1; break ;; esac
   done
   [ "$ok" = 1 ] || { echo "scope-guard: out of scope: $f" >&2; bad=1; }
 done <<EOF
--- a/scripts/test.sh
+++ b/scripts/test.sh
@@ -219,6 +219,11 @@
 has "scope-guard staged: names the offending path" "$out" "out of scope: other.txt"
 git reset -q -- other.txt && rm other.txt
 rc 2 "scope-guard: task file without Owns: fails closed" bash scripts/scope-guard.sh specs/M1-demo/tasks/T003.md
+TB=specs/M1-demo/tasks/T090.md
+printf 'Owns: src/a.txt, src/[id]/**\n' >"$TB"
+mkdir -p 'src/[id]' && echo z >'src/[id]/b.txt' && git add 'src/[id]/b.txt'
+rc 0 "scope-guard: a [ in Owns is literal (route folders)" bash scripts/scope-guard.sh "$TB"
+git reset -q -- 'src/[id]/b.txt' && rm -r 'src/[id]' "$TB"
 git commit -qm "a"
 rc 0 "scope-guard branch mode: owned commit passes" bash scripts/scope-guard.sh "$T1" milestone/m1-demo
 rc 0 "scope-guard branch mode: absolute task path works" bash scripts/scope-guard.sh "$repo/$T1" milestone/m1-demo
```

### H5 Commit per decision, MR per milestone, TL;DR  [status: adopted]

- F#: F6 · Layer: Skill · Reach: WORKFLOW.md + factory template
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `docs/WORKFLOW.md`, `templates/.gitlab/merge_request_templates/Default.md`
- Root cause: main's history was unreadable → commits were made per tool step and MRs were left for the end → WORKFLOW §8 said how to branch and squash tasks, but not how big a supervisor commit is, when the MR opens, what its description must say, or when merging may be automatic.
- Why this layer: §10 "Phase procedure botched → Skill", at WORKFLOW reach because every skill follows §8; the MR template's TL;DR heading is the checkable part. Not a check: commit size is a judgement no script can grade.
- Rules: `docs/WORKFLOW.md` §8 bullets 6 → 9 (ceiling ~20 rules); pruned: none, below ceiling.
- Guard: `grep -c '^## TL;DR' .gitlab/merge_request_templates/Default.md` prints 1 in a newly initialised repo; `git log --first-parent --format=%s main` reads one line per milestone.
- Teach: "Each merge to main is one milestone with a one-line TL;DR, and each commit inside it is one decision or result, so a reviewer can read the history like a changelog."
- diff-sha256: e6b50c35ca04
- Verdict: pending G-L5

```diff
--- a/docs/WORKFLOW.md
+++ b/docs/WORKFLOW.md
@@ -252,6 +252,15 @@
   with a merge commit (semi-linear), so `git log --first-parent main` reads as a list of milestones and one
   `git revert -m 1 <merge>` rolls a milestone back.
 - Stage files explicitly; never `git add -A`.
+- **Commits read as decisions and results** (owner's rule, 2026-10-10): one commit per decision or result (an
+  approved artifact, a squashed task, a set of review fixes), grouping small related edits; never one per tool
+  step. The subject is one line (at most 72 characters) saying what changed; the body names the D, FR and task ids.
+- **The MR is opened when the milestone branch is first pushed**, and its description fills
+  `.gitlab/merge_request_templates/Default.md`: the one-line TL;DR first, then every section answered, citing the
+  D-ids and the spec paths the milestone delivers.
+- **Auto-merge only on a standing yes:** when `## Approvals` holds the human's standing yes to auto-merge, the
+  supervisor merges the MR once G5 is approved (merge commit, TL;DR as its message) and pushes `main` to the
+  mirror; without that row, merging stays human-only (§2 rule 8).
 - Done = merged **and** `make check` run on main, SHA recorded in `MILESTONES.md` and Resume.
 
 ## 9. Decision journal schema (`docs/decisions/DECISION_JOURNAL.md`, committed)
--- a/templates/.gitlab/merge_request_templates/Default.md
+++ b/templates/.gitlab/merge_request_templates/Default.md
@@ -4,6 +4,10 @@
 Title: M<N> <goal in a few words>
 -->
 
+## TL;DR
+
+<One line: what this milestone changes for a user or a reviewer, in plain words.>
+
 ## What
 
 - Milestone: **M<N>** — <one-sentence goal> · branch `milestone/m<N>-<slug>` · report `docs/milestones/M<N>.md`
```

### H6 Add a TL;DR to this project's MR template  [status: adopted]

- F#: F6 · Layer: Skill · Reach: project
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: cerbo-supplement-store · Files: `.gitlab/merge_request_templates/Default.md`
- Root cause: Same as H5: init-repo never overwrites, so this project keeps the old template until its own copy changes.
- Why this layer: Same as H5; this is the project half the reach rule requires.
- Rules: `.gitlab/merge_request_templates/Default.md`: no rules; one section added; pruned: none.
- Guard: `grep -c '^## TL;DR' .gitlab/merge_request_templates/Default.md` prints 1.
- Teach: "The M5 MR starts with a one-line TL;DR because the template asks for it, not because someone remembered."
- diff-sha256: d14103b14077
- Verdict: adopted 2026-10-11 (Approvals 2026-10-10 17:52 CDT, H6@d14103b14077, "Approve, adopt H5 and H6")

```diff
--- a/.gitlab/merge_request_templates/Default.md
+++ b/.gitlab/merge_request_templates/Default.md
@@ -4,6 +4,10 @@
 Title: M<N> <goal in a few words>
 -->
 
+## TL;DR
+
+<One line: what this milestone changes for a user or a reviewer, in plain words.>
+
 ## What
 
 - Milestone: **M<N>** — <one-sentence goal> · branch `milestone/m<N>-<slug>` · report `docs/milestones/M<N>.md`
```

### H7 Apply, test, commit and push kit changes  [status: adopted]

- F#: F7 · Layer: Script · Reach: factory script + factory skill
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `scripts/apply-proposal.sh` (new), `skills/route-failure/SKILL.md`
- Root cause: the human wanted every factory improvement committed to the kit repo → applying was a pasted awk pipeline, and committing and pushing were separate manual steps → nothing tied them together, so an applied change could sit uncommitted.
- Why this layer: §10 "Mechanical step done wrong → Script": a script that refuses unless the approved hash matches, runs the kit tests, then commits and pushes makes the right path the only path. A git or Claude Code hook (option B) would fire on every edit in the kit, not only on approved proposals.
- Rules: `skills/route-failure/SKILL.md` 254 → 253 lines (ceiling 300); new script, no rules; pruned: the 3-line apply pipeline, replaced by one command.
- Guard: after each adoption `git -C "$KIT" status --porcelain` prints nothing and `git -C "$KIT" log -1 --format=%s` starts `Apply H`; in a scratch repo the script refused a wrong hash (exit 1), reverted a diff whose tests failed (exit 1) and committed and pushed a good one (exit 0).
- Teach: "Factory changes are approved by fingerprint, and one script applies, tests, commits and pushes them, so an improvement can't sit uncommitted on one laptop."
- diff-sha256: 0a9aa1f06a59
- Verdict: pending G-L5

```diff
--- /dev/null
+++ b/scripts/apply-proposal.sh
@@ -0,0 +1,62 @@
+#!/usr/bin/env bash
+# apply-proposal.sh — apply an approved route-failure proposal, then commit and push the factory record.
+#
+# Why this exists: a factory improvement left in a working copy never reaches the next project, so applying,
+# testing, committing and pushing are one command instead of four steps someone must remember (FINDINGS F7).
+# Run it only after the human's G-L5 yes is recorded; it refuses unless the diff bytes hash to the approved value.
+set -euo pipefail
+set -f
+
+usage() {
+  cat <<'EOF'
+usage: scripts/apply-proposal.sh <n> <diff-sha256> [<apply-in path>]
+         apply H<n> from HARNESS_CHANGELOG.md, then commit and push this kit
+       scripts/apply-proposal.sh --record "<message>"
+         commit and push FINDINGS.md and HARNESS_CHANGELOG.md only (a route-failure pass's record)
+
+<apply-in path> defaults to this kit. A project path applies the diff there and commits only the kit's record;
+the project's own commit stays with its supervisor. In the kit, scripts/test.sh must pass or the diff is reverted.
+Exit: 0 done · 1 hash mismatch, apply or test failure · 2 usage error.
+EOF
+}
+
+kit=$(cd "$(dirname "$0")/.." && pwd)
+log=$kit/HARNESS_CHANGELOG.md
+
+commit_push() { # <message> <path>...
+  msg=$1; shift
+  git -C "$kit" add -- "$@"
+  if git -C "$kit" diff --cached --quiet; then echo "apply-proposal: nothing to commit"; return 0; fi
+  git -C "$kit" commit -q -m "$msg"
+  git -C "$kit" push -q origin HEAD
+  echo "apply-proposal: committed and pushed $(git -C "$kit" rev-parse --short HEAD): $msg"
+}
+
+case "${1:-}" in
+  -h | --help) usage; exit 0 ;;
+  --record) [ -n "${2:-}" ] || { usage >&2; exit 2; }; commit_push "$2" FINDINGS.md HARNESS_CHANGELOG.md; exit 0 ;;
+esac
+[ $# -ge 2 ] && [ $# -le 3 ] || { usage >&2; exit 2; }
+n=$1 want=$2 dest=${3:-$kit}
+
+d=$(awk -v h="### H$n " 'index($0,h)==1{f=1;next} f&&/^### /{exit} f&&/^```diff$/{d=1;next} d&&/^```$/{exit} d' "$log")
+[ -n "$d" ] || { echo "apply-proposal: no diff for H$n in $log" >&2; exit 1; }
+got=$(printf '%s\n' "$d" | shasum -a 256 | cut -c1-12)
+[ "$got" = "$want" ] || { echo "apply-proposal: H$n hashes to $got, not the approved $want; ask again" >&2; exit 1; }
+printf '%s\n' "$d" | git -C "$dest" apply
+paths=$(printf '%s\n' "$d" | git -C "$dest" apply --numstat -R | cut -f3)
+
+title=$(grep -m1 "^### H$n " "$log" | sed -E "s/^### H$n //; s/ +\[status:.*//")
+fs=$(sed -n "/^### H$n /,/^### /p" "$log" | grep -m1 -oE 'F#: F[0-9]+( and F[0-9]+)?' | sed 's/^F#: //')
+if [ "$dest" -ef "$kit" ]; then
+  if ! bash "$kit/scripts/test.sh" >/dev/null 2>&1; then
+    printf '%s\n' "$d" | git -C "$kit" apply -R
+    echo "apply-proposal: scripts/test.sh failed with H$n applied; reverted it" >&2
+    exit 1
+  fi
+  # shellcheck disable=SC2086 # paths from git apply --numstat, one per line, no spaces in this kit
+  commit_push "Apply H$n: $title ($fs)" FINDINGS.md HARNESS_CHANGELOG.md $paths
+else
+  commit_push "Record H$n applied in $(basename "$dest"): $title ($fs)" FINDINGS.md HARNESS_CHANGELOG.md
+  echo "apply-proposal: applied H$n in $dest; its supervisor commits: $(printf '%s ' $paths)"
+fi
--- a/skills/route-failure/SKILL.md
+++ b/skills/route-failure/SKILL.md
@@ -219,7 +219,8 @@
 Wrote: $KIT/FINDINGS.md F<a>…F<b> · $KIT/HARNESS_CHANGELOG.md H<x>…H<y> (status proposed) ·
   docs/learnings/<slug>.md | none
 Applied: nothing. No skill, AGENTS.md, CLAUDE.md, hook, script or setting was edited. Nothing was committed:
-  you commit $KIT/FINDINGS.md and $KIT/HARNESS_CHANGELOG.md (the factory's public record) when you are ready.
+  scripts/apply-proposal.sh commits and pushes $KIT/FINDINGS.md and $KIT/HARNESS_CHANGELOG.md with each
+  adopted change, or alone with `--record "route-failure: <summary>"` once G-L5 is answered.
 Earlier proposals: <H<n> → adopted | approved, waiting to be applied | rejected | revise | stale | still waiting>
   · waiting in other projects: <H<n> (<project>)> | none
 Metrics (whole tracker, not only this window): first-pass acceptance <x>/<y> tasks · fix loops <f> FAIL lines
@@ -233,11 +234,9 @@
 On Approve the supervisor writes | <time> | G-L5 | H<n>@<diff-sha256> | <your exact words> | to ## Approvals (the
 block decision for rows without a diff: artifact FINDINGS.md F<a>-F<b>) and runs log-decision; software-factory-kit mode: I
 write your words into H<n>'s Verdict line instead. Only you, or the supervisor after that record, apply it, and the
-command refuses unless the bytes are the ones you approved:
-  d=$(awk -v h='### H<n> ' 'index($0,h)==1{f=1;next} f&&/^### /{exit} f&&/^```diff$/{d=1;next} d&&/^```$/{exit} d' \
-    "<software-factory-kit path>/HARNESS_CHANGELOG.md") && [ "$(printf '%s\n' "$d" | shasum -a 256 | cut -c1-12)" = <diff-sha256> ] &&
-  printf '%s\n' "$d" | git -C "<apply-in path>" apply
-The next route-failure pass records it as adopted.
+command refuses unless the bytes are the ones you approved, then runs the kit's tests, commits and pushes the kit:
+  bash "<software-factory-kit path>/scripts/apply-proposal.sh" <n> <diff-sha256> ["<apply-in path>"]
+The next route-failure pass records it as adopted and commits that record with `apply-proposal.sh --record`.
 Next skill (WORKFLOW §4 milestone close chain): `quiz-me`, once no G-L5 card of this pass is pending. I am not
 starting it.
 ```
```

### H8 Done-when only this task can pass; full Owns  [status: adopted]

- F#: F8 and F9 · Layer: Skill · Reach: factory skill
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `skills/slice-tasks/SKILL.md`
- Root cause: T009's Done-when was green at dispatch → its parts were the suite (turned green by earlier tasks) and make check → slice-tasks step 8's suite-joining recipe told it to run exactly those. T006's Owns missed AppShell and a migration → step 7 says what Owns must not hold but not that it must hold every file the Ask assigns.
- Why this layer: §10 "Phase procedure botched → Skill": the recipe itself produced both defects. implement-task's baseline (a check) already stopped T009; this removes the cause so the check stops firing.
- Rules: `skills/slice-tasks/SKILL.md` 279 → 283 lines (ceiling 300); red-flag rows unchanged (6); pruned: none, below ceiling.
- Guard: F8: `grep -l 'make -n check' specs/M*/tasks/T*.md` names the suite-joining task. F9: ⚠ no mechanical guard; the verifier's spec-fidelity axis is the backstop.
- Teach: "A task's check must be one only that task can turn green; otherwise it passes because of a neighbour's work."
- diff-sha256: d830e46064b7
- Verdict: pending G-L5

```diff
--- a/skills/slice-tasks/SKILL.md
+++ b/skills/slice-tasks/SKILL.md
@@ -120,7 +120,9 @@
    `tests/acceptance/**` (so never `tests/*` or `*`), and never a dependency manifest or lockfile: a slice that
    needs a new package gets a `⚠ Ask-first: <package> for <why>` for G4 (the human adds it and commits before
    dispatch). Mark `parallel: true` only when the task's `Owns:` is disjoint from every other `parallel: true`
-   task; otherwise `parallel: false`, and the supervisor runs it alone.
+   task; otherwise `parallel: false`, and the supervisor runs it alone. Every file the Ask assigns is owned:
+   the component that holds a state the task builds (e.g. the shell that mounts a countdown) and any migration a
+   counter or table in the Ask needs; a missing one surfaces mid-task as an Owns gap and a relaunch.
 8. **Write Done-when before the rest of the body.** One `sh` line: the AT filter for this task, then
    `&& make check`. The filter command is a make target that passes a filter through (e.g.
    `make test FILTER=M1_AT_001`) when AGENTS.md or the Makefile has one; else acceptance.md's `Run one test`
@@ -131,7 +133,9 @@
      assuming its recommendation (acceptance joins `make check` only when the milestone lands). Put that Q-n under
      G4 questions and say the Done-when lines change if G4 picks otherwise (implement-task stops when base
      `make check` is red). If acceptance.md gives the joining config line to a task, give its file to one task that
-     is `after:` every other task, whose Done-when runs all of `tests/acceptance/M<N>` then `make check`.
+     is `after:` every other task, whose Done-when starts `make -n check | grep -q tests/acceptance &&`, then runs
+     all of `tests/acceptance/M<N>`, then `make check`. Without that first part it is green the moment the other
+     tasks land, so it cannot tell whether this task did its job.
    - **Runner outside make.** If a Done-when calls the runner directly, add an Open `⚠`: "scripts/delegate.sh's
      default claude allow-list runs only make/git/date: dispatch claude tasks as Agent-tool subagents, or extend
      DELEGATE_CLAUDE_ALLOWED_TOOLS with the runner (supervisor's call)."
```

### H9 Cite a registry check for every version  [status: adopted]

- F#: F10 · Layer: Skill · Reach: factory skill
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `skills/design-hld/SKILL.md`, `skills/design-lld/SKILL.md`
- Root cause: D38 named Nuxt 3 → the model wrote the version it remembered → neither design skill asked for evidence that a named version is current.
- Why this layer: §10 "Phase procedure botched → Skill", as a Done-when command (a check inside the skill), not a sentence: it prints any decision that names a version without a registry citation.
- Rules: `skills/design-hld/SKILL.md` 226 → 229, `skills/design-lld/SKILL.md` 274 → 277 lines (ceiling 300); red-flag rows unchanged; pruned: none, below ceiling.
- Guard: the awk in the new Done-when prints `### D38 Web framework for the one deployable` on this project's lld.md today, and nothing once a decision cites `npm view <pkg> dist-tags`.
- Teach: "AI picks versions from memory, so every version in a design decision has to cite the registry check that proves it is current."
- diff-sha256: bb53b6150e83
- Verdict: pending G-L5

```diff
--- a/skills/design-hld/SKILL.md
+++ b/skills/design-hld/SKILL.md
@@ -140,6 +140,9 @@
 
 - [ ] Headings match the template, in order: `diff <(grep '^## ' "$S/assets/template.md") <(grep '^## ' $H)`
       prints nothing.
+- [ ] Every decision whose recommendation names a version cites the registry check you ran this session (model
+      memory lags the current major), e.g. `npm view <pkg> dist-tags` and its date, in that decision's block:
+      `awk '/^### D[0-9]+ /{if(v&&!r)print d;d=$0;v=r=0;next} /^## /{if(v&&!r)print d;d="";v=r=0} d&&/^- \*\*Recommendation:\*\*.*[0-9]/{v=1} d&&/(registry|npm view|pip index|go list -m|cargo search|composer show)/{r=1} END{if(v&&!r)print d}' $H` prints nothing.
 - [ ] Filled, with no guide residue: `grep -nE '\{\{|<!-- guide:' $H` prints nothing, and
       ``awk '/^```mermaid/{f=1} /^```$/{f=0;next} !f' $H | grep -E -- '-->' | grep -vxE '<!-- (diagram: [a-z-]+|/diagram) -->'``
       prints nothing.
--- a/skills/design-lld/SKILL.md
+++ b/skills/design-lld/SKILL.md
@@ -196,6 +196,9 @@
       `grep -q '^openapi: 3\.1\.' "$O" || echo "not 3.1"; grep -q 'application/problem+json' "$O" || echo "no problem+json"`
 - [ ] Every problem type used is in the registry:
       `comm -23 <(grep -oE '/problems/[a-z0-9-]+' "$L" | sort -u) <(sed -n '/^### Problem types/,/^### Idempotency/p' "$L" | grep -oE '^\| `/problems/[a-z0-9-]+' | grep -oE '/problems/[a-z0-9-]+' | sort -u)`
+- [ ] Every decision whose recommendation names a version cites the registry check you ran this session (model
+      memory lags the current major), e.g. `npm view <pkg> dist-tags` and its date, in that decision's block:
+      `awk '/^### D[0-9]+ /{if(v&&!r)print d;d=$0;v=r=0;next} /^## /{if(v&&!r)print d;d="";v=r=0} d&&/^- \*\*Recommendation:\*\*.*[0-9]/{v=1} d&&/(registry|npm view|pip index|go list -m|cargo search|composer show)/{r=1} END{if(v&&!r)print d}' "$L"`
 - [ ] Every diagram job has exactly one placeholder:
       ``diff <(grep -oE '<!-- diagram: [a-z0-9-]+ -->' "$L" | awk '{print $3}' | sort) <(sed -n '/^## 10\./,/^## Decisions/p' "$L" | grep -oE '`draw-diagrams [a-z0-9-]+`' | tr -d '`' | awk '{print $2}' | sort)``
 - [ ] §10 is complete:
```

### H10 Prove each test fails on broken code  [status: adopted]

- F#: F11 · Layer: Skill · Reach: factory skill
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `skills/implement-task/SKILL.md`
- Root cause: tests passed while the code could be wrong → red-first proves a test fails when the code is missing, not that it pins the right code → fakes that ignore WHERE clauses or locks, and tests that compare a value with itself, go green for any implementation.
- Why this layer: §10 "Phase procedure botched → Skill". A check would be mutation testing (option B), which needs a new dependency and an Ask-first decision; this step costs nothing to try first.
- Rules: `skills/implement-task/SKILL.md` 275 → 278 lines (ceiling 300); red-flag rows unchanged (6); pruned: none, below ceiling.
- Guard: verifier tests-that-lie rows: 4 with a disposition in M4 (pass5 R1, pass6 R1, pass7 R1, R2); M5 should have 0-1, else move to option B.
- Teach: "A test is only evidence if I have seen it fail when the code is wrong, so I break the line once, watch it go red, and only then trust the green."
- diff-sha256: 50ef7d53d151
- Verdict: pending G-L5

```diff
--- a/skills/implement-task/SKILL.md
+++ b/skills/implement-task/SKILL.md
@@ -145,7 +145,10 @@
    Writing the test first proves it can fail, so its later green means something.
 8. **Green.** Write the smallest code inside `Owns:` that makes the unit tests pass, ported from the map in step 6.
    Re-run the unit tests, then the Done-when. Refactor only while green and only inside `Owns:`. Never weaken an
-   assertion, add a skip, or special-case a test's input to get green.
+   assertion, add a skip, or special-case a test's input to get green. Then break each guarded line once (flip a
+   comparison, drop a WHERE clause, change the hashed string) and paste the red run before restoring it. A test
+   that stays green is checking a fake or itself: test against the real dependency instead (the test database
+   for SQL and locks, the built output for generated config), or name the gap as a question.
 9. **Count corrections.** An attempt to fix a failing check is a correction. If the same error (same test, same
    message) survives 2 corrections, stop: `human_review`, reason "stuck: <error> after 2 corrections", the exact
    output pasted and one question. A different error starts a new count. A third guess usually digs deeper into a
```

### H11 Start worker worktrees from the milestone branch  [status: adopted]

- F#: F12 · Layer: Environment · Reach: factory template (project already does it)
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `templates/CLAUDE.md`
- Root cause: M1 workers started on main → the Agent tool's `isolation: worktree` branches from the default branch → the CLAUDE.md template told the supervisor to use it for code.
- Why this layer: §10 "Flaky setup → Environment": the setup step itself was wrong. No project block: this project's supervisor has created worktrees from the milestone branch since M4 (every M4 DISPATCH line says `from milestone/...`).
- Rules: `templates/CLAUDE.md` list items 12 → 12 (ceiling ~20); pruned: none, one rule rewritten in place.
- Guard: every DISPATCH line names `from milestone/...`, and `git -C <worktree> merge-base --is-ancestor <milestone branch> HEAD` exits 0.
- Teach: "Each worker starts from the milestone branch, so it builds on its teammates' merged work instead of an old main."
- diff-sha256: dfce8aaa4377
- Verdict: pending G-L5

```diff
--- a/templates/CLAUDE.md
+++ b/templates/CLAUDE.md
@@ -63,8 +63,10 @@
 **parallelizable**. Every dispatch needs a contract file with `Owns:` and a runnable Done-when: a task file from
 `slice-tasks`, or for other jobs (diagrams, demo script) a job file you write at `.handoff/runs/<id>/task.md` in the
 same format. Commit the inputs it reads first (workers see the branch, not your working tree).
-- Claude subagent (default): Agent tool, `isolation: worktree` for code; prompt = "Read <abs path>/SKILL.md and
-  follow it for <task file>. HANDOFF_DIR=<abs>/.handoff". Pass paths, never summaries.
+- Claude subagent (default): for code, first `git worktree add .claude/worktrees/<id> -b <task branch>
+  <milestone branch>` (the Agent tool's `isolation: worktree` starts from the default branch, not the milestone);
+  prompt = "Read <abs path>/SKILL.md and follow it for <task file> in <worktree>. HANDOFF_DIR=<abs>/.handoff".
+  Pass paths, never summaries.
 - Other harness: `bash scripts/delegate.sh <task-file>`.
 - Log `DISPATCH <id> harness=<h> why=<one line>` for every job. Never show the verifier a worker's self-report.
 
```

### H12 Let log-decision create a missing journal  [status: adopted]

- F#: F13 · Layer: Skill · Reach: factory skill
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `skills/log-decision/SKILL.md`
- Root cause: log-decision stopped on a new repo → its Inputs row stops when no journal is committed → nothing creates the journal before the first gate on a brownfield repo or before the G-init commit.
- Why this layer: §10 "Phase procedure botched → Skill": the input row's stop made a normal first run fail; copying the kit's template is the tool the row already names.
- Rules: `skills/log-decision/SKILL.md` 267 → 267 lines (ceiling 300); one Inputs row rewritten; pruned: none.
- Guard: ⚠ no mechanical guard: log-decision has no test harness; its STOP line "created the journal" shows the path ran.
- Teach: "The decision log is created by the first decision, so recording never waits on setup."
- diff-sha256: 562b8efd0be7
- Verdict: pending G-L5

```diff
--- a/skills/log-decision/SKILL.md
+++ b/skills/log-decision/SKILL.md
@@ -48,7 +48,7 @@
 | Artifact at the approved version (required) | the row's `artifact@sha`, read with `git show <sha>:<path>`, never from the working tree; G-L5 is checked by hash (Gate sources) | `git cat-file -e <sha>:<path>` fails: stop: "<path> is not committed at <sha>. Commit it and re-record the approval." |
 | Options shown (required) | per Gate sources: the decision's section at that sha, else the owner skill's STOP message or card exactly as the human saw it (the supervisor pastes it verbatim) | Stop: "Which options were shown? Pass the path#section or the exact STOP/card text." |
 | Phase, milestone, gate id (required) | the call; else the artifact's header and the Approvals row. Gate id = the row's gate cell, verbatim | Ask (step 4). |
-| Journal (required) | `docs/decisions/DECISION_JOURNAL.md`, committed: `git cat-file -e HEAD:docs/decisions/DECISION_JOURNAL.md` | Stop: "No committed decision journal. Run scripts/init-repo.sh and commit it; log-decision never creates it." |
+| Journal | `docs/decisions/DECISION_JOURNAL.md`, committed: `git cat-file -e HEAD:docs/decisions/DECISION_JOURNAL.md` | Create it: copy `"${FACTORY_KIT_DIR:-$HOME/Desktop/gauntlet_workbench/software-factory-kit}"/templates/docs/decisions/DECISION_JOURNAL.md` to that path, append as usual (every entry is uncommitted, `L=0`), and say in STOP "created the journal; the supervisor commits it with this entry". No template there: stop and name both paths. |
 | Superseded decision | the call, the human's words, or the option text ("replaces D<k>") | Ask (step 4) when the words hint at one. |
 | Reflection | private words the human offered with the answer | Write none. Never ask. |
 | Proposer harness and model | the artifact's `Written by` row, else the `DISPATCH` line in `.handoff/TRACKER.md ## Log` | `⚠ not recorded` |
```

### H13 Generate a weighted project review of decisions  [status: adopted]

- F#: F25 · Layer: Script · Reach: factory script + WORKFLOW.md + factory skills + templates
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `docs/WORKFLOW.md`, `scripts/decision-views.sh` (new), `scripts/init-repo.sh`, `scripts/test.sh`, `skills/log-decision/SKILL.md`, `skills/log-decision/assets/template.md`, `skills/quiz-me/SKILL.md`, `templates/Makefile.example`, `templates/docs/decisions/DECISION_JOURNAL.md`, `templates/docs/decisions/REVIEW.md` (new)
- Root cause: the human wanted decisions grouped by umbrella topic and weight for project review, a daily standup view and one-liners → the journal is one chronological ledger with no topic, weight or summary field → no script or skill produced any other view.
- Why this layer: §10 "Mechanical step done wrong → Script": a generated view cannot drift from the ledger, and `--check` in `make check` makes a stale view fail. log-decision gains one Review line per entry (Skill) because only it writes entries; quiz-me reads the weights to order teaching.
- Rules: `skills/log-decision/SKILL.md` 267 → 273, `skills/quiz-me/SKILL.md` 295 → 295 (one line rewritten), ceiling 300; WORKFLOW §9 schema 6 → 7 bullets; `scripts/test.sh` 121 → 131 passed with this diff applied in a scratch clone; pruned: none, below ceilings.
- Guard: `bash scripts/test.sh` section 3b passes (stale view and unknown topic both exit 1); in every scaffolded repo `make check` runs `bash scripts/decision-views.sh --check`.
- Teach: "The ledger keeps every decision in time order for reviewing how AI was used, and one script turns it into a topic-and-weight review, so the two views never disagree."
- diff-sha256: 732be0c264af
- Verdict: pending G-L5

```diff
--- a/docs/WORKFLOW.md
+++ b/docs/WORKFLOW.md
@@ -273,8 +273,15 @@
 - Choice · Why (Y-statement: in context C, facing F, we chose X over Y to get Z, accepting W)
 - Cost accepted · Reversibility (Type 1 one-way / Type 2 two-way) · Confidence (low/med/high)
 - Revisit if · Evidence (file:line, R/S ids) · Interview line (one sentence you'd say out loud)
+- Review: Topic <from the journal's Topics: line> · Weight ●●● critical / ●●○ important / ●○○ minor · One-liner (≤ 15 words)
 ```
 
+The journal is the chronological ledger, for reviewing how AI was used. `scripts/decision-views.sh` generates
+`docs/decisions/REVIEW.md` from it for project review: decisions by topic and weight, how the workflow improved,
+and decisions by day (standups); `make check` fails when it is stale. Topics start from the factory default
+(Product, Data, Security, Money, Infrastructure, Process); changing the list is a decision. A project that adopts
+this mid-stream may tag older entries in `docs/decisions/backfill-tags.md` instead of rewriting them.
+
 Private reflections and quiz notes live outside the repo in `~/software-factory-kit-private/<repo>/`.
 
 ## 10. Failure routing (layer 5)
--- /dev/null
+++ b/scripts/decision-views.sh
@@ -0,0 +1,137 @@
+#!/usr/bin/env bash
+# decision-views.sh — generate docs/decisions/REVIEW.md, the project review of decisions (by topic and weight, how
+# the workflow improved, by day), from the chronological ledger docs/decisions/DECISION_JOURNAL.md.
+#
+# Why this exists: the journal is the AI-usage ledger, in time order; a project review needs the same decisions
+# grouped by topic and importance. Generating the view means it never disagrees with the ledger, and `--check` in
+# `make check` makes a stale view fail loudly (FINDINGS F25).
+set -euo pipefail
+
+usage() {
+  cat <<'EOF'
+usage: scripts/decision-views.sh [--check]
+
+  Writes docs/decisions/REVIEW.md from docs/decisions/DECISION_JOURNAL.md (plus docs/decisions/backfill-tags.md
+  when it exists). Run from the repo root.
+  --check  writes nothing; fails if REVIEW.md is missing or stale.
+
+Tags: each entry has a bullet `- Review: Topic <topic> · Weight <●●●|●●○|●○○> · One-liner: <at most 15 words>`.
+Entries written before tags existed can be tagged in backfill-tags.md rows `| D<n> | <topic> | <weight> | <one-liner> |`;
+an entry's own Review line wins. Topics come from the journal's `Topics:` line. Untagged entries are listed as such.
+Exit: 0 ok · 1 stale view, unknown topic or weight, or an over-long one-liner · 2 usage error or no journal.
+EOF
+}
+
+check=0
+case "${1:-}" in
+  -h | --help) usage; exit 0 ;;
+  --check) check=1 ;;
+  "") ;;
+  *) usage >&2; exit 2 ;;
+esac
+
+J=docs/decisions/DECISION_JOURNAL.md
+B=docs/decisions/backfill-tags.md
+OUT=docs/decisions/REVIEW.md
+[ -f "$J" ] || { echo "decision-views: no $J (run from the repo root)" >&2; exit 2; }
+[ -f "$B" ] || B=/dev/null
+
+tmp=$(mktemp)
+trap 'rm -f "$tmp"' EXIT
+
+awk -v bf="$B" '
+function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
+function wn(w) { return w == "●●●" ? 3 : w == "●●○" ? 2 : w == "●○○" ? 1 : 0 }
+function err(m) { print "decision-views: " m > "/dev/stderr"; bad = 1 }
+function mark(i) {
+  if (st[i] ~ /^superseded-by/) { r = st[i]; sub(/superseded-by /, "", r); return " (replaced by " r ")" }
+  if (st[i] == "rejected") return " (rejected)"
+  if (st[i] == "proposed") return " (proposed)"
+  return ""
+}
+function line(i) { return (st[i] ~ /^superseded-by/ ? "~~D" id[i] "~~" : "D" id[i]) " — " one[i] mark(i) }
+FILENAME == bf {
+  if ($0 ~ /^\| D[0-9]+ \|/) {
+    split($0, cc, "|"); k = trim(cc[2]); sub(/^D/, "", k)
+    btop[k] = trim(cc[3]); bw[k] = trim(cc[4]); bone[k] = trim(cc[5])
+  }
+  next
+}
+/^Topics:/ && !nt {
+  s = $0; sub(/^Topics:[ \t]*/, "", s); nt = split(s, tl, / · /)
+  for (t = 1; t <= nt; t++) { tl[t] = trim(tl[t]); known[tl[t]] = 1 }
+  next
+}
+/^### D[0-9]+ / {
+  n++; d = $2; sub(/^D/, "", d); id[n] = d
+  s = $0; sub(/^### D[0-9]+ /, "", s); title[n] = s; sub(/ +\[status:.*/, "", title[n])
+  sub(/.*\[status: /, "", s); sub(/\].*/, "", s); st[n] = s
+  next
+}
+n && date[n] == "" && match($0, /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/) { date[n] = substr($0, RSTART, RLENGTH) }
+n && /^- Review: / {
+  s = $0; sub(/^- Review: /, "", s); split(s, p, / · /)
+  top[n] = trim(p[1]); sub(/^Topic /, "", top[n])
+  w[n] = trim(p[2]); sub(/^Weight /, "", w[n])
+  one[n] = trim(p[3]); sub(/^One-liner: /, "", one[n])
+}
+n && match($0, /HARNESS_CHANGELOG\.md H[0-9]+/) { h[n] = substr($0, RSTART + 21, RLENGTH - 21) }
+n && match($0, /FINDINGS\.md F[0-9]+(, F[0-9]+)*/) { f[n] = substr($0, RSTART + 12, RLENGTH - 12) }
+END {
+  for (i = 1; i <= n; i++) {
+    k = id[i]
+    if (top[i] == "" && (k in btop)) { top[i] = btop[k]; w[i] = bw[k]; one[i] = bone[k] }
+    if (one[i] == "") one[i] = title[i]
+    if (top[i] == "") { top[i] = "Untagged"; continue }
+    if (!(top[i] in known)) err("D" k ": unknown topic \"" top[i] "\" (journal Topics: line)")
+    if (!wn(w[i])) err("D" k ": weight must be ●●●, ●●○ or ●○○")
+    if (split(one[i], x, / +/) > 15) err("D" k ": one-liner over 15 words")
+  }
+  if (bad) exit 1
+  print "# Project review"
+  print ""
+  print "<!-- Generated by scripts/decision-views.sh from DECISION_JOURNAL.md (and backfill-tags.md). Do not edit:"
+  print "     change the journal or the backfill table, then run the script. make check fails when this file is stale. -->"
+  print ""
+  print "Every decision grouped by topic, most important first. The chronological ledger, with every option, cost and"
+  print "quote, is [DECISION_JOURNAL.md](DECISION_JOURNAL.md)."
+  print "Weight: ●●● critical (hard to undo, or touches money, personal data or sign-in) · ●●○ important · ●○○ minor."
+  print ""
+  print "## By topic"
+  if (!n) { print ""; print "- none yet" }
+  tl[++nt] = "Untagged"
+  for (t = 1; t <= nt; t++) {
+    c = 0
+    for (i = 1; i <= n; i++) if (top[i] == tl[t]) c++
+    if (!c) continue
+    print ""; print "### " tl[t] " (" c ")"; print ""
+    for (v = 3; v >= 0; v--) for (old = 0; old <= 1; old++) for (i = 1; i <= n; i++)
+      if (top[i] == tl[t] && wn(w[i]) == v && (st[i] ~ /^superseded-by/) == old) print "- " (v ? w[i] " " : "") line(i)
+  }
+  print ""
+  print "## How the workflow improved"
+  print ""
+  print "Decisions that adopted a software-factory-kit change (H) and the finding (F) behind it, oldest first."
+  print ""
+  c = 0
+  for (i = 1; i <= n; i++) if (h[i] != "") { c++; print "- " date[i] " · D" id[i] " · " h[i] (f[i] != "" ? " · " f[i] : "") " — " one[i] mark(i) }
+  if (!c) print "- none yet"
+  print ""
+  print "## By day"
+  if (!n) { print ""; print "- none yet" }
+  for (i = n; i >= 1; i--) {
+    if (date[i] != last) { print ""; print "### " (date[i] == "" ? "undated" : date[i]); print ""; last = date[i] }
+    print "- D" id[i] " · " top[i] (wn(w[i]) ? " · " w[i] : "") " — " one[i] mark(i)
+  }
+}' "$B" "$J" >"$tmp"
+
+if [ "$check" = 1 ]; then
+  if ! cmp -s "$tmp" "$OUT"; then
+    echo "decision-views: $OUT is missing or stale; run: bash scripts/decision-views.sh" >&2
+    exit 1
+  fi
+  echo "decision-views: $OUT is current"
+else
+  cp "$tmp" "$OUT"
+  echo "decision-views: wrote $OUT"
+fi
--- a/scripts/init-repo.sh
+++ b/scripts/init-repo.sh
@@ -12,11 +12,11 @@
 Scaffolds into <repo-dir> (must be the root of a git repository):
   templates/**                      → same paths (AGENTS.md, CLAUDE.md, .claude/settings.json, .githooks/pre-push,
                                        .gitlab/merge_request_templates/Default.md, .handoff/TRACKER.md, MILESTONES.md,
-                                       docs/README.md, docs/decisions/DECISION_JOURNAL.md, specs/_templates/*)
+                                       docs/README.md, docs/decisions/{DECISION_JOURNAL,REVIEW}.md, specs/_templates/*)
   templates/Makefile.example        → Makefile when the repo has none (its check target fails until you adapt it);
                                        Makefile.example when a Makefile exists without a `check:` target
   agents/verifier.md                → .claude/agents/verifier.md
-  scripts/{scope-guard,delegate,embed-diagrams}.sh → scripts/
+  scripts/{scope-guard,delegate,embed-diagrams,decision-views}.sh → scripts/
   .handoff/{inbox,runs,reviews}/    (with .gitkeep so git tracks them)
   git config core.hooksPath .githooks   (only if hooksPath is unset or already .githooks)
   .gitignore lines: .handoff/runs/*/events.jsonl  .handoff/runs/*/stderr.log  docs/demo/raw/
@@ -89,7 +89,7 @@
 done < <(find "$tpl" -type f ! -name .DS_Store | LC_ALL=C sort)
 
 put "$kit/agents/verifier.md" .claude/agents/verifier.md
-for s in scope-guard.sh delegate.sh embed-diagrams.sh; do
+for s in scope-guard.sh delegate.sh embed-diagrams.sh decision-views.sh; do
   put "$kit/scripts/$s" "scripts/$s" 755
 done
 
--- a/scripts/test.sh
+++ b/scripts/test.sh
@@ -53,7 +53,7 @@
 for f in "$kit"/scripts/*.sh "$kit/templates/.githooks/pre-push"; do
   rc 0 "bash -n ${f#"$kit"/}" bash -n "$f"
 done
-for s in scope-guard delegate embed-diagrams init-repo install test; do
+for s in scope-guard delegate embed-diagrams decision-views init-repo install test; do
   rc 0 "$s.sh -h prints usage" bash "$kit/scripts/$s.sh" -h
   has "$s.sh -h starts with usage:" "$out" "usage: scripts/$s.sh"
 done
@@ -76,7 +76,7 @@
   .gitlab/merge_request_templates/Default.md .handoff/TRACKER.md .handoff/inbox/.gitkeep .handoff/runs/.gitkeep \
   .handoff/reviews/.gitkeep MILESTONES.md docs/README.md docs/decisions/DECISION_JOURNAL.md \
   specs/_templates/task.md specs/_templates/result.md Makefile scripts/scope-guard.sh scripts/delegate.sh \
-  scripts/embed-diagrams.sh; do
+  scripts/embed-diagrams.sh scripts/decision-views.sh docs/decisions/REVIEW.md; do
   [ -f "$repo/$f" ] || missing="$missing $f"
 done
 for f in AGENTS.md CLAUDE.md; do
@@ -276,6 +276,24 @@
 hasnt "embed: doc untouched when .mmd is missing" docs/x.md '```mermaid'
 printf '<!-- diagram: ../../etc/passwd -->\n' >docs/y.md
 rc 1 "embed: path-like diagram type is rejected" bash scripts/embed-diagrams.sh docs/y.md
+
+# ---- 3b. decision-views ----------------------------------------------------------------------------------
+rc 0 "decision-views: the scaffolded REVIEW.md is current" bash scripts/decision-views.sh --check
+cp docs/decisions/DECISION_JOURNAL.md "$tmp/journal.bak"
+cat >>docs/decisions/DECISION_JOURNAL.md <<'EOF'
+
+### D1 Charge once per order  [status: accepted]
+- Date 2026-10-10 18:00 CDT · phase 6 design-lld · milestone M1
+- Review: Topic Money · Weight ●●● · One-liner: One charge per order, guarded by an idempotency key.
+EOF
+rc 1 "decision-views: --check fails when REVIEW.md is stale" bash scripts/decision-views.sh --check
+rc 0 "decision-views: regenerates REVIEW.md" bash scripts/decision-views.sh
+has "decision-views: groups by topic and weight" docs/decisions/REVIEW.md "- ●●● D1 — One charge per order, guarded by an idempotency key."
+has "decision-views: lists decisions by day" docs/decisions/REVIEW.md "- D1 · Money · ●●● — One charge per order"
+rc 0 "decision-views: --check passes once regenerated" bash scripts/decision-views.sh --check
+replace_line docs/decisions/DECISION_JOURNAL.md 'Topic Money' 'Topic Billing'
+rc 1 "decision-views: refuses a topic missing from the Topics: line" bash scripts/decision-views.sh
+cp "$tmp/journal.bak" docs/decisions/DECISION_JOURNAL.md && bash scripts/decision-views.sh >/dev/null
 
 # ---- 4. delegate -----------------------------------------------------------------------------------------
 tracker=.handoff/TRACKER.md
--- a/skills/log-decision/SKILL.md
+++ b/skills/log-decision/SKILL.md
@@ -147,6 +147,9 @@
      Evidence = `file:line`, R/S ids, `proposed as <path> D<k>` (artifacts with D sections),
      `approval <gate id> <row time>`.
    - Interview line: one sentence of at most 30 words the human could say out loud: what, why, at what cost.
+   - Review line, for the project review: Topic = one name from the journal's `Topics:` line (none fits: the closest,
+     plus an Open ⚠ asking whether to add a topic); Weight = ●●● critical (Type 1, or touches money, personal data
+     or sign-in), ●●○ important, ●○○ minor; One-liner = what was chosen, over what, at what cost, in ≤ 15 words.
    - Secrets, credentials, PHI or personal data inside a quote → `[redacted: <kind>]`, and tell the human why (the
      repo is public).
 6. **Write the journal.** Right before each write, recompute the next id:
@@ -173,7 +176,8 @@
 8. **Private reflection, only if offered.**
    `R=~/software-factory-kit-private/$(basename "$(git rev-parse --show-toplevel)"); mkdir -p "$R"`, then append Part 3 to
    `$R/REFLECTIONS.md` with the human's words verbatim.
-9. **Verify.** Run every Done-when check; fix and re-run until all pass. Then send STOP.
+9. **Verify.** Regenerate the project review with `bash scripts/decision-views.sh` (when the script exists), then
+   run every Done-when check; fix and re-run until all pass. Then send STOP.
 
 ## Output
 
@@ -187,7 +191,9 @@
 
 Start each check's shell call with the step-1 check prelude (`J=…; L=…`). Each check states what it must print.
 
-- [ ] Only owned paths changed: `git status --porcelain` = the step-1 output plus `$J`, new
+- [ ] Every uncommitted entry has a Review line, and the review view is current; prints nothing:
+      `awk -v l="$L" '/^### D[0-9]+ /{if(n>l&&!r)print "D" n ": no Review line"; n=substr($2,2)+0; r=0} /^- Review: Topic /{r=1} END{if(n>l&&!r)print "D" n ": no Review line"}' "$J"; [ ! -f scripts/decision-views.sh ] || bash scripts/decision-views.sh --check >/dev/null`
+- [ ] Only owned paths changed: `git status --porcelain` = the step-1 output plus `$J`, `docs/decisions/REVIEW.md`, new
       `docs/decisions/[0-9][0-9][0-9][0-9]-*.md`, and an older record only when it was superseded.
 - [ ] Committed history intact: `diff <(git show HEAD:"$J") "$J" | grep '^<'` prints only `### D` heading lines and
       lines containing `pending — no quoted words yet`.
@@ -239,7 +245,7 @@
 Wrote: docs/decisions/DECISION_JOURNAL.md (+D<a>…D<b> | nothing appended); status edits: <D<k> proposed→accepted | D<k> superseded-by D<m> | none>
        <docs/decisions/NNNN-<slug>.md (Type 1 record) | no record: no accepted Type 1>
        <reflection appended to ~/software-factory-kit-private/<repo>/REFLECTIONS.md (outside the repo) | no reflection offered>
-- D<n> <title> [<status>] · <Type 1 one-way | Type 2 two-way>
+- D<n> <title> [<status>] · <Type 1 one-way | Type 2 two-way> · <Topic> <Weight>: <One-liner>
   You chose <X> over <Y>; you pay <W>; revisit if <trigger>.
   Interview line: "<...>"
 Nothing recorded for: <what and why, e.g. "Revise asked for a fourth option; nothing chosen yet" | none>
--- a/skills/log-decision/assets/template.md
+++ b/skills/log-decision/assets/template.md
@@ -43,6 +43,7 @@
 - Choice: {{option | none}} · Why: In the context of {{C}}, facing {{F}}, we chose {{X}} over {{Y}} to get {{Z}}, accepting {{W}}.
 - Cost accepted: {{W in plain words}} · Reversibility: {{Type 1 one-way | Type 2 two-way}} — {{why, in plain words}} · Confidence: {{low | med | high}}
 - Revisit if: {{observable trigger, ideally a metric or signal | ⚠ <question>}} · Evidence: {{file:line; R<NN>/S ids}}; {{proposed as <path> D<k>; }}approval {{gate id}} {{Approvals row time}}{{; ADR: docs/decisions/NNNN-slug.md}} · Interview line: "{{one sentence ≤ 30 words: what you chose, why, what it cost}}"
+- Review: Topic {{one name from the journal's Topics: line}} · Weight {{●●● | ●●○ | ●○○}} · One-liner: {{≤ 15 words: chosen, over what, at what cost}}
 
 ## Part 2 — one-way decision record `docs/decisions/{{NNNN}}-{{slug}}.md` (MADR 4)
 
--- a/skills/quiz-me/SKILL.md
+++ b/skills/quiz-me/SKILL.md
@@ -130,7 +130,7 @@
    shipped design element with no D-row (table, endpoint, state owner, sequence, invariant, trust boundary): G3
    asks the human to defend every one. Order:
    (a) never taught: the id is on no `^Taught:` line (`grep '^Taught:' <F> | grep -cE '\b<id>\b'` prints 0);
-   (b) Type 1 (one-way door); (c) low confidence; (d) most depended on: the higher
+   (b) weight ●●● in `docs/decisions/REVIEW.md` (when it exists), then Type 1 (one-way door); (c) low confidence; (d) most depended on: the higher
    `cat docs/architecture/hld.md docs/architecture/lld.md docs/milestones/M<N>.md 2>/dev/null | grep -cE '\b<id>\b'`;
    (e) due rows. Take at most 6 topics per session; the rest go to "Not yet taught" in STOP.
 4. **Teach, one topic card per message** (template Part 1, Teach card), then wait. Write middle-school clear:
--- a/templates/Makefile.example
+++ b/templates/Makefile.example
@@ -6,10 +6,10 @@
 # Commands table in AGENTS.md). Until then they fail on purpose, so an unconfigured repo can never look green.
 # Keep the target names: skills and hooks call `make check`, not the tools directly.
 
-.PHONY: check lint types test
+.PHONY: check lint types test decisions
 
-## check: lint + types + tests — the gate
-check: lint types test
+## check: lint + types + tests + decision review in sync — the gate
+check: lint types test decisions
 	@echo "make check: OK"
 
 ## lint: formatting / style, in check-only mode (never rewrite files here)
@@ -24,6 +24,10 @@
 test:
 	@echo "make test: not configured — edit Makefile (see the Laravel example below)" >&2; exit 1
 
+## decisions: docs/decisions/REVIEW.md matches the decision journal (works as is; no adapting needed)
+decisions:
+	bash scripts/decision-views.sh --check
+
 # --- Example: Laravel 13 / PHP 8.5 (Pint + Larastan/PHPStan + Pest or PHPUnit) -------------------------------
 # Replace the three recipes above with these (recipe lines must start with a TAB):
 #
--- a/templates/docs/decisions/DECISION_JOURNAL.md
+++ b/templates/docs/decisions/DECISION_JOURNAL.md
@@ -8,7 +8,11 @@
   `superseded-by D<m>`. Rejected options stay visible.
 - One-way (Type 1) decisions are also promoted to `docs/decisions/NNNN-<slug>.md`.
 - Who said yes, word for word, lives in `.handoff/TRACKER.md ## Approvals`; this file holds the reasoning.
+- Topics group decisions in the project review, `docs/decisions/REVIEW.md`, which
+  `scripts/decision-views.sh` generates from this ledger. Changing the list is itself a decision.
 
+Topics: Product · Data · Security · Money · Infrastructure · Process
+
 ## Entry schema
 
 Copy this block for each new entry (D-ids increase by one, starting at D1):
@@ -21,6 +25,7 @@
 - Choice · Why (Y-statement: in context C, facing F, we chose X over Y to get Z, accepting W)
 - Cost accepted · Reversibility (Type 1 one-way / Type 2 two-way) · Confidence (low/med/high)
 - Revisit if · Evidence (file:line, R/S ids) · Interview line (one sentence you'd say out loud)
+- Review: Topic <topic> · Weight <●●●|●●○|●○○> · One-liner: <at most 15 words>
 ```
 
 ## Entries
--- /dev/null
+++ b/templates/docs/decisions/REVIEW.md
@@ -0,0 +1,22 @@
+# Project review
+
+<!-- Generated by scripts/decision-views.sh from DECISION_JOURNAL.md (and backfill-tags.md). Do not edit:
+     change the journal or the backfill table, then run the script. make check fails when this file is stale. -->
+
+Every decision grouped by topic, most important first. The chronological ledger, with every option, cost and
+quote, is [DECISION_JOURNAL.md](DECISION_JOURNAL.md).
+Weight: ●●● critical (hard to undo, or touches money, personal data or sign-in) · ●●○ important · ●○○ minor.
+
+## By topic
+
+- none yet
+
+## How the workflow improved
+
+Decisions that adopted a software-factory-kit change (H) and the finding (F) behind it, oldest first.
+
+- none yet
+
+## By day
+
+- none yet
```

### H14 Add the review view and D1-D64 backfill here  [status: adopted]

- F#: F25 · Layer: Script · Reach: project
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: cerbo-supplement-store · Files: `Makefile`, `docs/decisions/DECISION_JOURNAL.md`, `docs/decisions/backfill-tags.md` (new), `scripts/decision-views.sh` (new)
- Root cause: Same as H13: init-repo never overwrites, so this project needs its own script copy, the Topics line, the check target, and a backfill table for the 64 decisions written before Review lines existed.
- Why this layer: Same as H13; the backfill table tags old entries without rewriting the append-only journal.
- Rules: `Makefile` check gains one target; `docs/decisions/DECISION_JOURNAL.md` header gains the Topics line and the schema's Review bullet (no entry changes); new `docs/decisions/backfill-tags.md` with 64 rows; pruned: none.
- Guard: `make decisions` exits 0 after `bash scripts/decision-views.sh`; in a scratch copy REVIEW.md lists Product 10, Data 8, Security 6, Money 8, Infrastructure 9, Process 23, Untagged 0.
- Teach: "Cerbo's whole decision history, D1 to D64, now reads by topic and weight, including how the workflow itself improved."
- diff-sha256: eb8d763f6268
- Verdict: adopted 2026-10-11 (Approvals 2026-10-10 18:23 CDT, H14@eb8d763f6268, "Approve, adopt H13 and H14")

```diff
--- a/Makefile
+++ b/Makefile
@@ -6,10 +6,10 @@
 # Commands table in AGENTS.md). Until then they fail on purpose, so an unconfigured repo can never look green.
 # Keep the target names: skills and hooks call `make check`, not the tools directly.
 
-.PHONY: check lint types test setup db-test-up test-acceptance test-acceptance-m4
+.PHONY: check lint types test setup db-test-up test-acceptance test-acceptance-m4 decisions
 
-## check: lint + types + tests + M4 acceptance suite — the gate
-check: lint types test test-acceptance-m4
+## check: lint + types + tests + M4 acceptance suite + decision review in sync — the gate
+check: lint types test test-acceptance-m4 decisions
 	@echo "make check: OK"
 
 ## lint: workflow scripts must parse (docs-only phase: no product code yet; stack tools are added at M3 design)
@@ -25,6 +25,10 @@
 	npx vitest run --dir tests/unit --passWithNoTests
 	@set -- docs/architecture/*.md; if [ -e "$$1" ]; then bash scripts/embed-diagrams.sh --check "$$@"; fi
 
+## decisions: docs/decisions/REVIEW.md matches the decision journal and backfill-tags.md
+decisions:
+	bash scripts/decision-views.sh --check
+
 ## setup: install the pinned dependencies (package-lock.json)
 setup:
 	npm ci
--- a/docs/decisions/DECISION_JOURNAL.md
+++ b/docs/decisions/DECISION_JOURNAL.md
@@ -8,7 +8,11 @@
   `superseded-by D<m>`. Rejected options stay visible.
 - One-way (Type 1) decisions are also promoted to `docs/decisions/NNNN-<slug>.md`.
 - Who said yes, word for word, lives in `.handoff/TRACKER.md ## Approvals`; this file holds the reasoning.
+- Topics group decisions in the project review, `docs/decisions/REVIEW.md`, which
+  `scripts/decision-views.sh` generates from this ledger. Changing the list is itself a decision.
 
+Topics: Product · Data · Security · Money · Infrastructure · Process
+
 ## Entry schema
 
 Copy this block for each new entry (D-ids increase by one, starting at D1):
@@ -21,6 +25,7 @@
 - Choice · Why (Y-statement: in context C, facing F, we chose X over Y to get Z, accepting W)
 - Cost accepted · Reversibility (Type 1 one-way / Type 2 two-way) · Confidence (low/med/high)
 - Revisit if · Evidence (file:line, R/S ids) · Interview line (one sentence you'd say out loud)
+- Review: Topic <topic> · Weight <●●●|●●○|●○○> · One-liner: <at most 15 words>
 ```
 
 ## Entries
--- /dev/null
+++ b/docs/decisions/backfill-tags.md
@@ -0,0 +1,73 @@
+# Backfill tags for D1–D64
+
+Topic, weight and one-liner for the decisions written before journal entries carried a `- Review:` line
+(software-factory-kit WORKFLOW.md §9). `scripts/decision-views.sh` reads this table as if each line were in its
+entry, so the project review (`REVIEW.md`) covers the whole history while the journal stays untouched. Approved once
+as a whole; a correction is a new decision. Weight: ●●● critical · ●●○ important · ●○○ minor.
+
+| D | Topic | Weight | One-liner |
+|---|---|---|---|
+| D1 | Infrastructure | ●●● | v1: Laravel 13 on PHP 8.5, set aside with the v1 build. |
+| D2 | Data | ●●● | v1: Postgres in production, SQLite in tests, suite run on both. |
+| D3 | Money | ●●● | v1: 75 bps fee on the subtotal, once per order, rounded half-up. |
+| D4 | Money | ●●● | v1: split stored on the order plus a settlement ledger. |
+| D5 | Money | ●●● | v1: reserve, charge outside a transaction, then settle. |
+| D6 | Data | ●●○ | v1: stock column plus movement log, decremented at payment. |
+| D7 | Infrastructure | ●○○ | v1: outside services stubbed behind seams. |
+| D8 | Product | ●●○ | v1: an explicit out-of-scope list. |
+| D9 | Process | ●○○ | v1: diagrams as .mmd sources with embedded copies. |
+| D10 | Process | ●○○ | v1: changes from a design-review panel accepted. |
+| D11 | Data | ●○○ | v1: one stock path through a single method. |
+| D12 | Product | ●○○ | v1: order cancel added to scope. |
+| D13 | Infrastructure | ●●○ | v1: Railway with a Dockerfile and Railway Postgres. |
+| D14 | Product | ●○○ | v1: neutral branding on the public demo. |
+| D15 | Process | ●○○ | v1: repo visibility stays the human's step. |
+| D16 | Process | ●○○ | v1: changes from a code-review panel accepted. |
+| D17 | Data | ●●○ | v1: never edit a migration that already ran in production. |
+| D18 | Process | ●●● | Restarted from scratch on a milestone branch with the gated workflow. |
+| D19 | Process | ●○○ | Docs-only rules until the stack was designed. |
+| D20 | Process | ●○○ | Harness findings F1–F3 routed at M1 close. |
+| D21 | Process | ●●○ | Briefs and PRDs name a North Star and the hiring partner's lens. |
+| D22 | Process | ●●● | The v1 build in main is set aside: never read, cited or reused. |
+| D23 | Process | ●○○ | Full track for the M1 brief. |
+| D24 | Process | ●●○ | Research sizes market, competitors and load before design. |
+| D25 | Product | ●●● | Money path first, HIPAA-ready, campaigns later. |
+| D26 | Security | ●●● | Sign-in, notices without health details, no patient identity for platform staff. |
+| D27 | Product | ●●○ | Live payout builder, two-step patient checkout, equation-first audit. |
+| D28 | Product | ●●○ | UX contract: 9 screens, six states each, 90-second demo. |
+| D29 | Money | ●●○ | Financial report with gross and net; four least-privilege operations roles. |
+| D30 | Product | ●○○ | Operations layouts: order funnel, balance-first report, people-list access. |
+| D31 | Product | ●○○ | UX contract extended to M6: 14 screens, every key screen demoed. |
+| D32 | Infrastructure | ●●● | TypeScript on Node.js with server-rendered Vue, matching Cerbo's front end. |
+| D33 | Data | ●●● | PostgreSQL managed by the host. |
+| D34 | Infrastructure | ●●○ | Pages and logic deploy together as one app. |
+| D35 | Money | ●●● | Split stored on the paid order plus an append-only ledger. |
+| D36 | Infrastructure | ●●● | One deployable, built API-first. |
+| D37 | Security | ●●○ | Seeded test accounts with server-side sessions. |
+| D38 | Infrastructure | ●●● | Nuxt 3 as the web framework, named from model memory. |
+| D39 | Data | ●●○ | Kysely queries with plain SQL migrations. |
+| D40 | Data | ●●○ | Bigint identity keys, order number = id, random tokens for outside links. |
+| D41 | Money | ●●● | One idempotency_keys table plus database backstops stop double charges. |
+| D42 | Money | ●●● | Synchronous charge between short transactions; webhooks for production. |
+| D43 | Product | ●○○ | Broader holistic-care products parked as a future non-goal. |
+| D44 | Infrastructure | ●●● | Nuxt 4, the current major per the npm registry. |
+| D45 | Process | ●●○ | M4 built as 9 vertical slices, tracer bullet first. |
+| D46 | Process | ●○○ | App code type-checked with vue-tsc inside make check. |
+| D47 | Money | ●●○ | A negative payout at payment sends the order to review. |
+| D48 | Process | ●○○ | Stacked milestones M1 to M4 merge in order. |
+| D49 | Security | ●○○ | node-forge advisory accepted: Nuxt dev tooling only. |
+| D50 | Security | ●○○ | braces advisory accepted: build tooling only. |
+| D51 | Security | ●○○ | simple-git advisory accepted: Nuxt devtools only. |
+| D52 | Security | ●●○ | SameSite cookies plus JSON-only requests as the CSRF defence. |
+| D53 | Product | ●○○ | Order quantity unbounded until stock limits exist. |
+| D54 | Process | ●○○ | M4 keeps 11 tasks as a one-time exception. |
+| D55 | Infrastructure | ●●○ | Demo deployed from the M4 branch before the merge chain. |
+| D56 | Data | ●○○ | Demo database runs PostgreSQL 18 while tests run 16. |
+| D57 | Process | ●●○ | One script applies, tests, commits and pushes factory changes. |
+| D58 | Process | ●●○ | Commit per decision, one MR per milestone, TL;DR first. |
+| D59 | Process | ●○○ | This repo's MR template starts with a TL;DR. |
+| D60 | Process | ●●○ | A test counts only after it is seen failing on broken code. |
+| D61 | Process | ●○○ | scope-guard reads brackets in Owns literally. |
+| D62 | Process | ●●○ | Each task's check is one only that task can pass. |
+| D63 | Process | ●●○ | Versions in design decisions cite a registry check. |
+| D64 | Process | ●○○ | Worker worktrees start from the milestone branch. |
--- /dev/null
+++ b/scripts/decision-views.sh
@@ -0,0 +1,137 @@
+#!/usr/bin/env bash
+# decision-views.sh — generate docs/decisions/REVIEW.md, the project review of decisions (by topic and weight, how
+# the workflow improved, by day), from the chronological ledger docs/decisions/DECISION_JOURNAL.md.
+#
+# Why this exists: the journal is the AI-usage ledger, in time order; a project review needs the same decisions
+# grouped by topic and importance. Generating the view means it never disagrees with the ledger, and `--check` in
+# `make check` makes a stale view fail loudly (FINDINGS F25).
+set -euo pipefail
+
+usage() {
+  cat <<'EOF'
+usage: scripts/decision-views.sh [--check]
+
+  Writes docs/decisions/REVIEW.md from docs/decisions/DECISION_JOURNAL.md (plus docs/decisions/backfill-tags.md
+  when it exists). Run from the repo root.
+  --check  writes nothing; fails if REVIEW.md is missing or stale.
+
+Tags: each entry has a bullet `- Review: Topic <topic> · Weight <●●●|●●○|●○○> · One-liner: <at most 15 words>`.
+Entries written before tags existed can be tagged in backfill-tags.md rows `| D<n> | <topic> | <weight> | <one-liner> |`;
+an entry's own Review line wins. Topics come from the journal's `Topics:` line. Untagged entries are listed as such.
+Exit: 0 ok · 1 stale view, unknown topic or weight, or an over-long one-liner · 2 usage error or no journal.
+EOF
+}
+
+check=0
+case "${1:-}" in
+  -h | --help) usage; exit 0 ;;
+  --check) check=1 ;;
+  "") ;;
+  *) usage >&2; exit 2 ;;
+esac
+
+J=docs/decisions/DECISION_JOURNAL.md
+B=docs/decisions/backfill-tags.md
+OUT=docs/decisions/REVIEW.md
+[ -f "$J" ] || { echo "decision-views: no $J (run from the repo root)" >&2; exit 2; }
+[ -f "$B" ] || B=/dev/null
+
+tmp=$(mktemp)
+trap 'rm -f "$tmp"' EXIT
+
+awk -v bf="$B" '
+function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
+function wn(w) { return w == "●●●" ? 3 : w == "●●○" ? 2 : w == "●○○" ? 1 : 0 }
+function err(m) { print "decision-views: " m > "/dev/stderr"; bad = 1 }
+function mark(i) {
+  if (st[i] ~ /^superseded-by/) { r = st[i]; sub(/superseded-by /, "", r); return " (replaced by " r ")" }
+  if (st[i] == "rejected") return " (rejected)"
+  if (st[i] == "proposed") return " (proposed)"
+  return ""
+}
+function line(i) { return (st[i] ~ /^superseded-by/ ? "~~D" id[i] "~~" : "D" id[i]) " — " one[i] mark(i) }
+FILENAME == bf {
+  if ($0 ~ /^\| D[0-9]+ \|/) {
+    split($0, cc, "|"); k = trim(cc[2]); sub(/^D/, "", k)
+    btop[k] = trim(cc[3]); bw[k] = trim(cc[4]); bone[k] = trim(cc[5])
+  }
+  next
+}
+/^Topics:/ && !nt {
+  s = $0; sub(/^Topics:[ \t]*/, "", s); nt = split(s, tl, / · /)
+  for (t = 1; t <= nt; t++) { tl[t] = trim(tl[t]); known[tl[t]] = 1 }
+  next
+}
+/^### D[0-9]+ / {
+  n++; d = $2; sub(/^D/, "", d); id[n] = d
+  s = $0; sub(/^### D[0-9]+ /, "", s); title[n] = s; sub(/ +\[status:.*/, "", title[n])
+  sub(/.*\[status: /, "", s); sub(/\].*/, "", s); st[n] = s
+  next
+}
+n && date[n] == "" && match($0, /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/) { date[n] = substr($0, RSTART, RLENGTH) }
+n && /^- Review: / {
+  s = $0; sub(/^- Review: /, "", s); split(s, p, / · /)
+  top[n] = trim(p[1]); sub(/^Topic /, "", top[n])
+  w[n] = trim(p[2]); sub(/^Weight /, "", w[n])
+  one[n] = trim(p[3]); sub(/^One-liner: /, "", one[n])
+}
+n && match($0, /HARNESS_CHANGELOG\.md H[0-9]+/) { h[n] = substr($0, RSTART + 21, RLENGTH - 21) }
+n && match($0, /FINDINGS\.md F[0-9]+(, F[0-9]+)*/) { f[n] = substr($0, RSTART + 12, RLENGTH - 12) }
+END {
+  for (i = 1; i <= n; i++) {
+    k = id[i]
+    if (top[i] == "" && (k in btop)) { top[i] = btop[k]; w[i] = bw[k]; one[i] = bone[k] }
+    if (one[i] == "") one[i] = title[i]
+    if (top[i] == "") { top[i] = "Untagged"; continue }
+    if (!(top[i] in known)) err("D" k ": unknown topic \"" top[i] "\" (journal Topics: line)")
+    if (!wn(w[i])) err("D" k ": weight must be ●●●, ●●○ or ●○○")
+    if (split(one[i], x, / +/) > 15) err("D" k ": one-liner over 15 words")
+  }
+  if (bad) exit 1
+  print "# Project review"
+  print ""
+  print "<!-- Generated by scripts/decision-views.sh from DECISION_JOURNAL.md (and backfill-tags.md). Do not edit:"
+  print "     change the journal or the backfill table, then run the script. make check fails when this file is stale. -->"
+  print ""
+  print "Every decision grouped by topic, most important first. The chronological ledger, with every option, cost and"
+  print "quote, is [DECISION_JOURNAL.md](DECISION_JOURNAL.md)."
+  print "Weight: ●●● critical (hard to undo, or touches money, personal data or sign-in) · ●●○ important · ●○○ minor."
+  print ""
+  print "## By topic"
+  if (!n) { print ""; print "- none yet" }
+  tl[++nt] = "Untagged"
+  for (t = 1; t <= nt; t++) {
+    c = 0
+    for (i = 1; i <= n; i++) if (top[i] == tl[t]) c++
+    if (!c) continue
+    print ""; print "### " tl[t] " (" c ")"; print ""
+    for (v = 3; v >= 0; v--) for (old = 0; old <= 1; old++) for (i = 1; i <= n; i++)
+      if (top[i] == tl[t] && wn(w[i]) == v && (st[i] ~ /^superseded-by/) == old) print "- " (v ? w[i] " " : "") line(i)
+  }
+  print ""
+  print "## How the workflow improved"
+  print ""
+  print "Decisions that adopted a software-factory-kit change (H) and the finding (F) behind it, oldest first."
+  print ""
+  c = 0
+  for (i = 1; i <= n; i++) if (h[i] != "") { c++; print "- " date[i] " · D" id[i] " · " h[i] (f[i] != "" ? " · " f[i] : "") " — " one[i] mark(i) }
+  if (!c) print "- none yet"
+  print ""
+  print "## By day"
+  if (!n) { print ""; print "- none yet" }
+  for (i = n; i >= 1; i--) {
+    if (date[i] != last) { print ""; print "### " (date[i] == "" ? "undated" : date[i]); print ""; last = date[i] }
+    print "- D" id[i] " · " top[i] (wn(w[i]) ? " · " w[i] : "") " — " one[i] mark(i)
+  }
+}' "$B" "$J" >"$tmp"
+
+if [ "$check" = 1 ]; then
+  if ! cmp -s "$tmp" "$OUT"; then
+    echo "decision-views: $OUT is missing or stale; run: bash scripts/decision-views.sh" >&2
+    exit 1
+  fi
+  echo "decision-views: $OUT is current"
+else
+  cp "$tmp" "$OUT"
+  echo "decision-views: wrote $OUT"
+fi
```

### H15 Look up proposal fields without a SIGPIPE  [status: adopted]

- F#: F26 · Layer: Script · Reach: factory script
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `scripts/apply-proposal.sh`
- Root cause: the apply stopped half-done → `sed | grep -m1` under `set -o pipefail` → grep exits at its first match, sed's next write gets SIGPIPE, pipefail turns 141 into a failure and `set -e` exits → only blocks larger than the pipe buffer trigger it, so H4-H11 passed.
- Why this layer: §10 "Mechanical step done wrong → Script": the script itself is wrong; one awk per lookup has no pipe to break.
- Rules: `scripts/apply-proposal.sh` two lookups rewritten plus one comment line; pruned: none.
- Guard: the old pipeline exits 141 in 2 of 3 runs on the H13 block today; the awk lookups print `Generate a weighted project review of decisions` and `F25` with exit 0, and `F8 and F9` for H8.
- Teach: "Under pipefail, a reader that stops early can kill its writer, so lookups read the file themselves instead of through a pipe."
- diff-sha256: 5fe6c05fbd96
- Verdict: pending G-L5

```diff
--- a/scripts/apply-proposal.sh
+++ b/scripts/apply-proposal.sh
@@ -46,8 +46,9 @@
 printf '%s\n' "$d" | git -C "$dest" apply
 paths=$(printf '%s\n' "$d" | git -C "$dest" apply --numstat -R | cut -f3)
 
-title=$(grep -m1 "^### H$n " "$log" | sed -E "s/^### H$n //; s/ +\[status:.*//")
-fs=$(sed -n "/^### H$n /,/^### /p" "$log" | grep -m1 -oE 'F#: F[0-9]+( and F[0-9]+)?' | sed 's/^F#: //')
+# One awk per lookup: an early-exiting reader in a pipe (grep -m1) kills its writer under pipefail (SIGPIPE, exit 141).
+title=$(awk -v h="### H$n " 'index($0,h)==1{t=substr($0,length(h)+1); sub(/ +\[status:.*/,"",t); print t; exit}' "$log")
+fs=$(awk -v h="### H$n " 'index($0,h)==1{f=1;next} f&&/^### /{exit} f&&match($0,/F#: F[0-9]+( and F[0-9]+)?/){print substr($0,RSTART+4,RLENGTH-4); exit}' "$log")
 if [ "$dest" -ef "$kit" ]; then
   if ! bash "$kit/scripts/test.sh" >/dev/null 2>&1; then
     printf '%s\n' "$d" | git -C "$kit" apply -R
```

### H16 Check CI every push; link every deploy  [status: superseded by H18]

- F#: F27 · Layer: Verification/hooks · Reach: WORKFLOW.md + factory template + factory skill
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `docs/WORKFLOW.md`, `scripts/init-repo.sh`, `scripts/test.sh`, `skills/ship-milestone/SKILL.md`, `templates/.gitlab-ci.yml` (new), `templates/.gitlab/merge_request_templates/Default.md`
- Root cause: "checked" meant a local make check with no shared record, and a deploy ended with evidence but no way for the human to try it → no pipeline existed in the factory's templates and no rule said to read one → ship-milestone's STOP had no review link or walkthrough.
- Why this layer: §10 "Done claimed but broken → Verification/hooks": a pipeline on the human's runner is a check that runs whatever the model does; the rules and STOP line tell the supervisor to read it and to hand over a walkthrough.
- Rules: WORKFLOW §8 bullets 9 → 11 (ceiling ~20); `skills/ship-milestone/SKILL.md` 276 → 279 (ceiling 300); new fail-closed `templates/.gitlab-ci.yml`; `scripts/test.sh` 131 passed with this diff applied in a scratch clone; pruned: none.
- Guard: init-repo scaffolds `.gitlab-ci.yml` (test.sh "every constitution file exists"); each MR's Verification names its pipeline, green before merge.
- Teach: "Every push runs the same gate in CI on my own runner, so 'it passed' has a shared record, and every deploy ends with a link and a walkthrough I can click through."
- diff-sha256: 23429c81fb1f
- Verdict: pending G-L5

```diff
--- a/docs/WORKFLOW.md
+++ b/docs/WORKFLOW.md
@@ -261,6 +261,11 @@
 - **Auto-merge only on a standing yes:** when `## Approvals` holds the human's standing yes to auto-merge, the
   supervisor merges the MR once G5 is approved (merge commit, TL;DR as its message) and pushes `main` to the
   mirror; without that row, merging stays human-only (§2 rule 8).
+- **CI checks every push** (owner's rule, 2026-10-10): `.gitlab-ci.yml` runs `make check` on the human's own
+  runner. After every push the supervisor reads the pipeline (`glab ci status`) and reports it; an MR merges only on
+  a green pipeline. A job stuck at `pending` means no runner is online: say so, and never merge on a local run alone.
+- **Every deploy ends with a review link** (owner's rule, 2026-10-10): once `/version` shows the deployed SHA, the
+  human gets the URL and a numbered walkthrough per demo user (ship-milestone STOP A).
 - Done = merged **and** `make check` run on main, SHA recorded in `MILESTONES.md` and Resume.
 
 ## 9. Decision journal schema (`docs/decisions/DECISION_JOURNAL.md`, committed)
--- a/scripts/init-repo.sh
+++ b/scripts/init-repo.sh
@@ -11,7 +11,8 @@
 
 Scaffolds into <repo-dir> (must be the root of a git repository):
   templates/**                      → same paths (AGENTS.md, CLAUDE.md, .claude/settings.json, .githooks/pre-push,
-                                       .gitlab/merge_request_templates/Default.md, .handoff/TRACKER.md, MILESTONES.md,
+                                       .gitlab-ci.yml, .gitlab/merge_request_templates/Default.md, .handoff/TRACKER.md,
+                                       MILESTONES.md,
                                        docs/README.md, docs/decisions/{DECISION_JOURNAL,REVIEW}.md, specs/_templates/*)
   templates/Makefile.example        → Makefile when the repo has none (its check target fails until you adapt it);
                                        Makefile.example when a Makefile exists without a `check:` target
--- a/scripts/test.sh
+++ b/scripts/test.sh
@@ -73,7 +73,7 @@
 rc 0 "init-repo: scaffolds a fresh repo" bash "$kit/scripts/init-repo.sh" "$repo"
 missing=""
 for f in .claude/settings.json .claude/agents/verifier.md .githooks/pre-push \
-  .gitlab/merge_request_templates/Default.md .handoff/TRACKER.md .handoff/inbox/.gitkeep .handoff/runs/.gitkeep \
+  .gitlab-ci.yml .gitlab/merge_request_templates/Default.md .handoff/TRACKER.md .handoff/inbox/.gitkeep .handoff/runs/.gitkeep \
   .handoff/reviews/.gitkeep MILESTONES.md docs/README.md docs/decisions/DECISION_JOURNAL.md \
   specs/_templates/task.md specs/_templates/result.md Makefile scripts/scope-guard.sh scripts/delegate.sh \
   scripts/embed-diagrams.sh scripts/decision-views.sh docs/decisions/REVIEW.md; do
--- a/skills/ship-milestone/SKILL.md
+++ b/skills/ship-milestone/SKILL.md
@@ -219,6 +219,9 @@
 - `bash scripts/smoke.sh <url> <sha>` → <its last line>
 - Probe: <name> on <path> every <interval>, first pass <time> (seen in <where>)
 - SLO-1: <one line> · Logs: <command> · Rollback: <RB-n one line> (<safe | not safe: why>)
+Review it: <url>. Demo sign-in: <where the password lives (a git-ignored file the human reads), never the value>.
+  Walkthrough, from acceptance.md ## Demo smoke, one numbered step per line: <step>. <user (role)>: <exact page path>
+  → <what they see>. Pages that do not exist yet are named, with the direct path to use instead.
 Not verified: <non-blocking GAP-n and anything else unproven, or "none">
 
 Gate G-live — "/version = merged SHA, smoke green with TLS verified?" (plus: one probe has passed)
--- /dev/null
+++ b/templates/.gitlab-ci.yml
@@ -0,0 +1,20 @@
+# GitLab CI: one job, the same gate as local and the pre-push hook (`make check`), on the human's own runner
+# (software-factory-kit WORKFLOW.md §8). If a job sits at "pending", no runner is online for this project.
+#
+# ADAPT PER STACK: set `image` to the stack's toolchain and add the `services` make check needs (e.g. a test
+# database). Until the Makefile is adapted, make check fails on purpose, so an unconfigured repo never looks green.
+
+workflow:
+  rules:
+    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
+    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS
+      when: never # the merge request pipeline covers this push
+    - if: $CI_COMMIT_BRANCH
+
+stages: [check]
+
+check:
+  stage: check
+  image: buildpack-deps:bookworm # ADAPT: make, git and bash are here; add the stack's toolchain
+  script:
+    - make check
--- a/templates/.gitlab/merge_request_templates/Default.md
+++ b/templates/.gitlab/merge_request_templates/Default.md
@@ -42,6 +42,7 @@
 ```
 
 - [ ] `scripts/scope-guard.sh <task-file> milestone/m<N>-<slug>` exited 0 for every task (paste the OK lines)
+- [ ] This MR's pipeline is green on the human's runner: <pipeline link>
 - [ ] Acceptance tests in `tests/acceptance/**` were written before the code and now pass (counts from the output above)
 - [ ] `scripts/embed-diagrams.sh --check` is clean for every changed design doc
 
```

### H17 Add a pipeline line to this MR template  [status: adopted]

- F#: F27 · Layer: Verification/hooks · Reach: project
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: cerbo-supplement-store · Files: `.gitlab/merge_request_templates/Default.md`
- Root cause: Same as H16: init-repo never overwrites, so this project's MR template needs its own pipeline line.
- Why this layer: Same as H16; this is the project half.
- Rules: `.gitlab/merge_request_templates/Default.md`: one checklist line added; pruned: none.
- Guard: `grep -c 'pipeline is green' .gitlab/merge_request_templates/Default.md` prints 1.
- Teach: "Each Cerbo MR shows its CI pipeline before it merges."
- diff-sha256: 1730d3f72cea
- Verdict: adopted 2026-10-11 (Approvals 2026-10-10 19:46 CDT, H17@1730d3f72cea, "Approve, adopt H18 and H17")

```diff
--- a/.gitlab/merge_request_templates/Default.md
+++ b/.gitlab/merge_request_templates/Default.md
@@ -42,6 +42,7 @@
 ```
 
 - [ ] `scripts/scope-guard.sh <task-file> milestone/m<N>-<slug>` exited 0 for every task (paste the OK lines)
+- [ ] This MR's pipeline is green on the human's runner: <pipeline link>
 - [ ] Acceptance tests in `tests/acceptance/**` were written before the code and now pass (counts from the output above)
 - [ ] `scripts/embed-diagrams.sh --check` is clean for every changed design doc
 
```

### H18 Check CI every push on the shell runner; link every deploy  [status: adopted]

- F#: F27 · Layer: Verification/hooks · Reach: WORKFLOW.md + factory template + factory skill · Supersedes: H16
- Proposed: 2026-10-10 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `docs/WORKFLOW.md`, `scripts/init-repo.sh`, `scripts/test.sh`, `skills/ship-milestone/SKILL.md`, `templates/.gitlab-ci.yml` (new), `templates/.gitlab/merge_request_templates/Default.md`
- Root cause: as H16, plus: the first pipeline used a Docker-executor runner whose container VM disk was full, and the human declined to grow the VM (TRACKER Log 2026-10-10 CI pipeline 48487 failed) → CI must run on the human's macOS shell runner, enabled per project without a new token ("could you do this for me on all future projects in gauntlet?").
- Why this layer: §10 "Done claimed but broken → Verification/hooks": a pipeline on the human's runner is a check that runs whatever the model does; a shell executor reuses the machine's tools and running services, so CI adds nothing to the container VM.
- Rules: WORKFLOW §8 bullets 9 → 11 (ceiling ~20); `skills/ship-milestone/SKILL.md` 276 → 279 (ceiling 300); new `templates/.gitlab-ci.yml` (tag `macbook-shell`); `scripts/test.sh` 131 passed with this diff applied in a scratch clone; pruned: none.
- Guard: init-repo scaffolds `.gitlab-ci.yml` (test.sh "every constitution file exists"); Cerbo pipeline 48540 on the shell runner passed (122 unit, 43 acceptance, make check OK) before MR !6 merged.
- Teach: "Every push runs the same gate in CI on my own Mac's runner, switched on per project with one API call, so 'it passed' has a shared record without filling a VM."
- diff-sha256: 0ee4f6f2422d
- Verdict: pending G-L5

```diff
--- a/docs/WORKFLOW.md
+++ b/docs/WORKFLOW.md
@@ -261,6 +261,14 @@
 - **Auto-merge only on a standing yes:** when `## Approvals` holds the human's standing yes to auto-merge, the
   supervisor merges the MR once G5 is approved (merge commit, TL;DR as its message) and pushes `main` to the
   mirror; without that row, merging stays human-only (§2 rule 8).
+- **CI checks every push** (owner's rule, 2026-10-10): `.gitlab-ci.yml` runs `make check` on the human's own
+  shell runner (tag `macbook-shell`; no Docker executor, so CI never grows the container VM). When a project's
+  GitLab repo is created, the supervisor enables that runner for it (`glab api -X POST projects/<id>/runners -f
+  runner_id=<id>`; no new token). After every push it reads the pipeline and reports the job's test counts; an MR
+  merges only on a green pipeline. A job stuck at `pending` means the runner is offline: say so, and never merge on
+  a local run alone.
+- **Every deploy ends with a review link** (owner's rule, 2026-10-10): once `/version` shows the deployed SHA, the
+  human gets the URL and a numbered walkthrough per demo user (ship-milestone STOP A).
 - Done = merged **and** `make check` run on main, SHA recorded in `MILESTONES.md` and Resume.
 
 ## 9. Decision journal schema (`docs/decisions/DECISION_JOURNAL.md`, committed)
--- a/scripts/init-repo.sh
+++ b/scripts/init-repo.sh
@@ -11,7 +11,8 @@
 
 Scaffolds into <repo-dir> (must be the root of a git repository):
   templates/**                      → same paths (AGENTS.md, CLAUDE.md, .claude/settings.json, .githooks/pre-push,
-                                       .gitlab/merge_request_templates/Default.md, .handoff/TRACKER.md, MILESTONES.md,
+                                       .gitlab-ci.yml, .gitlab/merge_request_templates/Default.md, .handoff/TRACKER.md,
+                                       MILESTONES.md,
                                        docs/README.md, docs/decisions/{DECISION_JOURNAL,REVIEW}.md, specs/_templates/*)
   templates/Makefile.example        → Makefile when the repo has none (its check target fails until you adapt it);
                                        Makefile.example when a Makefile exists without a `check:` target
--- a/scripts/test.sh
+++ b/scripts/test.sh
@@ -73,7 +73,7 @@
 rc 0 "init-repo: scaffolds a fresh repo" bash "$kit/scripts/init-repo.sh" "$repo"
 missing=""
 for f in .claude/settings.json .claude/agents/verifier.md .githooks/pre-push \
-  .gitlab/merge_request_templates/Default.md .handoff/TRACKER.md .handoff/inbox/.gitkeep .handoff/runs/.gitkeep \
+  .gitlab-ci.yml .gitlab/merge_request_templates/Default.md .handoff/TRACKER.md .handoff/inbox/.gitkeep .handoff/runs/.gitkeep \
   .handoff/reviews/.gitkeep MILESTONES.md docs/README.md docs/decisions/DECISION_JOURNAL.md \
   specs/_templates/task.md specs/_templates/result.md Makefile scripts/scope-guard.sh scripts/delegate.sh \
   scripts/embed-diagrams.sh scripts/decision-views.sh docs/decisions/REVIEW.md; do
--- a/skills/ship-milestone/SKILL.md
+++ b/skills/ship-milestone/SKILL.md
@@ -219,6 +219,9 @@
 - `bash scripts/smoke.sh <url> <sha>` → <its last line>
 - Probe: <name> on <path> every <interval>, first pass <time> (seen in <where>)
 - SLO-1: <one line> · Logs: <command> · Rollback: <RB-n one line> (<safe | not safe: why>)
+Review it: <url>. Demo sign-in: <where the password lives (a git-ignored file the human reads), never the value>.
+  Walkthrough, from acceptance.md ## Demo smoke, one numbered step per line: <step>. <user (role)>: <exact page path>
+  → <what they see>. Pages that do not exist yet are named, with the direct path to use instead.
 Not verified: <non-blocking GAP-n and anything else unproven, or "none">
 
 Gate G-live — "/version = merged SHA, smoke green with TLS verified?" (plus: one probe has passed)
--- /dev/null
+++ b/templates/.gitlab-ci.yml
@@ -0,0 +1,23 @@
+# GitLab CI: one job, the same gate as local and the pre-push hook (`make check`), on the human's own shell runner
+# (tag `macbook-shell`, software-factory-kit WORKFLOW.md §8). Jobs run straight on that machine, not in Docker, and
+# reuse services `make` starts (e.g. a test database via docker compose). If a job sits at "pending", the runner is
+# offline or not yet enabled for this project.
+#
+# ADAPT PER STACK: add the setup steps make check needs before it (e.g. `make db-test-up`, `npm ci`). Until the
+# Makefile is adapted, make check fails on purpose, so an unconfigured repo never looks green.
+
+workflow:
+  rules:
+    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
+    - if: $CI_COMMIT_BRANCH && $CI_OPEN_MERGE_REQUESTS
+      when: never # the merge request pipeline covers this push
+    - if: $CI_COMMIT_BRANCH
+
+stages: [check]
+
+check:
+  stage: check
+  tags: [macbook-shell]
+  script:
+    - export PATH="/opt/homebrew/bin:$PATH" # Homebrew tools; the runner service starts with a short PATH
+    - make check
--- a/templates/.gitlab/merge_request_templates/Default.md
+++ b/templates/.gitlab/merge_request_templates/Default.md
@@ -42,6 +42,7 @@
 ```
 
 - [ ] `scripts/scope-guard.sh <task-file> milestone/m<N>-<slug>` exited 0 for every task (paste the OK lines)
+- [ ] This MR's pipeline is green on the human's runner: <pipeline link>
 - [ ] Acceptance tests in `tests/acceptance/**` were written before the code and now pass (counts from the output above)
 - [ ] `scripts/embed-diagrams.sh --check` is clean for every changed design doc
 
```

### H20 Give copied kit files a project block  [status: proposed]

- F#: F29 · Layer: Skill · Reach: factory skill
- Proposed: 2026-10-11 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `skills/route-failure/references/routing.md`
- Root cause: M5-T008 hit a scope-guard bug the kit had fixed (H4) → H4 was filed with kit reach only → routing.md §3 lists copied scripts under "factory skill", whose row never asks for a project block, and init-repo never overwrites → the project copy kept the bug.
- Why this layer: §10 "Phase procedure botched → Skill": the reach table is the step that decides which blocks get filed; a sync tool (`init-repo.sh --drift`) is the stronger runner-up, but the table edit costs one cell and stops the miss at filing time.
- Rules: `skills/route-failure/references/routing.md` §3: 5 → 5 rows (two cells edited, no row added); pruned: none, below ceiling.
- Guard: the next kit block that edits `scripts/scope-guard.sh`, `delegate.sh`, `embed-diagrams.sh`, `decision-views.sh` or `agents/verifier.md` comes with a project block; `cmp "$KIT/scripts/scope-guard.sh" scripts/scope-guard.sh` exits 0 in Cerbo once H21 is applied.
- Teach: "A fix in the factory is not a fix in a project that copied the old file; the routing table now says so where the decision is made."
- diff-sha256: 11ab948173dd
- Verdict: pending G-L5

```diff
--- a/skills/route-failure/references/routing.md
+++ b/skills/route-failure/references/routing.md
@@ -47,8 +47,8 @@
 |---|---|---|
 | task | one `specs/M<N>-<slug>/tasks/T###.md` (route to `slice-tasks`; frozen after merge) | the gap is in one task's `Owns:` or Done-when |
 | project | the project's `AGENTS.md`, `CLAUDE.md`, `Makefile`, `.claude/settings.json`, `.githooks/`, `scripts/` | the cause is a fact about this stack, repo or domain |
-| factory template | `$KIT/templates/**` | every future project needs it; `init-repo.sh` never overwrites, so existing projects also need their own project-reach block |
-| factory skill | `$KIT/skills/<name>/**`, `$KIT/agents/**`, `$KIT/scripts/**` | the phase procedure itself is wrong for any project |
+| factory template | `$KIT/templates/**`, plus the files `init-repo.sh` copies: `$KIT/agents/verifier.md`, `$KIT/scripts/{scope-guard,delegate,embed-diagrams,decision-views}.sh` | every future project needs it; `init-repo.sh` never overwrites, so existing projects also need their own project-reach block (`cmp` the project copy first: H4 reached the kit, never Cerbo's scope-guard, F29) |
+| factory skill | `$KIT/skills/<name>/**`, `$KIT/agents/**`, `$KIT/scripts/**` not copied by `init-repo.sh` | the phase procedure itself is wrong for any project |
 | WORKFLOW.md | `$KIT/docs/WORKFLOW.md` | a rule of the factory is wrong; change it first, in the same diff as the skills that implement it |
 
 ## 4. Rule ceilings and counting
```

### H21 Sync this project's scope-guard to the kit  [status: proposed]

- F#: F29 · Layer: Skill · Reach: project
- Proposed: 2026-10-11 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: cerbo-supplement-store · Files: `scripts/scope-guard.sh`
- Root cause: Same as H20: the project copy never got H4; 428cd99 patched exact paths only, so a folder glob like `server/api/orders/[orderId]/**` still fails.
- Why this layer: Same as H20; this is the project half, and it replaces the project's own patch with the kit's tested line so the two copies are identical again.
- Rules: `scripts/scope-guard.sh`: no rules; pruned: none.
- Guard: `cmp "$KIT/scripts/scope-guard.sh" scripts/scope-guard.sh` exits 0; a scratch repo with Owns `app/pages/orders/[orderId].vue,server/api/orders/[orderId]/**` and both files staged gets exit 0 (today: exit 1, out of scope on the folder file; checked this pass).
- Teach: "Cerbo now runs the same boundary check the kit tests, not a local variant that only half-fixed the bug."
- diff-sha256: 30165f829ae7
- Verdict: pending G-L5

```diff
--- a/scripts/scope-guard.sh
+++ b/scripts/scope-guard.sh
@@ -17,6 +17,7 @@
 
 Owns: line(s) in the task file hold comma/space separated globs. `*` matches across `/` (shell case
 pattern), so `app/Services/**` and `app/Services/*` both cover every file below app/Services/.
+`[` is literal, so route folders like `server/api/orders/[orderId]/**` work (no character classes).
 A rename counts as delete + add, so both paths must be owned.
 
 Exit: 0 every changed path is owned · 1 a path is out of scope · 2 usage error, unknown ref, or no Owns:
@@ -62,10 +63,9 @@
   [ -n "$f" ] || continue
   n=$((n + 1)) ok=0
   for p in $owns; do
-    # an exact path matches literally first: Nuxt routes like app/pages/orders/[orderId].vue hold glob brackets
-    [ "$f" = "$p" ] && { ok=1; break; }
-    # shellcheck disable=SC2254 # $p is deliberately a pattern
-    case $f in $p) ok=1; break ;; esac
+    q=${p//\[/\\[} # a literal [ (Nuxt/Next route folders), never a character class
+    # shellcheck disable=SC2254 # $q is deliberately a pattern
+    case $f in $q) ok=1; break ;; esac
   done
   [ "$ok" = 1 ] || { echo "scope-guard: out of scope: $f" >&2; bad=1; }
 done <<EOF
```

### H22 Pre-push: worktree-safe check, QA tests alone  [status: proposed]

- F#: F30, F37 · Layer: Verification/hooks · Reach: factory template
- Proposed: 2026-10-11 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `templates/.githooks/pre-push`, `scripts/test.sh`
- Root cause: F30: hooks inherit GIT_DIR → in a linked worktree `git -C <dir> rev-parse --show-toplevel` answers the current directory → embed-diagrams built doubled paths → pushes blocked as "flaky". F37: a fix and its acceptance test went out in one commit → nothing separates QA-owned tests from the code they grade → the rule in CLAUDE.md and fix-bug was ignored.
- Why this layer: §10 "Done claimed but broken → Verification/hooks": both are mechanical facts about each pushed commit, so the hook checks them on every push; F37's rule already exists in CLAUDE.md and fix-bug, so a second sentence would be "rule ignored" again.
- Rules: `templates/.githooks/pre-push`: checks 3 → 4; `scripts/test.sh` 131 → 135 passed (scratch kit copy); pruned: none (scripts carry no rule count).
- Guard: `bash scripts/test.sh` prints `ok   pre-push: an acceptance test committed with product code is blocked` and `ok   pre-push: make check in a linked worktree sees that worktree (GIT_DIR unset)`; with today's hook both fail (4 FAIL lines, checked in a scratch kit).
- Teach: "The push hook now enforces that whoever fixes the code cannot also write the test that grades it, and it behaves the same in a worktree as in the main checkout."
- diff-sha256: dac0d3019c2d
- Verdict: pending G-L5

```diff
--- a/scripts/test.sh
+++ b/scripts/test.sh
@@ -381,7 +381,17 @@
 printf 'check:\n\t@echo check-red; exit 1\n' >Makefile && git add Makefile && git commit -qm "red"
 rc 1 "pre-push: failing make check blocks the push" git push -q origin feature/red
 has "pre-push: says make check failed" "$out" "make check failed"
+git checkout -q -b feature/mixed milestone/m1-demo
+mkdir -p tests/acceptance src && echo t >tests/acceptance/x.test && echo c >src/fix.txt
+git add tests/acceptance/x.test src/fix.txt && git commit -qm "fix: code and its acceptance test together"
+rc 1 "pre-push: an acceptance test committed with product code is blocked" git push -q origin feature/mixed
+has "pre-push: names the mixed commit" "$out" "changes tests/acceptance/** with src/fix.txt"
 git checkout -q milestone/m1-demo
+git worktree add -q "$tmp/wt-gitdir" -b feature/gitdir milestone/m1-demo
+printf 'check:\n\t@mkdir -p sub && test "$$(git -C sub rev-parse --show-toplevel)" = "$$(pwd -P)" && echo top-ok\n' >"$tmp/wt-gitdir/Makefile"
+git -C "$tmp/wt-gitdir" commit -qam "check: run git from a subdirectory"
+rc 0 "pre-push: make check in a linked worktree sees that worktree (GIT_DIR unset)" git -C "$tmp/wt-gitdir" push -q origin feature/gitdir
+has "pre-push: worktree make check ran" "$out" "top-ok"
 is "pre-push tests left the supervisor's TRACKER Log intact" "$(grep -c ' DISPATCH M1-T00' "$tracker")" 9
 
 # ---- 6. install.sh (dry run only, fake HOME) -------------------------------------------------------------
--- a/templates/.githooks/pre-push
+++ b/templates/.githooks/pre-push
@@ -9,9 +9,11 @@
 #        task branch m<N>/t###-<slug>        -> specs/M<N>-*/tasks/T###.md
 #        job branch  m<N>/<letters><nn>-<slug> (e.g. m0/d01-…, a supervisor job such as draw-diagrams)
 #                                            -> .handoff/runs/M<N>-<LETTERS><nn>/task.md (scripts/delegate.sh)
+#   4. no pushed commit changes tests/acceptance/** together with product code (QA-owned: the test lands first,
+#      in its own commit, so a fix can never write the test that grades it)
 #
 # Why local and not only CI: origin pushes to GitLab AND the GitHub mirror at once, before any CI runs.
-# All three checks run even after one fails, so you see every problem at once.
+# All four checks run even after one fails, so you see every problem at once.
 # Bypass: `git push --no-verify` is a human-only action — record the yes in .handoff/TRACKER.md first.
 # Run by hand (no stdin): checks the current branch.
 set -euo pipefail
@@ -20,6 +22,9 @@
 remote=${1:-origin}
 top=$(git rev-parse --show-toplevel)
 cd "$top"
+# git sets GIT_DIR (and friends) for hooks; inside a worktree that makes `git -C <dir> rev-parse --show-toplevel`
+# answer the current directory, so scripts resolve doubled paths. Run make check like a person would.
+unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_PREFIX
 fail=0
 pushes=() # "<branch> <local sha> <remote sha>"
 
@@ -106,5 +111,22 @@
   scripts/scope-guard.sh "$task" "$base" "$2" || fail=1
 done
 
+# ---- 4. acceptance tests never ride with product code ----------------------------------------------------
+# Allowed beside tests/acceptance/**: other tests, specs, docs, .handoff, MILESTONES.md and the Makefile target
+# that runs the suite. Merge commits are skipped (their parents were checked when they were pushed).
+for p in ${pushes[@]+"${pushes[@]}"}; do
+  set -- $p
+  if [ "${3//0/}" != "" ] && git cat-file -e "$3^{commit}" 2>/dev/null; then range="$3..$2"; else range="$2 --not --remotes=$remote"; fi
+  for c in $(git rev-list --no-merges $range); do
+    files=$(git diff-tree --no-commit-id --name-only -r "$c")
+    printf '%s\n' "$files" | grep -q '^tests/acceptance/' || continue
+    other=$(printf '%s\n' "$files" | grep -vE '^(tests/|specs/|docs/|\.handoff/|MILESTONES\.md$|Makefile$)' || true)
+    [ -z "$other" ] || {
+      echo "pre-push: BLOCKED — $(git log -1 --format='%h %s' "$c") changes tests/acceptance/** with $(echo $other) (commit the acceptance test on its own, first)" >&2
+      fail=1
+    }
+  done
+done
+
 [ "$fail" = 0 ] || { echo "pre-push: push blocked — fix the above (or a human records a yes and uses --no-verify)" >&2; exit 1; }
 echo "pre-push: all checks passed"
```

### H23 Block acceptance tests committed with product code  [status: proposed]

- F#: F37 · Layer: Verification/hooks · Reach: project
- Proposed: 2026-10-11 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: cerbo-supplement-store · Files: `.githooks/pre-push`
- Root cause: Same as H22 (F37): init-repo never overwrites, so Cerbo's hook needs the same fourth check; its GIT_DIR fix is already in (7e96344).
- Why this layer: Same as H22; after H22 and H23 the kit and project hooks are byte-identical.
- Rules: `.githooks/pre-push`: checks 3 → 4; pruned: none.
- Guard: over Cerbo's history the same per-commit test flags 84e7087 (payments.ts with close-out.test.ts) and nothing else; MILESTONES.md and Makefile beside acceptance tests stay allowed (checked this pass).
- Teach: "A commit that changes payments.ts and its acceptance test together can no longer leave this machine."
- diff-sha256: e3e718e446ba
- Verdict: pending G-L5

```diff
--- a/.githooks/pre-push
+++ b/.githooks/pre-push
@@ -9,9 +9,11 @@
 #        task branch m<N>/t###-<slug>        -> specs/M<N>-*/tasks/T###.md
 #        job branch  m<N>/<letters><nn>-<slug> (e.g. m0/d01-…, a supervisor job such as draw-diagrams)
 #                                            -> .handoff/runs/M<N>-<LETTERS><nn>/task.md (scripts/delegate.sh)
+#   4. no pushed commit changes tests/acceptance/** together with product code (QA-owned: the test lands first,
+#      in its own commit, so a fix can never write the test that grades it)
 #
 # Why local and not only CI: origin pushes to GitLab AND the GitHub mirror at once, before any CI runs.
-# All three checks run even after one fails, so you see every problem at once.
+# All four checks run even after one fails, so you see every problem at once.
 # Bypass: `git push --no-verify` is a human-only action — record the yes in .handoff/TRACKER.md first.
 # Run by hand (no stdin): checks the current branch.
 set -euo pipefail
@@ -109,5 +111,22 @@
   scripts/scope-guard.sh "$task" "$base" "$2" || fail=1
 done
 
+# ---- 4. acceptance tests never ride with product code ----------------------------------------------------
+# Allowed beside tests/acceptance/**: other tests, specs, docs, .handoff, MILESTONES.md and the Makefile target
+# that runs the suite. Merge commits are skipped (their parents were checked when they were pushed).
+for p in ${pushes[@]+"${pushes[@]}"}; do
+  set -- $p
+  if [ "${3//0/}" != "" ] && git cat-file -e "$3^{commit}" 2>/dev/null; then range="$3..$2"; else range="$2 --not --remotes=$remote"; fi
+  for c in $(git rev-list --no-merges $range); do
+    files=$(git diff-tree --no-commit-id --name-only -r "$c")
+    printf '%s\n' "$files" | grep -q '^tests/acceptance/' || continue
+    other=$(printf '%s\n' "$files" | grep -vE '^(tests/|specs/|docs/|\.handoff/|MILESTONES\.md$|Makefile$)' || true)
+    [ -z "$other" ] || {
+      echo "pre-push: BLOCKED — $(git log -1 --format='%h %s' "$c") changes tests/acceptance/** with $(echo $other) (commit the acceptance test on its own, first)" >&2
+      fail=1
+    }
+  done
+done
+
 [ "$fail" = 0 ] || { echo "pre-push: push blocked — fix the above (or a human records a yes and uses --no-verify)" >&2; exit 1; }
 echo "pre-push: all checks passed"
```

### H24 Analyze dotted milestones and NFR-only tracers  [status: proposed]

- F#: F31 · Layer: Script · Reach: factory skill
- Proposed: 2026-10-11 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `skills/slice-tasks/references/analyze.md`
- Root cause: M5.1 is a dotted id → the script's `M<N>` parse, after: strip and Consumes grep take digits only → the folder is rejected; a restyle proves NFRs and has no AE → the tracer and covers checks count FR/AE only → the supervisor ran a hand-edited copy at G4.
- Why this layer: §10 "Mechanical step done wrong → Script": the tool itself was wrong for a legal milestone shape, and a hand-edited copy at a gate is exactly what a script is there to prevent.
- Rules: `skills/slice-tasks/references/analyze.md`: checks table rows 12 → 12 (Order cell and Scope paragraph edited); pruned: none.
- Guard: on Cerbo, the new script prints RESULT: PASS for specs/M5.2-safe-landing, specs/M6.1-patient-orders and for specs/M5.1-visual-refresh at the G4 commit 6bc24f6 (today: "is not specs/M<N>-<slug>"); M6 stays PASS; M4 and M5 fail only on their accepted 11-task size, as today (checked this pass).
- Teach: "The gate's consistency check now understands the milestone names we actually use, so nobody edits the checker by hand at a gate."
- diff-sha256: 58bc64be50b3
- Verdict: pending G-L5

```diff
--- a/skills/slice-tasks/references/analyze.md
+++ b/skills/slice-tasks/references/analyze.md
@@ -11,7 +11,8 @@
 `Analyze:` line verbatim into the STOP message; never retype or round them.
 
 **Scope** = the FR/AE ids in the PRD `## Milestone cut` row for `M<N>` (its Scope and Proves cells) plus the ids in
-the Covers column of `acceptance.md ## Traceability`. Nothing else in `acceptance.md` counts: its
+the Covers column of `acceptance.md ## Traceability`, plus the NFR ids in that row's Proves cell (a restyle or
+hardening milestone proves NFRs and may have no AE). Milestone ids may be dotted (`M5.1`). Nothing else in `acceptance.md` counts: its
 `Out of scope this milestone:` line names later milestones' FRs.
 
 ## What it checks
@@ -24,7 +25,7 @@
 | Coverage | an in-scope FR/AE is covered by no task |
 | Owns | not exactly one `Owns:` line before `## Ask`; an empty entry or one containing a space; any glob that matches `tests/acceptance/**`, `specs/**`, `docs/**`, `.handoff/**`, `.claude/**`, `.githooks/**`, `AGENTS.md`, `CLAUDE.md`, `MILESTONES.md` or `scripts/scope-guard.sh`; any entry that is or covers a dependency manifest or lockfile (implementers never install) |
 | Parallel | two `parallel: true` tasks own overlapping globs (conservative: literal prefixes nest) |
-| Order | an `after:` id has no task file; a cycle; more than one task in wave 1, or wave 1 is not `T001`; `T001` covers no AE |
+| Order | an `after:` id has no task file; a cycle; more than one task in wave 1, or wave 1 is not `T001`; `T001` covers no AE while the scope has one |
 | Harness | a `codex` task with `hitl: true` or `parallel: false` |
 | Sections | `## ` headings are not exactly Ask, Done-when, Must not change, Consumes / Produces, Context manifest, Return; the first line under `## Ask` is not a title of at most 6 words (delegate.sh and implement-task turn it into the branch name); Done-when lacks `make check`; Return lacks `runs/<id>/result.md`; a `- Consumes:` line names a task id missing from `after:` |
 | Leftovers | `{{` or `<!-- guide:` remains; a fenced code block other than `sh`/`bash` (no code in task files) |
@@ -42,7 +43,7 @@
 set -u
 D=${1:?usage: sh -s -- specs/M<N>-<slug> [prd path]}; D=${D%/}; P=${2:-docs/product/prd.md}
 T=$D/tasks; A=$D/acceptance.md
-N=$(basename "$D" | sed -n 's/^M\([0-9][0-9]*\)-.*/\1/p')
+N=$(basename "$D" | sed -n 's/^M\([0-9][0-9.]*\)-.*/\1/p')
 [ -n "$N" ] || { echo "FAIL: $D is not specs/M<N>-<slug>"; exit 2; }
 fail=0; bad() { echo "FAIL: $*"; fail=1; }
 idsof() { grep -oE '(^|[^N])(FR|AE)-[0-9]{3}' | grep -oE '(FR|AE)-[0-9]{3}' | sort -u; }
@@ -66,7 +67,8 @@
 files=$(ls "$T"/T[0-9][0-9][0-9].md 2>/dev/null)
 [ -n "$files" ] || { echo "FAIL: no task files in $T"; exit 1; }
 set -f
-scope=$( { grep -E "^\| M$N( |\|)" "$P" 2>/dev/null | awk -F'|' '{print $4; print $5}'; trace | awk -F'|' '{print $3}'; } | idsof)
+scope=$( { grep -E "^\| M$N( |\|)" "$P" 2>/dev/null | awk -F'|' '{print $4; print $5}'; trace | awk -F'|' '{print $3}'; } | idsof
+  grep -E "^\| M$N( |\|)" "$P" 2>/dev/null | awk -F'|' '{print $5}' | grep -oE 'NFR-[0-9]{3}' | sort -u)
 [ -n "$scope" ] || bad "no FR/AE ids for M$N in the Milestone cut row of $P or the Traceability Covers of $A"
 k=0; pc=0; cc=0; xc=0; hc=0; bm=0; ec=0; ua=0; ao=0; ov=0; bl=0
 all=""; edges=""; cov=""; par=""
@@ -95,7 +97,7 @@
     else bad "$t: covers $c, not in M$N scope"; fi
   done
   [ -z "$covers" ] || [ "$n_in" -gt 0 ] || { bad "$t: covers no in-scope FR/AE"; ec=$((ec+1)); }
-  after=$(fm "$f" after | lst | sed 's/^M[0-9]*-//')
+  after=$(fm "$f" after | lst | sed 's/^M[0-9.]*-//')
   for a in $after; do case " $all " in *" $a "*) ;; *) bad "$t: after $a has no task file"; ua=$((ua+1));; esac; done
   edges="$edges
 $t $(printf '%s ' $after)"
@@ -123,7 +125,7 @@
     *) [ "$tw" -le 6 ] || bad "$t: Ask title has $tw words, at most 6 (it becomes the branch name)";; esac
   sec "$f" Done-when | grep -q 'make check' || bad "$t: Done-when must end with make check"
   sec "$f" Return | grep -q "runs/$id/result.md" || bad "$t: Return must name \$HANDOFF_DIR/runs/$id/result.md"
-  for u in $(sec "$f" 'Consumes / Produces' | grep -E '^- Consumes' | grep -oE 'M[0-9]+-T[0-9]{3}' | sed 's/^M[0-9]*-//'); do
+  for u in $(sec "$f" 'Consumes / Produces' | grep -E '^- Consumes' | grep -oE 'M[0-9.]+-T[0-9]{3}' | sed 's/^M[0-9.]*-//'); do
     printf '%s\n' "$after" | grep -qx "$u" || bad "$t: consumes from $u but after: lacks it"
   done
   grep -nE '\{\{|<!-- guide:' "$f" >/dev/null && bad "$t: unfilled {{placeholder}} or guide comment"
@@ -142,7 +144,7 @@
 cy=$(printf '%s\n' "$waves" | grep -c ' CYCLE$'); [ "$cy" = 0 ] || bad "after: cycle or unknown dep: $(printf '%s\n' "$waves" | grep ' CYCLE$' | cut -d' ' -f1 | tr '\n' ' ')"
 w1=$(printf '%s\n' "$waves" | awk '$2==1{print $1}' | tr '\n' ' ')
 [ "$w1" = "T001 " ] || bad "wave 1 must be the tracer bullet T001 alone (got: $w1)"
-[ -f "$T/T001.md" ] && { fm "$T/T001.md" covers | lst | grep -q '^AE-' || bad "T001 (tracer bullet) covers no AE"; }
+[ -f "$T/T001.md" ] && printf '%s\n' "$scope" | grep -q '^AE-' && { fm "$T/T001.md" covers | lst | grep -q '^AE-' || bad "T001 (tracer bullet) covers no AE"; }
 pl=$(printf '%s\n' "$par" | sed '/^$/d')
 if [ -n "$pl" ]; then
   ovl=$(printf '%s\n' "$pl" | { i=0; while read -r t1 g1; do i=$((i+1))
```

### H25 Run the Bash tool in bash here  [status: proposed]

- F#: F33 · Layer: Settings · Reach: project
- Proposed: 2026-10-11 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: cerbo-supplement-store · Files: `.claude/settings.json`
- Root cause: Bash snippets in skills and supervisor steps (`set -- $var`, unquoted `$F`, globs) behave differently in zsh → the Bash tool uses the login shell, zsh, on this Mac → nothing pins the shell the kit is written for.
- Why this layer: §10 "Flaky setup → Environment" with the fix in Settings (step 2, tools): the Claude Code CLI honours `CLAUDE_CODE_SHELL` (checked in the installed 2.1.287 binary), so the right shell becomes the default instead of a rule to remember; project reach first because bash does not read ~/.zprofile, where Homebrew's PATH lives, so the guard must confirm node, npx and glab still resolve before the kit template copies it.
- Rules: `.claude/settings.json`: one env key; pruned: none.
- Guard: after a restart, `ps -p $$ -o comm=` in the Bash tool prints bash and `command -v node npx glab` prints three paths; if not, revert the key (one line).
- Teach: "We pinned the agent's shell to the one our scripts are written for, instead of asking every agent to remember zsh's quirks."
- diff-sha256: 088425493cbb
- Verdict: pending G-L5

```diff
--- a/.claude/settings.json
+++ b/.claude/settings.json
@@ -1,5 +1,8 @@
 {
   "$schema": "https://json.schemastore.org/claude-code-settings.json",
+  "env": {
+    "CLAUDE_CODE_SHELL": "/bin/bash"
+  },
   "enabledPlugins": {
     "superpowers@claude-plugins-official": false,
     "ponytail@ponytail": false,
```

### H26 Real Task trailers; one Log line per id  [status: proposed]

- F#: F35, F39 · Layer: Skill · Reach: factory skill
- Proposed: 2026-10-11 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `skills/gather-evidence/SKILL.md`, `skills/implement-task/SKILL.md`, `templates/CLAUDE.md`
- Root cause: F35: `-m "Task: …"` is its own paragraph and the harness's Co-Authored-By paragraph follows → git sees no Task trailer → workers amend and report-milestone flags squash commits. F39: in-session subagents leave no RESULT line and DISPATCH lines listed several ids → report-milestone's first-pass rate reads 0/4 with tasks "not dispatched".
- Why this layer: F35 is a tool change inside the recipe (git's own `--trailer` flag merges into the Co-Authored-By block), the cheapest step that makes the right commit the default; F39 sharpens the existing dispatch rule in place (no new rule) so the Log carries what report-milestone already parses.
- Rules: `templates/CLAUDE.md` 12 → 12 list items (one rule replaced by a sharper one); `skills/implement-task/SKILL.md` 278 → 279 lines (ceiling 300); `skills/gather-evidence/SKILL.md` 252 → 252 lines; pruned: none needed.
- Guard: `git log -1 --format=%(trailers:key=Task,valueonly)` prints the id on a commit made with the new command (checked in a scratch repo with a Co-Authored-By paragraph before and after); the next report-milestone §8 shows no first_pass=unknown for a Claude-subagent task.
- Teach: "Git trailers are a parsed block, not a line that looks right; `--trailer` makes the commit correct the first time, and the Log now records what the metric needs."
- diff-sha256: 0703549f54fb
- Verdict: pending G-L5

```diff
--- a/skills/gather-evidence/SKILL.md
+++ b/skills/gather-evidence/SKILL.md
@@ -153,7 +153,7 @@
 11. **Dispatched only: commit, then write the result.**
     - Commit whenever you wrote R files and Done when passes, whatever the status (a partial answer with its gaps
       is still evidence): `git add -- <each R file> docs/research/sources.md` (explicit paths, never `-A`), then
-      `git commit -m "docs(m<N>/<job>): research R<NN>" -m "Task: <id>"`, with `<N>` and `<job>` from the
+      `git commit -m "docs(m<N>/<job>): research R<NN>" --trailer "Task: <id>"`, with `<N>` and `<job>` from the
       lowercased `id` and every R id listed (M1-T007 → `docs(m1/t007): research R05, R06`). Then
       `git status --porcelain -- . ":!.handoff"` must print nothing; `head_sha=$(git rev-parse --short HEAD)`.
     - Write `$HANDOFF_DIR/runs/<id>/result.md` from `specs/_templates/result.md`; never commit it. One key per
--- a/skills/implement-task/SKILL.md
+++ b/skills/implement-task/SKILL.md
@@ -165,7 +165,8 @@
     staged mode: it checks what you are about to commit) and paste it under section 7. Non-zero:
     `git restore --staged -- <path>` for each reported path and re-run; if the task truly needs that path, it is a
     stop condition. Commit:
-    `git commit -m "feat(m<N>/t###): <imperative summary, at most 72 chars>" -m "Task: M<N>-T###"`. Confirm the
+    `git commit -m "feat(m<N>/t###): <imperative summary, at most 72 chars>" --trailer "Task: M<N>-T###"`
+    (`--trailer` joins any Co-Authored-By block; a `-m "Task: …"` paragraph is not a trailer). Confirm the
     same `git status` is empty and record `git rev-parse HEAD` as `head_sha`.
 12. **Write the result.** Overwrite the provisional file: fill `assets/template.md` at the `## Return` path
     (`$HANDOFF_DIR/runs/<id>/result.md`, `<id>` = the task `id`). `changes` from
--- a/templates/CLAUDE.md
+++ b/templates/CLAUDE.md
@@ -69,12 +69,15 @@
   prompt = "Read <abs path>/SKILL.md and follow it for <task file> in <worktree>. HANDOFF_DIR=<abs>/.handoff".
   Pass paths, never summaries.
 - Other harness: `bash scripts/delegate.sh <task-file>`.
-- Log `DISPATCH <id> harness=<h> why=<one line>` for every job. Never show the verifier a worker's self-report.
+- Log one `DISPATCH <id> harness=<h> why=<one line>` line per id (never a list), and when a Claude subagent returns,
+  the line delegate.sh writes for other harnesses: `RESULT <id> status=<s> harness=claude-subagent timeout=no
+  tree=<clean|dirty>` (report-milestone's first-pass rate reads both). Never show the verifier a worker's self-report.
 
 ## Verify delegated work, in order
 `result.md` exists and parses (exit codes don't count) → `bash scripts/scope-guard.sh <task-file> <milestone-branch>`
 exits 0 → you run `make check` in the worktree yourself → read `git diff` against the claim → verifier pass
-(cross-family when possible) → `git merge --squash` onto the milestone branch → `Verified: <sha> <cmd> → <result>`.
+(cross-family when possible) → `git merge --squash` onto the milestone branch, committed with
+`--trailer "Task: <id>"` → `Verified: <sha> <cmd> → <result>`.
 
 ## Failure ladder
 Log FAIL → retry once with the exact error → fresh session after 2 failed corrections → fallback harness → reset the
```

### H27 Same trailer and Log rules in this CLAUDE.md  [status: proposed]

- F#: F35, F39 · Layer: Skill · Reach: project
- Proposed: 2026-10-11 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: cerbo-supplement-store · Files: `CLAUDE.md`
- Root cause: Same as H26: init-repo never overwrites, so Cerbo's supervisor rules need the same two edits.
- Why this layer: Same as H26; the project half.
- Rules: `CLAUDE.md` 12 → 12 list items; pruned: none needed.
- Guard: the next squash commit on a Cerbo milestone branch prints its id under `git log -1 --format=%(trailers:key=Task,valueonly)`, and the next Log has one DISPATCH and one RESULT line per Claude-subagent task.
- Teach: "Cerbo's squash commits now carry a real Task trailer, and its metric counts every dispatched task."
- diff-sha256: c2bc8cdf30f9
- Verdict: pending G-L5

```diff
--- a/CLAUDE.md
+++ b/CLAUDE.md
@@ -66,12 +66,15 @@
 - Claude subagent (default): Agent tool, `isolation: worktree` for code; prompt = "Read <abs path>/SKILL.md and
   follow it for <task file>. HANDOFF_DIR=<abs>/.handoff". Pass paths, never summaries.
 - Other harness: `bash scripts/delegate.sh <task-file>`.
-- Log `DISPATCH <id> harness=<h> why=<one line>` for every job. Never show the verifier a worker's self-report.
+- Log one `DISPATCH <id> harness=<h> why=<one line>` line per id (never a list), and when a Claude subagent returns,
+  the line delegate.sh writes for other harnesses: `RESULT <id> status=<s> harness=claude-subagent timeout=no
+  tree=<clean|dirty>` (report-milestone's first-pass rate reads both). Never show the verifier a worker's self-report.
 
 ## Verify delegated work, in order
 `result.md` exists and parses (exit codes don't count) → `bash scripts/scope-guard.sh <task-file> <milestone-branch>`
 exits 0 → you run `make check` in the worktree yourself → read `git diff` against the claim → verifier pass
-(cross-family when possible) → `git merge --squash` onto the milestone branch → `Verified: <sha> <cmd> → <result>`.
+(cross-family when possible) → `git merge --squash` onto the milestone branch, committed with
+`--trailer "Task: <id>"` → `Verified: <sha> <cmd> → <result>`.
 
 ## Failure ladder
 Log FAIL → retry once with the exact error → fresh session after 2 failed corrections → fallback harness → reset the
```

### H28 Migration tasks own the demo seed list  [status: proposed]

- F#: F38 · Layer: AGENTS.md · Reach: project
- Proposed: 2026-10-11 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: cerbo-supplement-store · Files: `AGENTS.md`
- Root cause: A new table must be named in RESET_TABLES (db/seed/demo.ts) → that coupling is a fact of this repo, not in any Ask → slice-tasks' adopted H8 sentence (own every file the Ask assigns) cannot see it → M5 shipped a broken re-seed and M6-T002 stopped on an Owns gap.
- Why this layer: §10 "Wrong command/API repeatedly → AGENTS.md": the check already exists (tests/unit/seed-demo.test.ts caught M6-T002) but fires mid-task; slice-tasks reads AGENTS.md, so one project line moves the fix to slicing time. Runner-up: derive RESET_TABLES from pg_tables in product code, which removes the coupling (fix-bug or a task, not a harness change).
- Rules: `AGENTS.md` 16 → 17 list items (ceiling ~20); pruned: none, below ceiling.
- Guard: in the next milestone's specs folder, `grep -L 'db/seed/demo.ts'` over the task files whose Owns names db/migrations prints nothing (the frozen M4 and M5 tasks list 7 such files today).
- Teach: "When two files must change together, write the pairing where the planner reads, not only in a test that fires halfway through a task."
- diff-sha256: 886510ef97aa
- Verdict: pending G-L5

```diff
--- a/AGENTS.md
+++ b/AGENTS.md
@@ -58,3 +58,5 @@
 - Stack: TypeScript 5.9 on Node 22.22+, Nuxt 4 (D44) with Vue 3, PostgreSQL 16 through Kysely with plain SQL
   migrations (D33, D39), Vitest. Acceptance tests run only against the throwaway `supplements_test` database.
 - Money, when it exists: integer cents only, never floats.
+- A task whose migration adds a table also owns `db/seed/demo.ts`: `RESET_TABLES` must name the table
+  (`tests/unit/seed-demo.test.ts` fails otherwise), so slice-tasks puts both in one `Owns:`.
```

### H29 Ship records go to main in their own MR  [status: proposed]

- F#: F40 · Layer: Skill · Reach: WORKFLOW.md
- Proposed: 2026-10-11 by route-failure (Claude Code, claude-opus-5-5) · Project: cerbo-supplement-store
- Apply in: software-factory-kit · Files: `docs/WORKFLOW.md`
- Root cause: Ship records are written after the milestone merge → main is protected, so they need an MR → no rule says which → they rode the next milestone's branch → report-milestone flagged them as unplanned commits twice (DV-5, DV-4).
- Why this layer: §10 "Phase procedure botched → Skill", at WORKFLOW.md reach because the MR rule lives in §8 and ship-milestone defers commits to the supervisor; Cerbo already switched to chore/m<N>-ship-records MRs at M6, so the rule records a working pattern. A report-milestone exemption would hide the records inside another milestone's revert.
- Rules: `docs/WORKFLOW.md` §8: 11 → 11 bullets (the Done bullet extended); pruned: none.
- Guard: `git log --first-parent --format=%s main` shows a ship-records merge after each milestone merge, and the next report-milestone lists no records-only unplanned commit.
- Teach: "Every change to main, even a record, takes its own reviewed path, so reverting a milestone never takes another milestone's paperwork with it."
- diff-sha256: 0a295ac08761
- Verdict: pending G-L5

```diff
--- a/docs/WORKFLOW.md
+++ b/docs/WORKFLOW.md
@@ -270,7 +270,10 @@
   a local run alone.
 - **Every deploy ends with a review link** (owner's rule, 2026-10-10): once `/version` shows the deployed SHA, the
   human gets the URL and a numbered walkthrough per demo user (ship-milestone STOP A).
-- Done = merged **and** `make check` run on main, SHA recorded in `MILESTONES.md` and Resume.
+- Done = merged **and** `make check` run on main, SHA recorded in `MILESTONES.md` and Resume. Records written after
+  the merge (the MILESTONES done row, the release log) reach a protected `main` through their own
+  `chore/m<N>-ship-records` MR, merged on green CI under the same standing yes; never on the next milestone's
+  branch, where report-milestone counts them as unplanned commits (G5 DV) and a revert of that milestone takes them.
 
 ## 9. Decision journal schema (`docs/decisions/DECISION_JOURNAL.md`, committed)
 
```

### H30 Measure tokens, human touches and wall-clock per milestone  [status: adopted]

- F#: F47 · Layer: Script · Reach: kit (scripts, report-milestone, WORKFLOW §10, templates)
- Proposed: 2026-10-14 by the supervisor (Claude Code, claude-opus-5-5) from reports/factory-level-up-context.md · Project: all
- Apply in: software-factory-kit · Files: `scripts/measure-usage.sh` (new), `scripts/test.sh`, `scripts/init-repo.sh`, `skills/report-milestone/{SKILL.md,assets/template.md,references/commands.md}`, `docs/WORKFLOW.md`, `templates/docs/metrics/FACTORY_METRICS.md` (new)
- Root cause: Cost was only read from per-run events.jsonl files → the supervisor session and Agent-tool subagents have none → every report said "not measured", and no one counted human touches → gate changes could only be judged by feel.
- Why this layer: §10 "Mechanical step done wrong → Script". Claude Code and Codex already log every turn's usage on disk, so a read-only script measures it exactly; a prompt asking the model to estimate would be a guess.
- Scope chosen by the human: option B (forward only, no backfill of Cerbo v2 or Equinox), name `measure-usage.sh`.
- Rules: WORKFLOW §10 metrics paragraph extended; report-milestone gains one owned path (its FACTORY_METRICS.md row) and recipe 10b; pruned: the "supervisor session … not measured" row.
- Guard: scripts/test.sh section 7 (fixture logs: in-window human prompts only, streamed-block dedupe, worktree subagents counted, Codex cached split); the next milestone report shows numbers in §8 Human touches and §9 supervisor row.
- Teach: "You can't remove a gate safely until you can see what it costs; the harness already writes the receipts, so read them instead of guessing."
- Check run before proposing: on Cerbo v2's window (2026-10-08 22:30 → 2026-10-12 00:00 CDT) it printed 296 prompts typed, 73.5 h, 2 Claude sessions, about 1.49 billion tokens (1.46 B cache reads, 2.3 M output). Not recorded in any project (option B).
- diff-sha256: 30a9ca682835
- Verdict: G-L5 approved 2026-10-14 22:32 CDT: "approve"

```diff
diff --git a/docs/WORKFLOW.md b/docs/WORKFLOW.md
index c81fd5e..6ab35c5 100644
--- a/docs/WORKFLOW.md
+++ b/docs/WORKFLOW.md
@@ -321,7 +321,9 @@ prune before adding (~20-rule ceiling per file).
 | One-off model quirk | nothing durable | log it only |
 
 Factory metrics: north star = first-pass acceptance rate per task and per MR; supporting = fix loops per task,
-gate Revise rate, scope-guard blocks, rework after merge. Never lines of code or agent counts.
+gate Revise rate, scope-guard blocks, rework after merge; cost = human touches (prompts typed + approvals), tokens
+per harness and model, and wall-clock per milestone, from `scripts/measure-usage.sh`, with one row per milestone in
+the project's `docs/metrics/FACTORY_METRICS.md`. Never lines of code or agent counts.
 
 ## 11. Terminology
 
diff --git a/scripts/init-repo.sh b/scripts/init-repo.sh
index 7363db0..86b3324 100755
--- a/scripts/init-repo.sh
+++ b/scripts/init-repo.sh
@@ -13,7 +13,8 @@ Scaffolds into <repo-dir> (must be the root of a git repository):
   templates/**                      → same paths (AGENTS.md, CLAUDE.md, .claude/settings.json, .githooks/pre-push,
                                        .gitlab-ci.yml, .gitlab/merge_request_templates/Default.md, .handoff/TRACKER.md,
                                        MILESTONES.md,
-                                       docs/README.md, docs/decisions/{DECISION_JOURNAL,REVIEW}.md, specs/_templates/*)
+                                       docs/README.md, docs/decisions/{DECISION_JOURNAL,REVIEW}.md, docs/metrics/FACTORY_METRICS.md,
+                                       specs/_templates/*)
   templates/Makefile.example        → Makefile when the repo has none (its check target fails until you adapt it);
                                        Makefile.example when a Makefile exists without a `check:` target
   agents/verifier.md                → .claude/agents/verifier.md
diff --git a/scripts/measure-usage.sh b/scripts/measure-usage.sh
new file mode 100755
index 0000000..8d292c2
--- /dev/null
+++ b/scripts/measure-usage.sh
@@ -0,0 +1,87 @@
+#!/usr/bin/env bash
+# measure-usage.sh — tokens, human touches and wall-clock for one project over a time window.
+#
+# Why this exists: gates can't be removed safely without measuring what they cost (FINDINGS F47). The per-run
+# events.jsonl files only cover delegated workers; the supervisor session and in-session subagents were
+# "not measured". Claude Code and Codex already log every turn's token usage on disk, so this reads those logs.
+set -euo pipefail
+usage() {
+  cat <<'EOF'
+usage: scripts/measure-usage.sh <repo-dir> <since> [<until>]
+  <since>/<until>: ISO 8601 times (e.g. 2026-10-14T09:00:00-05:00); <until> defaults to now.
+  Reads Claude Code transcripts (~/.claude/projects/**/*.jsonl, subagents included) and Codex sessions
+  (~/.codex/sessions/**/*.jsonl) whose working directory is <repo-dir> or a sibling/nested worktree of it.
+  Prints a markdown table: tokens per harness and model, human touches (prompts you typed), and wall-clock.
+  Tokens are the signal; a Max plan bills no per-token cost, so no dollar figure is printed.
+  Env: CLAUDE_PROJECTS_DIR, CODEX_SESSIONS_DIR override the log roots (used by test.sh).
+EOF
+}
+case "${1:-}" in -h | --help) usage; exit 0 ;; esac
+[ $# -ge 2 ] && [ $# -le 3 ] || { usage >&2; exit 2; }
+repo=$(cd "$1" && pwd -P)
+python3 -I - "$repo" "$2" "${3:-}" "${CLAUDE_PROJECTS_DIR:-$HOME/.claude/projects}" "${CODEX_SESSIONS_DIR:-$HOME/.codex/sessions}" <<'PY'
+import json, sys, glob, os
+from datetime import datetime, timezone
+repo, since, until, claude_root, codex_root = sys.argv[1:6]
+def ts(s):
+    d = datetime.fromisoformat(s.replace("Z", "+00:00"))
+    return d if d.tzinfo else d.astimezone()
+t0 = ts(since); t1 = ts(until) if until else datetime.now(timezone.utc)
+def mine(cwd):  # the repo, anything inside it, or a sibling worktree named <repo>-<id>
+    return bool(cwd) and (cwd == repo or cwd.startswith(repo + "/") or cwd.startswith(repo + "-"))
+def inwin(s):
+    try: return t0 <= ts(s) <= t1
+    except Exception: return False
+rows = {}  # (harness, model) -> [in, cache_write, cache_read, out]
+def add(h, m, a, b, c, d):
+    r = rows.setdefault((h, m or "unknown"), [0, 0, 0, 0]); r[0] += a; r[1] += b; r[2] += c; r[3] += d
+seen, touches, sessions = set(), 0, set()
+for f in glob.glob(os.path.join(claude_root, "**", "*.jsonl"), recursive=True):
+    try: fh = open(f, encoding="utf-8", errors="replace")
+    except OSError: continue
+    for line in fh:
+        try: e = json.loads(line)
+        except ValueError: continue
+        if not mine(e.get("cwd")) or not inwin(e.get("timestamp", "")): continue
+        t = e.get("type")
+        if t == "user" and e.get("turnOrigin") == "human" and not e.get("isSidechain"):
+            touches += 1
+        elif t == "assistant":
+            msg = e.get("message") or {}
+            key = (msg.get("id"), e.get("requestId"))
+            u = msg.get("usage")
+            if not u or key in seen: continue  # streamed blocks repeat one message's usage
+            seen.add(key); sessions.add(e.get("sessionId"))
+            add("claude", msg.get("model"), u.get("input_tokens", 0), u.get("cache_creation_input_tokens", 0),
+                u.get("cache_read_input_tokens", 0), u.get("output_tokens", 0))
+codex_sessions = 0
+for f in glob.glob(os.path.join(codex_root, "**", "*.jsonl"), recursive=True):
+    cwd = model = None; counted = False
+    try: fh = open(f, encoding="utf-8", errors="replace")
+    except OSError: continue
+    for line in fh:
+        try: e = json.loads(line)
+        except ValueError: continue
+        p = e.get("payload") or {}
+        if e.get("type") == "session_meta":
+            cwd = p.get("cwd"); model = p.get("model") or model
+        elif e.get("type") == "turn_context":
+            model = p.get("model") or model
+        elif e.get("type") == "event_msg" and p.get("type") == "token_count" and mine(cwd) and inwin(e.get("timestamp", "")):
+            u = ((p.get("info") or {}).get("last_token_usage")) or {}
+            if not u: continue
+            cached = u.get("cached_input_tokens", 0)
+            add("codex", model, u.get("input_tokens", 0) - cached, u.get("cache_write_input_tokens", 0), cached, u.get("output_tokens", 0))
+            counted = True
+    codex_sessions += counted
+print(f"Window: {t0.isoformat(timespec='minutes')} → {t1.isoformat(timespec='minutes')} · wall-clock {(t1 - t0).total_seconds() / 3600:.1f} h")
+print(f"Human touches: {touches} prompts typed · Claude sessions: {len(sessions)} · Codex sessions: {codex_sessions}")
+print()
+print("| Harness | Model | Input | Cache write | Cache read | Output |")
+print("|---|---|---|---|---|---|")
+tot = [0, 0, 0, 0]
+for (h, m), r in sorted(rows.items()):
+    print(f"| {h} | {m} | " + " | ".join(f"{x:,}" for x in r) + " |")
+    tot = [a + b for a, b in zip(tot, r)]
+print("| **total** | | " + " | ".join(f"**{x:,}**" for x in tot) + " |")
+PY
diff --git a/scripts/test.sh b/scripts/test.sh
index f9e38e1..ca4def9 100755
--- a/scripts/test.sh
+++ b/scripts/test.sh
@@ -399,6 +399,33 @@ rc 0 "install --dry-run: succeeds" env HOME="$tmp/home" bash "$kit/scripts/insta
 if [ ! -e "$tmp/home" ]; then ok "install --dry-run: changed nothing"; else bad "install --dry-run: changed nothing"; fi
 rc 0 "install --uninstall --dry-run: succeeds" env HOME="$tmp/home" bash "$kit/scripts/install.sh" --uninstall --dry-run
 
+# ---- 7. measure-usage.sh (fixture logs; no real transcripts read) ---------------------------------------
+mu=$tmp/mu; mkdir -p "$mu/claude/p/sub" "$mu/codex/2026/10/14" "$mu/repo" "$mu/repo-T001" "$mu/other"
+r=$(cd "$mu/repo" && pwd -P)
+o=$(cd "$mu/other" && pwd -P)
+cat >"$mu/claude/p/s.jsonl" <<JSONL
+{"type":"user","turnOrigin":"human","cwd":"$r","timestamp":"2026-10-14T10:00:00Z","sessionId":"s1"}
+{"type":"user","cwd":"$r","timestamp":"2026-10-14T10:00:01Z","sessionId":"s1"}
+{"type":"assistant","cwd":"$r","timestamp":"2026-10-14T10:00:02Z","sessionId":"s1","requestId":"q1","message":{"id":"m1","model":"claude-x","usage":{"input_tokens":10,"cache_creation_input_tokens":20,"cache_read_input_tokens":30,"output_tokens":5}}}
+{"type":"assistant","cwd":"$r","timestamp":"2026-10-14T10:00:02Z","sessionId":"s1","requestId":"q1","message":{"id":"m1","model":"claude-x","usage":{"input_tokens":10,"cache_creation_input_tokens":20,"cache_read_input_tokens":30,"output_tokens":5}}}
+{"type":"user","turnOrigin":"human","cwd":"$o","timestamp":"2026-10-14T10:00:03Z","sessionId":"s9"}
+{"type":"user","turnOrigin":"human","cwd":"$r","timestamp":"2026-10-13T10:00:00Z","sessionId":"s1"}
+JSONL
+cat >"$mu/claude/p/sub/agent.jsonl" <<JSONL
+{"type":"assistant","isSidechain":true,"cwd":"$r-T001","timestamp":"2026-10-14T11:00:00Z","sessionId":"s1","requestId":"q2","message":{"id":"m2","model":"claude-x","usage":{"input_tokens":1,"cache_creation_input_tokens":0,"cache_read_input_tokens":0,"output_tokens":2}}}
+JSONL
+cat >"$mu/codex/2026/10/14/rollout.jsonl" <<JSONL
+{"type":"session_meta","timestamp":"2026-10-14T12:00:00Z","payload":{"cwd":"$r","model":"gpt-x"}}
+{"type":"event_msg","timestamp":"2026-10-14T12:00:01Z","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":100,"cached_input_tokens":40,"output_tokens":7}}}}
+JSONL
+rc 0 "measure-usage: runs on fixture logs" env CLAUDE_PROJECTS_DIR="$mu/claude" CODEX_SESSIONS_DIR="$mu/codex" \
+  bash "$kit/scripts/measure-usage.sh" "$mu/repo" 2026-10-14T00:00:00Z 2026-10-14T23:00:00Z
+has "measure-usage: counts only in-window human prompts in this repo" "$out" "Human touches: 1 prompts typed"
+has "measure-usage: dedupes streamed blocks, includes worktree subagents" "$out" "| claude | claude-x | 11 | 20 | 30 | 7 |"
+has "measure-usage: Codex input excludes cached tokens" "$out" "| codex | gpt-x | 60 | 0 | 40 | 7 |"
+has "measure-usage: wall-clock from the window" "$out" "wall-clock 23.0 h"
+rc 2 "measure-usage: usage error without a window" bash "$kit/scripts/measure-usage.sh" "$mu/repo"
+
 echo
 echo "# $passed passed, $failed failed"
 [ "$failed" = 0 ]
diff --git a/skills/report-milestone/SKILL.md b/skills/report-milestone/SKILL.md
index e7dc14c..cba5677 100644
--- a/skills/report-milestone/SKILL.md
+++ b/skills/report-milestone/SKILL.md
@@ -17,7 +17,8 @@ confidence up.
 
 ## You own / You never touch
 
-- You own `docs/milestones/M<N>.md` fully (create it; regenerate it on a re-run or a Revise); you never edit
+- You own `docs/milestones/M<N>.md` fully (create it; regenerate it on a re-run or a Revise) and this milestone's one
+  row in `docs/metrics/FACTORY_METRICS.md` (append it; replace it on a re-run); you never edit
   `MILESTONES.md` (the supervisor owns its status column; merge SHA, main-check SHA and tag exist only after the
   merge), `specs/**`, `docs/decisions/**`, `docs/security/**`, `docs/product/**`, `tests/**` or product code.
 - You own reading `.handoff/**` (TRACKER, runs, reviews) as evidence; you never write there, except, when
@@ -116,7 +117,10 @@ command, or a claim without its evidence, stays out of the report.
     (which FAIL lines are route-failure candidates). In §9 say plainly that Claude's `total_cost_usd` is an
     API-equivalent figure a Max plan does not bill, and that Codex on the seat reports tokens only; anything
     without an event file is `not measured`, never an estimate. §10 "Checked by" comes from each task's VERIFY Log
-    line, or `⚠ no VERIFY line`.
+    line, or `⚠ no VERIFY line`. Run recipe 10b (`scripts/measure-usage.sh`) over the milestone window and paste
+    its output in §9: it measures the supervisor session and in-session subagents that leave no `events.jsonl`, and
+    gives §8 its human-touch and wall-clock rows. Then append the milestone's row to `docs/metrics/FACTORY_METRICS.md`
+    with the same numbers.
 11. **Not verified and rollback, §11-§12 (recipe 11).** Gather every `not_verified` from result files (worker
     claims), the verifier's Not reviewed list, each recipe that could not run, Approvals rows with no resolvable
     sha, and unmeasured cost. Riskiest first. For rollback, state the merge method, write the one-line revert, and
diff --git a/skills/report-milestone/assets/template.md b/skills/report-milestone/assets/template.md
index d29a0da..9dcca37 100644
--- a/skills/report-milestone/assets/template.md
+++ b/skills/report-milestone/assets/template.md
@@ -193,6 +193,8 @@ $ {{recipe 8 commands}}
 | Gate Revise count | {{r}} of {{g}} gate answers | `## Approvals` rows of this milestone whose words say Revise |
 | Scope-guard blocks | {{b}} logged · {{x}} failing now (§4.3) | FAIL lines naming scope-guard + non-zero exits in §4.3 |
 | Rework after merge | n/a — measured at the next milestone | — |
+| Human touches | {{h}} prompts typed · {{a}} Approvals rows | recipe 10b `Human touches` line · `## Approvals` rows of this milestone |
+| Wall-clock | {{w}} h | recipe 10b window: first to last TRACKER Log line of M{{N}} |
 
 ```console
 $ {{recipe 9 loop}}
@@ -213,7 +215,7 @@ a slice-tasks gap, worth a route-failure row"}}
 | Run | Harness | Tokens in / cached / out | Reported cost | Source |
 |---|---|---|---|---|
 | {{M<N>-T### or M<N>-T###.attempt-<ts>}} | {{claude / codex}} | {{in}} / {{cached}} / {{out}} | {{$x.xxxx API-equivalent / seat: not metered per run}} | `events.jsonl` {{result / turn.completed}} |
-| supervisor session | Claude Code | not measured: {{why}} | not measured | — |
+| supervisor session + in-session subagents | Claude Code | {{in}} / {{cached}} / {{out}} from recipe 10b | tokens only (Max plan) | `scripts/measure-usage.sh` |
 
 Totals: {{claude API-equivalent $ over n runs}} · {{codex tokens over n runs}} · {{n}} runs not measured.
 
diff --git a/skills/report-milestone/references/commands.md b/skills/report-milestone/references/commands.md
index 615db37..2f6a96a 100644
--- a/skills/report-milestone/references/commands.md
+++ b/skills/report-milestone/references/commands.md
@@ -219,8 +219,17 @@ Gate Revise count: recipe 6. Rework after merge: measured at the next milestone,
 
 Claude workers write stream-json (`"type":"result"` carries `total_cost_usd`, an API-equivalent figure that a Max
 subscription does not bill). Codex `exec --json` writes `turn.completed` events with token usage only (seat, not
-metered per run). Agent-tool subagents and the interactive supervisor leave no `events.jsonl`: write
-`not measured: <why>`, never an estimate.
+metered per run). Agent-tool subagents and the interactive supervisor leave no `events.jsonl`; recipe 10b measures them from the
+harness logs instead. Anything neither covers is `not measured: <why>`, never an estimate.
+
+**Recipe 10b: whole-milestone usage, human touches, wall-clock.** The window is the first to the last TRACKER Log
+line of the milestone (the Log's dates carry their timezone from `date`).
+
+```bash
+first=$(section Log | grep -E "[[:space:]]$M-T" | head -n 1 | cut -c1-25)
+last=$(section Log | grep -E "[[:space:]]$M-T" | tail -n 1 | cut -c1-25)
+bash "${FACTORY_KIT_DIR:-$HOME/Desktop/gauntlet_workbench/software-factory-kit}/scripts/measure-usage.sh" . "$first" "$last"
+```
 
 ```bash
 for d in .handoff/runs/$M-T*/; do e=${d}events.jsonl
diff --git a/templates/docs/metrics/FACTORY_METRICS.md b/templates/docs/metrics/FACTORY_METRICS.md
new file mode 100644
index 0000000..7c7b7bf
--- /dev/null
+++ b/templates/docs/metrics/FACTORY_METRICS.md
@@ -0,0 +1,8 @@
+# Factory metrics
+
+One row per milestone, appended by `report-milestone` (numbers from `docs/milestones/M<N>.md` §8-§9).
+The goal: fewer human touches per milestone with equal or fewer escaped defects (bugs found by using the app after
+merge), while tokens and wall-clock stay measured. A Max plan bills no per-token cost, so tokens are the cost signal.
+
+| Milestone | Wall-clock (h) | Human touches (prompts / approvals) | First-pass | Tokens in+cache / out | Escaped defects | Report |
+|---|---|---|---|---|---|---|
```

### H31 BMAD principles: sessions and batched checkpoints  [status: on branch bmad-principles, pending merge]

- F#: F48 · Layer: Agent policy · Reach: kit (WORKFLOW §2 rule 3, §3, §4, §4b, §5; templates/CLAUDE.md; 3 new skills; log-decision; verifier)
- Proposed: 2026-10-14 by the supervisor (Claude Code, claude-opus-5-5) · Requested by the human: "lets shift to b-mad principals, and put those changes on a different branch"
- What changed: one command per session (/plan-product, /plan-design, /build-milestone) chaining the existing phase skills; GI and GD batched cards (Type 1 + human-only ⚠ only); Type 2 decisions proceed via an `auto-T2` Approvals row; readiness PASS/CONCERNS/FAIL replaces G4; three verifier lenses; GT try-it checklist per role then merge on green replaces G5; tracks move both ways; spec frozen after GI/GD.
- Kept: every phase skill, scope-guard, make check, pre-push, verbatim approvals, the decision journal, human-only actions.
- Guard: H30 metrics on the next project — human touches per milestone below Cerbo v2's, escaped defects equal or lower.
- Merge: review the branch MR; merging it is the approval.
