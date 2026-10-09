#!/usr/bin/env bash
# install.sh — make software-factory-kit skills visible to every harness by symlinking (never copying) them.
#
# One source folder, many readers: editing skills/<name>/SKILL.md here is instantly what Claude Code,
# Codex, Cursor, Antigravity and Chops see, so the harnesses can never drift apart.
set -euo pipefail

usage() {
  cat <<'EOF'
usage: scripts/install.sh [--dry-run] [--uninstall]

Symlinks every skills/<name>/ that has a SKILL.md into
  ~/.agents/skills/<name>   (Codex, Cursor, Antigravity, Chops "Global")
  ~/.claude/skills/<name>   (Claude Code)

Idempotent: a link that already points here is left alone; a broken link, or one pointing into this repo's
skills/, is replaced. Refuses (and exits 1) when the destination is a real file/folder or a symlink to
somewhere else — move that aside yourself.

  --dry-run    print what would happen; change nothing
  --uninstall  remove only symlinks that point into this repo's skills/ (nothing else is touched)
EOF
}

dry=0 uninstall=0
for a in "$@"; do
  case $a in
    -h | --help) usage; exit 0 ;;
    --dry-run) dry=1 ;;
    --uninstall) uninstall=1 ;;
    *) echo "install: unknown argument: $a (see -h)" >&2; exit 2 ;;
  esac
done

kit=$(cd "$(dirname "$0")/.." && pwd -P)
targets=("$HOME/.agents/skills" "$HOME/.claude/skills")
rc=0

act() { # act <description> <command...>
  local what=$1; shift
  if [ "$dry" = 1 ]; then echo "  would $what"; else "$@"; echo "  $what"; fi
}
ours() { case $1 in "$kit"/skills/*) return 0 ;; *) return 1 ;; esac; }

if [ "$uninstall" = 1 ]; then
  for t in "${targets[@]}"; do
    [ -d "$t" ] || continue
    for l in "$t"/*; do
      [ -L "$l" ] || continue
      if ours "$(readlink "$l")"; then act "remove $l" rm "$l"; fi
    done
  done
  exit 0
fi

found=0 made="|"
for d in "$kit"/skills/*/; do
  [ -d "$d" ] || continue
  name=$(basename "$d")
  src="$kit/skills/$name"
  if [ ! -f "$src/SKILL.md" ]; then echo "  skip  $name (no SKILL.md)"; continue; fi
  found=$((found + 1))
  for t in "${targets[@]}"; do
    dest="$t/$name"
    if [ -L "$dest" ]; then
      cur=$(readlink "$dest")
      if [ "$cur" = "$src" ]; then
        echo "  ok    $dest"
      elif [ ! -e "$dest" ] || ours "$cur"; then
        act "relink $dest -> $src (was $cur)" sh -c 'rm "$1" && ln -s "$2" "$1"' _ "$dest" "$src"
      else
        echo "  REFUSE $dest is a symlink to $cur (not this repo) — remove it yourself" >&2
        rc=1
      fi
    elif [ -e "$dest" ]; then
      echo "  REFUSE $dest exists and is not a symlink — move it aside yourself" >&2
      rc=1
    else
      case $made in *"|$t|"*) ;; *) [ -d "$t" ] || act "mkdir $t" mkdir -p "$t"; made="$made$t|" ;; esac
      act "link  $dest -> $src" ln -s "$src" "$dest"
    fi
  done
done
[ "$found" -gt 0 ] || echo "install: no skills with a SKILL.md under $kit/skills yet"
exit "$rc"
