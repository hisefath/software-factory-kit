---
name: route-failure
description: "Use when an agent failed, escalated or was corrected (FAIL/ESCALATE lines in .handoff/TRACKER.md, verifier rows set to fix, a gate answered Revise, the human correcting an agent in this session), usually at milestone close, and the harness should change so it cannot happen again. Produces F<n> rows in software-factory-kit FINDINGS.md, exact proposed diffs in software-factory-kit HARNESS_CHANGELOG.md and, for durable lessons only, docs/learnings/<slug>.md. Do NOT use for fixing the product defect itself (use fix-bug) or for recording a product or architecture decision (use log-decision)."
disable-model-invocation: true
metadata:
  software-factory-kit: "0.1"
  phase: "15"
  gate: "G-L5"
---

# route-failure

**Outcome:** every failure that this project's `FINDINGS.md` rows do not yet cite has one `F<n>` row in software-factory-kit
`FINDINGS.md` naming the layer that owns it and a guard; every proposed harness change is an exact diff that applies
cleanly, filed as a `### H<n>` block with `status: proposed` in `HARNESS_CHANGELOG.md`; durable, non-obvious lessons
have a `docs/learnings/<slug>.md`; nothing else changed, nothing was committed and no diff was applied.

## You own / You never touch

- You own **new `F<n>` rows** appended to `$KIT/FINDINGS.md`, and the Status cell of rows a `route-failure` pass
  wrote, when you record a verdict. You never edit another cell of an old row, renumber or delete one; a wrong old
  row gets `superseded by F<m>` in its Status.
- You own **`### H<n>` blocks** under `## Proposals` in `$KIT/HARNESS_CHANGELOG.md` (after filing, only the
  heading status and the `Verdict:` line), and one table row per adopted proposal. You never change a filed
  block's diff (a changed diff is a new block that supersedes it), never edit existing table rows, and never write
  words the human did not say.
- You own **proposing** changes to skills, agents, templates, scripts, hooks, settings, the Makefile `check`
  target, `AGENTS.md`, `CLAUDE.md` and `WORKFLOW.md`, as diffs built from a scratch copy. You never apply a diff,
  even an approved one: editing those files is a human-only action (WORKFLOW.md §2 rule 8) that happens after the
  approval is recorded.
- You own **`docs/learnings/<slug>.md`** in the project for durable, non-obvious lessons. You never write one for a
  one-off model quirk, and you never touch product code, tests, specs, `docs/decisions/**` (`log-decision` owns
  it) or `.handoff/**` (the supervisor owns it; you only read it).
- You own **the classification and the recommendation**; the human owns the verdict at G-L5.
- You may quote evidence (a log line, an error, the human's words) up to 3 lines. You never copy secrets, tokens,
  PHI or real personal data: write `<redacted: kind>`. software-factory-kit is public.
- You own a fresh scratch directory per pass (`mktemp -d`). You never commit (the human commits software-factory-kit, the
  supervisor commits the project), push, install anything, or start the next skill.

## Inputs

Run `date '+%Y-%m-%d %H:%M %Z'` first; every time you write comes from it. Then create this pass's env file with
`assets/template.md` Part 0 and note the path it prints. Shell state does not survive between commands, so run
every later command in bash starting with `. <that path> &&`: it sets `KIT`, `ROOT`, `PROJECT`, `tmp` and `hx`,
turns on `pipefail` and `cd`s to `ROOT`.

**Mode.** *Project mode* (default) runs in a product repo. *software-factory-kit mode* runs when `PROJECT` is
`software-factory-kit`, i.e. the human corrected the factory itself: inputs 3-6 are optional, Q-b is the main source, and
there is no learning file and no `log-decision` (FINDINGS and HARNESS_CHANGELOG are the record).

Read, in this order:

1. **`$KIT/docs/WORKFLOW.md` §10, `$KIT/FINDINGS.md`, `$KIT/HARNESS_CHANGELOG.md`** (required). Missing: stop with
   "software-factory-kit not found at $KIT; set FACTORY_KIT_DIR."
2. **`AGENTS.md`** (required): the project's commands and rules. Missing: stop and name it.
3. **`.handoff/TRACKER.md`** (required in project mode, read-only): `## Log` lines with ` FAIL ` or ` ESCALATE `;
   `## Tasks` rows in `failed` or `human_review` (the table is cleared at milestone close: when it is empty, read
   the task table in `docs/milestones/M<N>.md`); `## Approvals` rows whose exact words start with Revise or Stop,
   rows whose words name a verifier `R<n>` (`grep -E 'R[0-9]+'` on that section: the human's dispositions), and
   every `G-L5` row (verdicts on earlier proposals). Missing: stop and name it.
4. **`.handoff/reviews/M<N>-pass<k>.md`**: the `R<n>` rows, i.e. what the verifier found. Take each row's
   disposition only from the input-3 Approvals rows that name it, never from the review's `suggested` column (the
   verifier's guess is not the human's word). `fix` or `file` = a defect the build let through; `discard` = a false
   alarm; no recorded disposition = `⚠ pending`, listed under Not routed.
5. **`.handoff/runs/*/result.md`** with status `human_review` or `relaunch`: the reason and Questions. A worker's
   claim is a lead, not evidence; confirm it in the log, the diff or the command output.
6. **`specs/bugs/*.md`**: a slug ending `-r2` or later is a regression.
7. **This session**: every time the human corrected an agent ("no", "that's wrong", "I said…", a revert, redone
   work). A fresh session cannot see earlier ones; Q-b asks.
8. **`docs/learnings/*.md`, `docs/decisions/DECISION_JOURNAL.md`**: lessons already written, accepted `D<n>`.
9. **The file each fix would change** (that SKILL.md, AGENTS.md, the script), in full, before you write its diff.
10. **`references/routing.md`** (this skill): load it at step 3 (§1 decides what is a failure); use §2-§4 at
    steps 5-7, §5 for the STOP metrics and §8 whenever you set a status.

The window is all evidence that this project's F rows do not yet cite, unless the human names one. Every evidence
pointer carries its source's full timestamp as written (template Part 1), so two passes on one day never collide.

## The one rule

Change the narrowest layer that would have stopped the failure without anyone having to remember (a check that
fails beats a tool that does it right, which beats a sentence asking the model to), and change nothing until the
human approves the exact diff.

## Steps

1. **Baseline.** `git -C "$KIT" status --porcelain > "$tmp/base-kit.txt"` and
   `git status --porcelain > "$tmp/base-project.txt"`; Done when compares against them. Next ids, recomputed right
   before each write: `grep -oE '^\| F[0-9]+ ' "$KIT/FINDINGS.md" | grep -oE '[0-9]+' | sort -n | tail -1` plus 1,
   and the same with `'^### H[0-9]+'` on `HARNESS_CHANGELOG.md` (none: `F1`, `H1`).
2. **Record earlier verdicts first.** Take each `### H<n>` still `proposed`, `approved` or `stale` whose
   `Project:` is `$PROJECT`; list every other one once in STOP as "waiting in <project>". Its verdict is the newest
   Approvals row whose artifact cell is `H<n>@<hash>` (software-factory-kit mode: the block's `Verdict:` line). G-L5 binds
   to the diff bytes, not to a commit, because the block lives in software-factory-kit, not in this repo (the form
   `log-decision` checks). The approval is **bound** when `hx <n> | shasum -a 256 | cut -c1-12` prints `<hash>`.
   - Revise → `revise`; the human's words become a failure input of this pass; the new block takes the same F row
     (`F#: F<n>`), the old one becomes `superseded by H<m>`, the F row `proposed (H<m>)`.
   - Stop → `rejected`; F row → `rejected (H<n>)`; its learning's frontmatter `status: rejected` (the lesson stays).
   - Approve, not bound (no hash, or the bytes differ) → `stale`; re-ask at this gate. Never record an adoption on
     a stale approval.
   - Approve, bound, `hx <n> | git -C <apply-in> apply --check -R` exits 0 → `adopted`; F row → `adopted (H<n>)`;
     add the Part 3 table row with the exact words; its learning's frontmatter `status: adopted`.
   - Approve, bound, `hx <n> | git -C <apply-in> apply --check` exits 0 → `approved`; F row → `approved (H<n>)`;
     STOP says it is waiting to be applied.
   - Approve, bound, neither check exits 0 (the target changed since) → `stale`; regenerate the diff in step 6 as
     a new block that supersedes it, and re-ask.
   - No row → unchanged; list it in STOP as still waiting.
3. **Inventory.** One line per candidate: source, evidence pointer (template Part 1 form), observable symptom.
   Drop every candidate this project's rows already cite:
   `grep -E "^\| F[0-9]+ \|[^|]*\| $PROJECT \|" "$KIT/FINDINGS.md" | grep -cF '<pointer>'` prints more than 0.
   Merge lines with the same root symptom. Classify with `references/routing.md` §1; list what is not a failure
   under "Not routed" with the reason (nothing records these, so a later pass checks them again; that is cheap).
4. **Interview only what the evidence leaves open.** One question per message, each with a recommended answer and
   its reason, at most 5 per pass. Facts only: adoption is decided at G-L5, not here.
   - **Q-a Window** (only when ambiguous): "Which runs does this retro cover? Recommended: everything not yet in
     FINDINGS.md: <n> FAIL, <n> ESCALATE, <n> Revise, <n> verifier rows."
   - **Q-b Corrections** (always, unless already listed): "Besides these <n> corrections I can see, where else did
     you correct an agent? One line each. Recommended: none beyond this list."
   - **Q-c Cause** (per failure whose cause the evidence does not settle, highest impact first): "For <symptom>,
     which is closer: <cause A> or <cause B>? Recommended: <A>, because <evidence>."
   - **Q-d Reach** (only when the fix could be project-only or factory-wide): "Would this bite every project, or
     only <PROJECT>? Recommended: <x>, because <reason>." Teach the cost: factory-wide means every future agent
     reads it; project-only means the next project repeats the mistake.
5. **Find the root cause, then the layer.** For each failure:
   a. Ask "why" until you reach something the harness controls: a missing check, a missing tool, an unclear or
      absent sentence, a wrong default, a wrong harness. "The model was careless" is never a root cause.
   b. Match the symptom to the WORKFLOW.md §10 rows. When several match, pick by `references/routing.md` §2:
      checks → tools → artifacts → prompts → no durable change, with §10's row order as the tiebreak inside a step.
   c. Pick the narrowest reach that is still durable: one task file → this project's files → a software-factory-kit
      template or skill → WORKFLOW.md. Go wider only when the same cause would recur in another project.
   d. Search history, `logged` rows included: `grep -niE '<2-3 symptom words>' "$KIT/FINDINGS.md"`. Same cause
      found → note `recurs F<m>`. A "one-off" seen twice is not one-off. A recurrence after an adopted fix means
      that fix's guard missed it: move one step earlier in the preference order instead of adding words.
   e. `grep -n` the target file for the rule. If it already says it, the failure is "rule ignored": do not add a
      second sentence; move to a check or a tool.
6. **Draft the fix by kind** (`references/routing.md` §6 has an example of each, §8 the statuses):
   - **Harness change:** one H block per F per repo (a fix in the project and in software-factory-kit is two blocks). Two
     fixes in this pass that touch the same file share one block whose `F#:` names both rows. Start the diff with
     `: > "$tmp/H<n>.diff"`; for each file copy it to `$tmp`, edit only the copy, then
     `diff -u --label a/<rel> --label b/<rel> <original> "$tmp/<copy>" >> "$tmp/H<n>.diff"` (exit 1 means it
     found a difference, as wanted) with `<rel>` relative to the repo root it applies in (a new file:
     `--label /dev/null --label b/<rel> /dev/null "$tmp/<copy>"`). If the change contradicts WORKFLOW.md, the
     software-factory-kit block also changes WORKFLOW.md (it wins every conflict). Check
     `git -C <apply-in> apply --check "$tmp/H<n>.diff"` exits 0.
   - **Product change** (a missing test, a spec gap, a wrong design decision): no diff. Status
     `routed → <skill>` with a one-line ask for `fix-bug`, `define-acceptance`, `clarify-spec <file>`, or
     `log-decision` superseding `D<n>`. A systemic gap also gets an H block (e.g. a question for a skill's bank):
     status `routed → <skill> + proposed (H<n>)`.
   - **Verifier false alarm** (`discard`): the first time, status `logged`, layer `nothing durable`, so a repeat can
     be found; the same false alarm again → an H block for `agents/verifier.md`.
   - **Session hygiene** (corrected twice in one session): no diff; status `logged`, advice in Proposed fix.
   - **One-off quirk** (first occurrence, no harness cause): status `logged`. Never freeze it into a rule.
7. **Prune before adding.** For each diff that adds a rule, count the target's rules before and after with the
   commands in `references/routing.md` §4. At the ceiling (~20 rules in AGENTS.md or CLAUDE.md, 6 red-flag rows or
   300 lines in a SKILL.md) the same diff removes or merges a rule, and the block says which and why. Prefer
   replacing a vague rule with the sharper one.
8. **Write the guard:** one check that would catch a recurrence, runnable where possible (a test name, a
   `scripts/test.sh` case, a `scope-guard.sh` exit code, a `grep` with its expected output, a hook). "The human will
   notice" is not a guard: write `⚠ no mechanical guard: <why>`.
9. **Write the outputs** (Output below). Write a learning only when both hold: it would recur on another task or
   project if nothing changed, and a capable newcomer reading AGENTS.md would not already know it. software-factory-kit
   mode: FINDINGS.md is the record, no learning file.
10. Run every Done-when check, fix what fails, send STOP, then present G-L5 one decision per reply. software-factory-kit
    mode: when the human answers, write their exact words and the block's hash into its `Verdict:` line before
    anything is applied; that line is the Approvals record.

## Output

Fill this skill's `assets/template.md`. Every field is required; an unknown is `⚠ <question>`, never a guess. No
`|` inside a table cell; counts come from commands; times from `date`.

- **Part 0** is the pass's env file in `$tmp`, never committed.
- **Part 1 → `$KIT/FINDINGS.md`**: one row per failure, appended to the table. Status is one of
  `proposed (H<n>)` · `approved (H<n>)` · `adopted (H<n>)` · `rejected (H<n>)` · `routed → <skill>` ·
  `routed → <skill> + proposed (H<n>)` · `logged` · `superseded by F<m>` (lifecycle: `references/routing.md` §8).
  The Symptom cell ends with its evidence pointer `(ev: …)`.
- **Part 2 → `$KIT/HARNESS_CHANGELOG.md`**: one `### H<n>` block per F per repo, under `## Proposals` (append that
  heading, with the template's comment, at the end of the file if it is missing). `Apply in:` is `software-factory-kit`
  (`<apply-in>` = `$KIT`) or the project name (`<apply-in>` = `$ROOT`), never an absolute path. Paste
  `$tmp/H<n>.diff` into the block unchanged. Its `diff-sha256` is `hx <n> | shasum -a 256 | cut -c1-12`, the
  first 12 hex of the diff bytes as stored, because those bytes are what the human approves. Heading status:
  `proposed | approved | adopted | revise | rejected | stale | superseded by H<m>`.
- **Part 3 → `$KIT/HARNESS_CHANGELOG.md` table**: only in step 2, for an adopted proposal.
- **Part 4 → `docs/learnings/<slug>.md`** in the project: kebab slug of at most 5 words, unique in that folder.
- **Part 5** is the G-L5 card, chat only.

## Done when

- [ ] Only allowed files changed: `git -C "$KIT" status --porcelain | diff "$tmp/base-kit.txt" -` shows only
      `FINDINGS.md` and `HARNESS_CHANGELOG.md`; `git status --porcelain | diff "$tmp/base-project.txt" -` shows
      only `docs/learnings/*.md`. Anything else: revert.
- [ ] Ids unique: `grep -oE '^\| F[0-9]+ ' "$KIT/FINDINGS.md" | sort | uniq -d` and
      `grep -oE '^### H[0-9]+ ' "$KIT/HARNESS_CHANGELOG.md" | sort | uniq -d` print nothing.
- [ ] No evidence routed twice: `grep -E "^\| F[0-9]+ \|[^|]*\| $PROJECT \|" "$KIT/FINDINGS.md" |
      grep -oE '\(ev: [^)]*\)' | sort | uniq -d` prints nothing.
- [ ] Every F row has 8 cells and a Guard:
      `awk -F'|' '$2 ~ /^ *F[0-9]+ *$/ && (NF != 10 || $9 ~ /^ *$/)' "$KIT/FINDINGS.md"` prints nothing.
- [ ] Each new H block: `hx <n> | git -C <apply-in> apply --check` exits 0 (applies cleanly, not yet applied), and
      `hx <n> | shasum -a 256 | cut -c1-12` equals the block's `diff-sha256` and is not `e3b0c44298fc` (the hash of
      empty input: `hx` found no diff).
- [ ] Links both ways: every Status containing `proposed (H<n>)` has that block, and every new block's `F#:` line
      names rows whose Symptom has an `(ev: …)` pointer (no change without a real occurrence).
- [ ] Every `logged` row has no H block and no learning file.
- [ ] Each new learning has all four headings: `for h in 'What happened' 'Why it happened' 'The rule now'
      'Evidence'; do grep -q "^## $h" docs/learnings/<slug>.md || echo "missing $h"; done` prints nothing.
- [ ] No secret values in what you wrote: `grep -nE 'AKIA[0-9A-Z]{16}|sk_(live|test)_|-----BEGIN [A-Z ]*PRIVATE
      KEY|xox[abprs]-|gh[pousr]_[A-Za-z0-9]{20,}|eyJ[A-Za-z0-9_-]{10,}\.' <each file you wrote>` and
      `grep -nF "$HOME" <each file you wrote>` print nothing, and no patient or customer data appears.
- [ ] Every count in the STOP message came from a command you ran this pass (`references/routing.md` §5).

## STOP

Send exactly this, filled, then stop. Then present the remaining decisions one per reply, highest impact first,
each as a Part 5 card, and finish with the Part 5 block decision for the `routed` and `logged` rows. With no H block
this pass, Decision 1 is that block decision.

```
route-failure stopped (<date>). Project <PROJECT> (<project | software-factory-kit> mode). Window: <evidence not yet in
  FINDINGS.md | the window you named>.
Wrote: $KIT/FINDINGS.md F<a>…F<b> · $KIT/HARNESS_CHANGELOG.md H<x>…H<y> (status proposed) ·
  docs/learnings/<slug>.md | none
Applied: nothing. No skill, AGENTS.md, CLAUDE.md, hook, script or setting was edited. Nothing was committed:
  you commit $KIT/FINDINGS.md and $KIT/HARNESS_CHANGELOG.md (the factory's public record) when you are ready.
Earlier proposals: <H<n> → adopted | approved, waiting to be applied | rejected | revise | stale | still waiting>
  · waiting in other projects: <H<n> (<project>)> | none
Metrics (whole tracker, not only this window): first-pass acceptance <x>/<y> tasks · fix loops <f> FAIL lines
  over <y> tasks · gate Revise <r>/<g> · scope-guard blocks <s> | n/a in software-factory-kit mode
Inventory: <n> failures → <p> proposed · <t> routed · <l> logged · <k> not routed
- F<n> [<layer>] <symptom> → <H<n> | routed → <skill> | logged>; guard: <check>
Not routed: <pointer: why it is not a failure> | none

Gate G-L5: "Which layer owns this, adopt this fix?"
<Decision 1: the first Part 5 card, filled>
On Approve the supervisor writes | <time> | G-L5 | H<n>@<diff-sha256> | <your exact words> | to ## Approvals (the
block decision for rows without a diff: artifact FINDINGS.md F<a>-F<b>) and runs log-decision; software-factory-kit mode: I
write your words into H<n>'s Verdict line instead. Only you, or the supervisor after that record, apply it, and the
command refuses unless the bytes are the ones you approved:
  d=$(awk -v h='### H<n> ' 'index($0,h)==1{f=1;next} f&&/^### /{exit} f&&/^```diff$/{d=1;next} d&&/^```$/{exit} d' \
    "<software-factory-kit path>/HARNESS_CHANGELOG.md") && [ "$(printf '%s\n' "$d" | shasum -a 256 | cut -c1-12)" = <diff-sha256> ] &&
  printf '%s\n' "$d" | git -C "<apply-in path>" apply
The next route-failure pass records it as adopted.
Next skill (WORKFLOW §4 milestone close chain): `quiz-me`, once no G-L5 card of this pass is pending. I am not
starting it.
```

## Red flags

| Thought you might have | What to do instead |
|---|---|
| "The agent just got it wrong; I'll add 'be careful to…' to AGENTS.md." | Find the check or tool that makes the mistake loud or impossible. A sentence is the last resort, and never a duplicate of one the file already has. |
| "This fix is obviously right; I'll apply it and save a round trip." | Write the H block and stop. The human approves those exact bytes (the hash) at G-L5; applying is human-only. |
| "That was weird; better add a rule so it never happens again." | First occurrence with no harness cause is a one-off: status `logged`. A second occurrence in FINDINGS promotes it. |
| "AGENTS.md is long, but one more line won't hurt." | Count the rules. At the ceiling the same diff removes or merges one; a rule the model skims past is worse than none. |
| "The verifier suggested fix for R3" or "the human said Revise at G2, so that agent failed." | Only the human's disposition in `## Approvals` counts (no word: `⚠ pending`), and a Revise because the human learned something is the gate working. Route it only when the inputs already held what the agent missed. |
| "I'll paste the whole error so the row explains itself." | Quote at most 3 lines with secrets and PHI redacted, or point at the TRACKER line. software-factory-kit is public. |
