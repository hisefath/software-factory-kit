---
name: clarify-spec
description: "Use when one spec artifact (brief, codebase audit, PRD, UX flows or screens, HLD, LLD, change plan, acceptance or demo script) still has open ⚠ markers or vague requirements that the human must settle before its gate. Produces the answers applied inline in that one file plus its Clarifications log. Do NOT use for a task file (use slice-tasks, or clarify the acceptance.md or lld.md it derives from), for writing, restructuring or re-scoping the artifact (use its owner skill, e.g. write-prd) or for recording a design decision (use log-decision)."
disable-model-invocation: true
metadata:
  software-factory-kit: "0.1"
  phase: "3b"
  gate: "per-question"
---

# clarify-spec

**Outcome:** one target artifact in which every question asked this pass is answered inline in the human's
words, its open question closed (resolved, waived, or left open by the human's choice), with a dated
`## Clarifications` log, and no other change anywhere.

## You own / You never touch

- You own **the one target file** the human named: the spots your answered questions point at, the `⚠` markers
  and open-question rows you resolve, waive or add, and one new `### Pass <k>` block under its `## Clarifications`.
  You never edit any other file: not the upstream or downstream artifact that now disagrees (name it in STOP), not
  `docs/decisions/**` (`log-decision` owns it), not `.handoff/**` (the supervisor owns it), not code or tests.
- You own **the questions**: which to ask, their order, their options and a recommendation for each. You never
  own **the answers**: the human picks, and you apply exactly what they said, nothing more.
- You own **marking** ambiguity in the target's own marker form. You never add a requirement, feature, number,
  unit, measurement method, actor, screen or non-goal that no answer states.
- You own **flagging decision candidates** in the log. You never write the decision record; the supervisor runs
  `log-decision`.
- You own **stating each answer** in the target's own style and ids. You never renumber or delete an existing id,
  rewrite text no answer covers, or edit an earlier `### Pass` block.
- You never commit, push, install anything, or start the next skill.

## Inputs

Read all of these before the first question. Never ask what they already answer.

1. **The target (required)**: exactly one path from the STOP table, named by the human or the supervisor's
   dispatch. None, several, or not a spec artifact (code, tests, `.handoff/**`, `docs/decisions/**`): stop and ask
   which single file, recommending the one whose gate is next in `.handoff/TRACKER.md ## Resume`. A task file
   (`specs/M<N>-<slug>/tasks/T###.md`) is never a target: its contract allows exactly six `## ` headings and it is
   the worker's only input. Stop and recommend `clarify-spec` on the `acceptance.md` or `lld.md` it derives from,
   or Revise via `slice-tasks`. Any other path missing from the STOP table: stop and ask which gate it feeds.
2. **`AGENTS.md` (required)**: project rules, commands, glossary, mandated stack. Missing: stop and name it.
3. **Upstream artifacts.** `M<N>` comes from the target's path, else the milestone in `.handoff/TRACKER.md
   ## Resume`, else the highest-numbered `specs/M*-*/`. A required file missing: stop and name it. An optional one
   missing: note "not present" and go on.

   | Target | Required | Read if present |
   |---|---|---|
   | brief | none (the human is the source) | the source files its REQ rows cite |
   | `docs/audit/AUDIT.md` | none | the code paths it cites; the brief |
   | `docs/product/prd.md` | Full track: `specs/M<N>-<slug>/brief.md` | the brief (Standard); `docs/research/R<NN>-*.md` for each `R<NN>` the brief lists; `docs/audit/AUDIT.md` |
   | `docs/design/flows.md`, `screens.md` | `docs/product/prd.md` | the brief |
   | `docs/architecture/hld.md` | `docs/product/prd.md` | `docs/design/flows.md` + `screens.md` (UI-critical only); `docs/audit/AUDIT.md`; research |
   | `docs/architecture/lld.md`, `change-plan.md` | `docs/architecture/hld.md`, `docs/product/prd.md` | flows/screens; `docs/audit/AUDIT.md`; the code paths a change plan cites |
   | `specs/M<N>-<slug>/acceptance.md` | `docs/product/prd.md`, `docs/architecture/lld.md` | `docs/architecture/hld.md`, `docs/design/screens.md` |
   | `docs/demo/SCRIPT.md` | `docs/product/prd.md` | `docs/milestones/M*.md`, `docs/architecture/diagrams/*.mmd` |

4. **`docs/decisions/DECISION_JOURNAL.md` (required)**: accepted `D<n>` are settled. Cite them; never re-ask them.
   Missing: stop: "No decision journal. Run scripts/init-repo.sh."
5. **`.handoff/TRACKER.md` (required, read-only)**: the track (Fix / Standard / Full) and `## Approvals` (which
   artifact is approved, at which SHA). Missing: stop: "No tracker. Run scripts/init-repo.sh."
6. **`references/taxonomy.md`** in this skill: categories (§2), phase fit (§3), card writing (§4), decision
   candidates (§5), **§6, this target's marker conventions** (what one open question is, how to count, close and
   add one) and §7, the HOW-word check.
7. **A live human.** This skill is interactive. If nobody can answer (an unattended or batch run), edit nothing
   and return the ranked question list from step 6 as your whole output.

## The one rule

**Ask, never decide:** every change you make to the target is one human answer to one question, logged in the
human's own words and then applied exactly where that question pointed.

## Steps

1. **Baseline.** Run these and keep the output; Done when compares against it:
   `date '+%Y-%m-%d %H:%M %Z'` · `git rev-parse --short HEAD 2>/dev/null || echo none` (none: the pass header says
   `base none (no commits)` and no file counts as approved in step 4) · `git status --porcelain` ·
   `cp <target> "${TMPDIR:-/tmp}/clarify-spec-$(basename <target>).base"` (scratch copy outside the repo) ·
   the open count with this target's command from taxonomy §6 · pass number `grep -c '^### Pass ' <target>` (this
   pass is k = that + 1) · last log id `grep -oE '^#### CQ-[0-9]+' <target> | sort -t- -k2 -n | tail -1` (next id
   = that + 1, else CQ-1).
2. **Read** every input in full. Note what each source already settles. Brownfield (the target cites code, or it
   is `AUDIT.md` or a change plan): read the code paths it cites before asking, read-only (`git grep`, `sed -n`),
   and keep `file:line` for each fact you verify.
3. **Inventory.** List the open questions by this target's §6 row: an inline `⚠` and the row or bullet that
   repeats it are ONE question; a brief's `⚠ … (→ R<NN>)` is `gather-evidence`'s, so park it; pair each inline
   `⚠` with its row by id, else by text. Then read the target section by section against the eight categories and
   note each unmarked ambiguity. For every candidate keep: location (section, id, line), category, the question,
   and what would change downstream (design, test, task, cost) with the answer. A marker's own `Recommended:` is a
   starting recommendation, not an answer.

   | Category | Ask when the target… |
   |---|---|
   | Scope | blurs in/out, lacks non-goals, says "etc.", "and more", "later?" |
   | Data / entities | names a thing without its fields, owner, lifecycle, uniqueness or volume |
   | User flows / UX | has a story with no actor, trigger or end state; a screen with no empty/error/loading state |
   | NFR numbers | says fast, secure, scalable, reliable or accessible without number + unit + how measured |
   | Edge cases / failure | is silent on invalid input, duplicates, timeouts, partial failure, concurrency, denial |
   | Integration / external | depends on an outside system without its contract, auth, limits or failure behaviour |
   | Terminology | uses two words for one thing, or one word for two things |
   | Completion signals | has a requirement with no observable pass/fail check (no SC / AE / Done-when) |

4. **Settle from source, without a question.** Apply the answer and log it as `from-source`, quoting the line and
   its `file:line`, when it comes from: (a) an approved upstream artifact; (b) an accepted `D<n>`; (c) a line of
   `AGENTS.md`, for a fact it states (a term, a command, a mandated technology); (d) a code fact you verified at
   `file:line`, for what the code does today, never what it should do; (e) the human's verbatim answer to the same
   question already logged in another artifact (a `CQ-<n>` entry, or an owner skill's question row quoting them).
   Approved means a `## Approvals` row for that file at a SHA and `git diff --quiet <sha> -- <file>` exits 0 (an
   approval goes stale once the file changes). A choice about what the product or design *should* do still goes to
   the human unless (a), (b) or (e) made it. A draft, research, the inbox or your own judgment is background for a
   question, never an answer.
5. **Filter.** Do not ask a found candidate that (a) asks HOW on a WHAT artifact (a framework, database or
   endpoint in a brief or PRD; a table or class in an HLD): park it for the phase that owns it; (b) invites scope
   the target never raised ("should it also…?"): drop it; or (c) changes no design, test or task whatever the
   answer: drop it. An explicit open question is never dropped: you ask it or the human waives it (a brief's
   `(→ R<NN>)` markers excepted: they are parked for `gather-evidence`). When an explicit one is a HOW question on
   a WHAT artifact, offer "waive here, decide in `<later skill>`" as an option.
6. **Rank and pick at most 5.** A Revise of `CQ-<n>` handed over from the last STOP goes first: its card shows
   the old answer and the requested change as options, and its entry carries `- Revises: CQ-<n>`. Then explicit
   markers, then found ones. Inside each group order by blast radius: scope → data/entities →
   integration/external → NFR numbers → edge cases/failure → user flows/UX → completion signals → terminology;
   break ties by the candidate whose answer unblocks the most others. The rest wait for the next pass.
7. **Ask one question.** Send one question card (`assets/template.md` Part 1), then wait. Never show the next card
   early; never answer it yourself. Give 2-3 mutually exclusive options plus "Leave open (do nothing)"; each
   implication says in plain words a beginner could repeat in an interview what changes downstream and what it
   costs. The recommendation names one option and its evidence (`file:line`, `D<n>`, `R<NN>`). The default is
   Leave open: the open question stays, the next skill works on the conservative assumption (taxonomy §4), and the
   gate lists it as open.
8. **Read the reply.**
   - An option letter, "recommended", or own words that answer the question: apply it (step 9).
   - Own words that are unclear or contradict another line of the target: ask one follow-up that quotes the
     conflict (it does not count toward the 5). Still unclear: `skipped`.
   - "You decide" or "whatever you think": restate the recommended option in one line and ask for an explicit
     yes. No yes: `skipped`.
   - `skip`, "leave open" or "do nothing": `skipped`, the marker stays. `waive <reason>`: `waived`. `stop` or
     `done`: close the pass (step 11).
   - An answer that reaches past the question (a new feature, actor, screen, integration): apply only the part
     that answers this question; log the rest verbatim as a scope change for the owner skill.
   - On a WHAT target (brief, PRD, flows, screens), an answer that names HOW (a framework, database, queue,
     library, endpoint, table): apply only the behaviour it asks for; log the HOW words verbatim on the pass's
     `Parked for a later phase` line → `design-hld` / `design-lld`. They go under the PRD's `## Constraints` only
     if the human says the technology is mandated, and by whom (one follow-up, not counted toward the 5).
9. **Log, then apply**, before the next question. The `CQ-<n>` entry is this per-question gate's verbatim record,
   written before the edit as WORKFLOW.md §2 rule 6 asks of every gate answer. The Approvals rows come later, at
   commit, because an Approvals row binds to a SHA (see STOP):
   - Append the `#### CQ-<n>` entry to this pass's block (Part 3). Create `## Clarifications` at the end of the
     file if it is missing; replace a `None yet.` placeholder; keep its HTML comment.
   - Close the question in this target's §6 form (Part 2): the row and every inline pointer, one CQ tag. Keep its
     id; give a new item the next free id under the target's own id rules; write a number, unit, condition or
     measurement method only as the human stated it, and turn a missing one into a new marker (add form), never
     your guess; let a chosen term replace its synonyms in this file only.
   - A revision: replace the body text tagged `(CQ-<old>)` and re-tag it `(CQ-<n>)`; never edit the old entry.
   - Remove the text in this file that the answer contradicts, and only that text. Retire ids only the way the
     target's rules say (e.g. strikethrough, never delete).
   - Redact secrets, credentials, PHI or real personal data in a verbatim answer as `[redacted: <kind>]` and tell
     the human why (repos are public).
10. **Flag decision candidates.** `yes` when the answer picks between real alternatives that change scope, the
    data model, a public contract or API, an external dependency or vendor, auth, payments or PHI handling, or an
    NFR target, or when it is costly to undo (Type 1). Otherwise `no`. Say why in one plain sentence. Then go back
    to step 7 until 5 questions are asked, the list is empty, or the human says stop.
11. **Close the pass.** Add each unasked step-6 candidate in this target's §6 add form (a marker states a
    question, never an answer). If the target has a `## Change log` and an Approvals row exists for it, add one row
    in its own columns: date (`date`), `clarify-spec pass <k>: CQ-<a>…CQ-<b>`, ids affected, and the fourth column
    by its header: `Approval` → `pending <gate id>`; `Why …` → `the human's words in ## Clarifications › Pass <k>`.
    Re-run the open count, fill the pass header (counts, markers added, parked), run Done when, then send STOP.

## Output

- **Path:** the target file only. The scratch baseline copy lives outside the repo and is not an output.
- Fill `assets/template.md`: Part 1 is each chat question card (never written to the file), Part 2 is the exact
  form of every inline edit, Part 3 is the `### Pass <k>` block appended under `## Clarifications`.
- Every field of every `CQ-<n>` entry is required. Unknown: write `not given`, never invent. Never write the `⚠`
  character inside `## Clarifications`: the open count must see only open questions.
- The `CQ-<n>` entry is the verbatim record of its question's gate. The pass-level Approve at STOP keeps the
  edits; it never stands in for a CQ's own words in the journal.

## Done when

`<base>` is the step-1 scratch copy; "the count" is this target's taxonomy §6 count. Each check states what it must
print.

- [ ] Only the target changed: `git status --porcelain` = the step-1 output plus `<target>`.
- [ ] At most 5 questions asked this pass (Pass k is the last block):
      `sed -n '/^### Pass <k> /,$p' <target> | grep -cE '^- Status: (resolved|waived|skipped)'` ≤ 5
- [ ] Log ids unique: `grep -oE '^#### CQ-[0-9]+' <target> | sort | uniq -d` prints nothing.
- [ ] No `⚠` inside the log: `sed -n '/^## Clarifications/,$p' <target> | grep -c '⚠'` prints 0.
- [ ] The pass header's "after" number equals the count run now.
- [ ] No id lost:
      `comm -23 <(grep -oE '[A-Z]{1,6}-?[0-9]+' <base> | sort -u) <(grep -oE '[A-Z]{1,6}-?[0-9]+' <target> | sort -u) | grep -vxE 'G[0-9]+'`
      prints nothing (gate ids leave with closed `(→ G0)` / `(→ G4)` markers; that is not a lost id).
- [ ] Every body hunk in `diff -u <base> <target>` traces to a `CQ-<n>` entry, a new marker in the §6 add form or
      this pass's Change log row. Anything else is unasked scope: revert it.
- [ ] Each resolved or waived CQ: no marker of that question is left (its row and every inline pointer) and the
      body states the outcome tagged `(CQ-<n>)`. Each skipped CQ: its marker is still there.
- [ ] Brief, PRD, flows or screens: the taxonomy §7 HOW check prints nothing beyond the hits it allows.
- [ ] Each entry has the question as asked, the options with "do nothing", the answer verbatim in quotes (or
      `[redacted: …]`), status, decision-candidate and scope-change lines; the pass header time came from `date`.
- [ ] No secrets, credentials or PHI in anything you wrote.

## STOP

Pick the next step by the first rule that matches: (1) a scope change was requested, or a cell now reads
`pending <owner skill>` → the target's owner skill (Revise); (2) open count > 0, at least one question this pass
was resolved or waived, and the human did not say stop → `clarify-spec` again on the same target; (3) otherwise →
the last column below. Approve here keeps this pass's edits only; it is never the target's gate.

| Target | Owner skill | Gate it faces next (WORKFLOW.md §4) | Rule 3: what happens next |
|---|---|---|---|
| `specs/M<N>-<slug>/brief.md` | `sharpen-brief` | G0 "Right problem, appetite, track?" | re-present G0, then `gather-evidence` (brief lists R<NN>) · `write-prd` (greenfield) · `audit-codebase` (brownfield) |
| `docs/audit/AUDIT.md` | `audit-codebase` | G-audit "Which findings constrain the build, which do I accept?" | re-present G-audit, then `write-prd` |
| `docs/product/prd.md` | `write-prd` | G1 "Right problem, scope, non-goals, success measure; every ⚠ resolved or waived?" | re-present G1, then Full: `map-ux-flows` (no UI: `design-hld`) · Standard: `design-lld` |
| `docs/design/flows.md`, `docs/design/screens.md` | `map-ux-flows` | G-ux "Which variant? Every state covered?" | re-present G-ux, then `design-hld` |
| `docs/architecture/hld.md` | `design-hld` | G2 "Do these containers, connections, trust boundaries and invariants match my intent? Approve D<n>?" | re-present G2, then `design-lld` |
| `docs/architecture/lld.md`, `specs/M<N>-<slug>/change-plan.md` | `design-lld` | G3 "Could I defend every table, state owner, endpoint and sequence in an interview?" | re-present G3, then `define-acceptance` |
| `specs/M<N>-<slug>/acceptance.md` | `define-acceptance` | G4 (acceptance is reviewed inside it, after the tasks exist) | run `slice-tasks` |
| `docs/demo/SCRIPT.md` | `write-demo-script` | G-demo: the human flips `status: approved` | the human flips it, then `record-demo` |

"Re-present" means the supervisor shows that gate for `<target>@<sha>` in the owner skill's STOP format (fresh
counts, open questions listed; at G2/G3 also the hardest decision, rejected alternatives and least-confident part).
Send exactly this, filled, and stop:

```
clarify-spec pass <k> stopped (<date>).
Wrote: <target> (CQ-<a>…CQ-<b>, each logged verbatim then applied inline; ## Clarifications › Pass <k>). No other file touched.
Open questions: <before> → <after>   (taxonomy §6 count for this target)
Coverage: Scope <s> · Data <s> · Flows/UX <s> · NFR numbers <s> · Edge cases <s> · Integration <s> · Terminology <s> · Completion <s>
  (Clear = already precise · Resolved = answered this pass · Open = still open · Parked = belongs to a later phase)
- CQ-<n> [<category>] <resolved | waived | skipped | from-source>: <the outcome in one line>
Markers added, not asked: <line: question | none>
Parked for a later phase: <question or HOW words → skill | none>
May now disagree, not edited: <path#section → skill | none>
Scope change requested: <"verbatim words" → Revise via <owner skill> | none>
Decision candidates: <CQ-<n>: why | none>
  Supervisor, on Approve, in order: (1) commit <target>; (2) for each candidate append to .handoff/TRACKER.md ## Approvals
  | <date> | 3b clarify-spec CQ-<n> | <target>@<sha> | "<CQ-<n> Answer (verbatim)>" |
  (3) run log-decision naming CQ-<n>. Your pass-level Approve below never replaces a CQ's own words.
Gate: per question (phase 3b). Each answer above is already recorded verbatim in its CQ entry.
Your call on this pass (this is NOT <gate id>; that gate comes after):
  Approve: keep these edits. The supervisor commits <target> and records gate "3b clarify-spec pass <k>" at
           <target>@<sha> (fast; later phases build on these answers).
  Revise: name the CQ id and the change. The supervisor re-runs clarify-spec, which asks it first as a new CQ
          marked "Revises: CQ-<n>" (cheap now; expensive once design or code is built on it).
  Stop: park here; open questions stay visible and nothing downstream starts.
Next: <(1) run `<owner skill>` (Revise) | (2) run `clarify-spec <target>` again | (3) the supervisor re-presents
<gate id>: "<gate question>" for <target>@<sha>; after its Approve, run `<skill>`>. I am not starting it.
```

## Red flags

| Thought you might have | What to do instead |
|---|---|
| "I'll list all five questions so they can answer in one go." | One card per message, then wait. Batched replies come back vague and can't be quoted verbatim against one question. |
| "The answer is obvious" or "they said 'up to you', so I'll write X." | Only the step-4 sources settle it. Otherwise X is the recommendation; get an explicit yes or mark it `skipped`. |
| "Their answer implies a new feature, and the HLD now disagrees; I'll update both." | Apply only what answers the question, in this file. Log the extra as a scope change and name the other file in STOP for its owner skill. |
| "They said 'just use Postgres'; I'll put that in the PRD." | That is HOW on a WHAT artifact. Apply the behaviour, park the words for `design-hld` / `design-lld`, and write a Constraint only if they say it is mandated and by whom. |
| "This is clearly an architecture decision; I'll write the D-entry." | Flag `Decision candidate: yes` with one plain sentence why. The supervisor writes its own Approvals row from the CQ's verbatim answer, then runs `log-decision`. |
| "Open count is 0, so the gate passed; I'll start the next phase or commit." | Approve here keeps the edits only. Send STOP and stop: the supervisor re-presents the real gate and commits. |
