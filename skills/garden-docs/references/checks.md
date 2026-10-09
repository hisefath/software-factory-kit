# garden-docs checks

One bash script, eleven checks (C1-C11). Each prints `ok` or `FAIL` lines; the last line is
`garden-docs checks: <n> failing` and the exit code is 0 only when nothing fails. The output is evidence: paste it
whole into the STOP message, and the supervisor pastes it into the MR as a comment (report-milestone does not read
it). Never retype, trim or summarize it.

## Run it

From the project root (bash 3.2+, BSD or GNU tools; reads only, except the one `curl` GET in C11). Each shell call
starts fresh, so use the literal values step 1 printed, never shell variables: `<HEAD>` from
`git rev-parse --short HEAD`, `<tmp>` from `mktemp -d`. `<skill-dir>` is the folder this skill was loaded from.

*Baseline* (step 2; always `-` as the URL, so C11 may FAIL here when README already shows a live URL):

```bash
awk '/^````bash$/{f=1;next} /^````$/{f=0} f' <skill-dir>/references/checks.md > <tmp>/garden-checks.sh
bash <tmp>/garden-checks.sh <skill-dir>/assets/template.md - > <tmp>/before.txt 2>&1; tail -1 <tmp>/before.txt
```

*After* (step 9, and every re-run after a fix; the demo URL README shows, or `-` when it says `Not live yet.`):

```bash
bash <tmp>/garden-checks.sh <skill-dir>/assets/template.md <demo-url | -> > <tmp>/after.txt 2>&1; cat <tmp>/after.txt
```

## What each check proves, and who fixes a failure

| Check | Proves | You fix it when the file is yours | Owner when it is not yours |
|---|---|---|---|
| C1 diagrams | Every embedded Mermaid block equals its `docs/architecture/diagrams/<type>.mmd` (`scripts/embed-diagrams.sh --check`) | `bash scripts/embed-diagrams.sh ARCHITECTURE.md` | supervisor runs `embed-diagrams.sh <doc>`; a missing `.mmd` → `draw-diagrams <type>` |
| C2 links | Every relative markdown link and image resolves to a file or folder (archived docs and `.handoff/` skipped) | point the link at the real path, or drop it | the skill in the index's "Written by" column for that path |
| C3 numbers | Every number in README prose sits right before a `[^n<k>]` footnote naming the command, its output, the SHA and date (a footnote clears only the number it follows); refs = definitions; no non-doc file changed since that SHA. Exempt: the title and the first non-empty line under it, because C6 traces both to AGENTS.md, plus Milestones and AI-usage table rows (copied) | re-run the command and update number + footnote, or drop the number | — (README is yours) |
| C4 quickstart | Every command line in README's Quickstart block appears verbatim in `AGENTS.md`, and none is a `<…>` placeholder | copy the command from AGENTS.md | a placeholder in AGENTS.md is a human-only edit: ask the human |
| C5 index | Every doc (`*.md`, `*.mmd`, everything under `docs/` and `specs/`) matches a path in `docs/README.md`; the factory rows equal template Part A | add a `## Project-specific` row, or archive (human's yes) | a wrong factory row → `route-failure` |
| C6 README shape | `## ` sections in the fixed order; the title equals AGENTS.md's H1 name (after `AGENTS.md —`); the first non-empty line under it equals AGENTS.md's first sentence (its first paragraph joined, cut at the first `.`, `!` or `?` followed by a space) | reorder; copy the name and the sentence, the sentence on one line | AGENTS.md placeholder → human-only edit |
| C7 milestones | README's Milestones rows (id, goal, status) equal MILESTONES.md's | copy the rows again | — |
| C8 architecture | If `ARCHITECTURE.md` exists: 350-650 words of prose; trade-off rows = exactly the journal's `[status: accepted]` D-rows whose `phase` bullet names `design-hld` or `design-lld`, or whose Reversibility is `Type 1`; every CN/L/TB/TH/INV/QA id exists in `hld.md` | trim/expand; add or remove rows; fix the id | a missing id in hld.md → `design-hld` |
| C9 scope | Since the clean start, only `README.md`, `ARCHITECTURE.md`, `docs/README.md`, `docs/archive/**` and the old paths of archived files (ledger row present) changed | tracked file your command changed: `git restore -- <path>` (the tree was clean at step 1) | untracked file a measuring command left (e.g. `.phpunit.result.cache`): never `rm` it; list it under "Not mine to fix", owner supervisor (`.gitignore` it) |
| C10 leftovers | No `{{`, `}}` or `<!-- guide:` in your files; secret-looking words listed for a human eyeball (`look` lines are not failures) | fill or delete | — |
| C11 demo | The URL you pass answers through `curl -fsSL` with TLS verified and appears in README; with `-`, README says `Not live yet.` | fix the URL or say `Not live yet.` | a dead live site → `ship-milestone` |

## The script

````bash
#!/usr/bin/env bash
# garden-docs checks (factory-kit 0.1). Run from the project root:
#   bash garden-checks.sh <garden-docs>/assets/template.md <demo-url | ->
set -u
T=${1:-} URL=${2:--}
fails=0
fail() { printf '  FAIL %s\n' "$*"; fails=$((fails + 1)); }
ok() { printf '  ok   %s\n' "$*"; }
fence='^[[:space:]]*(```|~~~)'
mine='README.md docs/README.md ARCHITECTURE.md docs/archive/README.md'

echo "C1 diagrams: embedded Mermaid = docs/architecture/diagrams/*.mmd"
d=$(grep -rlE '^[[:space:]]*<!--[[:space:]]*diagram:' --include='*.md' --exclude-dir=.git --exclude-dir=archive \
  --exclude-dir=.handoff --exclude-dir=vendor --exclude-dir=node_modules . 2>/dev/null | sed 's#^\./##' | sort)
if [ -z "$d" ]; then ok "no diagram placeholders in any doc"
elif [ ! -f scripts/embed-diagrams.sh ]; then fail "scripts/embed-diagrams.sh missing (run init-repo.sh)"
elif bash scripts/embed-diagrams.sh --check $d 2>&1 | sed 's/^/       /'; [ "${PIPESTATUS[0]}" = 0 ]; then ok "all in sync"
else fail "out of sync (see above)"; fi

echo "C2 links: every relative markdown link resolves (docs/archive/** except its README, and .handoff/** skipped)"
n=0
while IFS= read -r f; do
  [ -f "$f" ] || continue # tracked but moved away (e.g. just archived)
  while IFS= read -r l; do
    p=${l%%#*}; p=${p%%\?*}
    [ -n "$p" ] || continue
    case $p in /*) t=.$p ;; *) t=$(dirname "$f")/$p ;; esac
    [ -e "$t" ] || { fail "$f -> $l"; n=$((n + 1)); }
  done < <(awk -v fence="$fence" '$0 ~ fence {c = !c; next} !c' "$f" | sed 's/`[^`]*`//g' |
    grep -oE '\]\([^)[:space:]]+|^\[[^]^][^]]*\]:[[:space:]]+[^[:space:]]+' |
    sed -E 's/^\]\(//; s/^\[[^]]*\]:[[:space:]]+//; s/^<//; s/>$//' |
    grep -vE '^([A-Za-z][A-Za-z0-9+.-]*:|#|//)')
done < <({ git ls-files -co --exclude-standard -- '*.md' ':(exclude)docs/archive/**' ':(exclude).handoff/**'
  [ -f docs/archive/README.md ] && echo docs/archive/README.md; } | sort -u)
[ "$n" = 0 ] && ok "0 broken"

echo "C3 README numbers: each is followed by a [^nK] footnote = command, output, sha, date"
if [ ! -f README.md ]; then fail "README.md missing"; else
  r=$(awk -v fence="$fence" '
    $0 ~ fence { f = !f; next }
    f || /^\[\^n[0-9]+\]:/ { next }
    !h && /^# / { h = 1; next }  # title: C6 traces it to AGENTS.md
    h == 1 && NF { h = 2; next } # one-sentence description: C6 traces it to AGENTS.md
    /^## / { s = $0 }
    (s == "## Milestones" || s == "## AI usage") && /^\|/ { next }
    { l = $0
      gsub(/[0-9][0-9.,%]*\[\^n[0-9]+\]/, "", l); gsub(/\[\^n[0-9]+\]/, "", l) # a footnote clears only its number
      gsub(/\]\([^)]*\)/, "]", l); gsub(/<!--.*-->/, "", l); gsub(/https?:\/\/[^] )>]*/, "", l)
      gsub(/`[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]*`/, "", l)
      gsub(/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/, "", l)
      gsub(/(N?FR|SC|AE|CN|TB|TH|QA|INV|AR|D|M|T|R|S|Q|L|C)-?[0-9]+/, "", l)
      if (l ~ /[0-9]/) print "README.md:" NR ": " $0 }' README.md)
  if [ -n "$r" ]; then fail "numbers without a footnote:"; printf '%s\n' "$r" | sed 's/^/       /'; else ok "no unfootnoted numbers"; fi
  b=$(grep -nE '^\[\^n[0-9]+\]:' README.md |
    grep -vE '^[0-9]+:\[\^n[0-9]+\]: `[^`]+` → `[^`]+` @ [0-9a-f]{7,40}, [0-9]{4}-[0-9]{2}-[0-9]{2}$')
  [ -z "$b" ] && ok "footnotes well-formed" || { fail "malformed footnotes:"; printf '%s\n' "$b" | sed 's/^/       /'; }
  u=$(grep -vE '^\[\^n[0-9]+\]:' README.md | grep -oE '\[\^n[0-9]+\]' | sort -u | tr '\n' ' ')
  v=$(grep -oE '^\[\^n[0-9]+\]:' README.md | tr -d ':' | sort -u | tr '\n' ' ')
  [ "$u" = "$v" ] && ok "footnote refs = definitions (${u:-none})" || fail "refs [$u] != definitions [$v]"
  for s in $(sed -nE 's/^\[\^n[0-9]+\]: .* @ ([0-9a-f]{7,40}), [0-9-]+$/\1/p' README.md | sort -u); do
    if git diff --quiet "$s" HEAD -- . ':(exclude)*.md' ':(exclude)docs/**' ':(exclude).handoff/**' 2>/dev/null
    then ok "measured @ $s, no code changed since"
    else fail "measured @ $s, but non-doc files changed since (or unknown sha): re-measure"; fi
  done
fi

echo "C4 quickstart: every command line is verbatim in AGENTS.md"
q=$(awk '/^## Quickstart/{q=1;next} /^## /{q=0} q' README.md 2>/dev/null |
  awk -v fence="$fence" '$0 ~ fence {c = !c; next} c' | sed -E 's/^\$ //' | grep -vE '^[[:space:]]*(#|$)')
if [ -z "$q" ]; then fail "no command block under ## Quickstart"; else
  while IFS= read -r c; do
    case $c in '<'*) fail "placeholder, not a command: $c"; continue ;; esac
    if grep -qF -- "$c" AGENTS.md; then ok "$c"; else fail "not in AGENTS.md: $c"; fi
  done <<EOF
$q
EOF
fi

echo "C5 index: docs/README.md covers every doc; factory rows = template Part A"
if [ ! -f docs/README.md ]; then fail "docs/README.md missing"; else
  pats=$(grep -oE '`[^`]+`' docs/README.md | tr -d '`' | grep -E '/|\.[A-Za-z]+$' |
    sed -E 's/\{[^}]*\}/*/g; s/<[^>]*>/*/g; s/NNNN/[0-9][0-9][0-9][0-9]/g; s/###/[0-9][0-9][0-9]/g; s/\*\*/*/g; s#/$#/*#' | sort -u)
  set -f; o=0
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    hit=0; for p in $pats; do case $f in $p) hit=1; break ;; esac; done
    [ "$hit" = 1 ] || { fail "orphan, no index row: $f"; o=$((o + 1)); }
  done < <(git ls-files -co --exclude-standard -- '*.md' '*.mmd' 'docs/**' 'specs/**' | grep -v '/\.gitkeep$' | sort -u)
  set +f
  [ "$o" = 0 ] && ok "0 orphans"
  if [ -z "$T" ] || [ ! -f "$T" ]; then fail "template path not given or missing: '$T'"; else
    dd=$(diff <(awk '/^## Part A/{a=1;next} /^## Part B/{a=0} a' "$T" | awk '/^## Project-specific/{exit} /^\|/') \
      <(awk '/^## Project-specific/{exit} /^\|/' docs/README.md))
    [ -z "$dd" ] && ok "factory rows match Part A" || { fail "factory rows differ from Part A (< template, > docs/README.md):"; printf '%s\n' "$dd" | sed 's/^/       /'; }
  fi
fi

echo "C6 README shape: fixed section order; title and first line = AGENTS.md's name and first sentence"
dd=$(diff <(grep -E '^## ' README.md 2>/dev/null) <(printf '## %s\n' Demo Quickstart Architecture Docs Decisions Milestones 'AI usage'))
[ -z "$dd" ] && ok "sections in order" || { fail "sections differ from the fixed order (< README, > required):"; printf '%s\n' "$dd" | sed 's/^/       /'; }
n1=$(grep -m1 -E '^# ' AGENTS.md 2>/dev/null | sed -E 's/^# //; s/^AGENTS\.md[[:space:]]*(—|–|-)[[:space:]]*//')
n2=$(grep -m1 -E '^# ' README.md 2>/dev/null | sed -E 's/^# //')
case $n1 in '<'* | '') fail "AGENTS.md's H1 has no project name yet (human-only edit)" ;; esac
[ "$n1" = "$n2" ] && ok "title = AGENTS.md" || fail "title differs: AGENTS.md='$n1' README.md='$n2'"
# AGENTS.md: join the first paragraph under the H1 (it may wrap), then cut at the first sentence end.
s1=$(awk '/^# /&&!h{h=1;next} h&&/^#/{exit} h&&NF{printf "%s ",$0;s=1;next} s{exit}' AGENTS.md 2>/dev/null |
  sed -E 's/[[:space:]]+/ /g; s/([.!?]) .*$/\1/; s/ $//')
s2=$(awk '/^# /&&!h{h=1;next} h&&NF{print;exit}' README.md 2>/dev/null)
case $s1 in '<'* | '') fail "AGENTS.md has no one-sentence description yet (human-only edit)" ;; esac
[ "$s1" = "$s2" ] && ok "sentence = AGENTS.md" || fail "sentence differs: AGENTS.md='$s1' README.md='$s2'"

echo "C7 milestones: README rows (id | goal | status) = MILESTONES.md"
row='/^\| *M[0-9]+ *\|/ { for (i = 2; i < NF; i++) gsub(/^ +| +$/, "", $i); print $2 " | " $3 " | " $c }'
dd=$(diff <(awk -F'|' -v c=7 "$row" MILESTONES.md 2>/dev/null) \
  <(awk '/^## Milestones/{m=1;next} /^## /{m=0} m' README.md 2>/dev/null | awk -F'|' -v c=4 "$row"))
[ -z "$dd" ] && ok "in sync" || { fail "differs (< MILESTONES.md, > README.md):"; printf '%s\n' "$dd" | sed 's/^/       /'; }

echo "C8 ARCHITECTURE.md: 350-650 words, trade-offs = accepted design/Type 1 D-rows, ids exist in hld.md"
if [ ! -f ARCHITECTURE.md ]; then ok "not present (written only when graded or asked)"; else
  w=$(awk -v fence="$fence" '$0 ~ fence {f = !f; next} !f && !/^\|/ && !/^[[:space:]]*<!--/' ARCHITECTURE.md | wc -w | tr -d ' ')
  if [ "$w" -ge 350 ] && [ "$w" -le 650 ]; then ok "$w words of prose"; else fail "$w words of prose (want 350-650)"; fi
  # accepted D-rows from design-hld/design-lld (G2/G3), or Type 1 (one-way) from any phase
  dd=$(diff <(awk '
      function out() { if (id != "" && acc && sel) print id }
      /^### D[0-9]+ / { out(); id = $2; acc = ($0 ~ /\[status: accepted\]/); sel = 0; next }
      /^#/ { out(); id = ""; next }
      id != "" && ($0 ~ /phase [0-9]+[a-z]? design-(hld|lld)/ || $0 ~ /Reversibility: Type 1/) { sel = 1 }
      END { out() }' docs/decisions/DECISION_JOURNAL.md 2>/dev/null | sort -u) \
    <(grep -oE '^\| D[0-9]+ ' ARCHITECTURE.md | tr -d '| ' | sort -u))
  [ -z "$dd" ] && ok "trade-off rows = accepted design/Type 1 D-rows" || { fail "trade-off rows != accepted design/Type 1 D-rows (< journal only, > table only):"; printf '%s\n' "$dd" | sed 's/^/       /'; }
  for id in $(grep -oE '(CN|L|TB|TH|INV|QA)-[0-9]+' ARCHITECTURE.md | sort -u); do
    grep -qw -- "$id" docs/architecture/hld.md 2>/dev/null || fail "$id is not in docs/architecture/hld.md"
  done
fi

echo "C9 scope: only garden-docs paths changed since the clean start"
x=0
while IFS= read -r e; do
  st=${e:0:2} p=${e:3}; p=${p##* -> }
  case $p in README.md | ARCHITECTURE.md | docs/README.md | docs/archive/*) continue ;; esac
  grep -qF "\`$p\`" docs/archive/README.md 2>/dev/null && continue
  if [ "$st" = '??' ]; then fail "untracked, outside garden-docs paths: $p (never rm it; Not mine to fix, owner supervisor)"
  else fail "changed outside garden-docs paths: $p (if your command changed it: git restore -- $p)"; fi
  x=$((x + 1))
done < <(git status --porcelain --untracked-files=all)
[ "$x" = 0 ] && ok "only README.md, ARCHITECTURE.md, docs/README.md, docs/archive/** (+ archived old paths)"

echo "C10 leftovers: no {{ }} or guide comments; secret-looking words for a human eyeball"
for f in $mine; do
  [ -f "$f" ] || continue
  h=$(grep -nE '\{\{|\}\}|<!-- guide:' "$f")
  [ -z "$h" ] && ok "$f clean" || { fail "$f has template leftovers:"; printf '%s\n' "$h" | sed 's/^/       /'; }
  grep -niE 'password|passwd|secret|api[_-]?key|token|BEGIN [A-Z ]*PRIVATE' "$f" | sed "s#^#  look $f:#"
  printf '  ok   %s: %s open ⚠\n' "$f" "$(grep -c '⚠' "$f")"
done

echo "C11 demo: the live URL answers over verified TLS, or README says Not live yet."
if [ "$URL" = - ]; then
  grep -q '^Not live yet\.' README.md 2>/dev/null && ok "no live URL claimed; README says Not live yet." || fail "no URL passed, but README does not say 'Not live yet.'"
else
  code=$(curl -fsSL --max-time 15 -o /dev/null -w '%{http_code}' "$URL" 2>&1) && ok "$URL -> $code" || fail "$URL -> $code"
  grep -qF -- "$URL" README.md || fail "README.md does not show $URL"
fi

echo "garden-docs checks: $fails failing"
[ "$fails" = 0 ]
````
