---
name: quiz-me
description: "Use when the human wants to learn and rehearse defending this project's accepted decisions (a milestone's D-rows and the HLD/LLD choices behind them) before an interview, demo or review, or to re-test chosen or due topics from their private review list. Produces ~/factory-kit-private/<repo>/TOPICS_TO_REVIEW.md, outside the repo. Do NOT use for making, changing or recording a decision (use log-decision, or the owning design skill on Revise) or for writing demo material (use write-demo-script)."
disable-model-invocation: true
metadata:
  factory-kit: "0.1"
  phase: "16"
  gate: "self-check"
---

# quiz-me

**Outcome:** the human was taught every in-scope accepted decision in plain words, then quizzed one question at a
time and graded strictly against rubrics written before each question; every partial or wrong answer is a dated,
specific topic row in `~/factory-kit-private/<repo>/TOPICS_TO_REVIEW.md`; the repo is exactly as it was at the start.

## You own / You never touch

- You own `~/factory-kit-private/<repo>/TOPICS_TO_REVIEW.md` fully: creating it from `assets/template.md`, adding
  and updating `TR-<n>` topic rows, appending one `### S<k>` session block. You never write anything inside the
  repo: no docs, no `docs/learnings/`, no `.handoff/**`, no journal edit, no commit, no revert.
- You own **teaching**: plain-language explanations, analogies and background on general concepts (what a foreign
  key or an idempotency key is). You never invent **project facts**: what we chose, why, what we rejected and what
  it cost come only from the journal, HLD, LLD and milestone report, with a cite. Not recorded: say
  `⚠ not recorded` and list it as a journal gap.
- You own **the questions and their rubrics**, written to the session block before each question is sent. You
  never change a rubric after reading the answer.
- You own **the grade**: correct / partial / wrong plus the missing piece. You never round up, never give credit
  for confidence, length, jargon or for points your question, hint or model answer gave away, and never soften a
  verdict with praise.
- You own **flagging decision doubts** (the human argues a recorded choice is wrong) verbatim in STOP. You never
  edit, supersede or re-open a decision; the supervisor routes the doubt.
- You own the human's **private learning record**. You never write secrets, credentials, PHI or real patient or
  personal data into it, even inside a quoted answer: replace the value, and any real-looking person name, email,
  phone, date of birth or record number, with `[redacted: <kind>]` before writing, and say why.
- You own running read-only commands (`git status`, `git diff`, `grep`, `awk`, `date`) and naming the next skill.
  You never install anything, push, run unattended, or start that skill.

## Inputs

Run from the project repo root. Read these before the first teach card. A required input is missing: stop, name
the path, never guess.

1. **`AGENTS.md` (required):** project name, glossary, stack. Missing: "Run `scripts/init-repo.sh` first."
2. **`docs/decisions/DECISION_JOURNAL.md` (required):** `status: accepted` rows are what you teach. A
   `superseded-by` chain is "what changed your mind" material. Proposed and rejected rows are never taught as
   decisions. No accepted row: stop, "Nothing accepted to defend yet; pass a gate and run log-decision first."
3. **Track:** the milestone's `track/phase` cell in `.handoff/TRACKER.md ## Tasks` or its G0 row in `## Approvals`;
   else `track_recommended:` in the frontmatter of `specs/M<N>-*/brief.md`; unknown → treat as Standard.
4. **`docs/architecture/hld.md` and `docs/architecture/lld.md` (required unless the track is Fix):** the sections
   each D-row touches (`grep -n 'D<n>\b'`), HLD §5 trust boundaries, §7 invariants, §8 Scale budget (its "What
   breaks first at 10×" and "How you'd know in prod"), LLD §1 tables, §3 state ownership, §4 endpoints, §5 `SEQ-n`
   journeys, §6 `SM-n` state machines. HLD missing: "Run design-hld first." LLD missing: "Run design-lld first."
5. **`docs/milestones/M<N>.md` (required for scope `M<N>`):** what shipped, its evidence, the D-rows it cites.
   Missing: "Run report-milestone first, or pick a D-list scope."
6. **`docs/architecture/diagrams/*.mmd` (optional):** walk-through material. None: no diagram questions; say so.
7. **Defense expectations (the assignment's interview, defense, walkthrough or presentation requirements):**
   - First: `assignment:` in each brief's frontmatter
     (`awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f&&/^assignment:/' specs/M*-*/brief.md`). Open every listed
     repo path read-only. A listed name that is not a repo file lives outside the repo: step 2 asks for its path.
   - Then the brief's `## Spec is law` rows and the docs, skipping each brief's `## Interview log` (that is the
     requirements interview, not a defense rubric):
     `for f in AGENTS.md $(find specs docs/product docs/research -name '*.md' 2>/dev/null); do awk -v f="$f" '/^## Interview log/{s=1;next} /^## /{s=0} !s && tolower($0) ~ /interview|defen[cs]e|walk[- ]?through|presentation/ {print f":"FNR": "$0}' "$f"; done`
   - Found: weight questions toward it and cite it in rubrics; an expectation the sources cannot answer is listed
     in STOP. Nothing found and the human answers "none": write "no defense rubric found; using the journal schema".
8. **`~/factory-kit-private/<repo>/TOPICS_TO_REVIEW.md` (optional):** open `TR` rows, which are due (Next review ≤
   today), which ids appear on earlier `Taught:` lines. Missing: step 1 creates it.
9. **`.handoff/TRACKER.md ## Resume` (read-only, for STOP's next skill):** missing → next = `write-demo-script`.
10. **`references/question-bank.md`** in this skill: question stems per type and per design element, follow-up
    (transfer) stems, how to write a rubric, the grading calibration table. Read it before the first rubric.
11. **A live human.** This skill is interactive and is never dispatched. Nobody to answer: write nothing and stop.

## The one rule

**Teach before you test, then grade only against the rubric you wrote before asking:** an answer that misses a
must-have point is partial or wrong, however close, confident or well-phrased it sounds.

## Steps

Every shell block below runs as **one** command, exactly as written (`bash <<'EOF' … EOF`): it sets up its own
state, because shell variables do not survive between commands.

1. **Baseline the private file.** Any `STOP:` line → send it to the human, write nothing, stop.
```bash
bash <<'EOF'
set -u
top=$(git rev-parse --show-toplevel) || { echo "STOP: not inside a git repo"; exit 1; }
repo=$(basename "$top"); F="$HOME/factory-kit-private/$repo/TOPICS_TO_REVIEW.md"
date '+%Y-%m-%d %H:%M %Z'; echo "F=$F"
mkdir -p "$(dirname "$F")" && test -w "$(dirname "$F")" || { echo "STOP: cannot write $(dirname "$F")"; exit 1; }
if test -e "$F"; then
  [ "$(grep -cE '^## (Topics|Sessions)$' "$F")" = 2 ] || { echo "STOP: $F exists without the quiz-me skeleton"; exit 1; }
  echo "next session: S$(( $(awk '/^### S[0-9]+ /{n=substr($2,2)+0; if(n>m)m=n} END{print m+0}' "$F") + 1 ))"
  echo "next row: TR-$(( $(grep -oE '^\| TR-[0-9]+ ' "$F" | grep -oE '[0-9]+' | sort -n | tail -1) + 1 ))"
else echo "NEW: write the Part 2 skeleton; next session: S1; next row: TR-1"; fi
EOF
```
   Below, `<F>` is the path printed on the `F=` line. `NEW`: write the Part 2 skeleton of `assets/template.md` to
   `<F>` with `{{repo}}` filled. "Exists without the
   skeleton" (e.g. an older notes file for a same-named repo): ask whether to use another file name; never rewrite
   or append to it.
2. **Pick the scope, then write the session header.** If the human named a scope, use it. Otherwise ask one
   question with a recommendation:
   - `M<N>`: accepted D-rows of milestone M<N>, earlier accepted D-rows its report cites, the design elements the
     report says shipped, and due `TR` rows. Recommend it when a milestone report is newer than the last session.
   - `D<a>,D<b>,…`: only those accepted rows. Good for rehearsing right after G2 or G3.
   - `review`: only due `TR` rows. Recommend it when rows are due and no new report exists.
   - `TR-<a>,TR-<b>,…`: re-quiz just those rows, due or not; no teaching unless the topic was never taught.
   If Inputs item 7 found no openable assignment, ask one more question: "Is there an assignment or rubric with
   interview or defense requirements? (recommended: paste its path, or say 'none')". Then append the header; it
   records the repo fingerprint that Done when compares against. Fill the three `<…>` values first:
```bash
bash <<'EOF'
set -u; top=$(git rev-parse --show-toplevel) || exit 1; cd "$top"
F="$HOME/factory-kit-private/$(basename "$top")/TOPICS_TO_REVIEW.md"
k=$(( $(awk '/^### S[0-9]+ /{n=substr($2,2)+0; if(n>m)m=n} END{print m+0}' "$F") + 1 ))
fp=$({ git rev-parse HEAD; git --no-optional-locks status --porcelain=v1 -uall; git diff HEAD --binary; git ls-files -z -o --exclude-standard | xargs -0 cat; } 2>/dev/null | git hash-object --stdin | cut -c1-12)
printf '\n### S%s · %s · scope %s · base %s · fp %s · quiz-me (%s)\n\nDefense expectations: %s\nTaught: pending\n' \
  "$k" "$(date '+%Y-%m-%d %H:%M %Z')" '<scope>' "$(git rev-parse --short HEAD)" "$fp" '<harness, model id>' \
  '<path#section | no defense rubric found; using the journal schema>' >> "$F"
tail -5 "$F"
EOF
```
   **A run that opens with a dispute** of a closed question (`Q-<j>.<n>`, from an earlier session): handle it first,
   as the `#### Dispute of Q-<j>.<n>` item of this new session (template Part 3). Re-read the cited source and quote
   it; if the source supports the human, update that TR row by step 6's rules. Never edit the old Q block.
3. **Build the deck.** For each in-scope D-row pull: choice, Y-statement, options and the rejected ones, cost
   accepted, reversibility, confidence, revisit-if, evidence, interview line, plus the HLD/LLD sections that cite it,
   its diagram and its 10× row. A field the row lacks stays `⚠ not recorded` and becomes a journal gap. Add each
   shipped design element with no D-row (table, endpoint, state owner, sequence, invariant, trust boundary): G3
   asks the human to defend every one. Order:
   (a) never taught: the id is on no `^Taught:` line (`grep '^Taught:' <F> | grep -cE '\b<id>\b'` prints 0);
   (b) Type 1 (one-way door); (c) low confidence; (d) most depended on: the higher
   `cat docs/architecture/hld.md docs/architecture/lld.md docs/milestones/M<N>.md 2>/dev/null | grep -cE '\b<id>\b'`;
   (e) due rows. Take at most 6 topics per session; the rest go to "Not yet taught" in STOP.
4. **Teach, one topic card per message** (template Part 1, Teach card), then wait. Write middle-school clear:
   sentences under about 20 words, one everyday analogy, every term defined the first time, no bare acronyms.
   Then give the same idea in the real terms an interviewer uses. Every card has: what we chose, the plain
   explanation, the tradeoff (what we got, what we paid), each rejected alternative and why it lost (including "do
   nothing"), what would make us change it, where it lives (cites) and the interview line verbatim. Replies: `next`
   → next card; a question → answer from the sources with a cite, then offer `next` again; `stop` → step 8. Never
   quiz while teaching. Scopes `review` and `TR-…` skip teaching (the grade card's model answer re-teaches after a
   miss), except a topic never taught, which is always taught first. After the last card, replace
   `Taught: pending` with the ids taught (or `none (review)`).
5. **Write the rubric, then ask one question.** Append the `#### Q-<k>.<n>` block's Question, Type, Rubric (2-4
   must-have points, each with its cite, plus "wrong if") and Note lines to `<F>` and save **before** sending the
   question card. Then send exactly one question card and wait. Never show the next question early.
   - Mix the types: recall, why, 10×, what-if, diagram walk-through. Every topic with a recorded rationale gets a
     why-question. A topic with none (typically a design element with no D-row) gets a recall or walk-through
     question instead, with Note `why: not asked — not recorded (journal gap)`; never invent a rationale.
   - Scopes `M<N>` and `D-list`: at least one 10× question (from HLD §8) and one diagram walk-through, each on an
     in-scope topic that has that source; none has it → "not asked: <reason>" in the scorecard. Scopes `review`
     and `TR-…` ask only about their rows.
   - Two main questions per topic, at most 12 per session. Use the stems in `references/question-bank.md`.
   - Never put a must-have's key words in the question. For a `TR` row ask a fresh question on the same gap, never
     the old wording.
6. **Grade and record, then show the grade card** (template Part 1, Grade card, verdict first):
   - **correct**: every must-have point, in the human's own words, unprompted, nothing contradicting the source.
   - **partial**: at least one must-have, but another is missing or vague ("it's faster", "for scale"), a minor
     detail is wrong, or a hint was used.
   - **wrong**: no must-have; "I don't know"; `skip`; or any claim that contradicts a trust boundary, invariant,
     security, money or data-loss rule in the source, even next to correct points.
   A `hint` names the category of one missing point, never its content, and caps the grade at partial. No praise
   words on partial or wrong. **Disputes** during the session: re-read the cited source and quote it; change the
   grade only when the source supports the answer, and log the dispute either way. Effort, pressure or "you know
   what I meant" is not evidence. Before sending the card, append to the Q block: answer verbatim (trim past about
   80 words with `[…]`; redact per You own), hint used, verdict, missing piece, dispute, decision doubt, and for
   partial or wrong the Follow-up 1 question and rubric (step 7; the card carries it); every partial or wrong
   verdict line ends `→ TR-<n>`. Then update the topic row (dates from `date +%F`; due dates
   from `date -v+<d>d +%F 2>/dev/null || date -d '+<d> day' +%F` with `<d>` = 1, 3 or 7):
   - **Partial or wrong:** same topic id **and** same misunderstanding as an existing row → update that row;
     a different misunderstanding → a new row. The gap names the misunderstanding ("thinks a webhook retry is
     harmless without an idempotency key"), never just "D4 shaky". Set 🔴 for wrong (Next review +1 day) or 🟡
     for partial (+3 days), Last seen = today, Correct on = `none`. A ✅ row missed again reopens: status back to
     🔴/🟡, Resolved on = `—`. Never duplicate a row.
   - **Correct and unprompted** on a question about an open row's gap, due or not: add today to Correct on (once
     per day), Last seen = today. Two different dates in Correct on (only correct answers since the last miss stay
     there) → ✅, Resolved on = today, Next review = `—`; otherwise Next review +7 days.
   - Never delete or renumber a row. The human argues the decision itself is wrong (not that they forgot it):
     grade against the rubric anyway, record the words verbatim as a decision doubt, and continue.
7. **Follow up with a transfer question** (partial or wrong only; at most 2 per main question). The grade card has
   already shown the missing piece and the model answer, so never ask the human to repeat them: ask them to apply
   the missing piece to a new case (stems in `references/question-bank.md`). Each follow-up's question and one-line
   rubric are in the Q block before it is sent (Follow-up 1 in step 6); grade it, then append answer and verdict. A follow-up
   is practice: it never changes the main verdict, the row's status or its spacing (a wrong main answer stays 🔴).
8. **Close.** Append the Scorecard to the session block, with counts from `grep -c` on the block, never from
   memory, and the Ended line. If every main verdict is correct, re-read each answer against its rubric once more
   and write `re-checked: yes`. Fill Not yet taught, Journal gaps, Uncovered expectations and Decision doubts. Run
   Done when, then send STOP.

## Output

- **Path:** `~/factory-kit-private/<repo>/TOPICS_TO_REVIEW.md` only, outside the repo, never committed.
- Fill `assets/template.md`: Part 1 is the three chat cards (Teach, Question, Grade; never written to a file), Part 2
  is the file skeleton (created once), Part 3 is the `### S<k>` session block appended per session.
- Every field of every Q block and `TR` row is required. Unknown: `not given`. Missing project fact:
  `⚠ not recorded`. Never invent.

## Done when

Run this as one command from the repo root. Every check line must read `PASS`. Read every `INSPECT` line: each
must be a concept name ("idempotency token"), never a value; a value → redact it in `<F>` and re-run. A `FAIL`:
fix the private file `<F>` and re-run; never touch the repo. `FAIL repo-untouched`: revert nothing; paste
`git status --porcelain -uall` into STOP and say you did not write it.

```bash
bash <<'EOF'
set -u; bad=0; ok(){ echo "PASS $1"; }; no(){ echo "FAIL $1: $2"; bad=1; }
top=$(git rev-parse --show-toplevel) || { echo "FAIL repo: not a git repo"; exit 1; }; cd "$top"
F="$HOME/factory-kit-private/$(basename "$top")/TOPICS_TO_REVIEW.md"
test -s "$F" || { echo "FAIL file: missing or empty $F"; exit 1; }
k=$(awk '/^### S[0-9]+ /{n=substr($2,2)+0; if(n>m)m=n} END{print m+0}' "$F")
[ "$k" -ge 1 ] || { echo "FAIL session: no ### S<k> header in $F"; exit 1; }
B=$(awk -v h="### S$k " 'index($0,h)==1{f=1} f' "$F"); b(){ printf '%s\n' "$B"; }; hdr=$(b | head -1); echo "S$k: $hdr"
fp=$({ git rev-parse HEAD; git --no-optional-locks status --porcelain=v1 -uall; git diff HEAD --binary; git ls-files -z -o --exclude-standard | xargs -0 cat; } 2>/dev/null | git hash-object --stdin | cut -c1-12)
want=$(printf '%s' "$hdr" | grep -oE ' fp [0-9a-f]{12}' | cut -c5-)
[ -n "$want" ] && [ "$fp" = "$want" ] && ok repo-untouched || no repo-untouched "header fp ${want:-missing}, now $fp"
case "$(cd "$(dirname "$F")" && pwd -P)/" in "$(pwd -P)"/*) no outside-repo "$F";; *) ok outside-repo;; esac
[ "$(grep -cE '^## (Topics|Sessions)$' "$F")" = 2 ] && ok skeleton || no skeleton "need one ## Topics and one ## Sessions"
[ "$(grep -c "^### S$k " "$F")" = 1 ] && ok session-unique || no session-unique "S$k appears twice"
d=$(grep -oE '^\| TR-[0-9]+ ' "$F" | sort | uniq -d | tr -d '|' | xargs); [ -z "$d" ] && ok row-ids || no row-ids "duplicate $d"
d=$(b | grep -oE '^#### Q-[0-9]+\.[0-9]+' | sort | uniq -d | xargs); x=$(b | grep '^#### Q-' | grep -vc "^#### Q-$k\.")
[ -z "$d" ] && [ "$x" = 0 ] && ok q-ids || no q-ids "duplicates '$d', $x not numbered Q-$k.n"
b | grep -q '^Taught: pending' && no taught "Taught: still pending" || ok taught
q=$(b | grep -c '^#### Q-'); r=$(b | grep -c '^- Rubric:'); v=$(b | grep -c '^- Verdict:')
[ "$q" = "$r" ] && [ "$q" = "$v" ] && ok rubric-first || no rubric-first "Q $q, Rubric $r, Verdict $v"
{ [ "$q" -ge 1 ] || b | grep -qE '^- Ended: .*(before any question|dispute only)'; } && ok asked || no asked "0 questions and Ended does not say why"
[ "$q" -le 12 ] && ok max-12 || no max-12 "$q main questions"
x=$(b | grep -E 'Verdict: (partial|wrong)' | grep -vcE '→ TR-[0-9]+'); m=""
for t in $(b | grep -oE '→ TR-[0-9]+' | grep -oE 'TR-[0-9]+' | sort -u); do grep -qE "^\| $t \|" "$F" || m="$m $t"; done
[ "$x" = 0 ] && [ -z "$m" ] && ok misses-recorded || no misses-recorded "$x misses without → TR-n; rows missing:${m:- none}"
sc=$(b | grep -m1 '^- Main questions:'); n(){ printf '%s' "$sc" | grep -oE "$1 [0-9]+" | grep -oE '[0-9]+$'; }
c=$(b | grep -c '^- Verdict: correct'); p=$(b | grep -c '^- Verdict: partial'); w=$(b | grep -c '^- Verdict: wrong')
[ "$(n 'questions:')" = "$q" ] && [ "$(n correct)" = "$c" ] && [ "$(n partial)" = "$p" ] && [ "$(n wrong)" = "$w" ] \
  && ok scorecard || no scorecard "want q $q c $c p $p w $w; got '${sc:-no scorecard}'"
{ [ "$q" = 0 ] || [ "$c" != "$q" ] || b | grep -q '^- re-checked: yes'; } && ok re-checked || no re-checked "all correct: re-check and write it"
today=$(date +%F); yday=$(date -v-1d +%F 2>/dev/null || date -d '-1 day' +%F); max=$(date -v+7d +%F 2>/dev/null || date -d '+7 day' +%F)
hd=$(printf '%s' "$hdr" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)
fut=$(grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' "$F" | sort -u | awk -v m="$max" '$0>m' | xargs)
{ [ "$hd" = "$today" ] || [ "$hd" = "$yday" ]; } && [ -z "$fut" ] && ok dates || no dates "header '$hd' (today $today); after $max: ${fut:-none}"
pii=$(grep -nE '[0-9]{3}-[0-9]{2}-[0-9]{4}|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|\(?[0-9]{3}\)?[ .-][0-9]{3}-[0-9]{4}' "$F" | grep -vE '@example\.(com|org|net)')
[ -z "$pii" ] && ok no-pii-values || no no-pii-values "redact: $pii"
grep -niE 'password|passwd|secret|api[_-]?key|bearer |token|ssn|mrn|date of birth|\bdob\b|patient name' "$F" | sed 's/^/INSPECT /'
exit $bad
EOF
```

## STOP

Next skill. Scope `M<N>` and this milestone's demo is not done (`docs/demo/SCRIPT.md` frontmatter lacks
`status: approved`, or `docs/demo/RECORDING.md` is missing, or `git log -1 --format=%ct -- docs/demo/RECORDING.md`
is older than the same for `docs/milestones/M<N>.md`) → `write-demo-script`. Every other case → the skill named in
`.handoff/TRACKER.md ## Resume` › Next (read-only); TRACKER missing → `write-demo-script`; it names no skill →
`none — milestone loop complete; tell the supervisor`. Send exactly this, filled, and stop:

```
quiz-me session S<k> stopped (<date>).
Wrote: ~/factory-kit-private/<repo>/TOPICS_TO_REVIEW.md, your private study file outside the repo (session S<k>;
  topic rows added <TR ids | none>, updated <TR ids | none>, resolved <TR ids | none>).
  A topic row (TR-<n>) is one weak spot on your spaced-review list; it comes back on its due date.
Repo: <untouched (its fingerprint at the end matches the one taken at the start) | CHANGED during the session, not by me: <git status lines>>
Scope: <M<N> | D<a>,D<b> | review | TR-<a>,TR-<b>> · taught <t> topics · <q> main questions (+<f> follow-ups) · ended: <how>
Score: correct <c> · partial <p> · wrong <w>
  Each answer was graded against its rubric: the 2-4 points I wrote down, before asking, that a full answer needs.
  A hint caps an answer at partial. Follow-up questions are practice: they never change a grade or a due date.
By type: recall <c/p/w> · why <c/p/w> · 10× <c/p/w> · what-if <c/p/w> · diagram <c/p/w | not asked: reason>
Weakest: <TR-n: the gap in one line> (up to 3, 🔴 first)
Review due: <TR-n → date, … | none>
Not yet taught: <D ids / element ids | none>
Journal gaps (facts the decision journal never recorded, so I did not invent them): <D<n>: missing field | none>
Uncovered expectations (assignment interview/defense lines our docs cannot answer yet): <line | none>
Decision doubts you raised (nothing changed; the supervisor, who routes work between skills, decides): <"verbatim" about D<n> | none>
Gate: self-check (phase 16). Nothing is written to the repo for this gate.
Your call:
  Approve: these grades are honest and the topic rows are your study plan (fast; the due dates bring the weak
           spots back).
  Revise: (a) dispute a grade: run quiz-me again with "dispute Q-<k>.<n>: <why>"; I re-check it against the quoted
          source in a new session and leave this record untouched; or (b) another round now: run quiz-me with
          scope TR-<a>,TR-<b> (costs time today; a miss answered again soon fades slower).
  Stop: end here; the due dates stay in the private file.
Recommendation: <Approve | Revise: TR ids> because <plain words, e.g. "2 🔴 rows are about trust boundaries,
  which interviewers probe first">. Default if you say nothing: Stop.
Next: run `<one skill>` | none — milestone loop complete; tell the supervisor. I am not starting it.
```

## Red flags

| Thought you might have | What to do instead |
|---|---|
| "They clearly get it; the wording is just loose. Correct, nice job." | Grade the points, not the vibe. A missing or vague must-have is partial: name the missing piece, no praise. |
| "They nailed the follow-up, so I'll soften the row to 🟡." | The follow-up came after the model answer. It is practice; the main verdict sets status and spacing. |
| "The journal doesn't say why we rejected Y, but I know the usual reason." | Teach the general concept if it helps, but the project reason is `⚠ not recorded` and a journal gap. Ask a recall or walk-through question instead of a why-question. |
| "They pushed back hard; maybe I was too harsh." | Re-read the cited source and quote it. Change the grade only if the source supports them; log the dispute either way. |
| "Their answer shows the decision is wrong; I'll fix the D-row or the HLD." | Never edit the repo. Record a decision doubt verbatim; the supervisor routes it. |
| "I remember `$F` and `k` from the last command; the check can reuse them." | Shell state is gone between commands. Run each block whole; it derives its own state from the files. |
