# route-failure output skeleton

Six parts. Part 0 is a scratch file; Parts 1-4 are written to files; Part 5 is chat only. Fill every `<...>`; an
unknown is `⚠ <question>`, never a guess. No `|` inside a table cell. Times from `date`, counts from commands. Never
paste secrets, tokens, PHI, real personal data or an absolute home path: `<redacted: kind>`.
`$KIT` = `${FACTORY_KIT_DIR:-$HOME/Desktop/gauntlet_workbench/software-factory-kit}`.

---

## Part 0: the pass's env file (scratch, never committed; once per pass)

Run in bash from the project repo root (software-factory-kit mode: the software-factory-kit root). It prints the env file's path;
start every later command with `. <that path> &&`, because shell state does not survive between commands.

```
ROOT=$(git rev-parse --show-toplevel) && PROJECT=$(basename "$ROOT") &&
KIT="${FACTORY_KIT_DIR:-$HOME/Desktop/gauntlet_workbench/software-factory-kit}" &&
tmp=$(mktemp -d "${TMPDIR:-/tmp}/route-failure-$PROJECT.XXXXXX") &&
{ printf "set -o pipefail\nKIT='%s'\nROOT='%s'\nPROJECT='%s'\ntmp='%s'\ncd '%s' || return 1\n" \
    "$KIT" "$ROOT" "$PROJECT" "$tmp" "$ROOT"
  cat <<'EOF'
hx() { out=$(awk -v h="### H$1 " 'index($0,h)==1{f=1;next} f&&/^### /{exit} f&&/^```diff$/{d=1;next} d&&/^```$/{exit} d' "$KIT/HARNESS_CHANGELOG.md") || return 1
  [ -n "$out" ] || { echo "hx: no diff for H$1 in $KIT/HARNESS_CHANGELOG.md" >&2; return 1; }
  printf '%s\n' "$out"; }
EOF
} > "$tmp/env.sh" && echo "$tmp/env.sh"
```

`hx <n>` prints block H<n>'s diff exactly as stored in `$KIT/HARNESS_CHANGELOG.md` and fails loudly when there is
none. Every pass gets a fresh `mktemp -d` directory, so an aborted pass leaves nothing behind
that a later diff could pick up.

---

## Part 1: FINDINGS row (append to the table in `$KIT/FINDINGS.md`)

One row per failure. Columns are fixed by the file's header:
`| F# | Date | Project | Symptom | Layer | Proposed fix | Status | Guard |`

```
| F<n> | <YYYY-MM-DD from date> | <PROJECT> | <observable symptom, one line, no blame> (ev: <pointer>) | <layer, verbatim from WORKFLOW.md §10> | <the change in one line; "see H<n>" when a diff exists> | <status> | <runnable check, or ⚠ no mechanical guard: why> |
```

- **Evidence pointer** `(ev: …)`: one or more of the forms below, separated by ` ; `, each copying its source's
  timestamp exactly as written there, so `grep -F` finds it again and a second pass on the same day skips it. No
  `)` or `|` inside a pointer.
  `TRACKER Log <timestamp as written> FAIL M<N>-T###` (or `ESCALATE`) ·
  `TRACKER Approvals <time as written> <gate> Revise` (or `Stop`) · `task M<N>-T### <failed or human_review>` ·
  `M<N>-pass<k> R<n> <fix, file or discard> per Approvals <time as written>` · `runs/M<N>-T###/result.md` ·
  `specs/bugs/<slug>.md` · `human <YYYY-MM-DD HH:MM>: "<at most 12 words>"` · `<commit sha>`.
  Add `recurs F<m>` when history shows the same cause.
- **Layer** is one of: Tests/types · Lint / structural test · Policy (hard) · Verification/hooks · Spec ·
  AGENTS.md · Skill · Skill description/routing · Script · Environment · Agent policy · Architecture · Settings ·
  Session hygiene · nothing durable.
- **Status** is one of: `proposed (H<n>)` · `approved (H<n>)` · `adopted (H<n>)` · `rejected (H<n>)` ·
  `routed → <skill>` · `routed → <skill> + proposed (H<n>)` · `logged` · `superseded by F<m>`
  (lifecycle: `references/routing.md` §8).

Example:

```
| F3 | 2026-10-09 | cerbo-store | Worker claimed done; make check was red on main (ev: TRACKER Log 2026-10-09 21:14 CDT FAIL M1-T004) | Verification/hooks | Stop hook runs make check before a worker may finish; see H2 | proposed (H2) | scripts/test.sh case "stop hook blocks red check" exits 0 |
```

---

## Part 2: proposal block (under `## Proposals` at the end of `$KIT/HARNESS_CHANGELOG.md`)

If `## Proposals` is missing, append it once, with this comment, after the table:

```
## Proposals

<!-- Written by route-failure. One block per F per repo, status in the heading:
     proposed | approved | adopted | revise | rejected | stale | superseded by H<m>.
     A filed block's diff never changes; a changed diff is a new block that supersedes it.
     The human approves the exact diff bytes at G-L5; the approval binds to their hash, not to a commit:
     .handoff/TRACKER.md ## Approvals | time | G-L5 | H<n>@<diff-sha256> | exact words |
     (software-factory-kit mode: the block's Verdict line). Nothing here is applied before that record exists. -->
```

Each block, exactly:

````
### H<n> <imperative title, at most 8 words>  [status: proposed]

- F#: F<n> (two rows only when two fixes in one pass touch the same file) · Layer: <layer> · Reach: <task, project,
  factory template, factory skill or WORKFLOW.md>
- Proposed: <date> by route-failure (<harness>, <model id>) · Project: <PROJECT>
- Apply in: <software-factory-kit or PROJECT> (repo root; never an absolute path) · Files: `<rel path>`, `<rel path>`
- Root cause: <symptom → why → why → the harness gap, one line>
- Why this layer: <the §10 row, and why not the earlier preference step; one plain sentence>
- Rules: `<rel path>` <before> → <after> (ceiling <~20 rules, 6 red-flag rows or 300 lines>); pruned:
  <the rule removed or merged, and why; or none: below ceiling>
- Guard: <the check that would catch a recurrence, with its expected result>
- Teach: <one sentence the human could say in an interview about this tradeoff>
- diff-sha256: <first 12 hex of the diff bytes below>
- Verdict: pending G-L5

```diff
--- a/<rel path>
+++ b/<rel path>
@@ -<l>,<n> +<l>,<n> @@
 <context>
-<removed line>
+<added line>
```
````

Hash, check or apply the diff exactly as stored (`<apply-in>` = `$KIT` for `software-factory-kit`, `$ROOT` for the project):

```
hx <n> | shasum -a 256 | cut -c1-12          # diff-sha256; e3b0c44298fc means hx found nothing
hx <n> | git -C <apply-in> apply --check      # exit 0: applies cleanly, the proposal is still valid
hx <n> | git -C <apply-in> apply --check -R   # exit 0: already applied (adopted)
```

Applying is human-only; the STOP message prints a command that refuses unless the hash matches.

When recording a verdict (step 2), change only the heading's status and the `Verdict:` line:
`Verdict: <approved, adopted, revise, rejected or stale> <date> (Approvals <time>, H<n>@<hash>, "<exact words>")`.

---

## Part 3: adopted row (append to the table at the top of `$KIT/HARNESS_CHANGELOG.md`)

Only in step 2, once the diff is applied. Columns are fixed by the file's header:
`| Date | Version | Change | F# | Approved by (exact words) |`

```
| <date applied> | <version from the table's last row; never bump it yourself> | H<n>: <title> (<rel paths>) | F<n> | "<the human's exact words from the Approvals row>" |
```

---

## Part 4: `docs/learnings/<slug>.md` (in the project repo; durable, non-obvious lessons only)

The frontmatter `status:` is the only place the verdict lives; step 2 updates it.

```
---
learning: <slug>
date: <date>
project: <PROJECT>
finding: F<n>
proposal: <H<n>, or none>
layer: <layer>
status: <proposed, adopted or rejected>
---

# <the lesson as one rule sentence>

## What happened

<2-4 plain sentences: what the agent did, what it should have done, how it was noticed, what it cost (time,
rework, a wrong artifact). No blame, no secrets, no patient data.>

## Why it happened

<the why-chain from the symptom to the harness gap, one line per step>
1. <symptom>
2. <why>
3. <harness gap: missing check, missing tool, unclear rule, wrong default or wrong harness>

## The rule now

<the rule in one sentence>
- Enforced by: <file, check or hook that holds it once H<n> is adopted; see the frontmatter status>
- Interview line: <one sentence the human would say out loud about this lesson>

## Evidence

- <the F row's evidence pointers, human words quoted in at most 12 words>
- Guard: <the check from F<n>>
- Factory record: `FINDINGS.md` F<n>, `HARNESS_CHANGELOG.md` H<n>
```

---

## Part 5: G-L5 cards (chat only, never written to a file)

One proposal per reply, highest impact first (the STOP message carries Decision 1). WORKFLOW.md §5 order:
question · background · options with costs · recommendation · default.

```
Decision <k> · Question (G-L5): "Which layer owns this, adopt this fix?"
  F<n> → H<n> · layer: <layer> · reach: <reach> · rules in <file>: <before> → <after>
  Layer in plain words: <routing.md §2 "why it ranks here" sentence for this layer's step>
  Reach in plain words: <who reads this change: one task, this project, or every future project>
  Background: <what failed, for whom, how we know; plain words>
  A (recommended) adopt H<n>: <the change in one plain sentence> · cost: <what it costs>
  B <the next layer in the preference order>: <the change> · cost: <what it costs>
  C do nothing (log only): revisit if <trigger> · cost: it can happen again
  Why A over B: <one sentence a beginner could say in an interview>
  You approve exact bytes: diff-sha256 <hash>, the fingerprint of this change. If one byte changes, your
    approval no longer counts and I ask again.
  Default if you don't answer: H<n> stays proposed and nothing is applied.
Reply Approve (A), Revise (B, or your own words), or Stop (C).
```

Last, one block decision for every row without a diff:

```
Decision <k> · Question (G-L5): "Which layer owns this, adopt this fix?" (rows that need no harness change)
  - F<n> routed → <skill>: <the one-line ask>  (the supervisor adds a TRACKER row)
  - F<n> logged: <why it is one-off, session hygiene or a first false alarm>; revisit if it happens again
  Background: a routed row is a product fix another skill makes; a logged row is kept so a repeat is noticed.
  A (recommended) accept all as listed · cost: none now; a recurrence promotes the row
  B name a row to treat as durable · cost: one more route-failure pass
  C do nothing · cost: routed fixes are not queued
  Default if you don't answer: the rows stay as written and nothing is queued.
Reply Approve (A), Revise (B: name the F<n>), or Stop (C).
```
