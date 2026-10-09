---
name: sharpen-brief
description: Use when a new product, graded project or capstone is starting on the Full track and its brief does not exist yet, or when G0 came back Revise. Produces specs/M<N>-<slug>/brief.md. Do NOT use for writing requirements or a PRD (use write-prd) or for answering the brief's research questions (use gather-evidence).
disable-model-invocation: true
metadata:
  software-factory-kit: "0.1"
  phase: "1"
  gate: "G0"
---

# sharpen-brief

**Outcome:** one file, `specs/M<N>-<slug>/brief.md`, that states the problem in the human's words, maps every
assignment requirement to a deliverable and an owner, and was planned *with* the human (read first, then one
question at a time, each with a recommendation) so it is ready for them to answer G0.

## You own / You never touch

- You own `specs/M<N>-<slug>/brief.md` fully (create the folder); you never write any other path: not `docs/`,
  source code, tests, `AGENTS.md`, `CLAUDE.md`, `MILESTONES.md` or `.handoff/` (the supervisor owns those).
- You own the problem: the human's words, the job stories, the open questions; you never propose a solution, stack,
  schema, screen or endpoint. Ideas you hear go verbatim into `## Parking lot`.
- You own finding every assignment requirement and naming its owner; you never write requirements (FR/NFR ids,
  EARS sentences). `write-prd` does that.
- You own writing the research questions; you never answer them or browse for answers. `gather-evidence` does that.
- You own recommending appetite and track, with the cost of each option in plain words; you never decide them. The
  human decides at G0.
- You own marking every unknown as `⚠ <question> (→ G0)` or `(→ R<NN>)`; you never guess a date, timezone,
  filename or requirement.
- You own reading the whole repo and the assignment; you never run the project's toolchain, install anything, or
  run a git command that changes state.
- You own describing sensitive inputs ("partner API key: the human holds it"); you never copy secret values,
  credentials or patient/personal data into the brief, and you never quote an uncleared partner document word for
  word (step 1). Repos are public.

## Inputs

Read these first, in this order. If a MUST is missing, stop and name it. Never guess around it.

1. **The official assignment / spec (MUST).** The files or pasted text the human points to, every page, appendix,
   rubric and checkpoint doc. Missing → ask: "Where is the official assignment or spec? Paste it or give me the
   path." Record each source in the brief header as a repo-relative path, or, if it lives outside the repo, as the
   name the human gives it (`Cerbo partner spec v2, PDF, held by the human`), never an absolute or home path.
   A source outside the repo is **uncleared** unless the human already said it is public: add a `U-##` row "May
   the brief quote <source> word for word, and may a copy be committed? ⚠ confidential? (→ G0)". Until the human
   says yes, everything taken from it is a short paraphrase plus its page/section, written
   `(paraphrase, U-##) <text>`, never a verbatim quote (partner documents may be confidential; the repo is public).
2. **`AGENTS.md` (MUST).** The constitution: commands, stack and constraints already decided. Missing → stop:
   "Run `scripts/init-repo.sh` first (gate G-init)."
3. `.handoff/TRACKER.md`: `## Resume` and `## Tasks`, for what the supervisor routed and the track it announced.
4. `docs/decisions/DECISION_JOURNAL.md`: already decided. Never re-ask a decided question.
5. `MILESTONES.md`: milestone numbering.
6. `specs/*/brief.md` and `docs/product/prd.md`, if present.
7. `.handoff/inbox/*`: pasted notes and research. Candidate context only, never law.
8. The tree: `git ls-files` (or `ls -R` outside git), to tell greenfield from brownfield.

## The one rule

The assignment is law and the human's words are the problem: write down what is asked and why, in their words,
and turn every unknown into a question, never into a guess or a solution.

## Steps

1. **Clock and baseline.** Run `date '+%Y-%m-%d %H:%M %Z (UTC%z)'` and
   `git status --porcelain --untracked-files=all`; keep both outputs. Every time in the brief comes from `date`
   (run it again if the session spans hours).
2. **Check you are the right skill.** Write nothing and reply with the message below when `.handoff/TRACKER.md`
   routed this as Fix or Standard, or when no track was announced and `docs/product/prd.md` already covers this
   product: "This looks like <Fix | Standard>. sharpen-brief is the Full-track entry (WORKFLOW.md §3). Run
   <fix-bug | clarify-spec (the PRD has open ⚠) | design-lld (no open ⚠ in the PRD)> instead, or tell me to brief
   it as Full." Count the PRD's open markers with `grep -c '⚠' docs/product/prd.md`. If TRACKER announced Full,
   proceed even when a PRD exists (a graded project is always Full, and a track may move up, never down) and
   record the existing PRD in `## Track`.
3. **Read the law.** Read the assignment completely. In working notes (not a file), quote the exact words of:
   every must / shall / required / submit / include sentence; every named file or path (exact case, extension and
   location); every deadline or checkpoint with its timezone; every rubric or grading line; every hard gate; every
   act that needs a person (record, post, present, sign up, pay, flip visibility). When two sources disagree, the
   official assignment wins; write the conflict as `⚠ … (→ G0)`.
4. **Read the repo.** Read Inputs 2-8. Mark brownfield when product code exists that `init-repo.sh` did not
   scaffold (brownfield adds `audit-codebase` before `write-prd`). Pick `N`, first rule that matches:
   (a) a Revise re-run keeps the existing brief's folder; (b) `MILESTONES.md` is missing or its `M1` row is not
   `done` (a new product) → `N = 1` (`M1 Research` is the docs-only milestone that carries this brief and the
   research, WORKFLOW.md §8); (c) otherwise `N` = the lowest `M<N>` ≥ 1 whose **status** column is not `done`
   (`awk -F'|' '$2 ~ /M[1-9]/ {print $2,$7}' MILESTONES.md` prints id and status); (d) every such row is `done` →
   the highest N + 1. Pick `<slug>`: 2-4 kebab-case words naming the outcome, not the tech (`patient-reorders`,
   not `stripe-checkout`).
5. **Draft before you ask.** Fill everything the sources already answer: the ask, REQ rows, owners, deadlines,
   obvious user-owned steps, first job stories. List what is still unknown and rank it by the cost of a wrong
   guess: wrong problem > wrong appetite > wrong deliverable path > missed user-owned step > nice to know. Keep the
   top 5 at most. Load `references/question-bank.md` for wording and defaults. Never ask what the repo or the
   assignment already answers.
6. **Interview: one question per message.** Use this shape, then wait for the reply:

   ```
   Q<n> (<k> of ≤5) <question>
   Why it matters: <one plain sentence: what goes wrong if we guess>
   My recommendation: <answer>, because <source or reason>
   Reply in your own words, "yes" to take the recommendation, or "skip" (it becomes a ⚠).
   ```

   Log every answer verbatim in `## Interview log`, after redacting: a secret or personal value (key, password,
   email, phone, a real person's name, MRN, date of birth, address) becomes `[redacted: <what it was>]`, and if
   the real value is needed later, add a `U-##` row (the human supplies it outside the repo). The same redaction
   applies to everything else you copy verbatim (`## Ask`, `## Parking lot`). When an answer names a solution or
   a technology ("use Stripe", "a React widget"), park it verbatim as a `P-##` row and, if the need behind it is
   still unclear, spend your next question on "What would that let you do?". A technology the assignment or
   `AGENTS.md` *mandates* is a constraint, not an idea: it becomes a REQ row with its quote. After 5 questions,
   stop asking; every remaining unknown becomes an inline `⚠`.
7. **Write the problem and the job stories in their words.** Problem: quote only sentences that describe the
   pain, the people or the moment (the human's and the assignment's, each with its source; an uncleared source is
   paraphrased per step 1). A sentence that names a technology is never quoted here: it goes to a REQ row if the
   assignment or `AGENTS.md` mandates it, else to a `P-##` row, and the Problem cites it by id ("see REQ-03").
   Then a restatement a non-engineer would sign: who struggles, in what moment, what they do today instead, what
   that costs them. Job stories: `When <situation>, I want <motivation>, so I can <outcome>.` A situation and a
   motivation, never a feature, button or screen. The Source cell holds ids only (`REQ-##`, `Q#`), never quotes.
   A proper name the text cannot avoid (the partner's product, a mandated system the user knows by name) goes in
   the frontmatter `problem_allowlist`; nothing else may trip the vocabulary check in `## Done when`.
8. **Map the law.** One REQ row per requirement from step 3: verbatim quote (uncleared source:
   `(paraphrase, U-##) <short paraphrase>`), source location, deliverable, owning
   phase/skill (the WORKFLOW.md §4 row whose Output column produces it), due date. The deliverable is the
   assignment's exact filename and location; when it is not a file, name the observable proof ("public URL
   loads", "CI job green"). When the assignment names a path the factory does not default to (root
   `ARCHITECTURE.md` versus `docs/architecture/hld.md`), the assignment's path is the deliverable and the owner
   cell names the factory source. No skill fits → `⚠ no owning skill (→ G0)`; never stretch a skill's scope.
   Work only a person can do maps to a `U-##` row.
9. **List user-owned steps.** Everything only the human can do: the WORKFLOW.md §2 rule 8 actions this assignment
   needs (deploy, push, visibility flip, spend), plus recordings, posts, accounts and sign-ups, partner access,
   submission forms, live presentations. For each: why only the human, due date, what it blocks. Put the
   earliest-blocking first.
10. **Set appetite and track.** Appetite is the time the human *chose* to spend (from their words), not your
    estimate: scope bends to fit it. Record the timebox and every deadline as written plus local time, converted
    by a command, never mental math (BSD/macOS: `TZ=<zone> date -j -f '%Y-%m-%d %H:%M' '<when>' '+%s'`, then
    `date -r <secs>`; GNU: `date -d 'TZ="<zone>" <when>'`). No timezone in the source → `⚠ timezone? (→ G0)`.
    Track: fill the options table (Full / Standard / Fix / Do nothing) with what each costs in plain words,
    recommend one, and cite the WORKFLOW.md §3 rule that decides it. Write the recommendation to frontmatter
    `track_recommended`; the decided track is recorded at G0 in `.handoff/TRACKER.md ## Approvals`, never here.
11. **Write the research questions.** One `R<NN>` per unknown that evidence, not the human's preference, can
    settle: the question, the decision it unblocks, what evidence would settle it, and where it came from (REQ, JS
    or a ⚠ line). Ask about people, domain rules, constraints, mandated systems and assignment ambiguities; name a
    technology only if the assignment or `AGENTS.md` mandates it. Aim for 8 or fewer; drop any that unblock
    nothing. `gather-evidence` writes each answer to `docs/research/R<NN>-<slug>.md`.
12. **Fill the template, then self-check** against `## Done when`. Fix and re-run the checks until all pass, then
    send the STOP message.

**On a Revise re-run:** read the existing brief and the human's exact Revise words; change only what they name;
continue the Q numbering in the Interview log (new pass, ≤5 new questions); never renumber existing ids.

## Output

- Exactly one file, `specs/M<N>-<slug>/brief.md`, made by filling this skill's `assets/template.md`.
- Keep every `##` section, in template order, and replace every `{{…}}`. A section with nothing to say keeps one
  row reading `none: <why>` (for example, no ideas heard yet). Never delete a section.
- Unknowns are inline, where the answer belongs: `⚠ <question> (→ G0)` when the human must decide, or
  `⚠ <question> (→ R<NN>)` when evidence will settle it. Never invent a value to fill a cell.
- Ids are never reused or renumbered. Two digits from 01: `JS-##` job stories, `REQ-##` assignment requirements,
  `U-##` user-owned steps, `R<NN>` research questions (become `docs/research/R<NN>-<slug>.md`), `P-##` parked
  ideas. Interview questions are unpadded: `Q1, Q2, …`, continuing across passes.
- Anything copied verbatim is redacted first (step 6); anything from an uncleared source is a paraphrase (step 1).

## Done when

Run each check against `specs/M<N>-<slug>/brief.md` (call it `$B`); every box must be true.

- [ ] `$B` exists at a legal path: `printf '%s\n' "$B" | grep -E '^specs/M[1-9][0-9]*-[a-z0-9-]+/brief\.md$'`
      prints it.
- [ ] Only `$B` changed: diffing `git status --porcelain --untracked-files=all` against the step-1 baseline gives
      exactly one new or changed line, ending in `$B` (none on a Revise re-run of a brief that is still
      uncommitted).
- [ ] Sections match the template:
      `diff <(grep '^## ' <this skill>/assets/template.md) <(grep '^## ' "$B")` prints nothing.
- [ ] No placeholders left: `grep -n '{{' "$B"` prints nothing.
- [ ] Ids unique: `grep -oE '^\| (JS-|REQ-|U-|P-|R|Q)[0-9]+' "$B" | sort | uniq -d` prints nothing.
- [ ] Problem and job stories are solution-free. Set
      `T='api|endpoint|database|db|schema|table|server|backend|frontend|framework|library|plugin|widget|component|webhook|oauth|cloud|deploy|docker|sql|json|app'`,
      then append `|<name>` for every language, framework, database, host and partner-system name in `AGENTS.md`; set
      `A=$(sed -n 's/^problem_allowlist: *//p' "$B")`. Then
      `awk '/^## (Problem|Job stories)/{f=1;next} /^## /{f=0} f' "$B" | grep -iowE "$T" | grep -vixE "$A"`
      prints nothing. No exceptions: reword, move the sentence to a REQ/`P-##` row and cite its id, or (proper
      names only) add the term to `problem_allowlist`.
- [ ] Second full pass over the assignment added no REQ rows (if it did, add them and pass again). Every REQ row
      has a quote (uncleared source: `(paraphrase, U-##)`), a source location, a deliverable and an owner, or a
      `⚠ (→ G0)`. No local paths: `grep -nE '/Users/|/home/' "$B"` prints nothing.
- [ ] Every deadline has a timezone and a local time produced by `date`, or `⚠ timezone? (→ G0)`.
- [ ] Every job story has all three clauses and a source id (`REQ-##` / `Q#`); every `R<NN>` names the decision it unblocks.
- [ ] Interview log has ≤5 new Q rows this pass, each answer verbatim (redacted) or `skipped → ⚠`.
- [ ] No secrets or personal data. Value patterns print nothing:
      `grep -inE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|\(?[0-9]{3}\)?[-. ]?[0-9]{3}[-. ][0-9]{4}|(dob|date of birth|born|mrn|patient[ _-]?(id|name|number))[^|]{0,20}[0-9]' "$B"`.
      Hits from `grep -inE 'password|secret|token|api[_-]?key|ssn|dob|mrn|patient[ _-]?(id|name)' "$B"` are
      descriptions only, never values.

## STOP

Send exactly this message (fill every `<…>`; counts come from the commands shown), then stop. Never start the
next skill yourself. Pick the next skill by `grep -c '^| R[0-9]' "$B"`: ≥1 → `gather-evidence (answers
R01-R<NN>)`; 0 and greenfield → `write-prd`; 0 and brownfield → `audit-codebase (it runs before write-prd)`.
With ≥1 on a brownfield brief, add "then audit-codebase before write-prd" to that line.

```
Brief ready for G0: specs/M<N>-<slug>/brief.md
- Job stories: <grep -c '^| JS-'> · Assignment requirements mapped: <grep -c '^| REQ-'> · User-owned steps: <grep -c '^| U-'>
- Research questions: <grep -c '^| R[0-9]'> · Parked solution ideas: <grep -c '^| P-'>
- Tech words allowed in Problem/Job stories (problem_allowlist): <value, or none>
- Open ⚠ (grep -n '⚠'):
  <paste the lines, or "none">

Gate G0: "Right problem, appetite, track?"
Background:
- Problem: <one-line restatement, no tech words>
- Appetite: <timebox>; final deadline <as written> = <local time from date>.
  (Appetite = the time you choose to spend; if work runs over, we cut scope instead of extending the deadline.)
- Least sure about: <one line>
Track options and their cost (full table in ## Track; deadlines in ## Appetite and deadlines):
- Full: <cost cell from ## Track, plain words>
- Standard: <cost cell from ## Track>
- Fix: <cost cell from ## Track>
- Do nothing: <cost cell from ## Track>
Recommendation: <Full | Standard | Fix>, because <WORKFLOW.md §3 rule>. In plain words: <one-sentence tradeoff against the next-best option>.
Default if you don't reply: nothing proceeds; the brief waits for your answer.

Reply Approve, Revise (tell me what to change), or Stop.
On Approve, the supervisor records your exact words in .handoff/TRACKER.md ## Approvals, then runs log-decision.
Next skill: <gather-evidence (answers R01-R<NN>) | write-prd | audit-codebase (it runs before write-prd)>. If you choose Standard or Fix instead, the supervisor re-routes per WORKFLOW.md §3.
```

## Red flags

| Thought you might have | Do this instead |
|---|---|
| "They clearly want Stripe / React, or the assignment says 'a Laravel app'; I'll quote it in the problem." | Park an idea verbatim as `P-##`; a mandated tech becomes a REQ row. Problem cites the id and restates the need without tech words. Only an unavoidable proper name goes in `problem_allowlist`. |
| "I'll just ask what the stack and deadline are." | Read `AGENTS.md`, the decision journal and the assignment first. Ask only what they do not answer. |
| "A file with that name already exists, or the factory default path is close enough." | The deliverable is the assignment's exact filename and location. A grader opens the named path, not ours. |
| "I'll batch my questions to save time." | One question per message, with a recommendation and why it matters; at most 5; the rest become `⚠`. |
| "The deadline is Friday at midnight; I'll write the date." | Run `date`, convert with a command, write the source's timezone plus local time, or `⚠ timezone? (→ G0)`. |
| "While I'm here I'll look up the answers / draft the FRs." | Write research questions and REQ rows only. `gather-evidence` answers, `write-prd` specifies. Send STOP. |
