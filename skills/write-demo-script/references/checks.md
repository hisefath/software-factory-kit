# write-demo-script checks

Read this file only when SKILL.md step 1 or Done when sends you here. The `sh` block below is the whole check
kit: plain POSIX tools only (awk, sed, grep, comm, wc), nothing installed, nothing deleted, no `python`. Every
function prints one line per problem and **prints nothing when the files are sound** (except `grade` and the
counters `runtime` and `count_*`, which print a number).

Install it once per run (step 1), from the project root:

```text
WDS="${TMPDIR:-/tmp}/write-demo-script"; mkdir -p "$WDS"
awk '/^```sh$/{f=1;next} /^```$/{f=0} f' "<this skill's folder>/references/checks.md" > "$WDS/checks.sh"
```

Then start every check command with `. "${TMPDIR:-/tmp}/write-demo-script/checks.sh";` (each shell is fresh when
Codex runs you, so source it every time).

| Function | Checks | Clean output |
|---|---|---|
| `headings` | both files have every template heading, in order | nothing |
| `timing G <max s> [min s]` / `timing S 120` | m:ss format, no gaps or overlaps, hook ends by 0:05, cut length inside max (and min, when given), ≤ 2.5 spoken words per second, ≤ 7 on-screen words, voiceover ends with `.` `!` `?` | nothing |
| `parts G` / `parts S` | all seven parts present, in story order | nothing |
| `beats` | every shot has a beat id; every Demo beats row's shot id, time and beat id match the shot list, both ways | nothing |
| `reqs` | every demo requirement row names at least one shot | nothing |
| `claims` | claim ids defined once, every used id defined, every defined id used | nothing |
| `evidence` | every claim has a Kind and a `path:line`, the file is committed, the line exists; `does`/`proof` claims cite a shipped milestone's report or acceptance file | nothing |
| `numbers` | every number said or posted appears in a claim | nothing |
| `picture` | the one diagram path exists | nothing |
| `counts` | frontmatter `grader_cut`, `social_cut`, `reading_grade` and both "Runs" lines equal `runtime` and `grade` | nothing |
| `posts` | X ≤ 280 chars, thread posts ≤ 280, LinkedIn 150-300 words, the written counts equal the counted ones, hashtag counts, hashtags appear in the post text, alt text rows ≤ 250 chars | nothing |
| `privacy` | no secrets, no tokens in URLs | nothing |
| `emoji` | no emoji in shots or POSTS.md | nothing |
| `hype` | no hype words (plain-words.md rule 5) said, shown or posted | nothing |
| `opener` | neither cut opens with a greeting ("Hi, I'm…") | nothing |
| `partner '<Name\|Name>'` | the names appear nowhere in the social cut or POSTS.md | nothing |
| `runtime G\|S`, `count_shots G\|S`, `count_claims`, `count_cut`, `count_warn` | counters for frontmatter, STOP and Part C | a number (`runtime`: m:ss) |
| `spoken \| grade`, `posted \| grade` | reading grade estimate (Flesch-Kincaid; hashtags and links ignored, a line end ends a sentence) | `grade 5.8 (…)` — must be below 7.0 |
| `{ spoken; posted; } \| long` | sentences over 15 words | nothing |

```sh
# write-demo-script check kit. Source from the project root.
S=docs/demo/SCRIPT.md
P=docs/demo/POSTS.md
T="${TMPDIR:-/tmp}/write-demo-script"   # scratch files; never committed

# headings — every required heading of both files, in template order
headings() {
  grep -E '^#{2,3} ' "$S" | grep -E '^## |^### [1-7]\. |^### (Grader|Social) storyboard$' > "$T/h.txt"
  printf '%s\n' '## At a glance' '## Demo requirements' '## Words we explain' '## Script' '### 1. Hook' \
    '### 2. The problem' '### 3. Demo beats' '### 4. How it works in one picture' '### 5. Proof' \
    "### 6. What's next" '### 7. Call to action' '## Grader cut' '### Grader storyboard' '## Social cut' \
    '### Social storyboard' '## Claims' '## Cut claims' '## Open questions' '## Review notes' |
    diff - "$T/h.txt" | sed -n 's/^< /SCRIPT.md missing or out of order: /p; s/^> /SCRIPT.md unexpected heading: /p'
  grep -E '^## ' "$P" > "$T/hp.txt"
  printf '%s\n' '## X post' '## X thread (optional)' '## LinkedIn post' '## Alt text' '## Hashtags' |
    diff - "$T/hp.txt" | sed -n 's/^< /POSTS.md missing or out of order: /p; s/^> /POSTS.md unexpected heading: /p'
}

# shots G|S — the shot rows of one cut, tab-separated: id time part screen action voiceover onscreen claims beat
shots() {
  awk -F'|' -v c="$1" '$2 ~ "^ *" c "-[0-9][0-9] *$" {
    for (i = 2; i <= 10; i++) gsub(/^ +| +$/, "", $i)
    print $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9 "\t" $10 }' "$S"
}

# timing G|S <max seconds> [min seconds]
timing() {
  shots "$1" | awk -F'\t' -v max="$2" -v min="${3:-0}" '
    function sec(t,  a) { split(t, a, ":"); return a[1] * 60 + a[2] }
    { if (split($2, r, "-") != 2 || r[1] !~ /^[0-9]+:[0-5][0-9]$/ || r[2] !~ /^[0-9]+:[0-5][0-9]$/) {
        print $1 ": time must be m:ss-m:ss, got \"" $2 "\""; next }
      b = sec(r[1]); e = sec(r[2]); d = e - b
      if (seen[$1]++) print $1 ": duplicate shot id"
      if (NR == 1 && b != 0) print $1 ": the first shot must start at 0:00"
      if (NR > 1 && b != end) print $1 ": starts at " r[1] " but the shot before ends at " last
      if (d <= 0) print $1 ": ends before it starts"
      if ($3 == "Hook" && e > 5) print $1 ": the hook must end by 0:05"
      if ($6 != "—" && $6 !~ /[.!?]"?$/) print $1 ": voiceover must end with . ! or ? (use — for silence)"
      n = split($6, w, / +/); if ($6 != "—" && n > d * 2.5) print $1 ": " n " spoken words in " d " s (max " int(d * 2.5) ")"
      m = split($7, o, / +/); if (m > 7) print $1 ": " m " on-screen words (max 7)"
      if ($8 == "") print $1 ": Claims cell empty (use — when the shot states no fact)"
      end = e; last = r[2] }
    END { if (NR == 0) print "no shots for this cut"
          else { if (end > max) print "cut runs " end " s, max " max " s"; if (end < min) print "cut runs " end " s, min " min " s" } }'
}

# parts G|S — Hook, Problem, Demo, How it works, Proof, Next, Call to action: all present, in this order
parts() {
  shots "$1" | awk -F'\t' '
    BEGIN { n = split("Hook,Problem,Demo,How it works,Proof,Next,Call to action", P, ","); for (i = 1; i <= n; i++) k[P[i]] = i }
    { j = k[$3]; if (!j) { print $1 ": unknown part \"" $3 "\""; next }
      if (j < at) print $1 ": " $3 " comes after " P[at]; seen[j] = 1; at = j }
    END { for (i = 1; i <= n; i++) if (!seen[i]) print "missing part: " P[i] }'
}

# beats — each "G-04 · 0:25-0:40" cell in the Demo beats table matches the shot list; every shot names its beat
beats() {
  awk -F'|' '/^\| B[0-9]+ \|/ { print $6; print $7 }' "$S" | grep -oE '[GS]-[0-9]{2} · [0-9]+:[0-9]{2}-[0-9]+:[0-9]{2}' |
  while IFS= read -r x; do
    id=${x%% *}; t=${x##* }
    shots "${id%%-*}" | awk -F'\t' -v id="$id" -v t="$t" '$1 == id && $2 == t { ok = 1 } END { if (!ok) print id ": beat time " t " does not match the shot list" }'
  done
  awk -F'|' '/^\| B[0-9]+ \|/ && $6 !~ /G-[0-9]{2}/ { print $2 ": every beat must appear in the grader cut" }' "$S"
  # every shot names its footage: record-demo plans, shoots and checks by these ids
  { shots G; shots S; } | awk -F'\t' '$9 !~ /^B[0-9]+$/ { print $1 ": Beat cell must be one beat id like B3, got \"" $9 "\"" }'
  # Demo beats table <-> Demo shots: same shot, same beat id, both ways
  awk -F'|' '/^\| B[0-9]+ \|/ { b = $2; gsub(/ /, "", b)
      for (i = 6; i <= 7; i++) { c = $i; while (match(c, /[GS]-[0-9][0-9]/)) { print substr(c, RSTART, RLENGTH) " " b; c = substr(c, RSTART + RLENGTH) } } }' "$S" |
    LC_ALL=C sort > "$T/bt.txt"
  { shots G; shots S; } | awk -F'\t' '$3 == "Demo" { print $1 " " $9 }' | LC_ALL=C sort > "$T/bs.txt"
  LC_ALL=C comm -23 "$T/bt.txt" "$T/bs.txt" | sed 's/^/Demo beats table has (shot beat) /; s/$/, the shot list does not/'
  LC_ALL=C comm -13 "$T/bt.txt" "$T/bs.txt" | sed 's/^/Demo shot (shot beat) /; s/$/ is not in the Demo beats table/'
}

# reqs — every row of the Demo requirements table names at least one shot
reqs() {
  awk '/^## Demo requirements/ { f = 1; next } /^## / { f = 0 } f && /^\| / && !/^\| *(Source|---)/' "$S" |
    awk -F'|' '$4 !~ /[GS]-[0-9]{2}/ { print "requirement not shown in any shot: " $2 }'
}

# claimrows — the rows of the ## Claims table only (the Proof table also starts rows with C ids)
claimrows() { awk '/^## Claims$/ { f = 1; next } /^## / { f = 0 } f && /^\| C[0-9]+ \|/' "$S"; }

# claims — ids defined once; every used id defined; every defined id used
claims() {
  claimrows | awk -F'|' '{ gsub(/ /, "", $2); print $2 }' | LC_ALL=C sort > "$T/def.txt"
  { shots G | cut -f8; shots S | cut -f8; grep -oE 'Claims: [^·]*' "$P"; } | grep -oE 'C[0-9]+' | LC_ALL=C sort -u > "$T/use.txt"
  uniq "$T/def.txt" > "$T/defu.txt"
  uniq -d "$T/def.txt" | sed 's/^/claim id defined twice: /'
  LC_ALL=C comm -13 "$T/defu.txt" "$T/use.txt" | sed 's/^/used but not in Claims: /'
  LC_ALL=C comm -23 "$T/defu.txt" "$T/use.txt" | sed 's/^/in Claims but never used (cut it): /'
}

# evidence — every claim has a Kind and cites `path:line`; the file is committed; the line exists and is not blank;
# a does/proof claim cites a shipped milestone's report or acceptance file (frontmatter shipped: [M1, M2])
evidence() {
  claimrows | awk -F'|' '$5 !~ /`[^` ]+:[0-9]+`/ { gsub(/ /, "", $2); print $2 ": no `path:line` in Evidence" }'
  sh=$(grep -m1 '^shipped:' "$S" | sed 's/^shipped://' | tr -d '[] ' | tr ',' '|')
  claimrows | awk -F'|' -v sh="$sh" '{ id = $2; k = $3; gsub(/ /, "", id); gsub(/ /, "", k)
      if (k !~ /^(problem|does|proof|next)$/) { print id ": Kind must be problem, does, proof or next, got \"" k "\""; next }
      if (k != "does" && k != "proof") next
      ok = 0; e = $5
      while (match(e, /`[^` ]+:[0-9]+`/)) { p = substr(e, RSTART + 1, RLENGTH - 2); sub(/:[0-9]+$/, "", p)
        if (sh != "" && (p ~ ("^docs/milestones/(" sh ")[.]md$") || p ~ ("^specs/(" sh ")-[^/]+/acceptance[.]md$"))) ok = 1
        e = substr(e, RSTART + RLENGTH) }
      if (!ok) print id ": a " k " claim must cite docs/milestones/M<N>.md or specs/M<N>-*/acceptance.md of a shipped milestone (shipped: " (sh == "" ? "none" : sh) ")" }'
  claimrows | awk -F'|' '{ print $5 }' | grep -oE '`[^` ]+:[0-9]+`' | tr -d '`' | LC_ALL=C sort -u |
  while IFS= read -r ref; do
    f=${ref%:*}; l=${ref##*:}
    if [ ! -f "$f" ]; then echo "evidence file missing: $f"
    elif ! git ls-files --error-unmatch -- "$f" > /dev/null 2>&1; then echo "evidence file not committed: $f"
    elif [ -z "$(sed -n "${l}p" "$f" | tr -d '[:space:]')" ]; then echo "evidence line blank or past the end: $ref"
    fi
  done
}

# spoken / posted — every word a viewer hears or reads in a post
spoken() { { shots G; shots S; } | cut -f6 | grep -vx '—'; }
post() { awk -v h="$1" '$0 == h { f = 1; next } f && /^#+ / { exit } f && /^```/ { b = !b; next } f && b' "$P"; }
posted() { for h in '## X post' '### 1/3' '### 2/3' '### 3/3' '## LinkedIn post'; do post "$h"; done; }

# numbers — every number said, shown or posted appears in the Claim column of the Claims table
nums() { tr -c 'A-Za-z0-9.,:%/\n' ' ' | tr -s ' ' '\n' | grep -E '^[0-9]' | sed -E 's/[.,:]+$//' | grep -vE '^[0-9]+/[0-9]+$' | LC_ALL=C sort -u; }
numbers() {
  { spoken; shots G | cut -f7; shots S | cut -f7; posted; } | nums > "$T/said.txt"
  claimrows | awk -F'|' '{ print $4 }' | nums > "$T/backed.txt"
  LC_ALL=C comm -23 "$T/said.txt" "$T/backed.txt" | sed 's/^/number not in any claim: /'
}

# picture — exactly one diagram is referenced, and it exists
picture() {
  n=$(awk '/^### 4\. How it works/ { f = 1; next } /^#{2,3} / { f = 0 } f' "$S" | grep -oE 'docs/architecture/diagrams/[A-Za-z0-9_-]+\.mmd' | LC_ALL=C sort -u | tee "$T/pic.txt" | wc -l | tr -d ' ')
  [ "$n" = 1 ] || echo "How it works must name exactly one diagram, found $n"
  while IFS= read -r f; do [ -f "$f" ] || echo "diagram missing: $f"; done < "$T/pic.txt"
}

# counters — the numbers for frontmatter, the Runs lines, STOP and Part C (counts come from commands, never memory)
runtime() { shots "$1" | tail -1 | cut -f2 | sed 's/.*-//'; }
count_shots() { shots "$1" | wc -l | tr -d ' '; }
count_claims() { claimrows | wc -l | tr -d ' '; }
count_cut() { awk '/^## Cut claims$/ { f = 1; next } /^## / { f = 0 } f && /^\| / && !/^\| *(What we wanted|---)/' "$S" | wc -l | tr -d ' '; }
count_warn() { awk '/^## Open questions$/ { f = 1; next } /^## / { f = 0 } f' "$S" | grep -c '⚠'; }

# counts — what SCRIPT.md says about itself equals what the counters count
counts() {
  for c in G S; do
    if [ "$c" = G ]; then key=grader_cut; h='## Grader cut'; else key=social_cut; h='## Social cut'; fi
    r=$(runtime "$c")
    v=$(grep -m1 "^$key:" "$S" | grep -oE '[0-9]+:[0-9]{2}')
    [ "$v" = "$r" ] || echo "frontmatter $key says ${v:-nothing}, runtime $c is $r"
    v=$(awk -v h="$h" '$0 == h { f = 1; next } /^#{2,3} / { f = 0 } f' "$S" | grep -oE 'Runs [0-9]+:[0-9]{2}' | head -1 | cut -c6-)
    [ "$v" = "$r" ] || echo "$h: Runs line says ${v:-nothing}, runtime $c is $r"
  done
  g="spoken: $(spoken | grade | cut -d' ' -f2) · posts: $(posted | grade | cut -d' ' -f2)"
  grep -m1 '^reading_grade:' "$S" | grep -qF "$g" || echo "reading_grade must read \"$g\""
}

# xchars <heading> — X's count: every URL (and the [video link] marker) counts as 23 characters
xchars() {
  post "$1" | sed -E 's#https?://[^[:space:]]+#xxxxxxxxxxxxxxxxxxxxxxx#g; s#\[video link\]#xxxxxxxxxxxxxxxxxxxxxxx#g' |
    LC_ALL=en_US.UTF-8 wc -m | awk '{ print $1 - 1 }'
}
section() { awk -v h="$1" '$0 == h { f = 1; next } /^## / { f = 0 } f' "$P"; }

# posts — lengths, hashtags, alt text
posts() {
  n=$(xchars '## X post'); { [ "$n" -ge 1 ] && [ "$n" -le 280 ]; } || echo "X post: $n characters (allowed 1-280)"
  if grep -qx '### 1/3' "$P"; then
    for h in '### 1/3' '### 2/3' '### 3/3'; do
      n=$(xchars "$h"); { [ "$n" -ge 1 ] && [ "$n" -le 280 ]; } || echo "thread $h: $n characters (allowed 1-280)"
    done
  fi
  w=$(post '## LinkedIn post' | wc -w | tr -d ' '); { [ "$w" -ge 150 ] && [ "$w" -le 300 ]; } || echo "LinkedIn: $w words (allowed 150-300)"
  # the counts written under each post must be the counted ones (counts come from commands, never memory)
  c=$(section '## X post' | grep '^Characters:' | grep -oE '[0-9]+' | head -1)
  [ "$c" = "$(xchars '## X post')" ] || echo "X post: Characters line says ${c:-nothing}, xchars counts $(xchars '## X post')"
  if grep -qx '### 1/3' "$P"; then
    c=$(section '## X thread (optional)' | grep '^Characters:' | sed 's/ · .*//' | grep -oE '[0-9]+' | tr '\n' ' ')
    [ "$c" = "$(xchars '### 1/3') $(xchars '### 2/3') $(xchars '### 3/3') " ] || echo "X thread: Characters line says ${c:-nothing}, xchars counts $(xchars '### 1/3') $(xchars '### 2/3') $(xchars '### 3/3')"
  fi
  c=$(section '## LinkedIn post' | grep '^Words:' | grep -oE '[0-9]+' | head -1)
  [ "$c" = "$w" ] || echo "LinkedIn: Words line says ${c:-nothing}, wc -w counts $w"
  hx=$(section '## Hashtags' | grep '^- X:' | grep -oE '#[A-Za-z0-9_]+' | wc -l | tr -d ' ')
  { [ "$hx" -ge 1 ] && [ "$hx" -le 2 ]; } || echo "X hashtags: $hx (allowed 1-2)"
  hl=$(section '## Hashtags' | grep '^- LinkedIn:' | grep -oE '#[A-Za-z0-9_]+' | wc -l | tr -d ' ')
  { [ "$hl" -ge 3 ] && [ "$hl" -le 5 ]; } || echo "LinkedIn hashtags: $hl (allowed 3-5)"
  for pair in 'X:## X post' 'LinkedIn:## LinkedIn post'; do
    section '## Hashtags' | grep "^- ${pair%%:*}:" | grep -oE '#[A-Za-z0-9_]+' | while IFS= read -r tag; do
      post "${pair#*:}" | grep -qF -- "$tag" || echo "${pair%%:*} hashtag $tag is not in the post text"
    done
  done
  section '## Alt text' | grep -E '^\| ' | grep -vE '^\| *(Media|---)' > "$T/alt.txt"
  [ -s "$T/alt.txt" ] || echo "Alt text: no rows"
  awk -F'|' '{ t = $3; gsub(/^ +| +$/, "", t); if (t == "") print "alt text empty for" $2; else if (length(t) > 250) print "alt text over 250 characters for" $2 }' "$T/alt.txt"
}

# privacy — tokens in URLs and secret-shaped strings (names of people are checked by eye, see SKILL.md)
privacy() {
  grep -nE '[?&#](access_token|id_token|token|code|key|api_key|secret|password|session|sig|signature)=' "$S" "$P"
  grep -nE 'BEGIN [A-Z ]*PRIVATE KEY|sk-[A-Za-z0-9_-]{16,}|gh[pousr]_[A-Za-z0-9]{20,}|glpat-[A-Za-z0-9_-]{16,}|AKIA[0-9A-Z]{16}|xox[abp]-[A-Za-z0-9-]{10,}' "$S" "$P"
}

# emoji — UTF-8 lead bytes of the emoji (U+1F000+) and dingbat (U+2700-27BF) blocks, in shots and POSTS.md
# ponytail: byte match; misses U+2600-26FF symbols (that block holds the allowed ⚠), so a glance still helps
emoji() { { shots G; shots S; cat "$P"; } | LC_ALL=C grep -E "$(printf '\360\237|\342\234|\342\235|\342\236')" | sed 's/^/emoji: /'; }

# hype — plain-words.md rule 5, in everything said, shown or posted
hype() {
  { spoken; shots G | cut -f7; shots S | cut -f7; posted; } |
    grep -iwE 'revolutionary|seamless|seamlessly|robust|game-changing|cutting-edge|leverage|utilize|simply|just|magic' |
    sed 's/^/hype word: /'
}

# opener — the first words of each cut are the hook, never a greeting
opener() {
  for c in G S; do
    shots "$c" | head -1 | cut -f6 |
      grep -iE "^[\"“]?(hi|hello|hey)([^a-z]|$)|^[\"“]?(i am|i'm|i’m|my name|today i|in this video)" |
      sed "s/^/$c cut opens with a greeting: /"
  done
}

# partner '<Name|Name>' — partner names in the social cut or the posts (skip when a REQ/U row or the human clears it)
partner() { [ -n "$1" ] || return 0; { shots S; cat "$P"; } | grep -iwE -- "$1" | sed 's/^/partner named in public copy: /'; }

# prose — stdin as one sentence per line, without hashtags, links and the [video link] marker.
# A line end is a sentence end too: voiceover cells and post paragraphs are one line each.
prose() {
  sed -E 's#https?://[^[:space:]]+##g; s#\[video link\]##g; s/(^|[[:space:]])#[A-Za-z0-9_]+/\1/g' |
    awk '{ gsub(/[.!?]+["”)]*([[:space:]]+|$)/, "&\n"); print }' |
    sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//' | grep -E '[A-Za-z0-9]'
}

# grade — Flesch-Kincaid grade estimate of the prose on stdin (a heuristic: aim for 4-6, must be below 7.0)
grade() {
  prose | awk '
    function syl(w,  n, t) {
      w = tolower(w); gsub(/[^a-z]/, "", w); if (w == "") return 0
      if (length(w) <= 3) return 1
      t = w
      if (t ~ /[^aeiouystxzdgch]es$/ || t ~ /[^aeioutd]ed$/) t = substr(t, 1, length(t) - 2)
      else if (t ~ /[^aeiouyl]e$/ || t ~ /[aeiouy]le$/) t = substr(t, 1, length(t) - 1)
      n = gsub(/[aeiouy]+/, "", t)
      return n < 1 ? 1 : n }
    { s++; n = split($0, W, /[[:space:]]+/); for (i = 1; i <= n; i++) { k = syl(W[i]); if (k) { words++; sy += k } } }
    END {
      if (!words) { print "grade n/a (no words)"; exit }
      printf "grade %.1f (%d words, %d sentences, %.2f syllables per word)\n", 0.39 * words / s + 11.8 * sy / words - 15.59, words, s, sy / words }'
}

# long — sentences over 15 words
long() { prose | awk '{ n = 0; for (i = 1; i <= NF; i++) if ($i ~ /[A-Za-z0-9]/) n++; if (n > 15) print n " words: " $0 }'; }
```
