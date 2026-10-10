---
name: log-decision
description: "Use only after the human has answered a gate, a per-finding gate card (G-audit A<n>, G5 SEC-<n> or DV-<n>, G-L5 H<n>) or a clarify-spec decision candidate, and the supervisor has written that answer verbatim to .handoff/TRACKER.md ## Approvals; never before the answer exists. Produces appended D<n> entries in docs/decisions/DECISION_JOURNAL.md, plus docs/decisions/NNNN-<slug>.md for an accepted one-way (Type 1) decision. Do NOT use to propose or choose an option (the artifact's owner skill proposes, e.g. design-hld), to settle ⚠ markers (use clarify-spec), or for verifier row dispositions (they stay in the review file)."
metadata:
  software-factory-kit: "0.1"
  phase: "X"
  gate: "none"
---

# log-decision

**Outcome:** `docs/decisions/DECISION_JOURNAL.md` ends with one schema-complete `D<n>` entry per decision the
human's latest answer settled: `accepted` or `rejected` only beside the human's quoted words, otherwise `proposed`,
with every option that lost still visible. Each accepted Type 1 decision also has its MADR record
`docs/decisions/NNNN-<slug>.md`. Nothing already committed in the journal is renumbered, reworded or removed.

## You own / You never touch

- You own **appending** entries at the end of `docs/decisions/DECISION_JOURNAL.md`. In an entry already committed
  (present in `git show HEAD:docs/decisions/DECISION_JOURNAL.md`) you change only its heading status token
  (`proposed` → `accepted`/`rejected`, or any → `superseded-by D<m>`) and its `pending — no quoted words yet` text,
  replaced by the quote (plus `; ADR: <path>` when it becomes an accepted Type 1). You never reword, renumber,
  reorder or delete any other committed line.
- You own **correcting an uncommitted entry** (above the last committed id) in exactly the field the human's
  `Revise D<n> <field>` names; you never touch an uncommitted entry nobody named. Once committed, a correction is a
  new entry that supersedes it.
- You own **creating** `docs/decisions/NNNN-<slug>.md` for accepted Type 1 decisions and changing an older record's
  `status:` line when it is superseded; you never edit any other line of an existing record.
- You own **quoting** the human's words exactly; you never choose, re-recommend, paraphrase the answer, or set a
  status the words do not support.
- You own **copying** options, costs and reasons from the artifact at the approved version; you never invent a pro,
  a cost, a reason or a first proposal, and you never drop a rejected option, "do nothing", or the agent's first
  proposal.
- You own appending a reflection the human offered to `~/software-factory-kit-private/<repo>/REFLECTIONS.md`; you never
  write a reflection inside the repo, ask for one, or write one yourself.
- You own reading anything; you never edit the source artifact (its owner skill does), `.handoff/**` (the
  supervisor does), `AGENTS.md`, `CLAUDE.md`, skills, code or tests. You never commit, push, install anything or
  start the next phase.

## Inputs

Work from the repo root. The supervisor's call names these. Read each before writing. A required input missing or
unreadable: stop, name it, never guess.

| Input | Where | If missing |
|---|---|---|
| Gate answer, verbatim (required) | the `.handoff/TRACKER.md ## Approvals` row the call names (gate cell + `artifact@sha`), else the newest row | Stop: "No Approvals row for <gate> <artifact>. The supervisor writes it before anything else (WORKFLOW.md §2 rule 6)." G-demo: see Gate sources, never stop. |
| Artifact at the approved version (required) | the row's `artifact@sha`, read with `git show <sha>:<path>`, never from the working tree; G-L5 is checked by hash (Gate sources) | `git cat-file -e <sha>:<path>` fails: stop: "<path> is not committed at <sha>. Commit it and re-record the approval." |
| Options shown (required) | per Gate sources: the decision's section at that sha, else the owner skill's STOP message or card exactly as the human saw it (the supervisor pastes it verbatim) | Stop: "Which options were shown? Pass the path#section or the exact STOP/card text." |
| Phase, milestone, gate id (required) | the call; else the artifact's header and the Approvals row. Gate id = the row's gate cell, verbatim | Ask (step 4). |
| Journal (required) | `docs/decisions/DECISION_JOURNAL.md`, committed: `git cat-file -e HEAD:docs/decisions/DECISION_JOURNAL.md` | Stop: "No committed decision journal. Run scripts/init-repo.sh and commit it; log-decision never creates it." |
| Superseded decision | the call, the human's words, or the option text ("replaces D<k>") | Ask (step 4) when the words hint at one. |
| Reflection | private words the human offered with the answer | Write none. Never ask. |
| Proposer harness and model | the artifact's `Written by` row, else the `DISPATCH` line in `.handoff/TRACKER.md ## Log` | `⚠ not recorded` |
| `docs/product/prd.md` | for checking cited FR/NFR ids | Skip that check; say so in STOP's "Checks skipped" line. |

**Gate sources.** Find the row for the answer you are recording; it says where the options are and what one entry
covers.

| Answer to | Approvals gate cell · artifact | Options as shown | Do-nothing row | One entry per |
|---|---|---|---|---|
| G2, G3, or any artifact with `### D<k>` sections | gate id · `<path>@<sha>` | each `D<k>` section at the sha | its do-nothing option | `D<k>` the words cover |
| G-init, G0, G1, G-ux, G4, G5, G-live, G-demo (whole gate) | gate id · `<path>@<sha>` | the owner skill's STOP message: its listed options (G0: the tracks), else Approve / Revise / Stop | a shown "Do nothing", else Stop | gate |
| G-audit card | the card title verbatim: `G-audit A<n>`, `G-audit block A<x>,A<y>`, `G-audit as-is` (audit-codebase record mode joins on it) · `docs/audit/AUDIT.md@<sha>` | the card's options; cons from the finding's AUDIT.md row | `accept (do nothing, recorded)` | card; a block's Choice lists `A<n> → <disposition>` for each |
| check-security card inside G5 | the cell naming `SEC-<n>` · `docs/security/CHECKLIST.md@<sha>` | fix / accept / investigate as carded | `accept (do nothing now)` | card |
| report-milestone deviation | the cell naming `DV-<n>` · `docs/milestones/M<N>.md@<sha>` | the plan as approved (task file@sha; it is the agent's first proposal), what landed (the DV row), the card's c) | c) "don't know" | `DV-<n>` |
| G-L5 | `G-L5` · `H<n>@<hash>` (not git; check below) | the G-L5 card: A adopt H<n>, B the other layer, C do nothing | C (the card maps Stop to C) | `H<n>` |
| clarify-spec decision candidate | the row approving that clarify-spec pass · `<target>@<sha>` | the `#### CQ-<n>` entry's Options at that sha | the card's skip default: the ⚠ stays and the gate cannot pass until it is resolved or waived | `CQ-<n>` the call names |
| verifier row dispositions | — | — | — | none: out of scope, say so in STOP |

- **G-L5 check:** `KIT="${FACTORY_KIT_DIR:-$HOME/Desktop/gauntlet_workbench/software-factory-kit}"`, then
  ``awk -v h='### H<n> ' 'index($0,h)==1{f=1;next} f&&/^### /{exit} f&&/^```diff$/{d=1;next} d&&/^```$/{exit} d' "$KIT/HARNESS_CHANGELOG.md" | shasum -a 256 | cut -c1-12``
  must print `<hash>`. Anything else means the approved bytes are gone: write `proposed`, flag "stale G-L5 hash".
  The entry's artifact is `HARNESS_CHANGELOG.md H<n>@<hash>`.
- **G-demo:** `git show <sha>:docs/demo/SCRIPT.md` must say `status: approved` in its frontmatter. No G-demo row:
  write the entry `proposed` (the status flip alone is not quoted words) and flag "no G-demo Approvals row".
- **CQ:** the human's pick is the CQ entry's `Answer (verbatim)` at the sha, never the Approvals words ("Approve"
  there means "keep these edits", not "take the recommendation").

## The one rule

**Record, never decide:** a status other than `proposed` exists only beside the human's own words, quoted from their
`## Approvals` row (and, for a CQ, from the CQ entry at the approved sha), and every option the human saw, including
"do nothing" and the agent's first proposal, stays in the record.

## Steps

1. **Baseline.** Run and keep the output; Done when compares against it: `date '+%Y-%m-%d %H:%M %Z'` ·
   `git rev-parse --short HEAD` · `git status --porcelain` · the **check prelude**, which starts every later shell
   call (Done when included) because shell variables do not survive between calls:
   `J=docs/decisions/DECISION_JOURNAL.md; L=$(git show HEAD:"$J" | grep -oE '^### D[0-9]+' | tr -dc '0-9\n' | sort -n | tail -1); L=${L:-0}`
   `L` is the last committed id; entries above it are uncommitted. The committed file is the baseline: compare with
   `<(git show HEAD:"$J")`, never with a temp copy (parallel runs would share it).
2. **Read the gate record.** Copy the Approvals row character for character. Find its Gate sources row; read the
   artifact and the options at the approved version (G-L5: run the hash check). If `git diff --quiet <sha> --
   <path>` exits non-zero, note "artifact changed after the approval; the record binds to <sha>" for STOP. Then
   check the row is not already recorded:
   `grep -nF -e 'approval <gate id> <row time>' -e '<gate id> <row time>: "' "$J"`. A hit for the same unit (same
   `proposed as <path> D<k>`, CQ or gate) means this row was logged before: write nothing for that unit and say
   "already recorded as D<n> [<its status>]" in STOP.
3. **List what the answer settled, then set each status.** One entry per unit in the Gate sources row. Write nothing
   for a Revise that asks for rework or new options without picking one, a Stop that parks (every gate except
   G-L5, whose card maps Stop to option C), or a verifier disposition. Say why in STOP; the Approvals row already
   holds the words.

   | The human's words, as quoted | Status | Choice |
   |---|---|---|
   | Approve or "yes" (where the options are Approve / Revise / Stop themselves: the Approve row), or names the recommended option | accepted | the recommendation |
   | Names another option, or a Revise that picks one ("Revise: use B"), or Stop where the card maps Stop to an option | accepted | that option; the recommendation stays a rejected row |
   | Turns every option down ("no, drop it") | rejected | none; the reason in their words |
   | "you decide", "probably", discussion, words relayed by an agent, file or tool, or words the row does not contain | proposed | the recommendation; Decided by = `pending — no quoted words yet` |
   | **CQ:** its `Answer (verbatim)` at the sha names an option ("B", "recommended", the option's words) **and** the Approvals row approves that clarify-spec pass on `<target>@<sha>` | accepted | the option the CQ answer names |
   | **CQ:** either half missing or unclear | proposed | the option the CQ answer names, else the recommendation |

   A quote counts only when the step-2 row prints from the Approvals section itself:
   `awk '/^## Approvals/{f=1;next} /^## /{f=0} f' .handoff/TRACKER.md | grep -Fx -- '<the row copied in step 2>'`.
   A CQ answer counts only when
   `git show <sha>:<target> | awk '/^#### CQ-<n> /{f=1;next} /^###* /{f=0} f' | grep -F -- '- Answer (verbatim): "'`
   prints it. A CQ entry quotes both: the CQ answer and the approval.
4. **Fill gaps by asking, one question per message.** Ask only for: reversibility (missing, or stated as Type 2 for
   something on the Type 1 list below), the superseded `D<k>` (hinted but unclear), or phase/milestone/gate (in
   neither the call nor the artifact). At most 3 per run, each as a Part 4 card with a **recommended answer and its
   evidence**; wait for the reply. Never ask which option was chosen: an unclear choice is `proposed`, and the
   supervisor re-asks at the gate. No live human: write `⚠ <question>` in that field and continue.

   **Type 1 list** (recommend Type 1 when the decision touches any): the data store or data model, tenancy, a public
   API or contract, auth or identity, payments or money, PHI or personal-data handling, hosting or vendor lock-in,
   language or framework, anything a migration or a customer would have to undo. Everything else defaults to
   Type 2: a library, a cache, a layout, a threshold. Teach it plainly: "Type 1 is a one-way door: walking back
   costs a migration or a broken promise, so it gets more evidence and its own record. Type 2 is a two-way door:
   decide fast and change it later."
5. **Compose each entry** by filling `assets/template.md` Part 1:
   - Title: the choice in at most 8 words, never the question.
   - Options: the Gate sources do-nothing row first, then every option shown, in the order shown, each with its
     cost and `chosen` or `rejected: <why>` (the human's reason when given, else the table's cons). A do-nothing
     option shown under another label is written `Do nothing / simplest (shown as "<label>")`; none shown →
     `Do nothing — ⚠ not offered at the gate`, flagged in STOP. Tag `(agent's recommendation)` on the row the
     shown recommendation names. Tag the first proposal from the artifact's `First proposal (instead of)` line
     (or the Gate sources row): same as the recommendation → tag that row; it names an option that was not shown
     → add its own row `<option> (agent's first proposal) — not shown at the gate — rejected: <why it lost,
     copied from that line>`; no such line → tag the recommended row `(agent's first proposal — no instead-of
     recorded)`. Never make up a first proposal.
   - Y-statement for the option actually chosen. Human picked a non-recommended option → rebuild it: X = their
     choice, Y = the options that lost, Z = their reason quoted, else the chosen option's pros marked "(from the
     options table)", W = its cons. Never copy a Why that argued for the loser.
   - Cost accepted = W in plain words. Confidence = the artifact's. Revisit if = the artifact's trigger, else `⚠`.
     Evidence = `file:line`, R/S ids, `proposed as <path> D<k>` (artifacts with D sections),
     `approval <gate id> <row time>`.
   - Interview line: one sentence of at most 30 words the human could say out loud: what, why, at what cost.
   - Review line, for the project review: Topic = one name from the journal's `Topics:` line (none fits: the closest,
     plus an Open ⚠ asking whether to add a topic); Weight = ●●● critical (Type 1, or touches money, personal data
     or sign-in), ●●○ important, ●○○ minor; One-liner = what was chosen, over what, at what cost, in ≤ 15 words.
   - Secrets, credentials, PHI or personal data inside a quote → `[redacted: <kind>]`, and tell the human why (the
     repo is public).
6. **Write the journal.** Right before each write, recompute the next id:
   `grep -oE '^### D[0-9]+' "$J" | tr -dc '0-9\n' | sort -n | tail -1`, plus 1 (none = D1); never take an id from
   memory, the call or the artifact. If the artifact's `D<k>` differs, keep the journal id; Evidence already says
   `proposed as <path> D<k>`. Then branch on the newest earlier entry for the same decision (same
   `proposed as <path> D<k>`; same `CQ-<n>` on the same target; else the same gate id on the same artifact path):
   - **None, or it is `rejected` / `superseded-by`:** append the entry at the end of the file (the first one goes
     below the `<!-- log-decision appends D1 below this line. -->` comment), one blank line between entries.
   - **`proposed`, now answered with the same choice:** append nothing. Change its status token to `accepted` or
     `rejected` and replace `pending — no quoted words yet` with `<gate id> <row time>: "<exact words>"`.
   - **`accepted` with the same choice:** write nothing; "already accepted as D<n>" in STOP.
   - **A different choice:** append the new entry (Context ends "Supersedes D<k>: <why, quoted>"), then change only
     D<k>'s heading token to `[status: superseded-by D<m>]`. A superseded or rejected entry never changes again.
   - **Correction run** (`Revise D<n> <field>: <fix>` after a STOP): D<n> must be above `L`, else stop ("D<n> is
     committed; a correction is a superseding entry"). Rewrite only that field, from the same sources; step 3 still
     sets the status.
7. **Promote Type 1.** For each entry now `accepted` and Type 1, create `docs/decisions/NNNN-<slug>.md` from Part 2:
   NNNN = the D number zero-padded to 4 (D7 → `0007`, one id space for both files), slug = the title in
   kebab-case. Point the entry at it: a new entry gets `; ADR: docs/decisions/NNNN-<slug>.md` in Evidence; an entry
   flipped in step 6 gets it appended to the quote that replaced `pending — no quoted words yet` (that line is the
   only one a flip may change). Superseding a decision that has a record: change only that record's `status:` line
   to `superseded by NNNN`.
8. **Private reflection, only if offered.**
   `R=~/software-factory-kit-private/$(basename "$(git rev-parse --show-toplevel)"); mkdir -p "$R"`, then append Part 3 to
   `$R/REFLECTIONS.md` with the human's words verbatim.
9. **Verify.** Regenerate the project review with `bash scripts/decision-views.sh` (when the script exists), then
   run every Done-when check; fix and re-run until all pass. Then send STOP.

## Output

- `docs/decisions/DECISION_JOURNAL.md`: new entries appended (Part 1), plus only the edits step 6-7 allow.
- `docs/decisions/NNNN-<slug>.md`: one per accepted Type 1 entry (Part 2).
- `~/software-factory-kit-private/<repo>/REFLECTIONS.md`: only when the human offered a reflection (Part 3).
- Fill `assets/template.md` exactly. Every field is required; unknown → `⚠ <question>`, never invented. Part 4 is the
  chat question card, never written to a file.

## Done when

Start each check's shell call with the step-1 check prelude (`J=…; L=…`). Each check states what it must print.

- [ ] Every uncommitted entry has a Review line, and the review view is current; prints nothing:
      `awk -v l="$L" '/^### D[0-9]+ /{if(n>l&&!r)print "D" n ": no Review line"; n=substr($2,2)+0; r=0} /^- Review: Topic /{r=1} END{if(n>l&&!r)print "D" n ": no Review line"}' "$J"; [ ! -f scripts/decision-views.sh ] || bash scripts/decision-views.sh --check >/dev/null`
- [ ] Only owned paths changed: `git status --porcelain` = the step-1 output plus `$J`, `docs/decisions/REVIEW.md`, new
      `docs/decisions/[0-9][0-9][0-9][0-9]-*.md`, and an older record only when it was superseded.
- [ ] Committed history intact: `diff <(git show HEAD:"$J") "$J" | grep '^<'` prints only `### D` heading lines and
      lines containing `pending — no quoted words yet`.
- [ ] Ids unique and gapless: `grep -oE '^### D[0-9]+' "$J" | sort | uniq -d` and
      `grep -oE '^### D[0-9]+' "$J" | tr -dc '0-9\n' | sort -n | awk -v l="$L" '$1>l && $1!=++l {print "gap at D" $1}'`
      print nothing.
- [ ] Every uncommitted entry has the six schema bullets, a do-nothing row and a first-proposal tag; prints nothing:
      `awk -v l="$L" 'function c(){if(n>l&&(b!=6||!d||!f))print "D" n ": bullets=" b " do-nothing=" d " first-proposal=" f} /^### D[0-9]+ /{c();n=substr($2,2)+0;b=d=f=0;next} /^- (Date|Context and forces|Options:|Choice|Cost accepted|Revisit if)/{b++} /^  - Do nothing/{d=1} /agent.s first proposal/{f=1} END{c()}' "$J"`
- [ ] Every entry written or flipped this run as accepted or rejected passes the step-3 quote commands: its
      Approvals row prints, and for a CQ entry its `Answer (verbatim)` line prints.
- [ ] Every accepted Type 1 entry has its record:
      `grep -cE '^## (Context and Problem Statement|Decision Drivers|Considered Options|Decision Outcome)$|^### (Consequences|Confirmation)$' <record>`
      prints 6, and `grep -c 'ADR: docs/decisions/<NNNN>-' "$J"` prints at least 1.
- [ ] Cited ids exist:
      `for id in $(diff <(git show HEAD:"$J") "$J" | grep -oE 'N?FR-[0-9]{3}' | sort -u); do grep -qw "$id" docs/product/prd.md || echo "unknown $id"; done`
      prints nothing.
- [ ] No secrets: `diff <(git show HEAD:"$J") "$J" | grep -niE '(password|secret|token|api[_-]?key)[[:space:]]*[:=]'`
      prints nothing, and no quote holds a real person's health or personal data.
- [ ] Reflection stayed private: `git status --porcelain | grep -c REFLECTIONS` prints 0.

## STOP

Pick the one next skill: answer was Revise → the artifact's owner skill; a Stop that parks → no skill (use the
"parked" last line); otherwise the row for what you recorded. Copy that row's question into the message.

| Gate recorded | Its question (WORKFLOW.md §4) | Next skill |
|---|---|---|
| G-init | "Are these the rules every agent here must obey?" | `sharpen-brief` |
| G0 | "Right problem, appetite, track?" | `gather-evidence`; no research questions: brownfield → `audit-codebase`, else `write-prd` |
| G-audit card | "Which findings constrain the build, which do I accept?" | `audit-codebase record` (next card, or writes the dispositions and names `write-prd`) |
| G1 | "Right problem, scope, non-goals, success measure; every ⚠ resolved or waived?" | Full: `map-ux-flows` (no UI: `design-hld`) · Standard: `design-lld` |
| G-ux | "Which variant? Every state covered?" | `design-hld` |
| G2 | "Do these containers, connections, trust boundaries and invariants match my intent? Approve D<n>?" | `design-lld` |
| G3 | "Could I defend every table, state owner, endpoint and sequence in an interview?" | `define-acceptance` |
| G4 | "Approve slices, order (tracer bullet first), Owns, harness per task, acceptance coverage?" | `implement-task` (you say "go M<N>") |
| G5 SEC-<n> card | "Zero unaccepted high/critical; accept listed risks?" | the next security card; none left: `report-milestone` |
| G5 DV-<n> | the deviation question as asked | `report-milestone` (it reads the new D<n> into §5) |
| G5 | "Evidence pasted, dispositions done, nothing graded its own work, one-revert rollback? Merge / Revise / Stop" | `ship-milestone` (after you merge) |
| G-live | "/version = merged SHA, smoke green with TLS verified?" | `garden-docs` (first commit of the next milestone branch; WORKFLOW §4 milestone close chain) |
| G-L5 | "Which layer owns this, adopt this fix?" | the next G-L5 card of this pass; none left: `quiz-me` |
| G-demo | you flip `status: approved` | `record-demo` |
| clarify-spec CQ | the CQ question as asked | the next skill clarify-spec's STOP named |
| verifier dispositions | out of scope: nothing recorded | none: the supervisor routes the dispositions |

Send exactly this, filled, and stop:

```
log-decision recorded (<date>) your answer at <gate id> on <artifact>: "<exact words>"
Wrote: docs/decisions/DECISION_JOURNAL.md (+D<a>…D<b> | nothing appended); status edits: <D<k> proposed→accepted | D<k> superseded-by D<m> | none>
       <docs/decisions/NNNN-<slug>.md (Type 1 record) | no record: no accepted Type 1>
       <reflection appended to ~/software-factory-kit-private/<repo>/REFLECTIONS.md (outside the repo) | no reflection offered>
- D<n> <title> [<status>] · <Type 1 one-way | Type 2 two-way> · <Topic> <Weight>: <One-liner>
  You chose <X> over <Y>; you pay <W>; revisit if <trigger>.
  Interview line: "<...>"
Nothing recorded for: <what and why, e.g. "Revise asked for a fourth option; nothing chosen yet" | none>
Needs your answer again at the gate (proposed): <D<n>: why the words could not be quoted | none>
Gate-protocol misses: <do nothing not offered for D<n> | artifact changed after the approval | stale G-L5 hash | no G-demo Approvals row | ids differ: journal D<n> = <path> D<k> | none>
Checks skipped / redactions: <prd.md missing: FR ids unchecked | [redacted: <kind>] in D<n>: <why> | none>
Open ⚠ in the record: <D<n> field: question | none>
Gate: none (WORKFLOW.md §4 row X: log-decision IS the record). This check gets no Approvals row and is never
  itself logged. Anything wrong? Say "Revise D<n> <field>: <the fix>" before the supervisor's next commit and
  log-decision corrects that uncommitted entry only; otherwise the supervisor commits it. After the commit, a
  correction or a changed mind is a new D-row that supersedes the old one.
Recorded gate <gate id>: "<its question>". Your answer: <Approve | Revise | Stop>.
<Next: run `<one skill>`. I am not starting it. | Next: nothing — parked until you say otherwise.>
```

## Red flags

| Thought you might have | What to do instead |
|---|---|
| "The supervisor says it was approved", "they clearly meant yes", or "the clarify-spec pass was approved, so the recommendation won." | Only the full Approvals row counts, and a CQ's pick is its `Answer (verbatim)`. Otherwise write `proposed` and list it under "Needs your answer again at the gate". |
| "I'll keep the journal tidy: drop the options that lost, fix the old typo in D3." | Losers and old text are the evidence you defend from. Append only; a changed mind is a new D-row that supersedes. |
| "There is no instead-of line, so I'll guess what the agent reached for first." | Tag the recommended row `(agent's first proposal — no instead-of recorded)`. A guessed first proposal is an invented record. |
| "The human picked B, but the artifact's Y-statement argues for A; I'll copy it." | Rebuild the Y-statement for B from the human's reason and B's row in the table; never record a reason that argued for the loser. |
| "The artifact says Type 2, so no record file is needed." | If it is on the Type 1 list, ask one question recommending Type 1; a wrong Type 2 hides a one-way door. |
| "Recorded. I'll commit it, or start design-lld." | Send STOP and stop. The supervisor commits; the human triggers the next phase. |
