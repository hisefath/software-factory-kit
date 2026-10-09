# slice-tasks analyze pass

A read-only consistency check across the PRD milestone row, `acceptance.md`, every task file and `MILESTONES.md`.
It writes nothing. Run it from the project root after writing the task files and after every revision:

```
awk '/^```sh$/{f=1;next} /^```$/{f=0} f' <this skill's dir>/references/analyze.md | sh -s -- specs/M<N>-<slug>
```

It exits 0 and prints `RESULT: PASS` only when every check holds. Paste its plan table, coverage matrix and
`Analyze:` line verbatim into the STOP message; never retype or round them.

**Scope** = the FR/AE ids in the PRD `## Milestone cut` row for `M<N>` (its Scope and Proves cells) plus the ids in
the Covers column of `acceptance.md ## Traceability`. Nothing else in `acceptance.md` counts: its
`Out of scope this milestone:` line names later milestones' FRs.

## What it checks

| Check | Fails when |
|---|---|
| Scope | no FR/AE ids in the PRD row's Scope/Proves cells or the Traceability Covers column |
| Frontmatter | keys are not exactly `id milestone skill covers after harness mode hitl parallel budget`, in that order; `id` ≠ `M<N>-T###` of the file name; `skill` ≠ `implement-task`; `harness` ∉ {claude, codex}; `mode` ≠ `workspace-write`; `hitl`/`parallel` not true/false; budget not `<n> run(s), <m> min` or `m` > 120 |
| Covers | empty, no in-scope FR/AE, or an id outside this milestone's scope (NFR ids that exist in the PRD are allowed extras) |
| Coverage | an in-scope FR/AE is covered by no task |
| Owns | not exactly one `Owns:` line before `## Ask`; an empty entry or one containing a space; any glob that matches `tests/acceptance/**`, `specs/**`, `docs/**`, `.handoff/**`, `.claude/**`, `.githooks/**`, `AGENTS.md`, `CLAUDE.md`, `MILESTONES.md` or `scripts/scope-guard.sh`; any entry that is or covers a dependency manifest or lockfile (implementers never install) |
| Parallel | two `parallel: true` tasks own overlapping globs (conservative: literal prefixes nest) |
| Order | an `after:` id has no task file; a cycle; more than one task in wave 1, or wave 1 is not `T001`; `T001` covers no AE |
| Harness | a `codex` task with `hitl: true` or `parallel: false` |
| Sections | `## ` headings are not exactly Ask, Done-when, Must not change, Consumes / Produces, Context manifest, Return; the first line under `## Ask` is not a title of at most 6 words (delegate.sh and implement-task turn it into the branch name); Done-when lacks `make check`; Return lacks `runs/<id>/result.md`; a `- Consumes:` line names a task id missing from `after:` |
| Leftovers | `{{` or `<!-- guide:` remains; a fenced code block other than `sh`/`bash` (no code in task files) |
| Size | more than 10 task files |
| Milestones | `MILESTONES.md` has no row starting with `\| M<N>`, more than one, or its cell count differs from its table header's |

Warnings (printed, do not fail; each one becomes a `⚠` in the STOP message): an in-scope id with no
`tests/acceptance/**` path in any Traceability row that covers it (define-acceptance gap); a task marked
`⚠ BLOCKED` (not dispatchable until its question is resolved and G4 re-approved).

Glob semantics match `scripts/scope-guard.sh`: shell `case` patterns, where `*` also crosses `/`, so
`app/*` covers every file under `app/`.

```sh
set -u
D=${1:?usage: sh -s -- specs/M<N>-<slug> [prd path]}; D=${D%/}; P=${2:-docs/product/prd.md}
T=$D/tasks; A=$D/acceptance.md
N=$(basename "$D" | sed -n 's/^M\([0-9][0-9]*\)-.*/\1/p')
[ -n "$N" ] || { echo "FAIL: $D is not specs/M<N>-<slug>"; exit 2; }
fail=0; bad() { echo "FAIL: $*"; fail=1; }
idsof() { grep -oE '(^|[^N])(FR|AE)-[0-9]{3}' | grep -oE '(FR|AE)-[0-9]{3}' | sort -u; }
fm() { awk -v k="$2" 'NR==1{next} $0=="---"{exit} index($0,k":")==1{sub(/^[^:]*:[ \t]*/,"");print;exit}' "$1"; }
lst() { tr -d '[],' | tr ' \t' '\n\n' | sed '/^$/d'; }
sec() { awk -v h="## $2" 'index($0,h)==1{f=1;next} /^## /{f=0} f' "$1"; }
trace() { awk -F'|' '/^## Traceability/{f=1;next} /^## /{f=0} f && $2 ~ /AT-[0-9]/' "$A" 2>/dev/null; }
ats() { trace | awk -F'|' -v i="$1" '{ n=split($3, c, /[^A-Za-z0-9-]+/)
  for (k=1; k<=n; k++) if (c[k]==i) { a=$2; gsub(/[ \t]/,"",a); l=$7; gsub(/^[ \t]+|[ \t]+$/,"",l)
    t=$8; gsub(/[` \t]/,"",t); sub(/::.*/,"",t); print a " (" l ") " t; break } }' | sort -u; }
hasglob() { case $1 in *[][*?]*) return 0;; esac; return 1; }
pre() { printf '%s' "$1" | sed 's/[][*?].*//'; }
overlap() {
  if ! hasglob "$1" && ! hasglob "$2"; then [ "$1" = "$2" ]; return; fi
  if ! hasglob "$1"; then case $1 in $2) return 0;; esac; return 1; fi
  if ! hasglob "$2"; then case $2 in $1) return 0;; esac; return 1; fi
  a=$(pre "$1"); b=$(pre "$2")
  case $a in "$b"*) return 0;; esac; case $b in "$a"*) return 0;; esac; return 1
}
DEPS="composer.json composer.lock package.json package-lock.json npm-shrinkwrap.json yarn.lock pnpm-lock.yaml bun.lockb Gemfile Gemfile.lock go.mod go.sum requirements.txt pyproject.toml poetry.lock uv.lock Pipfile Pipfile.lock Cargo.toml Cargo.lock mix.exs mix.lock"
files=$(ls "$T"/T[0-9][0-9][0-9].md 2>/dev/null)
[ -n "$files" ] || { echo "FAIL: no task files in $T"; exit 1; }
set -f
scope=$( { grep -E "^\| M$N( |\|)" "$P" 2>/dev/null | awk -F'|' '{print $4; print $5}'; trace | awk -F'|' '{print $3}'; } | idsof)
[ -n "$scope" ] || bad "no FR/AE ids for M$N in the Milestone cut row of $P or the Traceability Covers of $A"
k=0; pc=0; cc=0; xc=0; hc=0; bm=0; ec=0; ua=0; ao=0; ov=0; bl=0
all=""; edges=""; cov=""; par=""
for f in $files; do all="$all $(basename "$f" .md)"; done
for f in $files; do
  t=$(basename "$f" .md); id="M$N-$t"; k=$((k+1))
  keys=$(awk 'NR==1{next} $0=="---"{exit} {sub(/:.*/,"");print}' "$f" | tr '\n' ' ')
  [ "$keys" = "id milestone skill covers after harness mode hitl parallel budget " ] || bad "$t: frontmatter keys: $keys"
  [ "$(fm "$f" id)" = "$id" ] || bad "$t: id must be $id"
  [ "$(fm "$f" milestone)" = "M$N" ] || bad "$t: milestone must be M$N"
  [ "$(fm "$f" skill)" = implement-task ] || bad "$t: skill must be implement-task"
  [ "$(fm "$f" mode)" = workspace-write ] || bad "$t: mode must be workspace-write"
  h=$(fm "$f" harness); hi=$(fm "$f" hitl); pa=$(fm "$f" parallel); bu=$(fm "$f" budget)
  case $h in claude) cc=$((cc+1));; codex) xc=$((xc+1));; *) bad "$t: harness '$h' not claude|codex";; esac
  case $hi in true) hc=$((hc+1));; false) ;; *) bad "$t: hitl must be true|false";; esac
  case $pa in true) pc=$((pc+1));; false) ;; *) bad "$t: parallel must be true|false";; esac
  m=$(printf '%s' "$bu" | sed -n 's/^[0-9][0-9]* runs\{0,1\}, \([0-9][0-9]*\) min$/\1/p')
  if [ -z "$m" ]; then bad "$t: budget '$bu' not '<n> run(s), <m> min'"; else
    bm=$((bm+m)); [ "$m" -le 120 ] || bad "$t: budget $m min > 120 (split the task)"; fi
  covers=$(fm "$f" covers | lst); n_in=0
  [ -n "$covers" ] || { bad "$t: covers is empty"; ec=$((ec+1)); }
  for c in $covers; do
    if printf '%s\n' "$scope" | grep -qx "$c"; then n_in=$((n_in+1)); cov="$cov
$c $t"
    elif printf '%s' "$c" | grep -qE '^NFR-[0-9]{3}$' && grep -q "$c" "$P" 2>/dev/null; then :
    else bad "$t: covers $c, not in M$N scope"; fi
  done
  [ -z "$covers" ] || [ "$n_in" -gt 0 ] || { bad "$t: covers no in-scope FR/AE"; ec=$((ec+1)); }
  after=$(fm "$f" after | lst | sed 's/^M[0-9]*-//')
  for a in $after; do case " $all " in *" $a "*) ;; *) bad "$t: after $a has no task file"; ua=$((ua+1));; esac; done
  edges="$edges
$t $(printf '%s ' $after)"
  [ "$(grep -c '^Owns:' "$f")" = 1 ] || bad "$t: needs exactly one Owns: line"
  ol=$(grep -n '^Owns:' "$f" | head -1 | cut -d: -f1); al=$(grep -n '^## Ask' "$f" | head -1 | cut -d: -f1)
  [ -n "$ol" ] && [ -n "$al" ] && [ "$ol" -lt "$al" ] || bad "$t: Owns: must come before ## Ask"
  owns=$(sed -n 's/^Owns:[[:space:]]*//p' "$f")
  printf '%s\n' "$owns" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -qE '^$| ' && bad "$t: Owns has an empty entry or a space"
  for p in $(printf '%s' "$owns" | tr ',' ' '); do
    for z in tests/acceptance/x specs/x docs/x .handoff/x .claude/x .githooks/x AGENTS.md CLAUDE.md MILESTONES.md scripts/scope-guard.sh; do
      case $z in $p) bad "$t: Owns '$p' covers forbidden path $z"; case $z in tests/acceptance/*) ao=$((ao+1));; esac;; esac
    done
    for z in $DEPS; do
      case $z in $p) bad "$t: Owns '$p' covers dependency file $z (implementers never install: make the package an Ask-first ⚠ for G4)"; break;; esac
      [ "${p##*/}" != "$z" ] || { bad "$t: Owns '$p' is a dependency file (implementers never install: make the package an Ask-first ⚠ for G4)"; break; }
    done
    [ "$pa" = true ] && par="$par
$t $p"
  done
  [ "$h" != codex ] || { [ "$hi" = false ] && [ "$pa" = true ]; } || bad "$t: codex tasks must be hitl: false and parallel: true"
  hd=$(grep -E '^## ' "$f" | sed 's/[[:space:]]*$//' | tr '\n' '|')
  [ "$hd" = "## Ask|## Done-when|## Must not change|## Consumes / Produces|## Context manifest|## Return|" ] || bad "$t: section headings: $hd"
  ti=$(sec "$f" Ask | awk 'NF{print;exit}'); tw=$(printf '%s\n' "$ti" | wc -w | tr -d ' ')
  case $ti in ''|-*|'<'*|'⚠'*) bad "$t: first line under ## Ask must be a short title, not '$ti' (it becomes the branch name)";;
    *) [ "$tw" -le 6 ] || bad "$t: Ask title has $tw words, at most 6 (it becomes the branch name)";; esac
  sec "$f" Done-when | grep -q 'make check' || bad "$t: Done-when must end with make check"
  sec "$f" Return | grep -q "runs/$id/result.md" || bad "$t: Return must name \$HANDOFF_DIR/runs/$id/result.md"
  for u in $(sec "$f" 'Consumes / Produces' | grep -E '^- Consumes' | grep -oE 'M[0-9]+-T[0-9]{3}' | sed 's/^M[0-9]*-//'); do
    printf '%s\n' "$after" | grep -qx "$u" || bad "$t: consumes from $u but after: lacks it"
  done
  grep -nE '\{\{|<!-- guide:' "$f" >/dev/null && bad "$t: unfilled {{placeholder}} or guide comment"
  grep -nE '^```[A-Za-z]' "$f" | grep -vqE ':```(sh|bash)$' && bad "$t: code fence other than sh (no code in task files)"
  if grep -q '⚠ BLOCKED' "$f"; then bl=$((bl+1))
    echo "WARN: $id is BLOCKED, not dispatchable: $(grep -m1 '⚠ BLOCKED' "$f" | sed 's/^[-[:space:]]*//')"; fi
done
[ "$k" -le 10 ] || bad "$k tasks > 10 for one milestone (split the milestone in the PRD via clarify-spec)"
waves=$(printf '%s\n' "$edges" | sed '/^$/d' | awk '
{ id[NR]=$1; n=NR; d[$1]=""; for(i=2;i<=NF;i++) d[$1]=d[$1] " " $i }
END { left=n
  for (w=1; w<=n && left>0; w++) for (i=1;i<=n;i++) { t=id[i]; if (t in lv) continue
    ok=1; m=split(d[t], ds, " "); for (j=1;j<=m;j++) if (!(ds[j] in lv) || lv[ds[j]]==w) { ok=0; break }
    if (ok) { lv[t]=w; left-- } }
  for (i=1;i<=n;i++) print id[i], ((id[i] in lv) ? lv[id[i]] : "CYCLE") }')
cy=$(printf '%s\n' "$waves" | grep -c ' CYCLE$'); [ "$cy" = 0 ] || bad "after: cycle or unknown dep: $(printf '%s\n' "$waves" | grep ' CYCLE$' | cut -d' ' -f1 | tr '\n' ' ')"
w1=$(printf '%s\n' "$waves" | awk '$2==1{print $1}' | tr '\n' ' ')
[ "$w1" = "T001 " ] || bad "wave 1 must be the tracer bullet T001 alone (got: $w1)"
[ -f "$T/T001.md" ] && { fm "$T/T001.md" covers | lst | grep -q '^AE-' || bad "T001 (tracer bullet) covers no AE"; }
pl=$(printf '%s\n' "$par" | sed '/^$/d')
if [ -n "$pl" ]; then
  ovl=$(printf '%s\n' "$pl" | { i=0; while read -r t1 g1; do i=$((i+1))
    printf '%s\n' "$pl" | { j=0; while read -r t2 g2; do j=$((j+1))
      [ "$j" -gt "$i" ] && [ "$t1" != "$t2" ] && overlap "$g1" "$g2" && echo "OVERLAP: M$N-$t1 '$g1' x M$N-$t2 '$g2'"
    done; }; done; })
  [ -z "$ovl" ] || { printf '%s\n' "$ovl"; ov=$(printf '%s\n' "$ovl" | grep -c .)
    bad "$ov parallel Owns overlap(s): make one task after: the other, or move the shared file into a seam task"; }
fi
mr=$(grep -cE "^\| M$N( |\|)" MILESTONES.md 2>/dev/null); [ "$mr" = 1 ] || bad "MILESTONES.md needs exactly one | M$N row (found ${mr:-0})"
if [ "$mr" = 1 ]; then
  mc=$(awk -F'|' -v r="^[|] M$N( |[|])" '/^[|][-:| \t]+[|][ \t]*$/ {h=p} {p=NF} $0 ~ r {print h+0, NF; exit}' MILESTONES.md)
  hn=${mc% *}; rn=${mc#* }
  [ "$hn" -gt 2 ] && [ "$rn" = "$hn" ] || bad "MILESTONES.md M$N row has $((rn-2)) cells; its table header has $((hn>2 ? hn-2 : 0)) (copy FILE 2 of the template exactly)"
fi
echo; echo "| Wave | Task | Covers | After | Harness | Parallel | HITL | Budget |"; echo "|---|---|---|---|---|---|---|---|"
printf '%s\n' "$waves" | sort -k2,2n -k1,1 | while read -r t w; do f=$T/$t.md
  echo "| $w | M$N-$t | $(fm "$f" covers | lst | tr '\n' ' ')| $(fm "$f" after | lst | tr '\n' ' ')| $(fm "$f" harness) | $(fm "$f" parallel) | $(fm "$f" hitl) | $(fm "$f" budget) |"
done
echo; echo "| Id | Tasks | Acceptance tests (AT, level, file) |"; echo "|---|---|---|"; unc=0; na=0
for i in $scope; do
  ts=$(printf '%s\n' "$cov" | awk -v i="$i" '$1==i{print "M'"$N"'-"$2}' | sort -u | tr '\n' ' ')
  at=$(ats "$i" | tr '\n' ';' | sed 's/;$//; s/;/; /g')
  [ -n "$ts" ] || { ts="⚠ NONE"; unc=$((unc+1)); bad "$i is covered by no task"; }
  printf '%s' "$at" | grep -q 'tests/acceptance/' || { na=$((na+1)); echo "WARN: $i has no tests/acceptance path in $A ## Traceability (define-acceptance)" >&2; }
  echo "| $i | $ts| ${at:-⚠ none in acceptance.md} |"
done
nw=$(printf '%s\n' "$waves" | awk '$2!="CYCLE" && $2>m{m=$2} END{print m+0}')
echo; echo "Analyze: tasks=$k waves=$nw parallel=$pc claude=$cc codex=$xc hitl=$hc budget_min=$bm uncovered=$unc empty_covers=$ec parallel_overlaps=$ov unknown_after=$ua cycles=$cy acceptance_in_owns=$ao no_acceptance_test=$na blocked=$bl"
[ "$fail" = 0 ] && echo "RESULT: PASS" || echo "RESULT: FAIL"
exit $fail
```
