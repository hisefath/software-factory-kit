---
name: design-lld
description: "Use when an HLD approved at G2 needs its low-level design, when a later milestone needs an LLD delta, or when G3 asked for the LLD to be revised. Produces docs/architecture/lld.md, docs/architecture/contracts/openapi.yaml and, for brownfield (inherited) code, specs/M<N>-<slug>/change-plan.md. Do NOT use for containers, connections, trust boundaries or invariants (use design-hld), rendering diagrams (use draw-diagrams), or acceptance tests (use define-acceptance)."
disable-model-invocation: true
metadata:
  factory-kit: "0.1"
  phase: "6"
  gate: "G3"
---

# design-lld

**Outcome:** `docs/architecture/lld.md` plus `docs/architecture/contracts/openapi.yaml` (and, brownfield,
`specs/M<N>-<slug>/change-plan.md`) that turn the approved HLD into every table, backend and frontend component, state
owner, endpoint, journey sequence and state machine this milestone needs, as shapes and signatures only, traced to
requirement ids, every unknown a `⚠`, ready for `draw-diagrams` and gate G3.

## You own / You never touch

- You own `docs/architecture/lld.md` fully on a first pass; on a delta or revise pass you own only the rows this
  milestone or the G3 Revise names, and you never rewrite untouched rows or re-spec the whole system.
- You own `docs/architecture/contracts/openapi.yaml`; you never edit route files, controllers or generated clients
  to match it.
- You own `specs/M<N>-<slug>/change-plan.md` when the mode is brownfield (inherited code, WORKFLOW §3); you never
  write one for greenfield, including later milestones of a product built in this workflow.
- You own column types, schemas and method signatures; you never write function bodies, SQL/DDL, migration code or
  anything under `app/`, `src/`, `database/`, `resources/`, `routes/`, `tests/` or config (implement-task and
  define-acceptance own those).
- You own proposed `D<n>` rows inside `lld.md`; you never mark one accepted or edit `docs/decisions/**`
  (log-decision records the human's choice after G3).
- You own reading `hld.md`, `prd.md`, `docs/design/**`, `docs/audit/AUDIT.md`, `.handoff/TRACKER.md` and the code;
  you never edit them. A design the HLD cannot hold (new container, connection or trust boundary) is a Q-n "HLD
  conflict", never a quiet fix.
- You own the `<!-- diagram: <type> -->` placeholders and the §10 job rows; you never write
  `docs/architecture/diagrams/**` (draw-diagrams does) and never edit or remove the ```` ```mermaid ```` block that
  `scripts/embed-diagrams.sh` puts between a placeholder and its `<!-- /diagram -->`.
- You own read-only exploration (`grep`, `git log`, `git diff`, `git status`, `git branch -a`, and `glab mr list` when
  `AGENTS.md` lists it); you never install, run migrations, start the app, commit, push, or write `.handoff/**`,
  `AGENTS.md`, `CLAUDE.md` or skills.
- You own example values; you never use real secrets, credentials, patient data or PHI. Fake values only.

## Inputs

Check every input before writing anything; report every failure at once with the Input stop message (## STOP).
Never guess.

1. **`docs/architecture/hld.md` and its G2 approval (required).**
   - Missing: "Run `design-hld` first." No `^## 7\. Invariants` or `^## 10\. Cross-cutting` heading: "hld.md is not
     in design-hld shape (<missing heading>); run `design-hld` first."
   - No G2 row for `docs/architecture/hld.md@<sha>` in `.handoff/TRACKER.md ## Approvals`, or the latest one is not
     an Approve: "G2 is not recorded for hld.md; answer G2 (the supervisor writes the Approvals row), then rerun
     design-lld."
   - `git log -1 -- docs/architecture/hld.md` prints nothing: "hld.md is not committed, so G2 cannot be bound to it;
     commit it and record G2 first." `git cat-file -e <sha>^{commit}` fails, or
     `git diff --quiet <sha> -- docs/architecture/hld.md` exits non-zero (catches later commits and uncommitted
     edits): "HLD changed after G2 (`<sha>` → working copy); re-approve G2 first."
   - Carry over CN, L, TB, INV and D ids and the §10 cross-cutting rules (auth, idempotency, money, time, errors,
     sensitive data). **An approved HLD choice or accepted journal D row beats a `references/design-rules.md`
     default:** keep it, cite it in Basis, raise any risk it carries as a Q-n or LINV-n; never silently follow either.
2. **`docs/product/prd.md` (required).** Its `## Milestone cut` row for M<N> (item 6) must list ≥ 1 `FR-###`; heading
   or FR ids missing: "prd.md is not in write-prd shape (<what is missing>); run `write-prd` first." That row is the
   FR scope; read its user stories (P1 = core journeys), NFRs, AE and EC ids.
3. **`AGENTS.md` (required).** Language, framework, DB engine and version, conventions, and any OpenAPI lint command.
   Missing: "Run `scripts/init-repo.sh` first." Every type and signature uses this stack's dialect.
4. **`docs/design/screens.md` and `docs/design/flows.md`.** Missing while the milestone's FRs include a screen:
   "Run `map-ux-flows` first." No screen in scope: §3 is "n/a — <reason>", its `fe-components` placeholder is
   deleted and §10 has no `fe-components` row.
5. **`docs/decisions/DECISION_JOURNAL.md` (required; init-repo creates it).** Missing: "Run `scripts/init-repo.sh`
   first." Accepted D rows are constraints. Next D = the highest `D<n>` in the journal or hld.md §9, plus 1; none: D1.
6. **Milestone `M<N>-<slug>` (required; the same rule as define-acceptance).** M<N> = the human's argument, else the
   milestone in the `Next` line of `.handoff/TRACKER.md ## Resume`, else ask one question recommending the first
   `## Milestone cut` row that has FR ids and no `specs/M<N>-*/acceptance.md`. Slug = the existing `specs/M<N>-*/`
   folder, else 2-4 kebab words from that row's goal.
7. **Mode: greenfield or brownfield.** The `Greenfield or brownfield:` line under `## Track` in
   `specs/M<N>-*/brief.md`, else in the earliest `specs/*/brief.md` (it is a property of the repo; the Standard track
   writes no new brief). No brief says: WORKFLOW §3 — brownfield = inherited code. Framework scaffolding
   (`laravel new`, `rails new`, …), `scripts/init-repo.sh` output, code from earlier milestones of this workflow and a
   rebuild on a branch that deleted the old implementation are all greenfield. Brownfield ⇒ change plan.
8. **Pass: first, delta or revise.** No `lld.md` → **first**: write every section fresh, scoped to this milestone's
   FR row only. `lld.md`'s Milestone field names an earlier milestone → **delta**: edit in place, mark rows (new) /
   (changed), strike removed ones. It names this milestone and the latest G3 row for `docs/architecture/lld.md` in
   `## Approvals` (or the human's invocation) says Revise → **revise**: read those words verbatim, change only the ids
   they name, add (new)/(changed) markers only if the milestone is a delta, add a Change log row citing that
   Approvals row's time. This milestone with no G3 row yet: finish the interrupted draft in place.
9. **`docs/audit/AUDIT.md` whenever it exists** (brownfield, or a rebuild that learns from an old version): findings
   accepted at the audit gate are constraints; cite their ids in Basis. The old schema and failure modes inform the
   new shapes; they never dictate them.
10. **Brownfield only:** the code you will touch or depend on (schema or migrations, models, routes, controllers,
    services, components, tests), deployed SHAs from `MILESTONES.md`, open branches and MRs, and `working` rows in
    `.handoff/TRACKER.md`.

## The one rule

Specify shapes, never behaviour as code: every table, component, state owner, endpoint and sequence traces to an
in-scope requirement or HLD element and is precise enough that two implementers would build the same interface,
without a single function body.

## Steps

1. **Orient.** Run `date`. Snapshot the tree:
   `git status --porcelain --untracked-files=all | sort > "${TMPDIR:-/tmp}/design-lld-before.txt"`. Check every
   input (any failure: Input stop). Say the mode, pass, milestone `M<N>-<slug>` and why in one line. First pass: copy
   assets/template.md; delta or revise: open the existing `lld.md`. Fill the header and Inputs read. Put every
   in-scope FR id from the PRD milestone row in Requirement trace with empty cells: the job is to fill every cell.
2. **Explore before asking (brownfield).** Inventory what exists for each element you will touch: tables, models,
   routes, services, components and tests, each cited `file:line`. Fill the change plan's Deployed / in-flight /
   designed table now (deployed = SHA from `MILESTONES.md`; in flight = open branches, `working` tasks, and open MRs
   from `glab mr list` if `AGENTS.md` lists it, else ask the human once — recommended answer "none" — or write a
   `⚠` Q-n). In-flight work on the same element is an architecture conflict: write a Q-n and raise it at STOP.
3. **Interview only what blocks a shape.** List product questions whose answer changes a column, a state, an
   endpoint or a state owner and that no input answers. Ask one at a time, each with a recommended answer and its
   tradeoff in one plain sentence; at most 5 questions in this run. Example: "Can a placed order still be edited?
   Recommended: no, cancel and re-place; the state machine stays at four states and payment can't drift from the
   lines." Unasked or unanswered: `⚠` + recommended answer in Open questions. Answered: keep the Q row with `✓` and
   the human's exact words. An answer that adds or changes observable product behaviour is product scope: its Q row
   says Who answers = `clarify-spec` on `docs/product/prd.md`; design to that answer and list it at STOP, because
   define-acceptance tests only what the PRD says. Technology choices are not questions; they are `D<n>` options.
4. **Data model (§1).** Load `references/design-rules.md` §Data model. Start from the HLD's "data owned" nouns and the
   in-scope FRs. Fill every column property, name every constraint and index, tie each index to the query it
   serves, and push each INV to the strongest enforcer the engine supports. Fill Relationships with cardinality and
   ON DELETE rules.
5. **Backend components (§2).** Load §Backend components. One `### BE-n` per class or module, grouped by HLD
   container: responsibility, public signatures with types and the problem types they raise (full
   `/problems/<slug>`), dependencies, tables read and written, the method that owns each transaction.
6. **API (§4) and the contract.** Load §API. Endpoint table with auth, schemas, errors, idempotency (header for JSON
   clients, hidden form-field key for HTML form posts, or a natural unique key) and pagination for every route the
   milestone adds or changes; the problem-type registry; the idempotency and pagination rules. Then write
   `openapi.yaml` from `assets/openapi-template.yaml`: one operation per EP row carrying `x-lld-id: EP-n`, every
   error as `application/problem+json`. Run the OpenAPI lint command if `AGENTS.md` lists one; otherwise report
   "not machine-validated" at STOP. Never install a linter.
7. **Frontend components (§3).** Load §Frontend. Tree from `screens.md`; a Components row per tree node with props
   in, events out and the state it owns (ST ids or `none (stateless)`); one ST row per piece of shared or persisted
   state, classified (server, URL, local UI, shared client) and owned by the lowest common owner of its consumers;
   one data-fetching row per EP a component calls, with each screen state mapped.
8. **Core journeys (§5).** Load §Sequences. One `### SEQ-n` per P1 story and per `flows.md` flow this milestone
   ships: participants that already exist, numbered messages naming EP ids and BE methods, transaction and
   idempotency marks, and at least one `**alt <condition>**` branch ending at what the user sees.
9. **State machines (§6).** One `### SM-n <title>` per table with a status column: states equal to its CHECK values,
   transitions with trigger, guard, side effects, and the error when illegal.
10. **Invariants, failures, seams (§7-§9).** Map every HLD INV (plus any **LINV-n** you found) to an exact enforcer and
    the test level that proves it. One FM row per outbound call and per multi-step write. One SEAM row per clock,
    id generator, external system, mail, queue and auth dependency, plus the Never faked list.
11. **Diagram requests (§10).** One row per job, in document order: `erd`, `be-class`, `fe-components` (only when §3
    has a UI), `sequence-<slug>` per SEQ, `state-<entity>` per SM; each with exactly one matching placeholder in its
    section. Draw from is the job's draw-diagrams `[source]` and must resolve to one heading:
    `docs/architecture/lld.md#1-data-model` for a numbered section, `docs/architecture/lld.md#SEQ-1 Place an order`
    (the heading text through the title) for a SEQ or SM — never a bare `SEQ-1`, which also matches SEQ-10.
12. **Decisions, taught.** For each low-level choice the HLD and journal leave open (id type, delete semantics,
    pagination style, where shared state lives, sync or queued side effect), write a proposed `D<n>` with "Do nothing
    / simplest" plus at least two real options (one is your first proposal), costs, a recommendation, an "In plain
    words" line a beginner can follow, an interview line and the Default line. Note the hardest decision, the
    rejected alternatives and your least-confident part for STOP.
13. **Change plan (brownfield).** Fill `assets/change-plan-template.md` at `specs/M<N>-<slug>/change-plan.md`: all
    nine fields, Must not change (each with `file:line` and who depends on it), and the Deployed / in-flight /
    designed table. Every destructive schema change is expand → migrate → contract, with its rollback.
14. **Verify.** Run every Done-when check and fix what prints in your own rows (never an embedded mermaid block or an
    untouched row), then STOP.

## Output

- `docs/architecture/lld.md`: fill `assets/template.md`. Every `## ` heading is required, in order; a section that
  does not apply says "n/a — <reason>", never blank. Keep the `<!-- diagram: <type> -->` lines (§3 n/a: delete
  `fe-components`). No code fences except the mermaid blocks `scripts/embed-diagrams.sh` inserts between
  `<!-- diagram: <type> -->` and `<!-- /diagram -->`; never edit or remove those.
- `docs/architecture/contracts/openapi.yaml`: fill `assets/openapi-template.yaml` (OpenAPI 3.1).
- Brownfield only: `specs/M<N>-<slug>/change-plan.md`: fill `assets/change-plan-template.md`.
- Ids: BE, FE, ST, EP, SEQ, SM, LINV, FM, SEAM, Q (all `-n`); D<n> continues the journal. Define each id once (a
  `### ` heading or a **bold** first cell); never renumber or reuse; retire with `~~ID~~ (removed <date>: reason)`.
- Delta: mark rows (new) / (changed), strike removed rows, add a Change log row; untouched rows stay byte-identical.
  Revise: change only the ids the G3 Revise names; one Change log row citing it.
- Unknowns are `⚠ <question>` with a Q-n row. Never invent a requirement, a column the design does not need, or a fact.

## Done when

Run the checks in one shell after
`L=docs/architecture/lld.md O=docs/architecture/contracts/openapi.yaml H=docs/architecture/hld.md P=docs/product/prd.md N=<milestone number> B="${TMPDIR:-/tmp}/design-lld-before.txt"`.
Each command must print nothing.

- [ ] Files exist: `for f in "$L" "$O"; do test -s "$f" || echo "missing $f"; done`
- [ ] Headings present:
      `for h in "Inputs read" "Requirement trace" "1. Data model" "2. Backend components" "3. Frontend components" "4. API design" "5. Core journeys" "6. State machines" "7. Invariants" "8. Error handling" "9. Test seams" "10. Diagram requests" "Decisions" "Open questions" "Change log"; do grep -q "^## $h" "$L" || echo "missing $h"; done`
- [ ] Templates fully filled: `grep -nE '\{\{|<!-- guide:|# guide:' "$L" "$O"`
- [ ] Ids defined once:
      `grep -oE '(^### |\*\*)(BE|FE|ST|EP|SEQ|SM|LINV|FM|SEAM|Q)-[0-9]+' "$L" | sed -E 's/^(### |\*\*)//' | sort | uniq -d`
- [ ] Every referenced id is defined:
      `comm -23 <(grep -oE '(^|[^A-Za-z])(BE|FE|ST|EP|SEQ|SM|LINV|FM|SEAM|Q)-[0-9]+' "$L" | grep -oE '[A-Z]+-[0-9]+' | sort -u) <(grep -oE '(^### |\*\*|~~)(BE|FE|ST|EP|SEQ|SM|LINV|FM|SEAM|Q)-[0-9]+' "$L" | grep -oE '[A-Z]+-[0-9]+' | sort -u)`
- [ ] Every in-scope FR is traced (an empty PRD row fails):
      `F=$(sed -n '/^## Milestone cut/,/^## /p' "$P" | grep -E "^\| M$N " | grep -oE 'FR-[0-9]{3}' | sort -u); [ -n "$F" ] || echo "no FR ids in the M$N Milestone cut row"; [ -z "$F" ] || comm -23 <(printf '%s\n' "$F") <(sed -n '/^## Requirement trace/,/^## 1\./p' "$L" | grep -oE 'FR-[0-9]{3}' | sort -u)`
- [ ] No trace row is all "—":
      `sed -n '/^## Requirement trace/,/^## 1\./p' "$L" | grep -E '^\| [A-Z]+-[0-9]+' | awk -F'|' '{for(i=3;i<NF;i++){c=$i; gsub(/[ \t]/,"",c); if(c!="—"&&c!="")next} print}'`
- [ ] Every live HLD invariant is mapped (`LINV-n` does not count; an HLD §7 with no INV rows fails unless it says n/a):
      `I=$(sed -n '/^## 7\./,/^## 8\./p' "$H" | grep -oE '^\| INV-[0-9]+' | grep -oE 'INV-[0-9]+' | sort -u); [ -n "$I" ] || sed -n '/^## 7\./,/^## 8\./p' "$H" | grep -q 'n/a' || echo "HLD §7 has no INV rows"; [ -z "$I" ] || comm -23 <(printf '%s\n' "$I") <(sed -n '/^## 7\./,/^## 8\./p' "$L" | grep -oE '(^|[^A-Z])INV-[0-9]+' | grep -oE 'INV-[0-9]+' | sort -u)`
- [ ] Every endpoint is in the contract and nothing else is:
      `diff <(grep -oE '^\| \*\*EP-[0-9]+' "$L" | grep -oE 'EP-[0-9]+' | sort) <(grep -oE 'x-lld-id: *"?EP-[0-9]+' "$O" | grep -oE 'EP-[0-9]+' | sort)`
- [ ] Contract is 3.1 with problem details:
      `grep -q '^openapi: 3\.1\.' "$O" || echo "not 3.1"; grep -q 'application/problem+json' "$O" || echo "no problem+json"`
- [ ] Every problem type used is in the registry:
      `comm -23 <(grep -oE '/problems/[a-z0-9-]+' "$L" | sort -u) <(sed -n '/^### Problem types/,/^### Idempotency/p' "$L" | grep -oE '^\| `/problems/[a-z0-9-]+' | grep -oE '/problems/[a-z0-9-]+' | sort -u)`
- [ ] Every diagram job has exactly one placeholder:
      ``diff <(grep -oE '<!-- diagram: [a-z0-9-]+ -->' "$L" | awk '{print $3}' | sort) <(sed -n '/^## 10\./,/^## Decisions/p' "$L" | grep -oE '`draw-diagrams [a-z0-9-]+`' | tr -d '`' | awk '{print $2}' | sort)``
- [ ] §10 is complete:
      `for j in erd be-class; do grep -q "draw-diagrams $j" "$L" || echo "no $j job"; done; [ "$(grep -c '^### SEQ-' "$L")" = "$(grep -c 'draw-diagrams sequence-' "$L")" ] || echo "SEQ count != sequence jobs"; [ "$(grep -c '^### SM-' "$L")" = "$(grep -c 'draw-diagrams state-' "$L")" ] || echo "SM count != state jobs"`
- [ ] Component tree and Components rows match (§3 n/a: both empty):
      `comm -3 <(sed -n '/^### Component tree/,/^### Components/p' "$L" | grep -oE 'FE-[0-9]+' | sort -u) <(grep -oE '^\| \*\*FE-[0-9]+' "$L" | grep -oE 'FE-[0-9]+' | sort -u)`
- [ ] Every journey has an error branch:
      `awk '/^##+ /{if(s!=""&&!a)print s; s=""} /^### SEQ-/{s=$0;a=0} /^\*\*alt /{a=1} END{if(s!=""&&!a)print s}' "$L"`
- [ ] No code outside embedded diagram blocks (signatures in table cells are allowed):
      ``awk '/^[ \t]*<!--[ \t]*diagram:/{p=1;next} s{if(/^[ \t]*```[ \t]*$/)s=0;next} p&&/^[ \t]*```mermaid/{s=1;p=0;next} {p=0;print NR": "$0}' "$L" | grep -E '^[0-9]+: [[:space:]]*```|CREATE (TABLE|INDEX)|ALTER TABLE|INSERT INTO|DROP TABLE'``
- [ ] Only owned paths changed during this run (paths already dirty in `$B` are reported at STOP, never reverted):
      `comm -13 "$B" <(git status --porcelain --untracked-files=all | sort) | grep -vE ' (docs/architecture/(lld\.md|contracts/openapi\.yaml)|specs/M[0-9]+-[a-z0-9-]+/change-plan\.md)$'`
- [ ] Eyeball: each table with a status column has an SM; every `⚠` line names a Q-n; every Components row states
      owned state; every SEQ participant exists in HLD §2/§3 or §2/§3 here; no secrets or PHI in examples.
- [ ] Brownfield: `for h in "Implementation approach" "Files likely to change" "Dependencies" "API changes" "Data model impact and migration" "Testing strategy" "Backward compatibility" "Security implications" "Rollout, migration risks and rollback" "Must not change" "Deployed / in-flight / designed"; do grep -q "^## $h" specs/M$N-*/change-plan.md || echo "missing $h"; done`

## STOP

**Input stop.** When any input check fails, send exactly this (one Missing line per failed input, all of them;
no gate question, no counts) and stop:

```
design-lld stopped (<date>) at input check. Nothing written.
Missing: <path> — <remedy from Inputs>
Next: <the first remedy's skill or script>
```

**Draft stop.** Get every count from a command (`grep -c '^#### ' "$L"` tables, `grep -c '^### BE-'` backend,
`grep -cE '^\| \*\*FE-'` frontend, `grep -cE '^\| \*\*ST-'` state rows, `grep -cE '^\| \*\*EP-'` endpoints,
`grep -c '^### SEQ-'` journeys, `grep -c '^### SM-'` state machines, `grep -c '^### D[0-9]'` decisions,
`grep -E '^\| \*\*Q-' "$L" | grep -c '⚠'` open questions), then send exactly this and stop:

```
design-lld stopped (<date>). Mode: <greenfield | brownfield>, pass: <first | delta | revise>, milestone M<N>-<slug>.
Wrote: docs/architecture/lld.md · docs/architecture/contracts/openapi.yaml<· specs/M<N>-<slug>/change-plan.md>
Counts: <t> tables · <b> backend components · <f> frontend components · <s> state rows · <e> endpoints ·
<j> journeys · <m> state machines · <d> proposed decisions (D<a>–D<z>) · <q> open ⚠
Contract: <lint command → result | not machine-validated (AGENTS.md lists no OpenAPI lint command)>
Product answers for clarify-spec on prd.md: <Q ids | none>
Other paths changed in the tree: <paths in the before-snapshot or not written by me | none>

Next skill: draw-diagrams — supervisor: commit lld.md, write one job file per lld.md §10 row
(.handoff/runs/M<N>-D##/task.md, WORKFLOW §7 "Job file"; Draw from goes in its Context manifest give:), commit
them, and dispatch them in parallel with scripts/delegate.sh. Jobs:
  draw-diagrams <type> "<Draw from>"      (one line per §10 row)
Then the supervisor runs scripts/embed-diagrams.sh docs/architecture/lld.md.

Gate G3 opens once the diagrams are embedded (embedding edits lld.md, so an approval given now would be stale);
the supervisor will ask then. Read now and prepare:
G3 — "Could I defend every table, state owner, endpoint and sequence in an interview?"
- Hardest decision: D<n> <title> — <why it was hard, in plain words>
- Rejected alternatives: <option> — <why it lost>; <option> — <why it lost>
- Least confident about: <section or id> — <why>; it would firm up with <evidence or test>
- Drill: <the three questions an interviewer is most likely to ask about this design>

<Decision 1 of d, in the D<n> shape from the template, with "In plain words" and its Default line>

When G3 opens, reply Approve / Revise (name the id and what to change: cheapest now, before any migration exists) /
Stop (park; nothing downstream starts). One decision per reply.
Default if you don't answer: stays proposed; nothing downstream may build on it.
Do not answer yet unless you want to Revise or Stop before the diagrams are drawn. I will not start the next phase.
```

Exactly one next skill: `draw-diagrams`. If an "HLD conflict" Q-n is open, name `design-hld` instead and leave the
gate closed. Never start either yourself.

## Red flags

| Thought you might have | What to do instead |
|---|---|
| "I'll sketch the method body so the intent is clear." | Write the signature, its types and the problem types it raises; behaviour lives in the §5 sequence. Bodies are implement-task's job. |
| "This state goes in a global store so every screen can reach it." | Classify it (server, URL, local, shared) and give it to the lowest common owner of its consumers; server data is never copied into a store; a store needs a `D<n>`. |
| "The app validates that, so no constraint is needed." | Push the invariant to the strongest enforcer the engine supports; code alone is the last rung and needs a seam and a test. |
| "Nobody double-clicks; POST /orders is fine without a key." | Every mutation a client can repeat gets a key — `Idempotency-Key` header, a form-field key for HTML form posts, or a natural unique key — with replay, mismatch and in-flight behaviour written down. |
| "The HLD has no box for this, so I'll add a queue here." | Write a Q-n "HLD conflict", name `design-hld` as the next skill, and stop. The LLD never adds containers, connections or trust boundaries. |
| "This milestone adds one column, so let me redo the LLD and tidy those mermaid blocks." | Delta: edit only the touched rows and mark them (new)/(changed). A mermaid block under a placeholder is embedded draw-diagrams output: leave it byte-identical. |
