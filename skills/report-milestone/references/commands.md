# report-milestone: command recipes

Load this file at step 1. Every number in the report comes from one of these recipes. Paste each recipe you used
into its report section as a fenced block: `$ <command>` on the first line, the real output below, trimmed only
with `[... trimmed ...]`, never retyped.

All recipes are read-only, except `make check` (the project's own checks) and `glab` reads (GET only). Never paste
raw lines from `events.jsonl`, `last-message.md` or `stderr.log`: they can hold file contents. Recipes 9 and 10
extract numbers and model ids only.

## How to run a recipe

Recipes are **bash** (3.2+, BSD or GNU tools). Agent shells are often zsh, which aborts on an unmatched glob such as
`T*.md` and splits words differently, and often start fresh on every call, so variables do not carry over. Run each
recipe (and each Done-when check) as a file, with the §0 block first and stdin closed, so nothing inside it (make,
glab) can read the rest of the script:

```bash
f=$(mktemp); cat >"$f" <<'RECIPE'
<the whole §0 block>
<the recipe>
RECIPE
bash "$f" </dev/null
```

## 0. Variables (step 1)

```bash
ARG=                       # the M<N> argument if the human gave one (e.g. ARG=M2), else leave empty
MB_ARG=                    # dispatched only: the task file's milestone_branch:, else leave empty
b=${MB_ARG:-$(git branch --show-current)}
case "$b" in milestone/m[0-9]*-?*) ;; *) echo "STOP: '$b' is not milestone/m<N>-<slug>" >&2; exit 2 ;; esac
N=${b#milestone/m}; N=${N%%-*}; SLUG=${b#milestone/m$N-}
case "$N" in *[!0-9]*) echo "STOP: '$b' has no numeric milestone number" >&2; exit 2 ;; esac
[ -z "$ARG" ] || [ "$ARG" = "M$N" ] || { echo "STOP: asked for $ARG, but the branch is $b" >&2; exit 2; }
M=M$N; MB=$b; S=specs/$M-$SLUG; R=docs/milestones/$M.md; T=.handoff/TRACKER.md
MAIN=main                  # the default branch AGENTS.md "Git" names; else: git symbolic-ref --short refs/remotes/origin/HEAD
BASE=$(git merge-base "$MAIN" "$MB"); HEAD_SHA=$(git rev-parse "$MB")
# rows of one TRACKER section (Tasks | Approvals | Log)
section() { awk -v h="$1" '/^## /{on=($0 ~ "^## " h); next} on' "$T"; }
# one frontmatter value; works for one-key-per-line and for compact "a: 1   b: 2" lines
fmval() { grep -m1 -oE "(^|[[:space:]])$1:[[:space:]]*(\[[^]]*\]|\"[^\"]*\"|[^[:space:]]+)" "$2" 2>/dev/null |
  sed -E "s/^[[:space:]]*$1:[[:space:]]*//; s/^\"//; s/\"\$//"; }
# first-parent commits of the milestone: full sha, short sha, Task trailer (comma-joined), subject
commits() { git log --first-parent --reverse \
  --format='%H%x09%h%x09%(trailers:key=Task,valueonly,separator=%x2C)%x09%s' "$BASE..$MB" "$@"; }
# Approvals rows | time | gate | artifact@sha | exact words |; scoped = artifact sha on $MB but not on $BASE
approvals() { section Approvals | grep -E '^\|' | grep -vE '^\| *(time|:?-{3,}:?) *\|'; }
scoped() { approvals | while IFS= read -r row; do
  sha=$(printf '%s\n' "$row" | awk -F'|' '{print $4}' | grep -oE '@[0-9a-f]{7,40}' | head -n 1 | tr -d @)
  [ -n "$sha" ] && git merge-base --is-ancestor "$sha" "$MB" 2>/dev/null &&
    ! git merge-base --is-ancestor "$sha" "$BASE" 2>/dev/null && printf '%s\n' "$row"; done; }
```

## 1. Preflight (step 2)

```bash
date '+%F %H:%M %Z'
git branch --show-current
[ "$(git rev-parse HEAD)" = "$HEAD_SHA" ] && echo "HEAD is the head of $MB" || echo "STOP: HEAD is not the head of $MB"
git status --porcelain -- . ':!.handoff' ":!$R"          # must print nothing (make check tests committed code only)
grep -E "^\| *$M[ |]" MILESTONES.md                      # the planned row
git rev-list --count "$BASE..$MB"                        # must be > 0
git merge-base --is-ancestor "$MAIN" "$MB" && echo "contains $MAIN" || echo "$MAIN moved since branching: merge result untested"
git rev-parse -q --verify "origin/$MAIN" >/dev/null && { git merge-base --is-ancestor "origin/$MAIN" "$MB" &&
  echo "contains origin/$MAIN (as last fetched)" || echo "origin/$MAIN moved: merge result untested"; }
section Tasks | grep -E "\| *$M-T[0-9]{3} *\|" | grep -E '\| *(todo|working|input-required) *\|'   # in flight: must print nothing
```

## 2. Delivered vs planned (§1, step 4)

```bash
for f in "$S"/tasks/T*.md; do printf '%s\t%s\t%s\n' "$(fmval id "$f")" "$(fmval covers "$f")" "$f"; done   # planned
ls "$S"/tasks/T*.md | wc -l | tr -d ' '                                       # planned count
commits | cut -f2-                                                             # what landed, oldest first
commits | awk -F'\t' '$3 != ""' | wc -l | tr -d ' '                           # commits with a Task trailer
commits | awk -F'\t' '$3 == ""' | cut -f2,4                                   # unplanned commits (fix-bug, syncs, strays)
for f in "$S"/tasks/T*.md; do id=$(fmval id "$f"); r=.handoff/runs/$id/result.md
  c=$(commits | awk -F'\t' -v id="$id" 'index("," $3 ",", "," id ",") {printf "%s ", $2}')
  printf '%s\tcommits=%s\tresult=%s\n' "$id" "${c:-none}" "$([ -f "$r" ] && fmval status "$r" || echo missing)"
done                                                                           # one line per planned task (result = worker claim)
```

## 3. Requirements coverage (§2)

```bash
for f in "$S"/tasks/T*.md; do fmval covers "$f"; done | grep -oE '(N?FR|AE)-[0-9]+' | sort -u   # ids the tasks claim
comm -13 <(for f in "$S"/tasks/T*.md; do fmval covers "$f"; done | grep -oE 'AE-[0-9]+' | sort -u) \
         <(grep -oE 'AE-[0-9]+' "$S/acceptance.md" | sort -u)                 # AEs no task covers: must print nothing
grep -m1 -w "FR-001" docs/product/prd.md                                       # title of one FR (repeat per id)
```

## 4. Verification (§4, step 3)

```bash
git rev-parse --short HEAD; git branch --show-current
out=$(mktemp); make check >"$out" 2>&1; rc=$?; tail -n 40 "$out"; echo "exit $rc"
# non-zero exit only: each covered AE's acceptance tests (acceptance.md AT rows), as they appear in the full output
[ "$rc" -eq 0 ] || for ae in $(for f in "$S"/tasks/T*.md; do fmval covers "$f"; done | grep -oE 'AE-[0-9]+' | sort -u); do
  grep -E '^\| *AT-[0-9]+ *\|' "$S/acceptance.md" | grep -w -- "$ae" | grep -oE 'test_[A-Za-z0-9_]+' | sort -u |
    while read -r t; do printf '%s %s: ' "$ae" "$t"; grep -m1 -F -- "$t" "$out" || echo "not in output"; done
done
# scope-guard per squash commit: Owns is read from the task file as committed just before that commit
commits | awk -F'\t' '$3 != "" {print $1, $2, $3}' | while read -r sha short ids; do
  id=${ids%%,*}; f=$(grep -lE "(^|[[:space:]])id:[[:space:]]*$id([[:space:]]|\$)" "$S"/tasks/T*.md | head -n 1)
  o=$(bash scripts/scope-guard.sh "${f:-missing-task-file}" "$sha^" "$sha" 2>&1); echo "$short $id exit=$?"
  printf '%s\n' "$o" | sed 's/^/    /'
done                                                                           # every exit must be 0
commits -- tests/acceptance/ | awk -F'\t' '$3 != ""' | cut -f2,3,4            # implementer commits touching acceptance tests: must print nothing
# diagrams: changed design docs, plus every doc that embeds a changed .mmd
mmd=$(git diff --name-only "$BASE..$MB" -- 'docs/architecture/diagrams/*.mmd'); echo "changed diagram sources: ${mmd:-none}"
docs=$( { git diff --name-only --diff-filter=d "$BASE..$MB" -- docs/architecture/hld.md docs/architecture/lld.md
  for p in $mmd; do grep -rlF --include='*.md' --exclude-dir=milestones -- "<!-- diagram: $(basename "$p" .mmd) -->" docs; done; } | sort -u)
[ -z "$docs" ] && echo "no design doc or embedded diagram changed" || { bash scripts/embed-diagrams.sh --check $docs; echo "exit $?"; }
```

## 5. Decisions and plan drift (§3, §5)

```bash
git diff "$BASE..$MB" -- docs/decisions/DECISION_JOURNAL.md | grep -E '^\+### D[0-9]+'   # D-rows added or re-statused here
git diff "$BASE..$MB" -- docs/decisions/DECISION_JOURNAL.md | grep -cE '^\+### D[0-9]+'  # their count
git diff --name-only --diff-filter=A "$BASE..$MB" -- docs/decisions/ | grep -E '/[0-9]{4}-'   # new one-way ADR files
# §5: the sha G4 approved (MILESTONES "gate SHAs", else the G4 Approvals row naming this milestone), then task-file edits after it
g4=$(grep -E "^\| *$M[ |]" MILESTONES.md | grep -oE 'G4@[0-9a-f]{7,40}' | tail -n 1 | cut -d@ -f2)
[ -n "$g4" ] || g4=$(approvals | awk -F'|' -v m="$M-" '$3 ~ /^ *G4 *$/ && index($4, m)' | grep -oE '@[0-9a-f]{7,40}' | tail -n 1 | tr -d @)
echo "G4-approved sha: ${g4:-⚠ none recorded}"
[ -n "$g4" ] && git log --format='%h %s' "$g4..$MB" -- "$S/tasks/"            # task files edited after approval: each is a DV row
```

## 6. Gate answers in this milestone (§6, §8, §10)

An Approvals row belongs to this milestone when its `artifact@sha` commit is on `$MB` but not on `$BASE` (`scoped`, §0).

```bash
scoped                                                                         # paste: every gate answer of this milestone
echo "gate answers: $(scoped | wc -l | tr -d ' ')"
echo "gate Revise answers: $(scoped | awk -F'|' 'tolower($5) ~ /revise/' | wc -l | tr -d ' ')"
echo "gate answers per gate: $(scoped | awk -F'|' '{g=$3; gsub(/ /, "", g); c[g]++} END {for (k in c) printf "%s=%d ", k, c[k]}')"
approvals | while IFS= read -r row; do sha=$(printf '%s\n' "$row" | awk -F'|' '{print $4}' | grep -oE '@[0-9a-f]{7,40}' | tr -d @)
  { [ -n "$sha" ] && git cat-file -e "$sha^{commit}" 2>/dev/null; } || printf '%s\n' "$row"; done   # rows with no resolvable sha: Not verified
```

## 7. Verifier rows (§6)

```bash
ls .handoff/reviews/$M-pass*.md
grep -HoE 'Reviewer: [^·|]*' .handoff/reviews/$M-pass*.md                     # who reviewed, per pass
for p in .handoff/reviews/$M-pass*.md; do printf '%s self-reports quoted to the verifier: ' "$p"
  awk '/^## Not reviewed/{on=1; next} /^## /{on=0} on' "$p" | grep -iE 'self-report|result\.md|runs/|last-message' || echo "none quoted"; done
grep -HE '^\| *R[0-9]+ *\|' .handoff/reviews/$M-pass*.md | awk -F'|' '{print $1 $2 "|" $3 "|" $4 "|" $(NF-1)}' | cut -c1-160
grep -cE '^\| *R[0-9]+ *\|' .handoff/reviews/$M-pass*.md                     # rows per pass
grep -hE '^\| *R[0-9]+ *\|' .handoff/reviews/$M-pass*.md | grep -cE '\| *P[01] *\|'   # P0/P1 rows
scoped | grep -E 'R[0-9]+'                                                     # the human's recorded dispositions, verbatim
for p in .handoff/reviews/$M-pass*.md; do rc=$(git log -1 --format=%H -- "$p")
  [ -n "$rc" ] && { echo "commits after $p (where its fix rows landed):"; git log --first-parent --format='  %h %s' "$rc..$MB"; } ||
    echo "$p not committed"; done
```

## 8. Security (§7)

check-security records acceptance in its Findings table as `accepted (D<n>)` and prints a G5 condition line. The awk
is its own Done-when count (Findings columns: ID, Source, Severity, Finding, Evidence, Reachable, Recommend,
Disposition, State).

```bash
C=docs/security/CHECKLIST.md
if [ ! -f "$C" ]; then echo "$C missing: ⚠ pending check-security"; else
cs=$(git log -1 --format=%H -- "$C"); git log -1 --format='%h %cI' -- "$C"
[ -n "$cs" ] && git diff --name-only "$cs..$MB" -- . ':!docs' ':!.handoff' ':!specs' || echo "CHECKLIST.md not committed"   # code changed after the checklist: must print nothing
grep -E '^- \*\*(G5 security condition|Accepted risks):\*\*' "$C"
awk -F'|' '$2 ~ /^ *(CK|LLM)-[0-9]+ *$/ {s=$5; gsub(/ /,"",s); r[s]++} $2 ~ /^ *SEC-[0-9]+ *$/ && $10 ~ /open/ {v=$4; gsub(/ /,"",v); n[v]++; if ($3 ~ /secret/) k++; if ((v=="critical" || v=="high") && $9 !~ /D[0-9]+/) u++} END{printf "pass=%d fail=%d na=%d critical=%d high=%d medium=%d low=%d secrets=%d unaccepted_high_critical=%d\n", r["pass"], r["fail"], r["n.a."], n["critical"], n["high"], n["medium"], n["low"], k, u}' "$C"
awk -F'|' '$2 ~ /^ *SEC-[0-9]+ *$/ && $10 ~ /open/ {v=$4; gsub(/ /,"",v); if (((v=="critical" || v=="high") && $9 !~ /D[0-9]+/) || $3 ~ /secret/) print "unaccepted:" $2 "|" v "|" $9}' "$C"   # each one by id
fi
command -v gitleaks >/dev/null && { gitleaks git --log-opts="$BASE..$MB" --redact --no-banner; echo "exit $?"; } || echo "gitleaks NOT INSTALLED"
```

`gitleaks` older than 8.19 uses `gitleaks detect --log-opts=...`. Never install it here.

## 9. Factory metrics (§8)

First-pass = dispatched exactly once; no FAIL or ESCALATE line; no `human_review` or `relaunch` in its Log lines or
its `## Tasks` row; the last delegate `RESULT` line shows `status=done`, `timeout=no` and `tree=clean`; and a squash
commit landed. A RESULT line without those fields (for example a supervisor-written line for an in-session
subagent) is `unknown` and counts as not first-pass. The rate is over dispatched tasks; tasks never dispatched are
listed, not counted. Rates round **down** (shell integer division); never round up.

```bash
n=0; fp=0; unk=0; loops=0; nd=""
for f in "$S"/tasks/T*.md; do id=$(fmval id "$f")
  lg=$(section Log | grep -E "[[:space:]](ROUTE|DISPATCH|RESULT|VERIFY|FAIL|ESCALATE)[[:space:]]+$id([[:space:]]|\$)")   # events about this task
  d=$(printf '%s\n' "$lg" | grep -cE "[[:space:]]DISPATCH[[:space:]]+$id([[:space:]]|\$)")
  a=$(ls -d ".handoff/runs/$id.attempt-"* 2>/dev/null | wc -l | tr -d ' ')
  [ "$a" -gt 0 ] && [ "$d" -lt $((a + 1)) ] && d=$((a + 1))      # an archived attempt is a dispatch even unlogged
  if [ "$d" -eq 0 ]; then nd="$nd $id"; echo "$id dispatches=0: not dispatched, outside the rate"; continue; fi
  bad=$(printf '%s\n' "$lg" | grep -cE "[[:space:]](FAIL|ESCALATE)[[:space:]]+$id([[:space:]]|\$)")
  hr=$( { printf '%s\n' "$lg"; section Tasks | grep -E "^\| *$id *\|"; } | grep -ciE 'human_review|relaunch')
  rl=$(printf '%s\n' "$lg" | grep -E "[[:space:]]RESULT[[:space:]]+$id([[:space:]]|\$)" | tail -n 1)
  st=$(printf '%s\n' "$rl" | grep -oE 'status=[a-z_]+' | cut -d= -f2)
  to=$(printf '%s\n' "$rl" | grep -oE 'timeout=[a-z]+' | cut -d= -f2)
  tree=$(printf '%s\n' "$rl" | grep -oE 'tree=[a-z]+' | cut -d= -f2)
  c=$(commits | awk -F'\t' -v id="$id" 'index("," $3 ",", "," id ",")' | wc -l | tr -d ' ')
  if [ "$d" -ne 1 ] || [ "$bad" -ne 0 ] || [ "$hr" -ne 0 ] || [ "$c" -eq 0 ] ||
     { [ -n "$st" ] && [ "$st" != done ]; } || [ "$to" = yes ] || [ "$tree" = dirty ]; then ok=0
  elif [ "$st" = done ] && [ "$to" = no ] && [ "$tree" = clean ]; then ok=1; fp=$((fp + 1))
  else ok=unknown; unk=$((unk + 1)); fi                          # RESULT line missing or without the fields: not proof
  n=$((n + 1)); [ "$d" -gt 1 ] && loops=$((loops + d - 1))
  echo "$id dispatches=$d fail_or_escalate=$bad human_review_or_relaunch=$hr last_result=\"status=${st:-?} timeout=${to:-?} tree=${tree:-?}\" squash_commits=$c first_pass=$ok"
done
[ "$n" -gt 0 ] && echo "first-pass acceptance: $fp/$n dispatched = $((100 * fp / n))% (rounded down; $unk unknown counted as not first-pass) · fix loops (re-dispatches): $loops" ||
  echo "first-pass acceptance: n/a, no task was dispatched"
echo "not dispatched:${nd:- none}"
echo "scope-guard blocks logged: $(section Log | grep -E "[[:space:]]FAIL[[:space:]]+$M-T[0-9]{3}" | grep -ci 'scope-guard')"
echo "verifier passes: $(ls .handoff/reviews/$M-pass*.md 2>/dev/null | wc -l | tr -d ' ')"
```

Gate Revise count: recipe 6. Rework after merge: measured at the next milestone, `n/a` here.

## 10. Cost, usage, harness, model, checker (§9, §10)

Claude workers write stream-json (`"type":"result"` carries `total_cost_usd`, an API-equivalent figure that a Max
subscription does not bill). Codex `exec --json` writes `turn.completed` events with token usage only (seat, not
metered per run). Agent-tool subagents and the interactive supervisor leave no `events.jsonl`; recipe 10b measures them from the
harness logs instead. Anything neither covers is `not measured: <why>`, never an estimate.

**Recipe 10b: whole-milestone usage, human touches, wall-clock.** The window is the first to the last TRACKER Log
line of the milestone (the Log's dates carry their timezone from `date`).

```bash
first=$(section Log | grep -E "[[:space:]]$M-T" | head -n 1 | cut -c1-25)
last=$(section Log | grep -E "[[:space:]]$M-T" | tail -n 1 | cut -c1-25)
bash "${FACTORY_KIT_DIR:-$HOME/Desktop/gauntlet_workbench/software-factory-kit}/scripts/measure-usage.sh" . "$first" "$last"
```

```bash
for d in .handoff/runs/$M-T*/; do e=${d}events.jsonl
  if [ ! -f "$e" ]; then echo "$d no events.jsonl: not measured"
  elif grep -q '"type":"result"' "$e"; then printf '%s claude ' "$d"; grep '"type":"result"' "$e" | tail -n 1 |
    grep -oE '"(total_cost_usd|input_tokens|cache_read_input_tokens|cache_creation_input_tokens|output_tokens|num_turns|duration_ms)":[0-9.]+' | tr '\n' ' '; echo
  elif grep -q '"type":"turn.completed"' "$e"; then printf '%s codex ' "$d"; grep '"type":"turn.completed"' "$e" |
    grep -oE '"[a-z_]*tokens":[0-9]+' | awk -F: '{s[$1]+=$2} END {for (k in s) printf "%s:%d ", k, s[k]; print ""}'
  else echo "$d no usage event: not measured"; fi
done                                                                           # one line per run dir, archived attempts included
cat .handoff/runs/$M-T*/events.jsonl 2>/dev/null | grep '"type":"result"' | grep -oE '"total_cost_usd":[0-9.]+' |
  awk -F: '{s += $2} END {printf "claude API-equivalent cost: $%.4f over %d runs\n", s, NR}'
for d in .handoff/runs/$M-T*/; do printf '%s | %s | result.md model: %s | events model: %s\n' "$(basename "$d")" \
  "$(grep -m1 '^# harness:' "${d}cmd.txt" 2>/dev/null | cut -c12-90)" "$(fmval model "${d}result.md")" \
  "$(grep -m1 -oE '"model":"[^"]+"' "${d}events.jsonl" 2>/dev/null)"; done   # harness + model per run
for f in "$S"/tasks/T*.md; do id=$(fmval id "$f")
  v=$(section Log | grep -E "[[:space:]]VERIFY[[:space:]]+$id([[:space:]]|\$)" | tail -n 1 | cut -c1-200)
  echo "$id checked by: ${v:-⚠ no VERIFY line}"; done                        # §10 "Checked by"
```

## 11. Rollback (§12)

```bash
j=$(glab mr view "$MB" -F json 2>/dev/null) && printf '%s\n' "$j" | grep -oE '"(iid|draft|squash|web_url)":("[^"]*"|[a-z0-9]+)' |
  sort -u || echo "glab: no MR for $MB, or not authenticated"
glab api "projects/:fullpath" 2>/dev/null | grep -oE '"merge_method":"[a-z_]+"' || echo "merge method: not checked"
echo "merges inside the branch (syncs from main; information only): $(git rev-list --count --merges "$BASE..$MB")"
git diff --name-status "$BASE..$MB" | grep -iE 'migrat|schema|seed|\.env|config/' || echo none   # what a code revert does not undo by itself
```

`merge_method` `merge` or `rebase_merge` (semi-linear) creates a merge commit: one `git revert -m 1` undoes the
milestone. `ff` creates none: rollback is not one revert, so G5 clause 4 is **no** until the human changes the
project setting. Why `-m 1` works even when the branch merged main into itself: the milestone's merge commit has
two parents, main as it was (parent 1) and the branch (parent 2); `-m 1` reverts exactly the difference between
parent 1 and the merge, which is the milestone's own work, because anything synced from main is already in
parent 1. The rollback command, runnable after the merge (GitLab's merge commit names the source branch):

```bash
m=$(git log "$MAIN" --first-parent --merges -1 --format=%H --grep="$MB"); [ -n "$m" ] && git revert -m 1 "$m" || echo "no merge of $MB on $MAIN yet"
```

Write it into §12 with `$MAIN` and `$MB` spelled out. You never run it; before the merge it only prints the
`no merge` line.

## 12. Report tallies (§13, header, STOP; step 13)

Counts from the report itself, so every headline number has a command. Run it once §1-§12 are written, answer the
§13 clauses, then run it again and paste that second run in §13 (its last line counts your yes answers). A line
that prints nothing or `⚠ pending` means the section it reads is not filled.

```bash
sec() { awk -v s="$1" '/^```/{f=!f} !f && /^## /{on=($0 ~ "^## " s "\\. ")} on' "$R"; }   # one numbered section
rows() { sec "$1" | awk -F'|' -v k="$2" -v c="$3" -v re="$4" '$2 ~ k { x = $c; if (x ~ re) n++ } END { print n + 0 }'; }
echo "planned=$(rows 1 '^ *M[0-9]+-T[0-9]+ *$' 2 .) delivered=$(rows 1 '^ *M[0-9]+-T[0-9]+ *$' 3 '^ *delivered *$') partial=$(rows 1 '^ *M[0-9]+-T[0-9]+ *$' 3 partial) cut=$(rows 1 '^ *M[0-9]+-T[0-9]+ *$' 3 '^ *cut') missing=$(rows 1 '^ *M[0-9]+-T[0-9]+ *$' 3 missing)"
echo "unplanned_commits=$(rows 1 '^ *`[0-9a-f]+` *$' 2 .)"
sec 4 | grep -E '^exit [0-9]+$' | head -n 1 | sed 's/^/make check /'
echo "proposed_d_rows=$(rows 3 '^ *D[0-9]+ *$' 4 proposed)"
echo "deviations=$(rows 5 '^ *DV-[0-9]+ *$' 2 .) undecided_deviations=$(sec 5 | awk -F'|' '$2 ~ /^ *DV-[0-9]+ *$/ && ($5 ~ /why not recorded/ || $6 ~ /needs log-decision/)' | wc -l | tr -d ' ')"
echo "review_rows=$(rows 6 '^ *(p[0-9]+-)?R[0-9]+ *$' 2 .) recorded_dispositions=$(sec 6 | awk -F'|' '$2 ~ /^ *(p[0-9]+-)?R[0-9]+ *$/ && $6 ~ /Approvals/ && $6 !~ /pending/' | wc -l | tr -d ' ')"
echo "open_p0_p1=$(sec 6 | awk -F'|' '$2 ~ /^ *(p[0-9]+-)?R[0-9]+ *$/ && $4 ~ /P[01]/ && ($6 !~ /Approvals/ || $6 ~ /pending/ || ($6 ~ /fix/ && $7 !~ /[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]/))' | wc -l | tr -d ' ')"
x=$(sec 7 | grep -oE '(secrets|unaccepted_high_critical)=[0-9]+' | tail -n 2 | tr '\n' ' '); echo "security: ${x:-⚠ pending (no check-security count pasted in §7)}"
echo "pending_markers=$(for s in 4 6 7; do sec "$s"; done | grep -c '⚠ pending')"
sec 8 | grep -E '^(first-pass acceptance|not dispatched|scope-guard blocks logged|gate Revise answers|gate answers):'
echo "not_verified_items=$(sec 11 | grep -cE '^- ')"; sec 11 | grep -m1 -E '^- ' | cut -c1-160 | sed 's/^- /riskiest: /'
echo "g5_clauses_yes=$(sec 13 | grep -cE '^\| *(Evidence pasted|Dispositions done|Nothing graded its own work|One-revert rollback) *\| *yes *\|')/4"
```

`open_p0_p1` counts a P0/P1 row whose disposition is not a recorded human answer, or is `fix` with no commit sha
in Where handled. `undecided_deviations` counts DV rows still `⚠ why not recorded` or `⚠ needs log-decision`.
