---
name: write-prd
description: Use when an approved brief (G0) exists and the product's requirements must be written or extended before any design work, or when G1 came back Revise. Produces docs/product/prd.md. Do NOT use for resolving open ⚠ questions in an existing PRD (use clarify-spec) or for choosing architecture or stack (use design-hld).
disable-model-invocation: true
metadata:
  software-factory-kit: "0.1"
  phase: "3"
  gate: "G1"
---

# write-prd

**Outcome:** `docs/product/prd.md` filled from `assets/template.md` — every section present, every requirement
testable and traced to a story, every assignment requirement it owns traced to PRD ids, no technology named outside
`## Constraints`, open unknowns marked `⚠` — waiting at gate **G1** for the human's Approve / Revise / Stop.

## You own / You never touch

- You own `docs/product/prd.md` fully (create it, or update it in place as a living document); you never edit the
  brief, `docs/research/**`, `docs/audit/**`, `docs/decisions/**`, `specs/**`, `MILESTONES.md`, `.handoff/**`,
  `AGENTS.md`, `CLAUDE.md`, code or tests, and you never commit: the supervisor commits the PRD (and companion
  files) before it records G1.
- You own the graded companion files a brief REQ row names (e.g. `USERS.md`, `KEY_METRICS.md`), at that row's
  exact path (else under `docs/product/`), as verbatim copies of PRD lines; you never create one no REQ row names,
  and you regenerate every one on each run so none drifts from the PRD.
- You own the WHAT and the WHY; you never choose the HOW (frameworks, databases, endpoints, tables, screen layouts)
  — you turn each HOW idea into the need it serves, or park it for `design-hld`.
- You own asking the human; you never answer for them — unknowns become `⚠`, and anything you assume beyond what
  its cited line says (delegated by "you decide" or inferred by you) becomes `A-n … Basis: assumed by agent;
  confirm at G1`.
- You own reading every cited document wherever it lives; you never copy an outside document into the repo, write a
  local path (`/Users/…`, `/home/…`, `~/…`) into the PRD, or quote an uncleared source word for word (the brief's
  open `U-##` "may the brief quote…" row): paraphrase it with its page or section, as the brief does.
- You own concrete examples; you never put real patient data, partner-confidential text or secret values in the
  PRD: AEs and ECs use fictional people and values, and a logged reply has such values replaced by
  `[redacted: <what it was>]`. The repo is public.
- You own the milestone cut by FR ids; you never write tasks, task estimates or `MILESTONES.md` rows.
- You own the draft and the gate message; you never record an approval or start the next phase.

## Inputs

Read these first, fully. Run `date` before writing any time.

1. `AGENTS.md` — project rules and commands. A technology it names is a mandate only when it cites the document
   that mandates it. Missing → stop: "No AGENTS.md; run `scripts/init-repo.sh` (G-init) first."
2. The brief (`$B`): the path the human passes, else `ls specs/*/brief.md` (exactly one → use it; several → ask
   which, as your first question). It needs a G0 row for `<brief>@<sha>` in `.handoff/TRACKER.md ## Approvals`,
   and `git diff --quiet <sha> -- <brief>` must exit 0. Missing or non-zero → stop: "Brief <path> has no current G0
   approval; finish `sharpen-brief` / G0 first." Read it all, above all: `## Spec is law` (each `REQ-##` row cites
   its source and names a deliverable and an owner), the `JS-##` job stories, the `R<NN>` research questions,
   `problem_allowlist`, the `Greenfield or brownfield:` line, and every `⚠ … (→ G0)` still open. G0 approved with
   those open waived them, it did not answer them: they go to the top of your gap list (Step 3).
3. Every assignment, rubric or partner document the brief cites (its `assignment:` field and REQ Source column). A
   repo path → read it. Named but outside the repo → ask the human where it is (an input request, not one of the 5
   questions) and read it there. A cited document that cannot be read → stop and name it; never reconstruct it from
   memory. Cite it as the brief does — `path:line`, or `<file or source name> p.N` / `§N` for a PDF or an outside
   document — usually through its REQ id, which already carries that location.
4. `docs/research/sources.md` and every `docs/research/R<NN>-*.md`, paired with the brief's R rows by id. A brief R
   row with no R file is not a stop: it tops the gap list (Step 3), and if still unanswered it becomes
   `⚠ … (→ R<NN>)` and a research follow-up in STOP.
5. The brief's `Greenfield or brownfield:` line decides. Brownfield → `docs/audit/AUDIT.md` with `status: approved`
   is required (missing or draft → stop: "Brownfield brief without an approved audit; run `audit-codebase`
   first."); its `constrain` findings feed Constraints and Non-goals. Greenfield → read `AUDIT.md` only if it exists
   (a rebuild-reference audit). If the line disagrees with the repo (greenfield, yet product code that
   `init-repo.sh` did not scaffold is present), ask that as your first question instead of stopping.
6. `docs/decisions/DECISION_JOURNAL.md` — never contradict an accepted `D<n>`; cite it.
7. `docs/product/prd.md` if it exists → **update mode** (Step 1). On a Revise re-run, also the newest G1 row for it
   in `.handoff/TRACKER.md ## Approvals` (the human's exact Revise words) and whatever those words point at (e.g.
   the `Q-n` rows of `specs/M<N>-<slug>/acceptance.md` that `define-acceptance` handed back).

`.handoff/inbox/` holds candidate sources only; never cite it as evidence.

## The one rule

Write what the product must do and why it matters, in the users' words, precisely enough that a stranger could
test it — and never how it will be built.

## Steps

1. **Set the mode.** No PRD → create from `assets/template.md`. PRD exists → update: keep every existing id and
   its meaning; new ids continue from the highest existing one
   (`grep -oE 'FR-[0-9]{3}' docs/product/prd.md | sort -u | tail -1`, same for NFR/SC/AE); retire ids with
   strikethrough, never delete or renumber; leave `## Clarifications` untouched. Every run adds exactly one
   `## Change log` row (a new PRD gets `First draft`).
   **On a Revise re-run:** read the human's exact Revise words (Input 7); change only what they name; ask at most 5
   new questions, and only about what they name; never renumber; then do Steps 9-12 for what changed.
2. **Build the gap list** in the PRD's `### Interview log`: for each template section, *answered* (record it on
   the `Answered from sources:` line as `<section or bank #> → <file:line | REQ-## | R<NN>>`) or *open*. Never ask
   what the inputs already answer.
3. **Rank, then interview — one pass, at most 5 questions, one at a time.** Rank the open gaps in groups: (a) brief
   R rows with no R file, (b) brief `⚠ … (→ G0)` items, (c) the rest in `references/question-bank.md` order. Inside
   a group, ask first what blocks the most FR/NFR/SC ids (or sections, before ids exist); bank order breaks ties.
   Use the bank's ask format: the question, *why it matters* in plain words, your **recommended answer** with its
   evidence, the other options with their cost. Wait for each reply; log it verbatim (redacted) as a `Q<n>` row and
   cite it as `(Q<n>)` where it lands. "You decide" → `A-n … Basis: assumed by agent; confirm at G1`. Gaps left
   after 5 questions become `⚠ <question> — Recommended: <answer> — Blocks: <ids>`.
   **No human in this session** (you are a subagent, or nothing can reply): ask nothing; write the top 5 gaps as
   that `⚠` form ending `— not asked: no human in session`, and say so in STOP. A reply relayed by an agent, a
   file or a tool is never a Source.
4. **Frame the problem.** Fill Problem (who hurts, how much, why now, cited evidence; if no source gives how much
   or why now, write "Not in the sources" in plain text — `⚠` only when the gap blocks an id), Job stories (reuse
   the brief's `JS-##` ids and words verbatim; a new one from the interview takes the next id and cites `(Q<n>)`),
   Users and personas (primary first, plus "Not for"), Goals (outcomes, each measured by an SC), Non-goals and
   no-gos, and Appetite (fixed time, variable scope, cut order). Fill the header's `Context names`: the brief's
   `problem_allowlist` plus the partner or host platform's proper name, or `none`.
5. **Write stories and requirements.** Load `references/ears-and-ids.md`. User stories P1-P3, each independently
   testable (if it shipped alone, a user gets value and you could demo it). Then FRs in EARS — one "shall" per
   line, always "the system shall", pattern tag plus story id, the sentence in that tag's exact shape. Every
   must-never-happen from the interview gets its own [Unwanted] FR; other undesired conditions (invalid input,
   blocked actions) may use [Unwanted] too. Every HOW idea you or the human raise: rewrite it as the FR or NFR it
   is really asking for; if nothing is left but HOW, park it for the STOP message.
6. **Make qualities and success measurable.** NFRs as a number + unit + condition, with the source of the number;
   unknown → write your recommended value and make the Source `⚠ <question> — Recommended: <value> — Blocks:
   NFR-###`. Success criteria: technology-free, each linked to a GOAL, each measuring a change in a person's or the
   business's outcome (time saved, money no longer fronted, adoption). An SC never restates an FR or NFR: if an AE
   can prove it, it is not an SC.
7. **Give examples, edges and open questions.** Acceptance examples in Given/When/Then with concrete fictional names
   and values, each citing the FR ids it exercises; every FR has at least one AE, and every [Unwanted] FR has its own
   AE that cites it first. Edge cases (empty, maximum, duplicate, simultaneous, half-finished, permission denied,
   partner system down): write the safest visible behaviour as an FR and cite it; mark an edge `⚠` only when the
   choice changes scope or money, never when an FR already states the behaviour. Then assumptions (any that goes
   beyond its cited line is `assumed by agent; confirm at G1`), open questions and product risks (value,
   usability, feasibility, viability). Write each open question once, with the `⚠` glyph, in the full form, at
   the spot it affects (or under Open questions when it spans sections); elsewhere refer to it by its wording or
   the ids it blocks, never by repeating the glyph.
8. **Cut milestones.** Full track (WORKFLOW.md §8): the planning phases are milestones with no FRs: M1 Research
   (brief + research), M2 Product (this PRD), M3 Design (HLD, LLD, diagrams; when the human splits it, M3 HLD and
   M4 LLD). The first implementation milestone after them (M4, or M5 after a split) = Tracer bullet: the thinnest
   end-to-end slice of the P1 journey that a person can watch work. Then the next ids by priority, and Later.
   Standard track: keep the existing rows and append the new milestone. Every active FR id sits in exactly one
   row. Each row has an exit demo in one sentence.
9. **Fill Constraints and the assignment trace last.** A constraint (technology, vendor, platform, rule, deadline,
   budget) needs a mandate from one of: a brief REQ row (it cites the assignment, partner or law); an accepted
   `D<n>` recording the human's mandate (a G0 answer, a G-audit `constrain` finding); or the human's interview
   answer naming who mandates it `(Q<n>)`. A preference with no one mandating it is a design choice: leave it out
   and park it. A cited document that names a technology, vendor or platform without clearly requiring it → a row
   whose Constraint is `⚠ Is <name> mandated, or context only? — Recommended: <treat as mandated / context only> —
   Blocks: C-<n>`, with its Source. List every technology, vendor or platform word of a row in its `Names` cell.
   Then `### Assignment trace`: one row per REQ owned by `write-prd`, delivered under `docs/product/`, naming a
   companion file, or cited by a C row — the PRD ids or companion file that satisfy it, or a `⚠`.
10. **Companion files.** Only for REQ rows that name them: copy the relevant PRD lines verbatim, ids included,
    under the heading `Derived from docs/product/prd.md — edit the PRD, not this file.` Regenerate them on every
    run (`clarify-spec` edits only the PRD).
11. **Verify.** Run every check in Done when; fix and re-run until all pass. Get every count you report from a
    command.
12. **Pick the one next skill.** `map-ux-flows` if any P1 story is done by a person on a screen; otherwise
    `design-hld`. Then print the STOP message and stop.

## Output

- `docs/product/prd.md` — fill `assets/template.md` exactly: every `## ` heading, same order, nothing renamed,
  every HTML comment and `{{placeholder}}` removed. A section with nothing in it says `None.` and why. Mark every
  unknown `⚠ <question> — Recommended: <answer> — Blocks: <ids>`; never invent a fact, number or quote.
- Companion files named by a REQ row, only (Step 10).

## Done when

Run from the project root. Every command must print nothing (the loops included). `B` = the brief;
`<companions>` = the companion file paths, or leave it empty.

```sh
P=docs/product/prd.md; T=<this skill's folder>/assets/template.md; B=<the brief>; CF='<companions>'
BODY=$(sed '/^## Clarifications/,$d' "$P")
diff <(grep '^## ' "$T") <(grep '^## ' "$P")                                     # all sections, same order
grep -nE '\{\{|<!--' "$P"                                                        # template fully filled
grep -oE '^- (~~)?\*\*(FR|NFR|SC|AE)-[0-9]{3}' "$P" | grep -oE '[A-Z]+-[0-9]{3}' | sort | uniq -d   # ids unique
grep -E '^- \*\*FR-' "$P" | grep -vE '^- \*\*FR-[0-9]{3}\*\* \[(Ubiquitous|Event|State|Unwanted|Optional|Complex)\] \(US-[0-9]+\) '
grep -E '^- \*\*FR-[0-9]{3}\*\* \[Ubiquitous\]' "$P" | grep -vE '\) The system shall '      # EARS shape per tag
grep -E '^- \*\*FR-[0-9]{3}\*\* \[Event\]' "$P"      | grep -vE '\) When .+, the system shall '
grep -E '^- \*\*FR-[0-9]{3}\*\* \[State\]' "$P"      | grep -vE '\) While .+, the system shall '
grep -E '^- \*\*FR-[0-9]{3}\*\* \[Unwanted\]' "$P"   | grep -vE '\) If .+, then the system shall '
grep -E '^- \*\*FR-[0-9]{3}\*\* \[Optional\]' "$P"   | grep -vE '\) Where .+, the system shall '
grep -E '^- \*\*FR-[0-9]{3}\*\* \[Complex\]' "$P"    | grep -vE '\) While .+, when .+, the system shall '
grep -E '^- \*\*FR-' "$P" | grep -iE 'shall.*shall'                              # one shall per FR
grep -E '^- \*\*NFR-' "$P" | grep -viE '[0-9] ?(%|ms|s|seconds?|min|minutes?|hours?|days?|weeks?|months?|years?|users?|people|requests?|orders?|items?|records?|times)([^a-z]|$)|[0-9] [a-z ]+ per [a-z]|\$ ?[0-9]|WCAG [0-9]'
grep -E '^- \*\*SC-' "$P" | grep -vE '\(GOAL-[0-9]+\)'                           # SC linked to a goal
grep -E '^- \*\*AE-' "$P" | grep -vE '^- \*\*AE-[0-9]{3}\*\* \(FR-[0-9]{3}(, FR-[0-9]{3})*\) Given .* When .* Then '
grep -E '^### US-' "$P" | grep -vE '\(P[123]\)$'                                 # every story prioritised
[ "$(grep -c '^### US-' "$P")" = "$(grep -c '^- Independent test:' "$P")" ] || echo "story missing Independent test"
grep -E '^- \*\*(FR|NFR|SC|AE)-' "$P" | grep -iwE 'fast|quick(ly)?|easy|easily|intuitive|user-friendly|robust|seamless(ly)?|appropriate(ly)?|optimal|as needed|etc|and/or'
MC=$(awk '/^## /{m=($0 ~ /^## Milestone cut/)} m' "$P")
for id in $(grep -oE '^- \*\*FR-[0-9]{3}' "$P" | grep -oE 'FR-[0-9]{3}'); do
  grep -qE "^- \*\*AE-[0-9]{3}\*\* \([^)]*${id}[,)]" "$P" || echo "no AE cites $id"
  n=$(printf '%s\n' "$MC" | grep -E '^\| (M[0-9]|Later)' | grep -cE "(^|[^N])$id"); [ "$n" -eq 1 ] || echo "$id in $n milestone rows"
done
for id in $(grep -E '^- \*\*FR-[0-9]{3}\*\* \[Unwanted\]' "$P" | grep -oE '^- \*\*FR-[0-9]{3}' | grep -oE 'FR-[0-9]{3}'); do
  grep -qE "^- \*\*AE-[0-9]{3}\*\* \(${id}[,)]" "$P" || echo "no AE leads with $id"
done
printf '%s\n' "$BODY" | grep '⚠' | grep -vE '⚠ .+ — Recommended: .+ — Blocks: [A-Z]+-[0-9]+'   # every ⚠ is one full question
printf '%s\n' "$BODY" | grep -E '⚠.*⚠'                                           # at most one per line
for q in $(printf '%s\n' "$BODY" | grep -oE '\(Q[0-9]+\)' | tr -d '()' | sort -u); do grep -qE "^\| $q \|" "$P" || echo "no Interview log row $q"; done
for r in $(awk -F'|' '$2 ~ /REQ-[0-9]+/ && ($5 ~ /docs\/product\// || $6 ~ /write-prd/) {gsub(/ /,"",$2); print $2}' "$B"); do grep -qw "$r" "$P" || echo "$r not traced"; done
for r in $(grep -oE 'REQ-[0-9]+' "$P" | sort -u); do grep -qE "^\| $r \|" "$B" || echo "$r not in the brief"; done
awk -F'|' '/^\| C-[0-9]+ / && $6 !~ /REQ-[0-9]+|D[0-9]+|\(Q[0-9]+\)/' "$P"      # every constraint cites its mandate
# Technology-name check: no framework / language / DB / data-model / endpoint / infra names outside ## Constraints
NOC=$(awk '/^## /{c=($0 ~ /^## (Constraints|Clarifications)/); i=0} /^### /{i=($0 ~ /^### Interview log/)} !c && !i {print FNR": "$0}' "$P")
printf '%s\n' "$NOC" | grep -iwE 'laravel|php|livewire|inertia|blade|eloquent|filament|sanctum|vite|alpine(\.?js)?|htmx|react|vue|svelte|angular|next\.js|nuxt|django|flask|fastapi|rails|express\.js|spring boot|node\.js|typescript|javascript|python|golang|java|tailwind|stripe|postgres(ql)?|mysql|mariadb|sqlite|mongo(db)?|redis|dynamodb|elasticsearch|supabase|firebase|s3|databases?|db|tables?|columns?|schemas?|migrations?|orm|sql|json|apis?|endpoints?|webhooks?|graphql|restful|rest api|grpc|oauth|jwt|saml|sso|cache|queue|cron|servers?|backend|frontend|frameworks?|librar(y|ies)|plugins?|widgets?|components?|apps?|deploy(s|ed|ment)?|cloud|docker|kubernetes|k8s|aws|gcp|azure|lambda|heroku|railway|vercel|nginx|microservices?'
printf '%s\n' "$NOC" | grep -iE '/api/|(^|[^a-z])(get|post|put|patch|delete) +/'
A=$(awk -F'|' '$2 ~ /^ *Context names *$/ {print $3}' "$P" | tr ',' '\n' | sed 's/^ *//; s/ *$//; /^$/d' | grep -vix 'none' | paste -sd'|' -)
CW=$(awk -F'|' '/^\| C-[0-9]+ / {print $4}' "$P" | tr ',' '\n' | sed 's/^ *//; s/ *$//; /^$/d' | grep -vixE "none|—|-|${A:-none}" | paste -sd'|' -)
[ -z "$CW" ] || printf '%s\n' "$NOC" | grep -iwE "$CW"                             # Constraint names stay in Constraints
[ -z "$A" ] || awk '/^## /{s=$0; i=0} /^### /{i=($0 ~ /^### Interview log/)} s != "" && !i && s !~ /^## (Problem|Users and personas|Constraints|Clarifications)/ {print FNR": "$0}' "$P" | grep -iwE "$A"
# Privacy: no personal values, no local paths
grep -inE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|\(?[0-9]{3}\)?[-. ]?[0-9]{3}[-. ][0-9]{4}|(dob|date of birth|born|mrn|patient[ _-]?(id|name|number))[^|]{0,20}[0-9]' "$P"
grep -nE '/Users/|/home/|~/' "$P"
for C in $(echo "$CF"); do grep -E '(FR|NFR|SC|AE)-[0-9]{3}|(US|JS|GOAL|NG|NOGO|EC|A|C|RISK)-[0-9]+' "$C" | while IFS= read -r l; do grep -qxF -- "$l" "$P" || echo "$C drifted: $l"; done; done
```

Update mode, also: `comm -23 <(git show HEAD:"$P" 2>/dev/null | grep -oE '(FR|NFR|SC|AE)-[0-9]{3}|US-[0-9]+' | sort -u) <(grep -oE '(FR|NFR|SC|AE)-[0-9]{3}|US-[0-9]+' "$P" | sort -u)`
prints nothing (no id vanished).

- [ ] All commands above print nothing. The only allowed technology-name hit is a word the users themselves use as
      domain vocabulary (e.g. a pharmacist's "queue"); each one is listed in the STOP message.
- [ ] Every job story cites its source (`JS-##` from the brief, or `(Q<n>)`); every number has a source or a `⚠`.
- [ ] No accepted `D<n>` is contradicted; no uncleared source is quoted word for word.
- [ ] Hits of `grep -inE 'password|secret|token|api[_-]?key|ssn|dob|mrn' "$P"` are descriptions only, never values.
- [ ] STOP numbers come from commands: counts
      `for k in '^### US-' '\(P1\)$' '^- \*\*FR-' '^- \*\*NFR-' '^- \*\*SC-' '^- \*\*AE-'; do printf '%s ' "$(grep -cE "$k" "$P")"; done; printf '%s\n' "$BODY" | grep -c '⚠'`;
      the Open ⚠ list is `printf '%s\n' "$BODY" | grep -n '⚠'` and has exactly that many lines; agent assumptions
      `sed -nE 's/^- \*\*(A-[0-9]+)\*\* .*assumed by agent; confirm at G1.*/\1/p' "$P"`; research follow-ups
      `printf '%s\n' "$BODY" | grep -oE '\(→ R[0-9]+\)' | grep -oE 'R[0-9]+' | sort -u`.

## STOP

Print this message, filled in, then stop. Do not start the next skill, even if the reply sounds like approval.

```
write-prd is done. Nothing else runs until you answer.

Written: docs/product/prd.md — <n> user stories (<n> P1), <n> FR, <n> NFR, <n> SC, <n> AE, <n> open ⚠
         <companion file paths | No companion files: no REQ row names one>
Uncommitted: <paths> (the supervisor commits them before recording G1)
Interview: <k> questions asked | not asked: no human in session (the top 5 gaps are ⚠ below)
Checks:  all Done-when commands print nothing. Technology-name check — words kept as the users' own vocabulary:
         <words | none>; context names allowed in Problem, Job stories and Users: <names | none>

How to read it: FR = something the product does · NFR = how well it does it, with a number · SC = how we will know
it worked for people · AE = a concrete example a tester can run · ⚠ = a question only you can answer · P1 = must
ship · tracer bullet (first build milestone, M4) = the thinnest end-to-end slice you can watch work · EARS = fixed sentence shapes
("When …, the system shall …", "If …, then the system shall …") that make each requirement testable.

Gate G1 · "Right problem, scope, non-goals, success measure; every ⚠ resolved or waived?"

Background: <2-3 plain sentences: whose problem, the P1 journey, what the tracer bullet (M4) will prove>
Least sure about: <the one scope or priority call most likely to be wrong, and why>
Read in this order: Problem + job stories (their pain, their words?) → Non-goals (anything you assumed was in?)
→ Success criteria (would hitting these numbers mean success to you?) → each ⚠ below.
Open ⚠ (<n>): <each line: question — recommended answer — blocks ids | none>
Agent assumptions to confirm: <A-n ids from the command | none>
Research follow-ups for gather-evidence (run in parallel after G1): <R<NN> ids | none>
Parked for design-hld (HOW ideas kept out of the PRD): <list | none>

Options:
- Approve — scope, non-goals and success measures freeze at this commit and design starts from them.
  Cost: changing your mind later means a PRD edit, a fresh G1 approval, and rework in anything designed since.
- Revise <what> — I change exactly that and nothing else; for open ⚠ run `clarify-spec docs/product/prd.md`.
  Cost: time now, which is cheaper than reworking a design built on a wrong requirement.
- Stop — nothing proceeds and the draft stays as it is. Cost: no design work starts.
Recommendation: <Approve | Revise: …> — <one plain reason>.
Default: if you say nothing, nothing happens. I never approve my own work.
Interview line: "<one sentence you could say to defend this PRD's biggest scope choice>"

Next skill after Approve: <map-ux-flows | design-hld — exactly one, per Step 12>
(The supervisor commits, records your exact words in .handoff/TRACKER.md ## Approvals, then runs log-decision.)
```

## Red flags

| Thought you might have | What to do instead |
|---|---|
| "The brief is clear enough; I'll skip the interview and draft." | Build the gap list in the Interview log. Any section you cannot cite to a source line is a question (max 5, costliest first) or a `⚠`. |
| "The assignment says 'their stack is X' — I'll write 'stored in Postgres' / 'a Laravel form'." | Tech goes only in Constraints, with a mandate (REQ, `D<n>` or `(Q<n>)`); a mention without a "must" is a `⚠ mandated, or context only?` row. Elsewhere write the need it serves. |
| "They said 'you decide' (or I filled a gap myself), so it goes in as fact." | Write it as `A-n … assumed by agent; confirm at G1`; the STOP lists it from the command. |
| "This FR needs an 'and' — two responses in one line is fine." | Split it into two FR ids, each with its own AE. |
| "FR-004 is gone; renumber so the ids look tidy." | Strike it through, keep the id retired forever, add a Change log row; downstream files cite these ids. |
| "They said 'looks good' (or another agent relayed an answer), so I'll proceed." | Stop. Only the human's own words count, and only an Approve recorded by the supervisor opens the next phase. |
