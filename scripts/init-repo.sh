#!/usr/bin/env bash
# init-repo.sh — phase 0: scaffold the constitution into a project repo (WORKFLOW.md §4 row 0).
#
# Copies software-factory-kit templates/ (+ the verifier subagent and the three workflow scripts) into the repo,
# never overwriting an existing file: anything already there is skipped and reported, so re-running is safe.
set -euo pipefail

usage() {
  cat <<'EOF'
usage: scripts/init-repo.sh <repo-dir> [--brownfield]

Scaffolds into <repo-dir> (must be the root of a git repository):
  templates/**                      → same paths (AGENTS.md, CLAUDE.md, .claude/settings.json, .githooks/pre-push,
                                       .gitlab/merge_request_templates/Default.md, .handoff/TRACKER.md, MILESTONES.md,
                                       docs/README.md, docs/decisions/DECISION_JOURNAL.md, specs/_templates/*)
  templates/Makefile.example        → Makefile when the repo has none (its check target fails until you adapt it);
                                       Makefile.example when a Makefile exists without a `check:` target
  agents/verifier.md                → .claude/agents/verifier.md
  scripts/{scope-guard,delegate,embed-diagrams}.sh → scripts/
  .handoff/{inbox,runs,reviews}/    (with .gitkeep so git tracks them)
  git config core.hooksPath .githooks   (only if hooksPath is unset or already .githooks)
  .gitignore lines: .handoff/runs/*/events.jsonl  .handoff/runs/*/stderr.log  docs/demo/raw/

Never overwrites an existing file (skip + report). Commits nothing: you review (G-init) and stage explicitly.
  --brownfield   inherited code: next steps add audit-codebase before write-prd
EOF
}

die() { echo "init-repo: $*" >&2; exit 1; }

repo="" mode=greenfield
for a in "$@"; do
  case $a in
    -h | --help) usage; exit 0 ;;
    --brownfield) mode=brownfield ;;
    -*) die "unknown option: $a (see -h)" ;;
    *) [ -z "$repo" ] || die "only one repo dir"; repo=$a ;;
  esac
done
[ -n "$repo" ] || { usage >&2; exit 1; }
[ -d "$repo" ] || die "not a directory: $repo"
repo=$(cd "$repo" && pwd -P)
top=$(git -C "$repo" rev-parse --show-toplevel 2>/dev/null) || die "$repo is not a git repository — run: git -C '$repo' init -b main"
[ "$(cd "$top" && pwd -P)" = "$repo" ] || die "give the repository root ($top), not a subdirectory"

kit=$(cd "$(dirname "$0")/.." && pwd -P)
tpl="$kit/templates"
[ -d "$tpl" ] || die "templates not found at $tpl"

created=0 skipped=0
put() { # put <source> <repo-relative dest> [chmod mode]
  local src=$1 rel=$2 dest="$repo/$2"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "  skip    $rel (exists)"
    skipped=$((skipped + 1))
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  [ -z "${3:-}" ] || chmod "$3" "$dest"
  echo "  create  $rel"
  created=$((created + 1))
}

echo "init-repo: scaffolding $repo ($mode) from $kit"

for t in AGENTS.md CLAUDE.md; do
  [ -f "$tpl/$t" ] || echo "  WARN    software-factory-kit has no templates/$t yet — $t not scaffolded" >&2
done

while IFS= read -r f; do
  rel=${f#"$tpl"/}
  case $rel in
    Makefile.example)
      if [ ! -e "$repo/Makefile" ]; then
        put "$f" Makefile
        echo "          ↳ its check target fails on purpose until you set lint/types/test for this stack"
      elif grep -q '^check:' "$repo/Makefile"; then
        echo "  skip    Makefile (exists and has a check: target)"
        skipped=$((skipped + 1))
      else
        put "$f" Makefile.example
        echo "  WARN    Makefile has no check: target — add one (see Makefile.example); the pre-push hook runs make check" >&2
      fi
      ;;
    .githooks/*) put "$f" "$rel" 755 ;;
    *) put "$f" "$rel" ;;
  esac
done < <(find "$tpl" -type f ! -name .DS_Store | LC_ALL=C sort)

put "$kit/agents/verifier.md" .claude/agents/verifier.md
for s in scope-guard.sh delegate.sh embed-diagrams.sh; do
  put "$kit/scripts/$s" "scripts/$s" 755
done

for d in inbox runs reviews; do
  mkdir -p "$repo/.handoff/$d"
  if [ -z "$(ls -A "$repo/.handoff/$d")" ]; then
    : >"$repo/.handoff/$d/.gitkeep"
    echo "  create  .handoff/$d/.gitkeep"
    created=$((created + 1))
  fi
done

hooks=$(git -C "$repo" config --get core.hooksPath || true)
case $hooks in
  .githooks) echo "  ok      git core.hooksPath already .githooks" ;;
  "") git -C "$repo" config core.hooksPath .githooks && echo "  set     git config core.hooksPath .githooks" ;;
  *) echo "  WARN    core.hooksPath is '$hooks' — left alone; wire .githooks/pre-push into it yourself" >&2 ;;
esac

gi="$repo/.gitignore" header=0
for line in '.handoff/runs/*/events.jsonl' '.handoff/runs/*/stderr.log' 'docs/demo/raw/'; do
  if [ -f "$gi" ] && grep -qxF "$line" "$gi"; then continue; fi
  if [ "$header" = 0 ]; then
    # make sure we start on a fresh line
    if [ -s "$gi" ] && [ "$(tail -c1 "$gi" | wc -l)" -eq 0 ]; then echo >>"$gi"; fi
    echo "# software-factory-kit (scripts/init-repo.sh): agent event logs may contain file contents; raw demo footage" >>"$gi"
    header=1
  fi
  echo "$line" >>"$gi"
  echo "  append  .gitignore: $line"
done

echo
echo "init-repo: $created created, $skipped skipped (existing files are never overwritten)."
cat <<EOF

Next steps
  1. Fill AGENTS.md with this stack's exact commands (install, lint, types, test, run). Skills read them from
     there and never guess.
  2. Make \`make check\` real: lint + types + tests, non-zero on any failure. It is the single green/red command
     every agent, the supervisor and .githooks/pre-push run.
  3. Gate G-init — "Are these the rules every agent here must obey?" Read the scaffold, then stage the files
     explicitly (never git add -A) and commit.
  4. Secret scanning: the pre-push hook warns loudly until gitleaks is installed (installing it is your call).
EOF
if [ "$mode" = brownfield ]; then
  cat <<'EOF'
  5. Brownfield: start the Full track with /sharpen-brief, and run /audit-codebase before /write-prd
     (design-lld will then write a change plan).
EOF
else
  echo "  5. Start the Full track: run /sharpen-brief."
fi
