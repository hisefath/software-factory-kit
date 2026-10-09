# sharpen-brief question bank

Load at step 5. Pick only questions the repo and the assignment do not already answer, at most 5 per pass, most
costly-to-guess first. Each entry: the question · ask only if · why it matters (say this to the human) · default
recommendation (replace with a sourced one whenever the assignment or repo gives you one).

## A. Problem and people

1. **"Who, specifically, hits this problem, and at what moment?"**
   Ask only if the assignment names a product but not a person and a moment.
   Why: job stories and the demo both hang on one real moment; "users" is not a person.
   Default: the role the assignment names first, at the moment it describes.
2. **"What do they do today instead, and what does that cost them?"**
   Ask only if no workaround appears in the sources.
   Why: the workaround is the real competitor; if it is cheap, the problem may be small.
   Default: the manual path the assignment implies, costing time or errors.
3. **"If nothing shipped, who would notice first, and what would they say?"**
   Ask only if the problem's urgency is unclear.
   Why: it separates a real pain from a nice-to-have, which sets how much appetite is sensible.
   Default: the grader or partner named in the assignment.
4. **"On demo day, what would make you say 'this worked'?"**
   Ask only if the assignment has no success criteria.
   Why: it seeds the PRD's success measures with something a viewer can watch happen.
   Default: one end-to-end moment a grader can see, taken from the assignment's demo requirement.

## B. Appetite and deadlines

5. **"How much of your time do you want to spend before you'd cut scope rather than extend?"**
   Ask always, unless the human already said.
   Why: appetite fixes the time and lets scope bend; an estimate does the opposite and usually slips.
   Default: the time until the next graded checkpoint, minus room for the user-owned steps.
6. **"Which deadline is the real one: the checkpoint, the final, or an earlier one you set?"**
   Ask only if the sources list several.
   Why: the earliest graded date decides what must exist first.
   Default: the earliest graded checkpoint.
7. **"The assignment says <time> with no timezone. Which zone?"**
   Ask only if no source gives the zone.
   Why: an hour's mistake can miss a hard gate.
   Default: the zone another official document from the same program uses; otherwise leave `⚠ (→ G0)`.

## C. Assignment ambiguity

8. **"The assignment says <X> here and <Y> there. Which wins?"**
   Ask only on a real conflict.
   Why: building to the wrong one wastes the appetite.
   Default: the later, more specific official document.
9. **"Is <deliverable> graded at the exact path it names (for example a root `ARCHITECTURE.md`)?"**
   Ask only if the factory's default path differs from the assignment's.
   Why: graders open the named file; a same-named file elsewhere, or one holding older content, scores zero.
   Default: yes, the assignment's exact path.
10. **"Is <item> required, or a suggestion?"**
    Ask only for "should / may / consider" wording.
    Why: treating suggestions as law eats appetite; ignoring law fails the gate.
    Default: must/required is law; should is law unless the human waives it at G0.

## D. User-owned steps and access

11. **"Which accounts, keys or partner access do you already have, and which must you still request?"**
    Ask only if the assignment mentions an outside system.
    Why: waiting on access is the most common silent blocker, and only you can request it.
    Default: list each as a `U-##` row with the date it first blocks work.
12. **"Who records, posts and presents, and on which platforms?"**
    Ask only if the assignment requires a video, a post or a live demo.
    Why: these are yours alone; the factory can only draft the script.
    Default: you record and post; `write-demo-script` drafts.
13. **"Must the repo be public, and from when?"**
    Ask only if visibility is required or partner material is involved.
    Why: public too early can leak partner documents; too late can fail submission.
    Default: private until the assignment requires public; the flip is a `U-##` row.

## E. Constraints and risk

14. **"Does this touch real people's health, money or personal data?"**
    Ask only if the domain does not make it obvious.
    Why: those rules constrain every later phase and must be researched, not assumed.
    Default: yes for healthcare or payments; add an `R<NN>` for the rules that apply.
15. **"Has the partner or teacher already fixed anything (stack, hosting, vendor) that isn't in AGENTS.md?"**
    Ask only if the sources hint at an external decision.
    Why: a mandate is a constraint (a REQ row with its quote); a preference is only a parked idea.
    Default: if mandated in writing, it becomes a REQ row; otherwise a `P-##` row.
16. **"Is this greenfield, or must it build on code you were given?"**
    Ask only if the tree is ambiguous.
    Why: inherited code adds `audit-codebase` before `write-prd`, and it changes the risk.
    Default: whatever the tree shows; ask only when it shows both.

## How this bank grows

`route-failure` adds a question here when a milestone built the wrong thing (WORKFLOW.md §10, "Spec" row). New
entries use the same four parts and end with `(added <date>, FINDINGS.md <row id>)`. Prune a question that has not
changed a brief in five projects.
