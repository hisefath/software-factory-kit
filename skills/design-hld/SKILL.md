---
name: design-hld
description: Use when the PRD has passed G1 and the system needs its high-level design before any low-level design starts, or when G2 asked for the HLD to be revised. Produces docs/architecture/hld.md. Do NOT use for tables, classes, endpoints, sequences or state machines (use design-lld).
disable-model-invocation: true
metadata:
  software-factory-kit: "0.1"
  phase: "5"
  gate: "G2"
---

# design-hld

**Outcome:** `docs/architecture/hld.md`, filled from `assets/template.md`. Every container, connection, invariant
and number in it traces to an FR/NFR/constraint id or to cited evidence. Every key decision is a `D<n>` with status
`proposed`. The STOP message hands G2 to the supervisor with the gate briefing and the first decision.

## You own / You never touch

- You own `docs/architecture/hld.md` fully: you create it, and you revise it in revision mode (the human re-ran
  `/design-hld` after a G2 Revise). You never edit `docs/architecture/lld.md`, `docs/architecture/contracts/**` or
  `docs/architecture/diagrams/**`.
- You own the diagram *requests* in §14 and the three diagram placeholder lines. You never write Mermaid or draw a
  diagram. draw-diagrams writes `docs/architecture/diagrams/<type>.mmd`, and the supervisor embeds each one under
  its placeholder with `scripts/embed-diagrams.sh`.
- You own *proposing* decisions as `D<n> [status: proposed]`, with options and a recommendation. You never mark
  one accepted, and you never write `docs/decisions/**`: log-decision records what the human decided.
- You own naming, in nouns, the data each container keeps. You never write tables, columns, classes, endpoints,
  request/response fields, sequences or code: design-lld and implement-task own those.
- You own reading every input and the codebase, read-only (`git log`, `git show`, `git diff`, `grep`). You never
  edit `docs/product/**`, `docs/design/**`, `docs/research/**`, `docs/audit/**` or `specs/**`. A PRD scope gap
  becomes a §13 `Q-n` row answered by `clarify-spec docs/product/prd.md` (or a write-prd Revise plus a G1
  re-approval), never a quiet change.
- You own the G2 briefing in your STOP message. You never write `.handoff/**`, commit, dispatch, push, install
  anything, record or act on a gate answer, or start the next phase. The supervisor commits hld.md before any
  dispatch and before recording any gate answer. After a Revise, the human re-runs `/design-hld`; the supervisor
  then re-commits hld.md and re-dispatches the diagram jobs your STOP names.

## Inputs

Read these in full before writing. Record each one with its version in `## Inputs read`. Anything that exists but
you did not open, or opened but may not use, goes on the **Not read** line with the reason.

| Path | Needed | If missing, stale or unusable |
|---|---|---|
| `docs/product/prd.md` | always | Missing: stop with "design-hld needs an approved PRD. Run write-prd and hold G1 first." If `grep -cE '\*\*FR-[0-9]{3}\*\*' docs/product/prd.md` prints `0`, stop with "prd.md is not a write-prd PRD (no FR-### ids); run write-prd first." |
| G1 row in `.handoff/TRACKER.md ## Approvals` | always | Missing: stop with "No G1 approval recorded for prd.md." If `git diff --quiet <approved sha> -- docs/product/prd.md` exits non-zero, stop with "PRD changed after G1 (approved <sha>); re-approve first." |
| `AGENTS.md` | always | Missing: stop and name it. A stack or host named in "Project specifics" is a §1 given; cite it as `AGENTS.md:<line>`. |
| `docs/decisions/DECISION_JOURNAL.md` | always | Missing: start at D1 and write "journal missing" on the Not read line. An accepted `D<n>` is a §1 given, like a `C-n`. Never argue it again. If a driver now contradicts it, add a `Q-n` row that names it. |
| `specs/M<N>-<slug>/brief.md` | if present | Put the appetite in §1 and in the §8 cost ceiling. Each `## Parking lot` `P-##` that is a technology or pattern idea becomes an option in its `D<n>` (often the first proposal), citing the `P-##`. |
| write-prd's "Parked for design-hld" line | if in this session | It lives in write-prd's STOP message, not in a file. Treat each item like a `P-##`, with Basis "write-prd STOP". If you cannot see it, skip it. |
| `docs/research/R*.md`, `docs/research/sources.md` | if present | Cite R/S ids as Basis. Continue without them. |
| `docs/design/flows.md`, `docs/design/screens.md` | if present | Use their journeys for load and latency only when a G-ux row exists and `git diff --quiet <its sha> -- docs/design/` exits 0. Otherwise list them on Not read as "no current G-ux approval". |
| `docs/audit/AUDIT.md` | brownfield: always | Missing: stop with "This repo has existing code. Run audit-codebase first." |
| `docs/architecture/hld.md` | if present | Revision mode: read the G2 Revise row's exact words, edit in place, keep every id, and add a Change log row. |
| Source code | brownfield | Map the running system first; cite `file:line`. |

## The one rule

Design the boxes and the lines between them, never the inside of a box: every container, connection, invariant and
number must trace to an FR/NFR/constraint id or cited evidence, or it becomes a `⚠` with a `Q-n`.

## Steps

1. **Clock, inputs, ids.** Run `date` and read every input above. The next free decision id is 1 more than the
   highest D number found in the journal and in any existing hld.md:
   `cat docs/decisions/DECISION_JOURNAL.md docs/architecture/hld.md 2>/dev/null | grep -oE '^### D[0-9]+' | tr -dc '0-9\n' | sort -n | tail -1`
   (empty output means D1). The journal's ids may still drift from yours, because log-decision assigns its own id
   when it writes. Never judge a decision by its number. hld `D<k>` is already logged if and only if
   `grep -E 'proposed as docs/architecture/hld\.md D<k>([^0-9]|$)' docs/decisions/DECISION_JOURNAL.md` matches.
2. **Drivers and givens (§1).** For each FR/NFR, ask: "if this disappeared, would a box or a line change?" If yes,
   it is a driver; list it. The givens are PRD `C-n` rows, the stack and host named in AGENTS.md "Project
   specifics", and accepted journal decisions. They go in the §1 givens table, citing `C-n`, `AGENTS.md:<line>`
   or `D<n>`, and never become a new `D<n>`. Only what the givens leave open can become one (Step 8).
3. **Brownfield only: map what runs today.** Entry points, data stores, outbound calls, background jobs, deploy —
   each with `file:line` and the AUDIT.md findings that constrain it. Tag containers `(existing)`, `(changed)` or
   `(new)`.
4. **Interview the gaps.** Load `references/question-bank.md`. Ask only what the inputs do not answer, highest
   impact first, **one question per reply, each with a recommended answer and why**, at most 5 this pass. Put each
   answer in the section it feeds, with the human's words as its source. If a question goes unanswered, use the
   recommendation and write it as `<value> (assumed, ⚠ Q-n)`, with a `Q-n` row in §13.
5. **Context, containers, connections, boundaries (§2-§5).** Load `references/section-guide.md` and follow it for
   stubs, the host platform and scheduled runs. Start from the simplest set that could meet the drivers (usually
   one app + one database). Add a container, connection or async hop only when a driver id demands it, and write
   that id in Basis. Give every connection an "On failure" answer. Give every trust boundary at least one STRIDE
   threat with a design-level mitigation.
6. **Qualities and invariants (§6-§7).** Write one quality scenario per architecture-relevant NFR. Add one
   degraded scenario per real (non-stub) external system, and one for the host. Every measure is a number with a
   unit. For each invariant, pick the strongest enforcer that can hold it (DB constraint > transaction >
   code + test > code) and describe it in words.
7. **Scale budget (§8).** First, write the usage model: one entry per role (role × count × core actions per day).
   Derive users, DAU, request rate and data growth from it. Check two things before going on. Daily records must
   be ≤ DAU × actions per user per day. DAU must be ≥ the distinct people the core actions need each day: an order
   that a patient must open needs that patient active. Follow every budget line with a `WHY:` derivation that a
   reader can redo with a calculator. Then rank what breaks first at 10×, with the number that breaks, and give
   the production signal, threshold and action that would warn you.
8. **Key decisions (§9).** A choice becomes a `D<n>` only if it changes a §3 box, a §4 line or a §7 enforcer,
   or costs ≥ 1 build-day or ≥ $5/month. Write each smaller choice as a §10/§11 row with a one-line why. Each `D<n>`
   has at least three options:
   - "Do nothing / simplest";
   - your first proposal (a parked `P-##` when there is one);
   - a real alternative.

   For each, fill pros, cons, cost (build + monthly run), Basis, recommendation, Y-statement, plain-words line,
   reversibility (Type 1/2), confidence, revisit-if and interview line. Order the decisions by how much else
   depends on each.
9. **Cross-cutting, deployment, cost (§10-§12).** Fill every §10 row; `n/a — reason` is allowed, blank is not.
   Name every environment in §11 with the *source* of its secrets. Project monthly cost at 100 / 1K / 10K / 100K
   users from unit prices, with the architecture change each tier needs. An uncited price is
   `⚠ estimate (Q-n)`.
10. **Risks and diagram requests (§13-§14).** Every inline `⚠` names its `Q-n`. Every `Q-n` row has a recommended
    answer and says what it blocks; a PRD scope gap's "Who answers" is `clarify-spec docs/product/prd.md`. Keep
    the three diagram jobs and their placeholder lines exactly as the template has them.
11. **Revision mode only (instead of Steps 2-10).** Change only what the recorded Revise names, following the
    same steps for the parts you touch. Keep every id; retire one with `~~ID~~ (removed <date>: reason)`. Add a
    Change log row naming each changed id. If §2, §3-§5 or §11 changed, name in STOP the diagram jobs that must be
    re-run.
12. **Verify and brief.** Run every check in Done when, then fix and re-run until all pass. Take every STOP count
    from the count command. Load `references/g2-presentation.md` and write the decision block in its shape: for a
    first draft, the first `D<n>`; in revision mode, the `D<n>` the Revise named (or the first unanswered one).

## Output

- Write `docs/architecture/hld.md` by filling `assets/template.md`:
  - every heading stays, in order;
  - every `{{…}}` is replaced;
  - every guide comment is deleted, from its opening line through its closing line;
  - the "How to read this HLD" paragraph stays;
  - the three diagram placeholder lines stay, exactly once each.
- An unknown is `⚠ <question> (Q-n)` with a `Q-n` row in §13, never an invented value. An assumption is
  `<value> (assumed, ⚠ Q-n)`.
- Ids: `CN-n` containers, `L-n` connections, `TB-n` boundaries, `TH-n` threats, `QA-n` scenarios, `INV-n`
  invariants, `AR-n` risks, `Q-n` open questions, `D<n>` decisions (continuing the journal). Never renumber,
  not even to match the journal.
- Nothing else is written.

## Done when

Run from the project root, with `H=docs/architecture/hld.md`, `J=docs/decisions/DECISION_JOURNAL.md` and
`S=<folder you read this SKILL.md from>`. Each command must print what is stated.

- [ ] Headings match the template, in order: `diff <(grep '^## ' "$S/assets/template.md") <(grep '^## ' $H)`
      prints nothing.
- [ ] Every decision whose recommendation names a version cites the registry check you ran this session (model
      memory lags the current major), e.g. `npm view <pkg> dist-tags` and its date, in that decision's block:
      `awk '/^### D[0-9]+ /{if(v&&!r)print d;d=$0;v=r=0;next} /^## /{if(v&&!r)print d;d="";v=r=0} d&&/^- \*\*Recommendation:\*\*.*[0-9]/{v=1} d&&/(registry|npm view|pip index|go list -m|cargo search|composer show)/{r=1} END{if(v&&!r)print d}' $H` prints nothing.
- [ ] Filled, with no guide residue: `grep -nE '\{\{|<!-- guide:' $H` prints nothing, and
      ``awk '/^```mermaid/{f=1} /^```$/{f=0;next} !f' $H | grep -E -- '-->' | grep -vxE '<!-- (diagram: [a-z-]+|/diagram) -->'``
      prints nothing.
- [ ] Each placeholder exactly once, in its section:
      `for t in hld-context hld-container deployment; do [ "$(grep -cF "<!-- diagram: $t -->" $H)" = 1 ] || echo "dup/missing $t"; done`
      prints nothing, and `awk '/^## /{s=$2} /^<!-- diagram: /{print s $3}' $H | tr '\n' ' '` prints
      `2.hld-context 3.hld-container 11.deployment `.
- [ ] No low-level design or code (embedded Mermaid is allowed):
      ``grep -nE 'CREATE TABLE|ALTER TABLE|(GET|POST|PUT|PATCH|DELETE) /|^[[:space:]]*(public |private )?(class|interface|function|def) |```[a-z]' $H | grep -v '```mermaid'``
      prints nothing. Then review each hit of
      `grep -niE '\b(columns?|primary key|foreign key|index on|varchar|bigint)\b|/api/' $H`. Each hit must be a
      use that is not design (e.g. quoting a non-goal); otherwise rewrite it in nouns.
- [ ] FR ids are traced and real: `grep -oE 'FR-[0-9]{3}' $H | sort -u | wc -l` is at least `1`, and
      `for id in $(grep -oE 'N?FR-[0-9]{3}' $H | sort -u); do grep -qw "$id" docs/product/prd.md || echo "unknown $id"; done`
      prints nothing.
- [ ] Decision ids are unique: `grep -oE '^### D[0-9]+' $H | sort | uniq -d` prints nothing.
- [ ] First draft only, every id is above the journal's (a missing journal counts as D0):
      `m=$(grep -oE '^### D[0-9]+' $J 2>/dev/null | tr -dc '0-9\n' | sort -n | tail -1); grep -oE '^### D[0-9]+' $H | tr -dc '0-9\n' | awk -v m="${m:-0}" '$1<=m {print "D"$1" <= journal D"m}'`
      prints nothing.
- [ ] Revision mode only: every `D<k>` you edited is named in a new Change log row, and an already-logged `D<k>`
      (Step 1 grep) keeps its number.
- [ ] Every decision has a do-nothing option: `grep -c '^### D[0-9]' $H` equals `grep -c '^| Do nothing' $H`.
- [ ] Every budget line has a derivation: in `awk '/^### Budget/,/^### What breaks/' $H`, the count of
      `grep -c '^- \*\*'` equals the count of `grep -c '^  WHY:'`, and both are at least `9`.
- [ ] The cost table has the four tiers: `awk '/^## 12\./,/^## 13\./' $H | grep -cE '^\| (100|1K|10K|100K) \|'`
      prints `4`.
- [ ] Every boundary has a threat:
      `comm -23 <(grep -oE '^\| TB-[0-9]+ ' $H | grep -oE 'TB-[0-9]+' | sort -u) <(grep -oE '^\| TH-[0-9]+ \| TB-[0-9]+ ' $H | grep -oE 'TB-[0-9]+' | sort -u)`
      prints nothing.
- [ ] Every connection has an "On failure" answer:
      `awk -F'|' '/^\| L-[0-9]+ /{v=tolower($8); gsub(/^ +| +$/,"",v); if (v=="" || v ~ /^(unspecified|tbd|—|-|\?)$/) print $2}' $H`
      prints nothing.
- [ ] Every `⚠` outside §13 points to a real `Q-n` row: `sed '/^## 13\./,/^## 14\./d' $H | grep '⚠' | grep -vE '\bQ-[0-9]+'`
      prints nothing, and
      `for q in $(sed '/^## 13\./,/^## 14\./d' $H | grep -oE '\bQ-[0-9]+' | sort -u); do grep -qE "^\| $q \|" $H || echo "no row $q"; done`
      prints nothing.
- [ ] No secret values: `grep -niE '(password|secret|api[_-]?key)=|sk_live_|BEGIN [A-Z ]*PRIVATE KEY|eyJ[A-Za-z0-9_-]{10,}' $H`
      prints nothing. Read §2 and §10 again to make sure they hold no real personal data or PHI; config and
      secrets appear by *name* only.
- [ ] Counts for STOP:
      `for p in CN L TB INV; do printf '%s=%s ' $p "$(grep -cE "^\| $p-[0-9]+ \|" $H)"; done; printf 'D=%s open=%s\n' "$(grep -c '^### D[0-9]' $H)" "$(grep -E '^\| Q-[0-9]+ \|' $H | grep -c '⚠')"`.

## STOP

Fill the brackets from the count command and the file, then send exactly this and stop. Leave out the bracketed
`[Revision: …]` line in a first draft.

```
design-hld wrote docs/architecture/hld.md (not committed) — <CN> containers, <L> connections, <TB> trust
boundaries, <INV> invariants, <D> decisions (D<a>–D<z>), <open> open questions.
[Revision: changed <ids>; diagram jobs to re-run: <jobs | none>.]

Words: container = something that runs or stores data on its own (app, database, queue). Connection = an arrow
between two of them and how it talks. Trust boundary = a line where data passes to a party with different
permissions. Invariant = a rule that must always hold, or data, money or trust is corrupted.

Gate G2 — "Do these containers, connections, trust boundaries and invariants match my intent? Approve D<n>?"
- Hardest decision: D<n> <title> — <why it was hard, in plain words>
- Rejected alternatives: D<n>: <option> — <why it lost>; D<n>: <option> — <why it lost>
- Least confident about: <section or id> — <why>; it would firm up with <evidence or test>
- Not read: <paths and why, or "none">

<decision block from Step 12, in the shape from references/g2-presentation.md>

Next skill: draw-diagrams. Supervisor: commit docs/architecture/hld.md first. Then write one job file per §14 row
(.handoff/runs/M<N>-D##/task.md, WORKFLOW §7 "Job file"), commit them, and dispatch them with scripts/delegate.sh in
parallel (first draft: hld-context, hld-container, deployment; revision: the jobs named above). When they are
back, run scripts/embed-diagrams.sh docs/architecture/hld.md and commit. Present the remaining D<n> one per reply
from `hld.md ### D<n>`, using design-hld's references/g2-presentation.md. Write an Approvals row against the
committed sha for each answer, then run log-decision. End with that file's closing G2 question. On Revise, the
human types /design-hld (revision mode).
Reply Approve / Revise (say what to change) / Stop for D<n>. I will not start the next phase.
```

## Red flags

| Thought you might have | What to do instead |
|---|---|
| "I'll sketch the orders table and a couple of endpoints so the boxes feel concrete." | Name the data in nouns ("CN-1 owns orders, payments") and stop; tables and endpoints are design-lld's job at G3. |
| "A queue, a cache and a few services will make this look like real architecture." | Start from one app + one database; every extra container needs a driver id in Basis, and "Do nothing / simplest" is always an option. |
| "These numbers are roughly right." | Write the usage model first and derive every number from it with a `WHY:` line; anything you can't derive is `(assumed, ⚠ Q-n)` with a recommended value. |
| "The stack is already chosen, so there's nothing to decide." | Stack and host in a PRD `C-n` or AGENTS.md are givens; cite them. Choices the givens leave open (host, sync/async, cache, tenancy, auth) are `D<n>` rows only if the PRD or AGENTS.md does not already settle them; cite where. |
| "Every library and setting deserves its own D<n>." | Only choices that change a §3 box, a §4 line or a §7 enforcer, or that cost ≥ 1 build-day or ≥ $5/month, are D<n>. Every D<n> is one more gate turn for the human. |
| "The human answered D1 — I'll show D2, apply the Revise, or start design-lld." | STOP ends this skill. The supervisor commits hld.md, presents the rest from the file and records answers. A Revise comes back as `/design-hld` in revision mode. |
