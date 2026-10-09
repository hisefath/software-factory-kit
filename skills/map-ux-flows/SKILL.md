---
name: map-ux-flows
description: Use when a G1-approved PRD has UI-critical stories and the screens, user flows, states and copy must be designed before architecture. Produces docs/design/flows.md and docs/design/screens.md. Do NOT use for component trees, state ownership or endpoints (use design-lld), for system boxes and trust boundaries (use design-hld), or for the demo script itself (use write-demo-script).
disable-model-invocation: true
metadata:
  software-factory-kit: "0.1"
  phase: "4"
  gate: "G-ux"
---

# map-ux-flows

**Outcome:** `docs/design/flows.md` and `docs/design/screens.md` at `status: complete` — every screen traced to an
in-scope PRD story, every flow numbered, the human's recorded variant choice quoted, and every screen's six states,
microcopy, accessibility, responsive and demo notes filled — ready for G-ux.

## You own / You never touch

- You own `docs/design/flows.md` and `docs/design/screens.md` fully; you never edit `docs/product/prd.md` or any
  other file — an ambiguity inside an existing story becomes a `⚠` line for `clarify-spec`; a missing story or
  access rule becomes a `⚠` line for a `write-prd` revision.
- You own what the user sees, reads and does on every screen; you never name how it is built — no component names,
  props, state libraries, endpoints or database fields (that is `design-lld`'s job). Plain layout words (list,
  panel, dialog, tab, banner) are fine; code names (`ProductCard`, `<CartDrawer>`, `cart_items`, `/api/cart`) are not.
- You own the list of screens the in-scope stories need; you never add a screen no story needs — write
  `⚠ scope request: <screen> because <reason> — needs a new PRD story (revise with write-prd, re-approve at G1)`.
- You own the variant drawings and a recommendation; you never mark a variant chosen — only the human's words,
  recorded in `.handoff/TRACKER.md ## Approvals`, do.
- You own reading the PRD, brief, research and audit; you never read `docs/architecture/**` or source code for
  design cues (designing from the build leaks HOW into WHAT).
- You own your run's `result.md` when dispatched; you never edit `.handoff/TRACKER.md` or the decision journal,
  and you never commit, push or merge (the supervisor commits both files before it records a gate answer).

## Inputs

Read these first, in order:

1. `AGENTS.md` — who uses the product, where it runs (a browser tab, or inside another product's frame), the docs
   map, and any commands. Missing → stop: "No AGENTS.md. Run scripts/init-repo.sh first."
2. `docs/product/prd.md` — `### US-<n>` stories with priorities, FRs, `## Milestone cut`, edge cases, constraints.
   Missing → stop: "No PRD. Run write-prd first." No `### US-<n>` headings → stop: "PRD stories have no ids.
   Revise with write-prd and re-approve at G1." Never invent an id.
3. `.handoff/TRACKER.md` `## Approvals` — a G1 row for `docs/product/prd.md@<sha>`. Missing → stop: "The PRD is not
   approved at G1." If `git diff --quiet <sha> -- docs/product/prd.md` exits non-zero → stop: "The G1 approval is
   stale: the PRD changed after <sha>. Re-approve it at G1 first."
4. **Milestone and in-scope stories.** `M<N>` comes from the run brief or the human's request. If neither names
   it, ask, recommending the lowest milestone in `## Milestone cut` that lists FR ids (dispatched: assume it and
   write a `⚠`). In-scope stories = the unique `(US-n)` tags on that row's FRs:
   ```
   P=docs/product/prd.md; N=<milestone number>
   awk '/^## /{m=($0 ~ /^## Milestone cut/)} m' "$P" | grep -E "^\| M$N " | grep -oE 'FR-[0-9]{3}' | sort -u |
     while read -r fr; do grep -E "^- \*\*$fr\*\* " "$P" | grep -oE '\(US-[0-9]+\)'; done | tr -d '()' | sort -u
   ```
   Prints nothing → stop: "M<N> has no FR ids in the PRD's Milestone cut."
5. Read if present, never block on absence (note it in Scope): `specs/M<N>-*/brief.md` (users, appetite),
   `docs/research/*.md` (evidence about users), `docs/audit/AUDIT.md` (brownfield: screens users already know),
   and existing `docs/design/flows.md` / `docs/design/screens.md` (they tell you which pass you are in).

## The one rule

Draw only what a person sees and does, only for a story that needs it: every screen traces to a story id, every
screen has every state, and nothing names how it is built.

## Steps

Run `date` first; its output is the only source for every `Updated:` line.

**Find your pass — the first rule that matches wins.** A *recorded answer* is a `G-ux` row in
`.handoff/TRACKER.md ## Approvals` for `docs/design/screens.md@<sha>` where
`git diff --quiet <sha> -- docs/design/screens.md` exits 0 (the file is unchanged since). Rows on a sha whose
screens.md says `variants-proposed` answer the variant half of G-ux; rows on a `complete` sha answer G-ux itself.
Use every recorded row, newest wins per screen. Words that are only in this conversation authorize nothing
(WORKFLOW.md §2 rule 6).

- Dispatched (a run brief `.handoff/runs/<id>/brief.md` names this job) and either output file exists → write
  nothing under `docs/design/`, write the result file (Output) with reason "docs/design already exists; the next
  pass needs the human", and stop.
- Dispatched, no output file → Pass 1, unattended: ask nothing, write each question as
  `⚠ <question> — assumed: <recommended answer>`, and use the assumption.
- No `docs/design/screens.md`, or no `status:` line in it → Pass 1.
- `status: variants-proposed`:
  - no recorded answer → print "Record the pick in .handoff/TRACKER.md ## Approvals first (WORKFLOW §2 rule 6)."
    (name the stale sha if a row exists for an older one), then STOP 1 again, and stop;
  - recorded Approve or picks for every `**Chosen:** ⚠ awaiting your pick` line → Pass 2;
  - recorded picks for only some key screens → print STOP 1 for the key screens still waiting, and stop;
  - recorded Revise naming S<n> → redraw only S<n>'s variants (still 2-3, real structural differences), keep
    every other section, re-run the Pass 1 checks, print STOP 1, and stop;
  - recorded Stop → leave both files at `variants-proposed`, print "map-ux-flows — stopped at your request (G-ux,
    variant half). Files left at variants-proposed. Cost: <STOP-COST>. To resume: record an Approve or Revise row
    for docs/design/screens.md@<sha>, then run map-ux-flows again.", and stop.
- `status: complete`:
  - recorded Revise → change only what it names, re-run Done when, print STOP 2;
  - in-scope stories (Inputs 4) missing from `## Traceability` → Pass 1 for the new screens only: next free S
    ids, existing sections untouched, both status lines back to `variants-proposed`;
  - otherwise → nothing to change: print STOP 2 again (or the recorded G-ux answer), and stop.

### Pass 1 — map and diverge

1. **Confirm the phase applies.** List every in-scope story (Inputs 4) with its id and priority. Mark the ones
   where a person sees or does something on a screen. If no P1 story is marked, stop: "Not UI-critical. Skip
   map-ux-flows; run design-hld next."
2. **Interview only the gaps.** Ask at most 5 questions, one at a time, each with a recommended answer and a
   one-line reason, and only what AGENTS.md, the PRD and the brief do not already answer. Bank, in priority order:
   - "Which width do most users see first, 375 px (phone) or 1280 px (desktop)? Recommended: <from the PRD's
     users>, because <where they work>."
   - "Does this run inside another product's frame? If so, how wide is it? Recommended: <from AGENTS.md>."
   - "Which story is the spine of the 90-second demo? Recommended: the first P1 story, because it shows the core
     value in the fewest screens."
   - Only to confirm an access rule the PRD states: "The PRD says only <role> may <action>; does any screen look
     different to signed-out users or other roles? Recommended: no." PRD silent → don't ask; write
     `⚠ access rule for <screen>: <recommended> — needs a PRD requirement (write-prd revision)` and use the safest
     assumption (only the users the story names; everyone else gets the Permission denied state).
   - "What voice should the copy use? Recommended: plain, calm, second person ('your order'), no jargon or codes."
3. **Inventory the screens.** Choose the smallest set that covers every marked story. Number them S1, S2, … in
   flow order, never zero-padded (`S01` is a `gather-evidence` source id; cite research by its `R<NN>` file, never
   as `[S<NN>]`). Each row names at least one in-scope story id copied exactly from the PRD. Merge two screens that
   serve the same moment. A screen you believe is needed but no story asks for goes to Open questions as a
   `⚠ scope request` (You own), never into the inventory. Mark **key screens**: on a P1 story's main path and
   shown in the demo — usually 1-3, never more than 3.
4. **Write the flows.** One flow F1, F2, … per marked story (stories may share one). Header: story ids, actor,
   trigger, goal. Number every step: `1. [S2] <what the user does> → <what they see>`. Letter each branch under
   the step it leaves: `2a. [S2 · Error] <condition> → <what they see> → <what they can do>`. Close with
   `Ends when:` and the outcome the user can see. Use the user's words, never system internals.
5. **Trace.** Fill the traceability rows: story → flows → screens. Every marked story has a flow, every `[S<n>]`
   in a flow exists in the inventory, and every screen serves a story.
6. **Draw the variants.** For each key screen draw 2-3 ASCII wireframes at the primary width with the legend in
   `references/wireframes.md`. Variants differ in structure — what comes first, how many steps, how much shows at
   once — never only color, font or spacing, and every variant covers the same stories. Under each write Idea ·
   Best when · Costs · Fails for, in plain words a beginner could repeat in an interview. Then one recommendation
   with its reason. Sample data is obviously fake ("Pat Example", "Vitamin D3 2000 IU"), never a real person or
   record.
7. **Write, check, stop.** Fill both files from `assets/template.md`: flows.md complete; screens.md with only the
   header, Global conventions, each screen's header line and `### Variants` (key screens: the drawings plus
   `**Chosen:** ⚠ awaiting your pick`; others: `n/a — not a key screen`), and Open questions. Set
   `status: variants-proposed` in both files. Run the Pass 1 checks in Done when, then print STOP 1 and stop.

### Pass 2 — converge and complete

8. **Record the pick.** Under each key screen write `**Chosen:** S<n>-V<k> — "<exact words from the Approvals
   row>" (<that row's time>)`, `**Rejected:** <id> — <one-line why not>` for each loser, and a one-sentence "Why
   this layout" the human could say out loud. Keep the rejected drawings: `log-decision` records the options that
   lost. A blend → draw the blend as the Layout and say which part came from which variant. If the pick changes
   the steps (one page instead of three), update flows.md to match.
9. **Lay out every screen.** Draw the final Layout: key screens get the chosen variant refined; every other screen
   gets one wireframe in the same pattern, no variants. Never rewrite a screen that is already complete.
10. **Fill all six states for every screen** — Empty, Loading, Error, Success, Permission denied, Edge data — each
    with when it happens, what the user sees, the exact microcopy, and what they can do next. Several moments in
    one state (Empty: first use, filtered, cleared; Error: their mistake, our failure, no connection) share the
    row as labelled strings: `First use: "…" / Filtered: "…" / Cleared: "…"`. A state or moment that truly cannot
    occur gets `n/a — <why>`, never a blank. Use the prompts in `references/wireframes.md`.
11. **Write the microcopy.** Exact strings for the title, actions, field labels, helper text, and the empty,
    error, success and confirmation messages. Errors say what happened and what to do next, never blame the
    user, never show a code. Buttons name their result ("Place order", not "Submit").
12. **Write the accessibility basics (WCAG 2.2 AA)** per screen from `references/wcag-basics.md`: contrast intent,
    a numbered focus order, a visible label for every input, a keyboard path for every action, target size, and
    how errors and status messages are announced. Label the section "planned, not verified" — later phases turn
    it into checks.
13. **Write the responsive notes** at 375 px and 1280 px: what stacks, what moves behind a disclosure, what stays
    visible (the primary action always stays reachable), and confirm nothing scrolls sideways.
14. **Lay out the demo.** Beats that fit 90 seconds along the spine story: time range, screen and state, what the
    viewer sees, the one action. Every key screen appears in a beat. Show at least one non-happy state recovering
    (an error fixed, an empty list filled) — it proves the states are real. This feeds `write-demo-script`; do not
    write the script.
15. **Close.** Collect every `⚠` into Open questions, set `status: complete` in both files, run every check in
    Done when, fix what fails, then print STOP 2 and stop.

## Output

- `docs/design/flows.md` and `docs/design/screens.md` — fill `assets/template.md`, which holds both skeletons.
  Every section is required; write `n/a — <why>` instead of deleting one. Mark every unknown `⚠ <question>`
  instead of inventing an answer.
- Dispatched only: the result file your brief names (`.handoff/runs/<id>/result.md`) with the full result contract
  of WORKFLOW.md §7 (`specs/_templates/result.md` when present): `task`, `harness`, `model`, `status: human_review`,
  `reason: variant choice needed`, `base_sha` = `head_sha` (`git rev-parse --short HEAD`; you don't commit),
  `changes: [docs/design/flows.md, docs/design/screens.md]`, `tests:` the Pass 1 Done-when commands and results,
  `not_verified: [pass 2]`; then `## Changes`, `## Tests run` (each command with pasted output), `## Questions`
  (every `⚠ … — assumed: …`). Any stop while dispatched (an Inputs stop, not UI-critical, files exist) still
  writes it: `status: human_review`, the stop message as `reason`, `changes: []`.

## Done when

Run each check; every count comes from the command, never from memory.

Pass 1:

- [ ] `grep -cE '^## (Scope|Screen inventory|Flows|Traceability|Open questions)$' docs/design/flows.md` prints 5.
- [ ] Screen ids are unique: `grep -oE '^## S[0-9]+' docs/design/screens.md | sort | uniq -d` prints nothing.
- [ ] The inventory and the screen sections hold the same ids:
      `diff <(grep -oE '^\| S[0-9]+ ' docs/design/flows.md | tr -d '| ' | sort -u) <(grep -oE '^## S[0-9]+' docs/design/screens.md | tr -d '# ' | sort -u)`
      prints nothing.
- [ ] Every `[S<n>]` in a flow is in the inventory: the ids from `grep -oE '\[S[0-9]+' docs/design/flows.md` are
      a subset of the inventory ids; no source ids leaked in: `grep -nE '\bS0[0-9]' docs/design/*.md` prints nothing.
- [ ] Every story id in the inventory is a PRD story in scope: `grep -cE '^### <id> ' docs/product/prd.md` prints
      1 for each, and each is in the Inputs 4 list.
- [ ] Every key screen has 2-3 `#### S<n>-V<k>` drawings and one `**Recommendation:**` line.
- [ ] Nothing names how it is built — both commands print nothing (a real product name such as "iPhone" or
      "PayPal" may stay; list it in your STOP message):
      `grep -nEi '\b(props?|usestate|useeffect|redux|zustand|pinia|vuex|mobx|livewire|inertia|alpine|component|endpoint|api|graphql|database|schema|migration|foreign key)\b|/api/|\b(get|post|put|patch|delete) /|\b[a-z]+_[a-z0-9_]+\b' docs/design/flows.md docs/design/screens.md`
      `grep -nE '<[A-Z][A-Za-z]+|\b[a-z]+[A-Z][A-Za-z]*\b|\b[A-Z][a-z]+[A-Z][A-Za-z]*\b' docs/design/flows.md docs/design/screens.md`
- [ ] No placeholder is left in what Pass 1 writes — both print nothing:
      `grep -nE '<[^>!][^>]*>' docs/design/flows.md`
      `awk '/^## /{s=($0 ~ /^## Demo layout/)} /^### /{s=($0 ~ /^### (Layout|States|Microcopy|Accessibility|Responsive)/)} !s {print FNR": "$0}' docs/design/screens.md | grep -E '<[^>!][^>]*>'`
- [ ] `git status --porcelain` lists no path you wrote outside `docs/design/` (plus your result.md if dispatched).

Pass 2 adds:

- [ ] `grep -c 'awaiting your pick' docs/design/screens.md` prints 0, and every quote in a `**Chosen:**` line is
      found by `grep -F '<quote>' .handoff/TRACKER.md` inside a G-ux Approvals row.
- [ ] `grep -cE '^### (Variants|Layout|States|Microcopy|Accessibility|Responsive)' docs/design/screens.md` = 6 ×
      the screen count.
- [ ] `grep -cE '^\| (Empty|Loading|Error|Success|Permission denied|Edge data) \|' docs/design/screens.md` = 6 ×
      the screen count, and no state row has an empty cell.
- [ ] `grep -cE '^\| (375|1280) px \|' docs/design/screens.md` = 2 × the screen count, and
      `grep -c '^- Focus order: 1\. ' docs/design/screens.md` = the screen count.
- [ ] The last demo beat ends at or before 1:30 and at least one beat shows a non-happy state.
- [ ] Every key screen is in a demo beat and every beat's screen is in the inventory — both `comm` lines print nothing:
      ```
      K=$(grep -E '^\| S[0-9]+ ' docs/design/flows.md | awk -F'|' '$6 ~ /yes/ {gsub(/ /,"",$2); print $2}' | sort -u)
      D=$(awk '/^## /{d=($0 ~ /^## Demo layout/)} d' docs/design/screens.md | grep -E '^\| B[0-9]+ ' | cut -d'|' -f4 | grep -oE 'S[0-9]+' | sort -u)
      I=$(grep -oE '^\| S[0-9]+ ' docs/design/flows.md | tr -d '| ' | sort -u)
      comm -23 <(echo "$K") <(echo "$D"); comm -23 <(echo "$D") <(echo "$I")
      ```
- [ ] No placeholder is left anywhere: `grep -nE '<[^>!][^>]*>' docs/design/*.md` prints nothing.
- [ ] Both files say `status: complete`; every `⚠` is listed under Open questions.

## STOP

The Stop option's real cost, used in both messages below and the Stop note in Steps (call it STOP-COST): "design-hld can still run, but
design-lld would design against screens with no states, and define-acceptance refuses to run without a G-ux
approval of screens.md — so the milestone stalls until G-ux is approved or the PRD drops the stories that need
screens."

After Pass 1, print exactly this (filled) and stop:

```
map-ux-flows — pass 1 done (variants proposed)
Wrote: docs/design/flows.md, docs/design/screens.md (status: variants-proposed)
Screens: <n> (key: <ids>) · Flows: <n> · Open ⚠: <n> · Real product names kept: <names | none>
  key screen = one of the 1-3 screens the demo depends on, so its layout is worth choosing on purpose.
  Open ⚠ = a question I could not answer from the docs; all are listed at the end of flows.md.

G-ux, variant half — "Which variant?"
Background: a variant is a different structure for the same screen (what comes first, how many steps, how much
shows at once), not a different color. Choosing now costs a reply; changing a layout after the build costs a rework.
<for each key screen still awaiting a pick:>
S<n> <name>
  V1 <name>: <best when> / <costs>
  V2 <name>: <best when> / <costs>
  V3 <name>: <best when> / <costs>
  I recommend V<k> because <plain-words reason>.

This is one bundled decision because the key screens sit in one flow and should share one pattern. To decide one
screen per reply instead, answer for one screen; I'll ask about the rest on the next run.
Options:
- Approve: "go" takes every recommendation; or name your picks ("S2-V1, S4-V3"); a blend is fine — say which part from which.
- Revise: name the screen and what none of its variants get right; I redraw that screen's variants only.
- Stop: skip UX design for now. Cost: <STOP-COST>
I recommend Approve with the picks above. Default: my recommendations.
Next: the supervisor commits both files, records your exact words as a row in .handoff/TRACKER.md ## Approvals
(gate G-ux, artifact docs/design/screens.md@<sha>), runs log-decision, then runs map-ux-flows again for pass 2
(pass 2 = every screen's states, copy, accessibility, phone and desktop layouts, and the demo beats).
```

After Pass 2, print exactly this (filled) and stop — never start the next phase:

```
map-ux-flows — done (ready for G-ux)
Wrote: docs/design/flows.md, docs/design/screens.md (status: complete)
Screens: <n> · Flows: <n> · State rows: <n> of <6 × screens> · Demo: <m:ss> · Open ⚠: <n>
  state row = one of the six situations every screen must handle (empty, loading, error, success, permission
  denied, edge data); edge data = unusual but real inputs: a very long name, zero or 200 items, a price that
  changed while the page was open.

G-ux — "Which variant? Every state covered?"
- Variants: S<n>-V<k> ("<your words>"), …
- States: every screen has all six. They matter because most real UI bugs live outside the happy path, and
  define-acceptance turns each row into a check.
- Least sure about: <one screen or state, and why>

Options:
- Approve: these screens and states become the contract the architecture and tasks must trace to.
- Revise: name the screen and the state or copy to change; I change only that.
- Stop: park the UI design. Cost: <STOP-COST>
I recommend <Approve because every in-scope story has a screen and every screen has its six states | Revise on
<the gap>, because <why>>. Default: Approve as written.
Next skill: design-hld — run it after your words are recorded (gate G-ux, docs/design/screens.md@<sha>) and
log-decision has run.
```

## Red flags

| Thought you might have | What to do instead |
|---|---|
| "I'll name the component or field so the implementer knows what to build." | Describe what the user sees and does; `design-lld` names the parts. Run the leak greps. |
| "This flow obviously needs a settings / admin / onboarding screen." | No story, no screen. Write a `⚠ scope request` for a `write-prd` revision and a new G1, and move on. |
| "My three variants are the same page in different colors." | Change the structure — what comes first, how many steps, how much shows at once (`references/wireframes.md`). |
| "The happy path is enough; the states can wait for the build." | Fill all six states for every screen now; the build has no designer to ask. |
| "They said V2 in chat — I'll mark it chosen and finish pass 2." | Only a G-ux Approvals row on the current screens.md sha chooses. Print the "Record the pick" line and STOP 1, then stop. |
| "I'll peek at the HLD or the code to see how the data loads." | Don't. Describe the wait the user sees (the Loading state); how it loads is `design-hld`'s call. |
