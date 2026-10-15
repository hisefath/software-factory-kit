#!/usr/bin/env bash
# test.sh — self-test for the software-factory-kit scripts, in a throwaway git repo under mktemp -d.
# No network, no tokens, no installs: claude/codex are replaced by stubs, `shell` tasks run real commands.
set -euo pipefail

usage() {
  cat <<'EOF'
usage: scripts/test.sh [-h]

Builds a scratch repo in a temp dir, runs init-repo.sh on it, then exercises scope-guard.sh, embed-diagrams.sh,
delegate.sh (shell harness for real; claude/codex via local stubs), the pre-push hook against a local bare remote,
and install.sh --dry-run with a fake HOME. Prints one ok/FAIL line per check and exits non-zero on any FAIL.
Env: KEEP=1 keeps the temp dir for inspection.
EOF
}
case "${1:-}" in -h | --help) usage; exit 0 ;; "") ;; *) usage >&2; exit 2 ;; esac

kit=$(cd "$(dirname "$0")/.." && pwd -P)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/software-factory-kit-test.XXXXXX")
tmp=$(cd "$tmp" && pwd -P)
cleanup() { if [ "${KEEP:-0}" = 1 ]; then echo "kept: $tmp"; else rm -rf "$tmp"; fi; }
trap cleanup EXIT

# Hermetic git: ignore the user's global/system config (commit signing, hooks, default branch).
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME="software-factory-kit test" GIT_AUTHOR_EMAIL=test@example.invalid
export GIT_COMMITTER_NAME="software-factory-kit test" GIT_COMMITTER_EMAIL=test@example.invalid

passed=0 failed=0
out="$tmp/out.log"
ok() { passed=$((passed + 1)); echo "ok   $1"; }
bad() {
  failed=$((failed + 1))
  echo "FAIL $1"
  if [ -n "${2:-}" ] && [ -f "$2" ]; then tail -15 "$2" | sed 's/^/     | /'; fi
}
# rc <want> <name> <cmd…> — run cmd with output in $out; pass when its exit code is <want>.
rc() {
  local want=$1 name=$2 got=0
  shift 2
  "$@" >"$out" 2>&1 || got=$?
  if [ "$got" = "$want" ]; then ok "$name"; else bad "$name (exit $got, want $want)" "$out"; fi
}
# has <name> <file> <fixed string> / hasnt …
has() { if grep -qF -- "$3" "$2"; then ok "$1"; else bad "$1 (missing: $3)" "$2"; fi; }
hasnt() { if grep -qF -- "$3" "$2"; then bad "$1 (unexpected: $3)" "$2"; else ok "$1"; fi; }
is() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (got '$2', want '$3')"; fi; }
replace_line() { sed "s|$2|$3|" "$1" >"$1.tmp" && mv "$1.tmp" "$1"; } # portable sed -i

echo "# software-factory-kit self-test ($tmp)"

# ---- 0. syntax and usage ---------------------------------------------------------------------------------
for f in "$kit"/scripts/*.sh "$kit/templates/.githooks/pre-push"; do
  rc 0 "bash -n ${f#"$kit"/}" bash -n "$f"
done
for s in scope-guard delegate embed-diagrams decision-views init-repo install test; do
  rc 0 "$s.sh -h prints usage" bash "$kit/scripts/$s.sh" -h
  has "$s.sh -h starts with usage:" "$out" "usage: scripts/$s.sh"
done
if command -v shellcheck >/dev/null 2>&1; then
  rc 0 "shellcheck scripts" shellcheck -S warning "$kit"/scripts/*.sh "$kit/templates/.githooks/pre-push"
else
  echo "note shellcheck not on PATH — lint skipped"
fi

# ---- 1. init-repo ----------------------------------------------------------------------------------------
repo="$tmp/demo"
git init -q -b main "$repo"
echo "# demo" >"$repo/README.md"
git -C "$repo" add README.md
git -C "$repo" commit -qm init

rc 0 "init-repo: scaffolds a fresh repo" bash "$kit/scripts/init-repo.sh" "$repo"
missing=""
for f in .claude/settings.json .claude/agents/verifier.md .githooks/pre-push \
  .gitlab-ci.yml .gitlab/merge_request_templates/Default.md .handoff/TRACKER.md .handoff/inbox/.gitkeep .handoff/runs/.gitkeep \
  .handoff/reviews/.gitkeep MILESTONES.md docs/README.md docs/decisions/DECISION_JOURNAL.md \
  specs/_templates/task.md specs/_templates/result.md Makefile scripts/scope-guard.sh scripts/delegate.sh \
  scripts/embed-diagrams.sh scripts/decision-views.sh docs/decisions/REVIEW.md; do
  [ -f "$repo/$f" ] || missing="$missing $f"
done
for f in AGENTS.md CLAUDE.md; do
  if [ -f "$kit/templates/$f" ] && [ ! -f "$repo/$f" ]; then missing="$missing $f"; fi
done
is "init-repo: every constitution file exists" "${missing:-none}" none
if [ -x "$repo/.githooks/pre-push" ] && [ -x "$repo/scripts/scope-guard.sh" ] && [ -x "$repo/scripts/delegate.sh" ] &&
  [ -x "$repo/scripts/embed-diagrams.sh" ]; then ok "init-repo: hook and scripts are executable"; else bad "init-repo: hook and scripts are executable"; fi
if command -v python3 >/dev/null 2>&1; then
  rc 0 "init-repo: .claude/settings.json is valid JSON" python3 -m json.tool "$repo/.claude/settings.json"
fi
is "init-repo: core.hooksPath = .githooks" "$(git -C "$repo" config --get core.hooksPath)" .githooks
has "init-repo: .gitignore ignores events.jsonl" "$repo/.gitignore" '.handoff/runs/*/events.jsonl'
has "init-repo: .gitignore ignores docs/demo/raw/" "$repo/.gitignore" 'docs/demo/raw/'
rc 2 "init-repo: generated Makefile fails closed until adapted" make -C "$repo" check

echo "local edit" >>"$repo/MILESTONES.md"
rc 0 "init-repo: re-run succeeds" bash "$kit/scripts/init-repo.sh" "$repo"
has "init-repo: re-run skips existing files" "$out" "skip    MILESTONES.md (exists)"
has "init-repo: re-run never overwrites" "$repo/MILESTONES.md" "local edit"
is "init-repo: re-run does not duplicate .gitignore lines" "$(grep -cxF '.handoff/runs/*/events.jsonl' "$repo/.gitignore")" 1
rc 1 "init-repo: refuses a non-git directory" bash "$kit/scripts/init-repo.sh" "$tmp"

# ---- fixtures: passing make check, milestone branch, task files, stub harnesses ----------------------------
cd "$repo"
printf 'check:\n\t@echo check-ok\n' >Makefile
git add -A && git commit -qm "chore: software-factory-kit scaffold"
git checkout -q -b milestone/m1-demo
mkdir -p specs/M1-demo/tasks
cat >specs/M1-demo/tasks/T001.md <<'EOF'
---
id: M1-T001
milestone: M1
skill: implement-task
covers: [FR-001]
harness: shell
budget: 1 run, 2 min
slug: write-a
milestone_branch: milestone/m1-demo
cmd: mkdir -p src && echo hello > src/a.txt && git add src/a.txt && { git diff --cached --quiet || git commit -qm "feat(m1/t001): a"; } && printf -- '---\ntask: %s\nharness: shell\nstatus: done\nreason: wrote src/a.txt\n---\n## Changes\n' "$TASK_ID" > "$RUN_DIR/result.md"
---
Owns: src/a.txt

## Ask
Write src/a.txt.
EOF
cat >specs/M1-demo/tasks/T002.md <<'EOF'
---
id: M1-T002   milestone: M1   skill: implement-task   harness: shell   slug: Forgets Result!   milestone_branch: milestone/m1-demo
cmd: echo "worked hard, wrote no result.md"
---
Owns: `src/b.txt`
EOF
cat >specs/M1-demo/tasks/T003.md <<'EOF'
---
id: M1-T003
harness: shell
milestone_branch: milestone/m1-demo
cmd: true
---
## Ask
A task file with no Owns: line.
EOF
cat >specs/M1-demo/tasks/T004.md <<'EOF'
---
id: M1-T004
skill: implement-task
harness: codex
slug: codex stub
milestone_branch: milestone/m1-demo
---
Owns: src/c.txt
EOF
cat >specs/M1-demo/tasks/T005.md <<'EOF'
---
id: M1-T005
skill: implement-task
harness: claude
milestone_branch: milestone/m1-demo
---
Owns: src/d.txt

## Ask
Claude stub run.
EOF
cat >specs/M1-demo/tasks/T006.md <<'EOF'
---
id: M1-T006
skill: implement-task
harness: shell
slug: hangs
milestone_branch: milestone/m1-demo
cmd: sleep 30
---
Owns: src/e.txt
EOF
for n in 7 8; do
  cat >"specs/M1-demo/tasks/T00$n.md" <<EOF
---
id: M1-T00$n
skill: implement-task
harness: shell
slug: parallel-$n
milestone_branch: milestone/m1-demo
cmd: sleep 1; printf -- '---\\ntask: %s\\nstatus: done\\nreason: parallel\\n---\\n' "\$TASK_ID" > "\$RUN_DIR/result.md"
---
Owns: src/p$n.txt
EOF
done
git add specs && git commit -qm "M1 tasks"

mkdir -p "$tmp/kit/skills/implement-task" "$tmp/bin"
echo "# implement-task (stub)" >"$tmp/kit/skills/implement-task/SKILL.md"
export FACTORY_KIT_DIR="$tmp/kit"
cat >"$tmp/bin/codex-stub" <<'EOF'
#!/bin/sh
[ "$1" = --version ] && { echo "codex-stub 0.0"; exit 0; }
printf '%s\n' "$@" > "$RUN_DIR/argv.txt"
while [ $# -gt 0 ]; do case $1 in -o) last=$2; shift ;; esac; shift; done
echo '{"type":"turn.completed"}'
echo "stub final message" > "$last"
printf -- '---\ntask: %s\nharness: codex\nstatus: human_review\nreason: stub\n---\n' "$TASK_ID" > "$RUN_DIR/result.md"
EOF
cat >"$tmp/bin/claude" <<'EOF'
#!/bin/sh
[ "$1" = --version ] && { echo "claude-stub 0.0"; exit 0; }
printf '%s\n' "$@" > "$RUN_DIR/argv.txt"
pwd -P > "$RUN_DIR/cwd.txt"
printf -- '---\ntask: "%s"\nharness: claude\nstatus: relaunch   reason: stub\n---\n' "$TASK_ID" > "$RUN_DIR/result.md"
EOF
chmod +x "$tmp/bin/codex-stub" "$tmp/bin/claude"

# ---- 2. scope-guard --------------------------------------------------------------------------------------
T1=specs/M1-demo/tasks/T001.md
git checkout -q -b scratch/scope milestone/m1-demo
mkdir -p src && echo x >src/a.txt && git add src/a.txt
rc 0 "scope-guard staged: owned path passes" bash scripts/scope-guard.sh "$T1"
echo y >other.txt && git add other.txt
rc 1 "scope-guard staged: unowned path fails" bash scripts/scope-guard.sh "$T1"
has "scope-guard staged: names the offending path" "$out" "out of scope: other.txt"
git reset -q -- other.txt && rm other.txt
rc 2 "scope-guard: task file without Owns: fails closed" bash scripts/scope-guard.sh specs/M1-demo/tasks/T003.md
TB=specs/M1-demo/tasks/T090.md
printf 'Owns: src/a.txt, src/[id]/**\n' >"$TB"
mkdir -p 'src/[id]' && echo z >'src/[id]/b.txt' && git add 'src/[id]/b.txt'
rc 0 "scope-guard: a [ in Owns is literal (route folders)" bash scripts/scope-guard.sh "$TB"
git reset -q -- 'src/[id]/b.txt' && rm -r 'src/[id]' "$TB"
git commit -qm "a"
rc 0 "scope-guard branch mode: owned commit passes" bash scripts/scope-guard.sh "$T1" milestone/m1-demo
rc 0 "scope-guard branch mode: absolute task path works" bash scripts/scope-guard.sh "$repo/$T1" milestone/m1-demo
replace_line "$T1" '^Owns: .*' 'Owns: **'
echo y >other.txt && git add "$T1" other.txt && git commit -qm "widen own scope"
rc 0 "scope-guard staged: (control) the widened working copy would allow anything" bash scripts/scope-guard.sh "$T1"
rc 1 "scope-guard branch mode: a branch cannot widen its own Owns" bash scripts/scope-guard.sh "$T1" milestone/m1-demo
has "scope-guard branch mode: reads Owns from the base" "$out" "out of scope: other.txt"
rc 2 "scope-guard branch mode: no Owns: on base fails closed" bash scripts/scope-guard.sh specs/M1-demo/tasks/T003.md milestone/m1-demo
rc 2 "scope-guard branch mode: unknown base ref fails closed" bash scripts/scope-guard.sh "$T1" no-such-branch
git checkout -q milestone/m1-demo
rm -f other.txt

# ---- 3. embed-diagrams -----------------------------------------------------------------------------------
mkdir -p docs/architecture/diagrams
printf 'erDiagram\n  CUSTOMER ||--o{ ORDER : places\n' >docs/architecture/diagrams/erd.mmd
cat >docs/architecture/lld.md <<'EOF'
# LLD

## Data model
<!-- diagram: erd -->

Prose after the diagram.

```text
<!-- diagram: erd -->
```
EOF
lld=docs/architecture/lld.md
rc 0 "embed: inserts the block" bash scripts/embed-diagrams.sh "$lld"
has "embed: mermaid fence present" "$lld" '```mermaid'
has "embed: .mmd content embedded" "$lld" "CUSTOMER ||--o{ ORDER : places"
has "embed: end marker present" "$lld" "<!-- /diagram -->"
has "embed: surrounding prose kept" "$lld" "Prose after the diagram."
is "embed: placeholder inside another code fence is ignored" "$(grep -c '^```mermaid' "$lld")" 1
before=$(cksum <"$lld")
rc 0 "embed: second run succeeds" bash scripts/embed-diagrams.sh "$lld"
is "embed: second run changes nothing (idempotent)" "$(cksum <"$lld")" "$before"
rc 0 "embed --check: in sync passes" bash scripts/embed-diagrams.sh --check "$lld"
printf '  ORDER ||--|{ LINE_ITEM : contains\n' >>docs/architecture/diagrams/erd.mmd
rc 1 "embed --check: edited .mmd is detected" bash scripts/embed-diagrams.sh --check "$lld"
is "embed --check: changes nothing" "$(cksum <"$lld")" "$before"
rc 0 "embed: re-embed after .mmd edit" bash scripts/embed-diagrams.sh "$lld"
has "embed: new .mmd line embedded" "$lld" "ORDER ||--|{ LINE_ITEM : contains"
is "embed: still exactly one block" "$(grep -c '^```mermaid' "$lld")" 1
rc 0 "embed --check: in sync again" bash scripts/embed-diagrams.sh --check "$lld"
printf '# x\n<!-- diagram: nope -->\n' >docs/x.md
rc 1 "embed --check: missing .mmd fails" bash scripts/embed-diagrams.sh --check docs/x.md
rc 1 "embed: missing .mmd fails" bash scripts/embed-diagrams.sh docs/x.md
hasnt "embed: doc untouched when .mmd is missing" docs/x.md '```mermaid'
printf '<!-- diagram: ../../etc/passwd -->\n' >docs/y.md
rc 1 "embed: path-like diagram type is rejected" bash scripts/embed-diagrams.sh docs/y.md

# ---- 3b. decision-views ----------------------------------------------------------------------------------
rc 0 "decision-views: the scaffolded REVIEW.md is current" bash scripts/decision-views.sh --check
cp docs/decisions/DECISION_JOURNAL.md "$tmp/journal.bak"
cat >>docs/decisions/DECISION_JOURNAL.md <<'EOF'

### D1 Charge once per order  [status: accepted]
- Date 2026-10-10 18:00 CDT · phase 6 design-lld · milestone M1
- Review: Topic Money · Weight ●●● · One-liner: One charge per order, guarded by an idempotency key.
EOF
rc 1 "decision-views: --check fails when REVIEW.md is stale" bash scripts/decision-views.sh --check
rc 0 "decision-views: regenerates REVIEW.md" bash scripts/decision-views.sh
has "decision-views: groups by topic and weight" docs/decisions/REVIEW.md "- ●●● D1 — One charge per order, guarded by an idempotency key."
has "decision-views: lists decisions by day" docs/decisions/REVIEW.md "- D1 · Money · ●●● — One charge per order"
rc 0 "decision-views: --check passes once regenerated" bash scripts/decision-views.sh --check
replace_line docs/decisions/DECISION_JOURNAL.md 'Topic Money' 'Topic Billing'
rc 1 "decision-views: refuses a topic missing from the Topics: line" bash scripts/decision-views.sh
cp "$tmp/journal.bak" docs/decisions/DECISION_JOURNAL.md && bash scripts/decision-views.sh >/dev/null

# ---- 4. delegate -----------------------------------------------------------------------------------------
tracker=.handoff/TRACKER.md
rc 0 "delegate shell: T001 dispatched and result parsed" bash scripts/delegate.sh "$T1"
wt1="$tmp/demo-M1-T001"
is "delegate: worktree ../<repo>-<id> on branch m<N>/t###-<slug>" "$(git -C "$wt1" symbolic-ref --short HEAD 2>&1)" m1/t001-write-a
if [ -f .handoff/runs/M1-T001/brief.md ] && [ -f .handoff/runs/M1-T001/cmd.txt ] && [ -f .handoff/runs/M1-T001/result.md ]; then
  ok "delegate: brief.md, cmd.txt, result.md written to .handoff/runs/M1-T001/"
else bad "delegate: brief.md, cmd.txt, result.md written to .handoff/runs/M1-T001/"; fi
has "delegate: brief carries the skill prompt" .handoff/runs/M1-T001/brief.md \
  "Run the implement-task skill: read $tmp/kit/skills/implement-task/SKILL.md and follow it for task file $T1"
has "delegate: brief names HANDOFF_DIR" .handoff/runs/M1-T001/brief.md "HANDOFF_DIR=$repo/.handoff"
has "delegate: cmd.txt records the harness version" .handoff/runs/M1-T001/cmd.txt "# harness: shell — GNU bash"
has "delegate: Log has DISPATCH" "$tracker" "DISPATCH M1-T001 harness=shell why="
has "delegate: Log has RESULT status=done" "$tracker" "RESULT M1-T001 status=done harness=shell exit=0 timeout=no tree=clean"
is "delegate: worker's commit is on the task branch" "$(git -C "$wt1" log -1 --format=%s)" "feat(m1/t001): a"
is "delegate: main checkout stays on the milestone branch" "$(git symbolic-ref --short HEAD)" milestone/m1-demo
rc 0 "delegate → scope-guard passes on the delegated branch" bash -c 'cd "$1" && bash scripts/scope-guard.sh "$2" milestone/m1-demo' _ "$wt1" "$T1"

echo "2026-01-01T00:00:00+0000 DISPATCH M1-T001 harness=shell why=simulated-crash" >>"$tracker"
rc 3 "delegate: refuses while the Log shows the id in flight" bash scripts/delegate.sh "$T1"
rc 0 "delegate --force: re-dispatches, reusing the worktree" bash scripts/delegate.sh --force "$T1"
if ls -d .handoff/runs/M1-T001.attempt-* >/dev/null 2>&1; then ok "delegate: previous attempt archived, not deleted"; else bad "delegate: previous attempt archived, not deleted"; fi

rc 4 "delegate: missing result.md exits 4" bash scripts/delegate.sh specs/M1-demo/tasks/T002.md
is "delegate: compact frontmatter parsed (slug → branch)" "$(git -C "$tmp/demo-M1-T002" symbolic-ref --short HEAD 2>&1)" m1/t002-forgets-result
has "delegate: Log has RESULT status=missing" "$tracker" "RESULT M1-T002 status=missing"

rc 1 "delegate: refuses a task file without Owns:" bash scripts/delegate.sh specs/M1-demo/tasks/T003.md
if [ ! -e "$tmp/demo-M1-T003" ]; then ok "delegate: no worktree for a refused task"; else bad "delegate: no worktree for a refused task"; fi
sed 's/^id: M1-T001$/id: M1-T009/' "$T1" >specs/M1-demo/tasks/T009.md
rc 1 "delegate: refuses a task file not committed on the milestone branch" bash scripts/delegate.sh specs/M1-demo/tasks/T009.md
rm specs/M1-demo/tasks/T009.md

rc 0 "delegate --dry-run: prints the codex command" env CODEX_BIN="$tmp/bin/codex-stub" bash scripts/delegate.sh --dry-run specs/M1-demo/tasks/T004.md
has "delegate --dry-run: codex exec in workspace-write sandbox" "$out" "exec --sandbox workspace-write -C $tmp/demo-M1-T004"
if [ ! -e "$tmp/demo-M1-T004" ] && [ ! -e .handoff/runs/M1-T004 ]; then ok "delegate --dry-run: created nothing"; else bad "delegate --dry-run: created nothing"; fi

rc 0 "delegate codex (stub): dispatched and result parsed" env CODEX_BIN="$tmp/bin/codex-stub" bash scripts/delegate.sh specs/M1-demo/tasks/T004.md
argv=.handoff/runs/M1-T004/argv.txt
is "delegate codex: argv = exec --sandbox workspace-write -C <worktree>" "$(head -5 "$argv" | tr '\n' ' ')" "exec --sandbox workspace-write -C $tmp/demo-M1-T004 "
has "delegate codex: -o last-message.md" "$argv" "$repo/.handoff/runs/M1-T004/last-message.md"
has "delegate codex: --json event stream" "$argv" "--json"
has "delegate codex: run dir is writable (--add-dir)" "$argv" "--add-dir"
has "delegate codex: events.jsonl captured" .handoff/runs/M1-T004/events.jsonl "turn.completed"
has "delegate codex: Log has RESULT status=human_review" "$tracker" "RESULT M1-T004 status=human_review harness=codex"

rc 0 "delegate claude (stub): dispatched and result parsed" env PATH="$tmp/bin:$PATH" bash scripts/delegate.sh specs/M1-demo/tasks/T005.md
argv=.handoff/runs/M1-T005/argv.txt
is "delegate claude: runs with cwd = worktree" "$(cat .handoff/runs/M1-T005/cwd.txt)" "$tmp/demo-M1-T005"
is "delegate claude: prompt follows -p" "$(sed -n 1p "$argv")" "-p"
has "delegate claude: --permission-mode acceptEdits" "$argv" "acceptEdits"
has "delegate claude: --output-format stream-json" "$argv" "stream-json"
has "delegate claude: --verbose" "$argv" "--verbose"
is "delegate claude: branch slug from ## Ask" "$(git -C "$tmp/demo-M1-T005" symbolic-ref --short HEAD 2>&1)" m1/t005-claude-stub-run
has "delegate claude: quoted + compact result frontmatter parsed" "$tracker" "RESULT M1-T005 status=relaunch harness=claude"

rc 5 "delegate: timeout kills the worker and exits 5" env DELEGATE_TIMEOUT_SEC=1 bash scripts/delegate.sh specs/M1-demo/tasks/T006.md
has "delegate: Log records the timeout" "$tracker" "RESULT M1-T006 status=missing harness=shell exit=143 timeout=yes"
is "delegate: Log section stays last and append-only" "$(tail -1 "$tracker" | awk '{print $2, $3}')" "RESULT M1-T006"

# Parallel fan-out: two dispatches at once must both get worktrees and both Log lines (mkdir lock on TRACKER).
bash scripts/delegate.sh specs/M1-demo/tasks/T007.md >"$tmp/p7.log" 2>&1 & p7=$!
bash scripts/delegate.sh specs/M1-demo/tasks/T008.md >"$tmp/p8.log" 2>&1 & p8=$!
r7=0 r8=0
wait "$p7" || r7=$?
wait "$p8" || r8=$?
is "delegate parallel: both dispatches exit 0" "$r7 $r8" "0 0"
is "delegate parallel: both DISPATCH and RESULT lines logged" "$(grep -cE ' (DISPATCH|RESULT) M1-T00[78] ' "$tracker")" 4
has "delegate parallel: T007 result parsed" "$tracker" "RESULT M1-T007 status=done"
has "delegate parallel: T008 result parsed" "$tracker" "RESULT M1-T008 status=done"

# ---- 5. pre-push hook (local bare remote; nothing leaves the machine) -------------------------------------
git init -q --bare "$tmp/remote.git"
git remote add origin "$tmp/remote.git"
rc 0 "pre-push: in-scope task branch pushes" git -C "$wt1" push -q origin m1/t001-write-a
has "pre-push: ran make check" "$out" "check-ok"
has "pre-push: ran scope-guard for the task branch" "$out" "scope-guard: OK"
if ! command -v gitleaks >/dev/null 2>&1; then has "pre-push: loud warning without gitleaks" "$out" "gitleaks is NOT installed"; fi
git checkout -q -b m1/t001-sneaky milestone/m1-demo
echo z >other.txt && git add other.txt && git commit -qm "sneak"
rc 1 "pre-push: out-of-scope task branch is blocked" git push -q origin m1/t001-sneaky
has "pre-push: names the out-of-scope path" "$out" "out of scope: other.txt"
git checkout -q -b feature/red milestone/m1-demo
printf 'check:\n\t@echo check-red; exit 1\n' >Makefile && git add Makefile && git commit -qm "red"
rc 1 "pre-push: failing make check blocks the push" git push -q origin feature/red
has "pre-push: says make check failed" "$out" "make check failed"
git checkout -q -b feature/mixed milestone/m1-demo
mkdir -p tests/acceptance src && echo t >tests/acceptance/x.test && echo c >src/fix.txt
git add tests/acceptance/x.test src/fix.txt && git commit -qm "fix: code and its acceptance test together"
rc 1 "pre-push: an acceptance test committed with product code is blocked" git push -q origin feature/mixed
has "pre-push: names the mixed commit" "$out" "changes tests/acceptance/** with src/fix.txt"
git checkout -q milestone/m1-demo
git worktree add -q "$tmp/wt-gitdir" -b feature/gitdir milestone/m1-demo
printf 'check:\n\t@mkdir -p sub && test "$$(git -C sub rev-parse --show-toplevel)" = "$$(pwd -P)" && echo top-ok\n' >"$tmp/wt-gitdir/Makefile"
git -C "$tmp/wt-gitdir" commit -qam "check: run git from a subdirectory"
rc 0 "pre-push: make check in a linked worktree sees that worktree (GIT_DIR unset)" git -C "$tmp/wt-gitdir" push -q origin feature/gitdir
has "pre-push: worktree make check ran" "$out" "top-ok"
is "pre-push tests left the supervisor's TRACKER Log intact" "$(grep -c ' DISPATCH M1-T00' "$tracker")" 9

# ---- 6. install.sh (dry run only, fake HOME) -------------------------------------------------------------
rc 0 "install --dry-run: succeeds" env HOME="$tmp/home" bash "$kit/scripts/install.sh" --dry-run
if [ ! -e "$tmp/home" ]; then ok "install --dry-run: changed nothing"; else bad "install --dry-run: changed nothing"; fi
rc 0 "install --uninstall --dry-run: succeeds" env HOME="$tmp/home" bash "$kit/scripts/install.sh" --uninstall --dry-run

# ---- 7. measure-usage.sh (fixture logs; no real transcripts read) ---------------------------------------
mu=$tmp/mu; mkdir -p "$mu/claude/p/sub" "$mu/codex/2026/10/14" "$mu/repo" "$mu/repo-T001" "$mu/other"
r=$(cd "$mu/repo" && pwd -P)
o=$(cd "$mu/other" && pwd -P)
cat >"$mu/claude/p/s.jsonl" <<JSONL
{"type":"user","turnOrigin":"human","cwd":"$r","timestamp":"2026-10-14T10:00:00Z","sessionId":"s1"}
{"type":"user","cwd":"$r","timestamp":"2026-10-14T10:00:01Z","sessionId":"s1"}
{"type":"assistant","cwd":"$r","timestamp":"2026-10-14T10:00:02Z","sessionId":"s1","requestId":"q1","message":{"id":"m1","model":"claude-x","usage":{"input_tokens":10,"cache_creation_input_tokens":20,"cache_read_input_tokens":30,"output_tokens":5}}}
{"type":"assistant","cwd":"$r","timestamp":"2026-10-14T10:00:02Z","sessionId":"s1","requestId":"q1","message":{"id":"m1","model":"claude-x","usage":{"input_tokens":10,"cache_creation_input_tokens":20,"cache_read_input_tokens":30,"output_tokens":5}}}
{"type":"user","turnOrigin":"human","cwd":"$o","timestamp":"2026-10-14T10:00:03Z","sessionId":"s9"}
{"type":"user","turnOrigin":"human","cwd":"$r","timestamp":"2026-10-13T10:00:00Z","sessionId":"s1"}
JSONL
cat >"$mu/claude/p/sub/agent.jsonl" <<JSONL
{"type":"assistant","isSidechain":true,"cwd":"$r-T001","timestamp":"2026-10-14T11:00:00Z","sessionId":"s1","requestId":"q2","message":{"id":"m2","model":"claude-x","usage":{"input_tokens":1,"cache_creation_input_tokens":0,"cache_read_input_tokens":0,"output_tokens":2}}}
JSONL
cat >"$mu/codex/2026/10/14/rollout.jsonl" <<JSONL
{"type":"session_meta","timestamp":"2026-10-14T12:00:00Z","payload":{"cwd":"$r","model":"gpt-x"}}
{"type":"event_msg","timestamp":"2026-10-14T12:00:01Z","payload":{"type":"token_count","info":{"last_token_usage":{"input_tokens":100,"cached_input_tokens":40,"output_tokens":7}}}}
JSONL
rc 0 "measure-usage: runs on fixture logs" env CLAUDE_PROJECTS_DIR="$mu/claude" CODEX_SESSIONS_DIR="$mu/codex" \
  bash "$kit/scripts/measure-usage.sh" "$mu/repo" 2026-10-14T00:00:00Z 2026-10-14T23:00:00Z
has "measure-usage: counts only in-window human prompts in this repo" "$out" "Human touches: 1 prompts typed"
has "measure-usage: dedupes streamed blocks, includes worktree subagents" "$out" "| claude | claude-x | 11 | 20 | 30 | 7 |"
has "measure-usage: Codex input excludes cached tokens" "$out" "| codex | gpt-x | 60 | 0 | 40 | 7 |"
has "measure-usage: wall-clock from the window" "$out" "wall-clock 23.0 h"
rc 2 "measure-usage: usage error without a window" bash "$kit/scripts/measure-usage.sh" "$mu/repo"

echo
echo "# $passed passed, $failed failed"
[ "$failed" = 0 ]
