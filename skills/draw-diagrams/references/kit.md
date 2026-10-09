# draw-diagrams kit

The shell helpers every step and the Done-when check call. Step 1 of SKILL.md copies the one `bash` block below
into `$tmp/kit.sh`, under a first line that sets `tmp K T RET BASE`, and every later command starts with
`. <tmp>/kit.sh &&` (shell state does not survive between an agent's commands; the file does). Run every command
from the repo root. The helpers only read the repo; they write only inside `$tmp`.

Why a kit: counts, anchors and trace checks are mechanical, and WORKFLOW §10 says a mechanical step done wrong
moves into a script the prompt calls. Every helper prints nothing when all is well, except the ones that report
(`dd_find_heading`, `dd_placeholders`, `dd_requested`, `dd_agents_dir`, `dd_render`, `dd_counts`, `dd_secrets`).

| Helper | Used in | Prints |
|---|---|---|
| `dd_agents_dir` | Inputs 4 | the AGENTS.md "Diagrams" path with its `*.mmd` glob removed |
| `dd_resolve [ref…]` | step 3 | nothing on success (fills `$tmp/src.md`, `$tmp/sources`); else why it stopped |
| `dd_find_heading <doc> <ref>` | step 3 (inside `dd_resolve`) | every heading `<ref>` names |
| `dd_placeholders` | step 4 | how many `<!-- diagram: $T -->` lines `$DOC` has, matched like `embed-diagrams.sh` |
| `dd_trace` | step 7 | untraced words, invented ids, dropped ids, dropped rows/columns/methods/states/steps |
| `dd_render` | step 8 | `verified\|…`, `unverified\|…` or `parse\|…` |
| `dd_counts` | STOP, Part C | `<n> <things>, <m> <links>` |
| `dd_done` | Done when | every failed check, one per line |
| `dd_secrets` | Done when | lines to eyeball for secret values |

```bash
# ---- draw-diagrams kit (references/kit.md) — sourced after the line that sets tmp K T RET BASE ----------------
OUT="docs/architecture/diagrams/$T.mmd"
case $T in hld-*|deployment) DOC=docs/architecture/hld.md ;; *) DOC=docs/architecture/lld.md ;; esac

# dd_anchor <heading line> — GitLab anchor (GitLab is the canonical remote): lowercase, punctuation dropped,
# spaces become '-', runs of '-' collapse to one. dd_find_heading also accepts GitHub's uncollapsed form.
dd_anchor() { printf '%s\n' "$1" | awk '{ s = tolower($0); sub(/^#+[ \t]+/, "", s); gsub(/[^a-z0-9_ -]/, "", s); gsub(/ /, "-", s); gsub(/-+/, "-", s); print s }'; }

# dd_headings <doc> — heading lines outside fenced code blocks.
dd_headings() { awk '/^[ \t]*(```|~~~)/ { f = !f; next } !f && /^#+[ \t]/' "$1"; }

# dd_find_heading <doc> <ref> — every heading <ref> names; exactly one must print.
#   §N    → the "## N. …" heading            §N ID → the "### ID …" heading (e.g. "§5 SEQ-1")
#   other → a heading whose anchor equals <ref>'s (hyphen runs collapsed on both sides), or whose text, with or
#           without its "N. " number, equals <ref> or starts with "<ref> " (so "SEQ-1" never matches "SEQ-10").
dd_find_heading() {
  dd_headings "$1" | awk -v r="$2" '
    function anc(s) { s = tolower(s); sub(/^#+[ \t]+/, "", s); gsub(/[^a-z0-9_ -]/, "", s); gsub(/ /, "-", s); gsub(/-+/, "-", s); return s }
    BEGIN { sec = (r ~ /^§/); if (sec) { sub(/^§[ \t]*/, "", r); n = split(r, a, /[ \t]+/) } else ra = anc(r) }
    { t = $0; sub(/^#+[ \t]+/, "", t); u = t; sub(/^[0-9]+\.[ \t]+/, "", u) }
    sec && n == 1 { if (index($0, "## " a[1] ". ") == 1) print; next }
    sec { if ($0 == "### " a[2] || index($0, "### " a[2] " ") == 1) print; next }
    anc($0) == ra || t == r || u == r || index(t, r " ") == 1 || index(u, r " ") == 1'
}

# dd_section <doc> <heading line> — that section, through the next heading of the same or higher level, with every
# embedded diagram block (```mermaid … ``` and <!-- /diagram --> right under a placeholder) removed: that block is a
# previous run's output, never source. Mirrors scripts/embed-diagrams.sh's block grammar.
dd_section() {
  awk -v h="$2" '
    s == 2 { if ($0 ~ /^```[ \t]*$/) s = 3; next }
    s == 1 { s = 0; if ($0 ~ /^```mermaid[ \t]*$/) { s = 2; next } }
    s == 3 { s = 0; if ($0 ~ /^[ \t]*<!--[ \t]*\/diagram[ \t]*-->[ \t]*$/) next }
    /^[ \t]*(```|~~~)/ { f = !f; if (p) print; next }
    !f && /^#+[ \t]/ { match($0, /^#+/); if (p && RLENGTH <= l) exit; if (!p && $0 == h) { p = 1; l = RLENGTH } }
    p && !f && /^[ \t]*<!--[ \t]*diagram:/ { s = 1 }
    p { print }' "$1"
}

# dd_placeholders — placeholder lines for $T in $DOC, outside fences, matched the way embed-diagrams.sh matches
# them (a whole line), so a placeholder quoted inside a table cell does not count. Must print 1.
dd_placeholders() {
  awk -v t="$T" '/^[ \t]*(```|~~~)/ { f = !f; next } !f && $0 ~ ("^[ \t]*<!--[ \t]*diagram:[ \t]*" t "[ \t]*-->[ \t]*$") { n++ } END { print n + 0 }' "$DOC"
}

# dd_requested — the "Draw from" cell of this job's row in $DOC's "Diagram requests" table, one ref per line
# ("§3, §4, §5" becomes three refs; backticks dropped).
dd_requested() {
  awk -F'|' -v j="\`draw-diagrams $T\`" 'index($2, j) { print $3; exit }' "$DOC" | tr -d '`' |
    sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' | awk '/^§/ { n = split($0, a, /,[ \t]*/); for (i = 1; i <= n; i++) print a[i]; next } NF { print }'
}

# dd_use_section <doc> <ref> — resolve, extract, pin. Appends to $tmp/src.md and $tmp/sources.
dd_use_section() {
  [ -f "$1" ] || { printf 'no file %s\n' "$1"; return 1; }
  dd_find_heading "$1" "$2" > "$tmp/hits"
  [ "$(grep -c . "$tmp/hits")" = 1 ] || { printf 'no unique section %s in %s; candidates:\n' "$2" "$1"; cat "$tmp/hits"; return 1; }
  _h=$(cat "$tmp/hits")
  dd_section "$1" "$_h" >> "$tmp/src.md"
  _sha=$(git log -1 --format=%h -- "$1")
  if [ -z "$_sha" ]; then _sha=uncommitted; elif [ -n "$(git status --porcelain -- "$1")" ]; then _sha="$_sha+dirty"; fi
  printf '%%%% source: %s#%s @ %s\n' "$1" "$(dd_anchor "$_h")" "$_sha" >> "$tmp/sources"
}

# dd_use_ref <ref> — "<path>#<anchor or heading text>" or "§…" (in $DOC).
dd_use_ref() { case $1 in *'#'*) dd_use_section "${1%%#*}" "${1#*#}" ;; *) dd_use_section "$DOC" "$1" ;; esac; }

# dd_resolve [ref…] — Inputs 3, in order: the refs given (the [source] argument or the job's "give:" entries) →
# for sequence-*/state-*, the one heading that names `$T` → this job's "Diagram requests" row.
dd_resolve() {
  : > "$tmp/src.md"; : > "$tmp/sources"
  if [ $# -gt 0 ]; then printf '%s\n' "$@" > "$tmp/refs"
  else
    : > "$tmp/refs"
    case $T in sequence-*|state-*) dd_headings "$DOC" | grep -F "\`$T\`" | sed -E 's/^#+[[:space:]]+//' > "$tmp/refs" ;; esac
    case $(grep -c . "$tmp/refs") in
      0) dd_requested > "$tmp/refs" ;;
      1) ;;
      *) printf 'several headings in %s name `%s`:\n' "$DOC" "$T"; cat "$tmp/refs"; return 1 ;;
    esac
  fi
  grep -q . "$tmp/refs" || { printf 'no source for %s: no [source], no heading naming `%s`, no Diagram requests row in %s\n' "$T" "$T" "$DOC"; return 1; }
  while IFS= read -r _r; do [ -z "$_r" ] || dd_use_ref "$_r" || return 1; done < "$tmp/refs"
  if grep -nE '^[[:space:]]*(```mermaid|%% diagram:)' "$tmp/src.md"; then
    echo "the section holds a Mermaid block outside a diagram placeholder: draw from the design text, not a picture"; return 1
  fi
}

# dd_agents_dir — the AGENTS.md "Diagrams" row's path, `*.mmd` glob removed. Must print docs/architecture/diagrams/
dd_agents_dir() { grep -E '^\|[[:space:]]*Diagrams' AGENTS.md | grep -oE '`[^`]+`' | head -1 | tr -d '`' | sed -E 's#\*\.mmd$##'; }

# dd_ids <file> — hyphenated ids (CN-1, BE-12, SEQ-3); struck-through ones (~~CN-3~~) are retired, so dropped.
dd_ids() { sed -E 's/~~[^~]*~~//g' "$1" | grep -oE '(^|[^A-Za-z0-9])[A-Z]{1,5}-[0-9]+' | grep -oE '[A-Z]{1,5}-[0-9]+' | sort -u; }

# dd_prefixes — id prefixes $T must draw (references/types.md "Ids drawn"); empty = no dropped-id check.
dd_prefixes() {
  case $T in
    hld-container) echo 'CN|L|TB' ;; deployment) echo CN ;; be-class) echo BE ;; fe-components) echo 'FE|ST' ;;
    sequence-*) grep -m1 -E 'Participants:' "$tmp/src.md" | sed -E 's/~~[^~]*~~//g' | grep -oE '[A-Z]{1,5}-[0-9]+' | cut -d- -f1 | sort -u | paste -sd'|' - ;;
  esac
}

# dd_notation — the only words a diagram may use that are not in the source: Mermaid keywords and this skill's own
# fixed notation, one case-insensitive whole-word regex per line. Change it only together with references/types.md.
dd_notation() {
  printf '%s\n' 'P[0-9]+' 'X[0-9]+' 'N[0-9]+' 'S[0-9]+'
  case $T in
    hld-context) _w='flowchart LR SYS person our system external C4Context title context System_Ext Rel' ;;
    hld-container) _w='flowchart LR subgraph end style stroke dasharray 5 person external system sync async' ;;
    deployment) _w='flowchart TB subgraph end ENV_[A-Za-z0-9_]+ [A-Za-z0-9_]+_CN[0-9]+ [A-Za-z0-9_]+_none DEP_[A-Za-z0-9_]+ SEC_[A-Za-z0-9_]+ none deployed by secrets from' ;;
    erd) _w='erDiagram PK FK UK ref not null nullable o' ;;
    be-class) _w='classDiagram class namespace note for depends on o' ;;
    fe-components) _w='flowchart TD owns reads none classDiagram class component o' ;;
    sequence-*) _w='sequenceDiagram autonumber actor participant as alt else end opt loop Note over main path steps' ;;
    state-*) _w='stateDiagram v2 state as choice' ;;
  esac
  printf '%s\n' "$_w" | tr ' ' '\n'
}

# dd_firstcells — first cells of the source's table rows (headers, separators and struck rows skipped).
dd_firstcells() {
  sed -E 's/~~[^~]*~~//g' "$tmp/src.md" | awk -F'|' '/^\|/ { if (!h) { h = 1; next } if ($2 ~ /^[ \t:-]+$/) next; c = $2; gsub(/^[ \t`*]+|[ \t`*]+$/, "", c); if (c != "") print c; next } { h = 0 }'
}

# dd_complete — completeness for elements that have no hyphenated id.
dd_complete() {
  case $T in
    hld-context|deployment)
      dd_firstcells | while IFS= read -r _c; do grep -qF -- "$_c" "$OUT" || printf 'dropped row: %s\n' "$_c"; done ;;
    erd)
      sed -E 's/~~[^~]*~~//g' "$tmp/src.md" | awk '/^#### /{ split($0, h, "`"); t = h[2]; next } /^#+[ \t]/{ t = "" } t != "" && /^\|[ \t]*`/ { split($0, c, "`"); print t "." c[2] }' | sort -u > "$tmp/src.cols"
      grep -vE '^[[:space:]]*%%' "$OUT" | awk '/\{[ \t]*$/ { e = $1; next } /^[ \t]*\}/ { e = ""; next } e != "" && NF >= 2 { print e "." $2 }' | sort -u > "$tmp/out.cols"
      [ -s "$tmp/src.cols" ] || echo "no #### column tables in the section: not in design-lld form"
      comm -23 "$tmp/src.cols" "$tmp/out.cols" | sed 's/^/dropped column: /'
      comm -13 "$tmp/src.cols" "$tmp/out.cols" | sed 's/^/invented column: /' ;;
    be-class)
      sed -E 's/~~[^~]*~~//g' "$tmp/src.md" | grep -oE '^\|[[:space:]]*`[A-Za-z_][A-Za-z0-9_]*\(' | sed -E 's/^\|[[:space:]]*`//; s/\($//' | sort -u |
        while IFS= read -r _m; do grep -qE "[+]$_m\(" "$OUT" || printf 'dropped method: %s\n' "$_m"; done ;;
    sequence-*)
      _s=$(sed -E 's/~~[^~]*~~//g' "$tmp/src.md" | grep -cE '^[[:space:]]*(- )?a?[0-9]+\.[[:space:]]')
      _d=$(grep -vE '^[[:space:]]*%%' "$OUT" | grep -cE -- '->>|-\)|^[[:space:]]*Note (over|left of|right of) [^:]+: [^⚠]')
      [ "$_s" = "$_d" ] || printf 'steps in source (n. and aN.): %s; messages + notes drawn: %s\n' "$_s" "$_d" ;;
    state-*)
      awk -F'|' '/^\|[ \t]*State[ \t]*\|/ { s = 1; next } s && $2 ~ /^[ \t:-]+$/ { next } s && /^\|/ { if ($2 !~ /~~/) print $2; next } { s = 0 }' "$tmp/src.md" |
        sed -E 's/^[[:space:]`]+//; s/[[:space:]`]+$//' | while IFS= read -r _st; do [ -z "$_st" ] || grep -qF -- "$_st" "$OUT" || printf 'dropped state: %s\n' "$_st"; done
      _s=$(awk -F'|' '/^\|[ \t]*From[ \t]*\|/ { s = 1; next } s && $2 ~ /^[ \t:-]+$/ { next } s && /^\|/ { if ($2 !~ /~~/) n++; next } { s = 0 } END { print n + 0 }' "$tmp/src.md")
      _d=$(grep -vE '^[[:space:]]*%%' "$OUT" | grep -E -- '-->' | grep -cvE '\[\*\]')
      [ "$_s" = "$_d" ] || printf 'transitions in source: %s; drawn: %s\n' "$_s" "$_d" ;;
  esac
}

# dd_trace — step 7: both directions, on the diagram itself. Prints nothing when every word and id traces.
dd_trace() {
  sed -E 's/~~[^~]*~~//g' "$tmp/src.md" > "$tmp/src.live"
  grep -vE '^[[:space:]]*%%' "$OUT" > "$tmp/out.body"
  { tr -cs 'A-Za-z0-9_' '\n' < "$tmp/src.live"; dd_ids "$tmp/src.live" | tr -d '-'; } | sort -u > "$tmp/src.words"
  dd_notation > "$tmp/notation.txt"
  # 1. every word drawn (ids, names, columns, methods, messages, states, labels) is in the section or the notation
  grep -vE '^[[:space:]]*(else ⚠|Note (over|left of|right of) [^:]+: ⚠ missing:)' "$tmp/out.body" |
    sed -E 's/<br *\/?>/ /g; s/#[A-Za-z0-9]+;/ /g' | tr -cs 'A-Za-z0-9_' '\n' | sed '/^$/d' | sort -u |
    grep -vxiEf "$tmp/notation.txt" | grep -vxiFf "$tmp/src.words" | sed 's/^/untraced word: /'
  # 2. no invented id; none of this type's id prefixes dropped
  dd_ids "$tmp/src.live" > "$tmp/src.ids"; dd_ids "$tmp/out.body" > "$tmp/out.ids"
  comm -13 "$tmp/src.ids" "$tmp/out.ids" | sed 's/^/invented id: /'
  _p=$(dd_prefixes)
  [ -z "$_p" ] || grep -E "^($_p)-" "$tmp/src.ids" | comm -23 - "$tmp/out.ids" | sed 's/^/dropped id: /'
  # 3. every table row, column, method, step or state the type must show
  dd_complete
}

# dd_kind — the first diagram line is the type's Mermaid kind.
dd_kind() {
  _k=$(grep -vE '^[[:space:]]*(%%|$)' "$OUT" | head -1 | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
  case $T in
    hld-context) _e='flowchart LR|C4Context' ;; hld-container) _e='flowchart LR' ;; deployment) _e='flowchart TB' ;;
    erd) _e=erDiagram ;; be-class) _e=classDiagram ;; fe-components) _e='flowchart TD|classDiagram' ;;
    sequence-*) _e=sequenceDiagram ;; state-*) _e=stateDiagram-v2 ;; *) _e='unknown type' ;;
  esac
  printf '%s\n' "$_k" | grep -qxE "$_e" || printf 'kind: first diagram line is "%s", expected %s\n' "$_k" "$_e"
}

# dd_typecheck — the per-type "Check" rules of references/types.md.
dd_typecheck() {
  _b="$tmp/out.body"; grep -vE '^[[:space:]]*%%' "$OUT" > "$_b"
  case $T in
    hld-context)
      if grep -qE '^[[:space:]]*C4Context' "$_b"; then _n=$(grep -cE '^[[:space:]]*System\(' "$_b"); else _n=$(grep -cE '<br/>our system"\]' "$_b"); fi
      [ "$_n" = 1 ] || printf 'our-system box count is %s, not 1\n' "$_n" ;;
    hld-container)
      [ "$(grep -cE '^[[:space:]]*subgraph TB[0-9]+' "$_b")" = "$(grep -cE '^[[:space:]]*style TB[0-9]+ stroke-dasharray' "$_b")" ] || echo "a TB subgraph has no dashed style line" ;;
    deployment)
      grep -nE '=[[:space:]]*[A-Za-z0-9_-]{12,}' "$_b" | sed 's/^/secret-looking value: /' ;;
    erd)
      grep -E -- '--|\.\.' "$_b" | grep -vE '[|}][|o](--|\.\.)[|o][|{]' | sed 's/^/relationship without cardinality at both ends: /' ;;
    be-class)
      grep -nE '\+[A-Za-z_][A-Za-z0-9_]*[[:space:]]*$' "$_b" | sed 's/^/method without parentheses: /' ;;
    fe-components)
      grep -qE '^[[:space:]]*classDiagram' "$_b" ||
        awk '/^[ \t]*%% ⚠ missing:/ { g = 1; next } /^[ \t]*[A-Za-z0-9_]+\["/ { if (!g && $0 !~ /owns:/) print "node without owns: " $0 } { g = 0 }' "$OUT" ;;
    sequence-*)
      for _k in autonumber alt else 'end'; do grep -qE "^[[:space:]]*$_k([[:space:]]|\$)" "$_b" || printf 'missing %s\n' "$_k"; done ;;
    state-*)
      grep -qE '^[[:space:]]*\[\*\] -->' "$_b" || grep -qiE '%% ⚠ missing:.*(start|initial)' "$OUT" || echo "no start"
      grep -qE -- '--> \[\*\]' "$_b" || grep -qiE '%% ⚠ missing:.*(end|final|terminal)' "$OUT" || echo "no end" ;;
  esac
}

# dd_render — step 8. Never installs anything. First field: verified | unverified | parse (your syntax: fix, re-run).
dd_render() {
  if ! command -v mmdc >/dev/null 2>&1; then echo 'unverified|mmdc not on PATH'; return 0; fi
  if mmdc -q -i "$OUT" -o "$tmp/$T.svg" > "$tmp/mmdc.log" 2>&1 && [ -s "$tmp/$T.svg" ]; then echo 'verified|mmdc -> exit 0, SVG in temp dir'; return 0; fi
  _e=$(grep -m1 -E 'Parse error|Syntax error|Lexical error|No diagram type detected' "$tmp/mmdc.log")
  if [ -n "$_e" ]; then printf 'parse|mmdc failed: %s\n' "$_e"; else printf 'unverified|mmdc failed: %s\n' "$(grep -m1 . "$tmp/mmdc.log")"; fi
}

# dd_counts — the numbers for STOP and the result's ## Changes (counted, never remembered).
dd_counts() {
  _b="$tmp/out.body"; grep -vE '^[[:space:]]*%%' "$OUT" > "$_b"
  case $T in
    erd) printf '%s entities, %s relationships\n' "$(grep -cE '^[[:space:]]*[A-Za-z0-9_]+[[:space:]]*\{[[:space:]]*$' "$_b")" "$(grep -cE '[|}][|o](--|\.\.)[|o][|{]' "$_b")" ;;
    sequence-*) printf '%s participants, %s messages\n' "$(grep -cE '^[[:space:]]*(actor|participant) ' "$_b")" "$(grep -cE -- '->>|-\)' "$_b")" ;;
    state-*) printf '%s states, %s transitions\n' "$(grep -E -- '-->' "$_b" | sed -E 's/:.*//; s/-->/ /' | tr -s ' \t' '\n\n' | grep -vE '^(\[\*\])?$' | sort -u | grep -c .)" "$(grep -E -- '-->' "$_b" | grep -cvE '\[\*\]')" ;;
    *) if grep -qE '^[[:space:]]*C4Context' "$_b"; then
         printf '%s elements, %s relationships\n' "$(grep -cE '^[[:space:]]*(Person|System|System_Ext)\(' "$_b")" "$(grep -cE '^[[:space:]]*Rel\(' "$_b")"
       elif grep -qE '^[[:space:]]*classDiagram' "$_b"; then
         printf '%s classes, %s relationships\n' "$(grep -cE '^[[:space:]]*class ' "$_b")" "$(grep -cE -- '<\|--|<\|\.\.|\*--|o--|\.\.>|-->' "$_b")"
       else
         printf '%s nodes, %s edges\n' "$(grep -cE '^[[:space:]]*[A-Za-z0-9_]+[[(]' "$_b")" "$(grep -cE -- '-->|-\.->' "$_b")"
       fi ;;
  esac
}

# dd_done — every Done-when check; prints one line per failure, nothing when the run is done.
dd_done() {
  [ -s "$OUT" ] || { echo "no $OUT"; return 0; }
  # only $OUT (and the result file, when it lives in this checkout) changed; -uall lists untracked files one by one,
  # so a new diagrams/ folder is not one opaque "?? docs/" line
  git status --porcelain -uall | diff "$tmp/before.txt" - | sed -n 's/^> ...//p' > "$tmp/changed"
  git diff --name-only "$BASE" HEAD >> "$tmp/changed"
  _ret=${RET#"$(git rev-parse --show-toplevel)"/}
  sed '/^$/d' "$tmp/changed" | grep -vxF -e "$OUT" -e "${_ret:-$OUT}" | sort -u | sed 's/^/changed besides the diagram: /'
  cksum docs/architecture/*.md | diff "$tmp/docs.ck" - > /dev/null || echo "a design doc changed during the run"
  head -1 "$OUT" | grep -qxF "%% diagram: $T" || echo "header: first line is not %% diagram: $T"
  grep '^%% source: ' "$OUT" | diff "$tmp/sources" - > /dev/null || echo "header: %% source: lines differ from $tmp/sources"
  [ "$(grep -cE '^%% render: (verified|unverified)$' "$OUT")" = 1 ] || echo "header: needs exactly one '%% render: verified|unverified'"
  for _h in drawn render-check missing; do grep -qE "^%% $_h: " "$OUT" || echo "header: no '%% $_h:' line"; done
  [ "$(grep -cE '^[[:space:]]*%% ⚠ missing:' "$OUT")" = "$(sed -n 's/^%% missing: //p' "$OUT")" ] || echo "header: '%% missing:' differs from the number of gap lines"
  grep -nE '\{\{|\}\}|^```' "$OUT" | sed 's/^/unfilled placeholder or fence: /'
  grep -nE '[^[:space:]][^%]*%%|%%\{' "$OUT" | sed 's/^/inline or directive comment: /'
  dd_kind; dd_trace; dd_typecheck
  if [ -n "$RET" ]; then
    [ -s "$RET" ] || { echo "no result at $RET"; return 0; }
    _st=$(sed -n 's/^status:[[:space:]]*//p' "$RET" | head -1)
    case $_st in done|human_review|relaunch) ;; *) echo "result: status '$_st' is not done|human_review|relaunch" ;; esac
    [ "$(grep -cE '^[[:space:]]*%% ⚠ missing:' "$OUT")" = 0 ] || [ "$_st" = human_review ] || echo "result: gaps drawn but status is $_st"
  fi
}

# dd_secrets — lines to eyeball: a column or noun called token is fine, a value is not.
dd_secrets() { grep -niE 'password|secret|token|api[_-]?key|BEGIN [A-Z ]*PRIVATE' "$OUT"; }
```
