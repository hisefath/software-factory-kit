#!/usr/bin/env bash
# apply-proposal.sh — apply an approved route-failure proposal, then commit and push the factory record.
#
# Why this exists: a factory improvement left in a working copy never reaches the next project, so applying,
# testing, committing and pushing are one command instead of four steps someone must remember (FINDINGS F7).
# Run it only after the human's G-L5 yes is recorded; it refuses unless the diff bytes hash to the approved value.
set -euo pipefail
set -f

usage() {
  cat <<'EOF'
usage: scripts/apply-proposal.sh <n> <diff-sha256> [<apply-in path>]
         apply H<n> from HARNESS_CHANGELOG.md, then commit and push this kit
       scripts/apply-proposal.sh --record "<message>"
         commit and push FINDINGS.md and HARNESS_CHANGELOG.md only (a route-failure pass's record)

<apply-in path> defaults to this kit. A project path applies the diff there and commits only the kit's record;
the project's own commit stays with its supervisor. In the kit, scripts/test.sh must pass or the diff is reverted.
Exit: 0 done · 1 hash mismatch, apply or test failure · 2 usage error.
EOF
}

kit=$(cd "$(dirname "$0")/.." && pwd)
log=$kit/HARNESS_CHANGELOG.md

commit_push() { # <message> <path>...
  msg=$1; shift
  git -C "$kit" add -- "$@"
  if git -C "$kit" diff --cached --quiet; then echo "apply-proposal: nothing to commit"; return 0; fi
  git -C "$kit" commit -q -m "$msg"
  git -C "$kit" push -q origin HEAD
  echo "apply-proposal: committed and pushed $(git -C "$kit" rev-parse --short HEAD): $msg"
}

case "${1:-}" in
  -h | --help) usage; exit 0 ;;
  --record) [ -n "${2:-}" ] || { usage >&2; exit 2; }; commit_push "$2" FINDINGS.md HARNESS_CHANGELOG.md; exit 0 ;;
esac
[ $# -ge 2 ] && [ $# -le 3 ] || { usage >&2; exit 2; }
n=$1 want=$2 dest=${3:-$kit}

d=$(awk -v h="### H$n " 'index($0,h)==1{f=1;next} f&&/^### /{exit} f&&/^```diff$/{d=1;next} d&&/^```$/{exit} d' "$log")
[ -n "$d" ] || { echo "apply-proposal: no diff for H$n in $log" >&2; exit 1; }
got=$(printf '%s\n' "$d" | shasum -a 256 | cut -c1-12)
[ "$got" = "$want" ] || { echo "apply-proposal: H$n hashes to $got, not the approved $want; ask again" >&2; exit 1; }
printf '%s\n' "$d" | git -C "$dest" apply
paths=$(printf '%s\n' "$d" | git -C "$dest" apply --numstat -R | cut -f3)

title=$(grep -m1 "^### H$n " "$log" | sed -E "s/^### H$n //; s/ +\[status:.*//")
fs=$(sed -n "/^### H$n /,/^### /p" "$log" | grep -m1 -oE 'F#: F[0-9]+( and F[0-9]+)?' | sed 's/^F#: //')
if [ "$dest" -ef "$kit" ]; then
  if ! bash "$kit/scripts/test.sh" >/dev/null 2>&1; then
    printf '%s\n' "$d" | git -C "$kit" apply -R
    echo "apply-proposal: scripts/test.sh failed with H$n applied; reverted it" >&2
    exit 1
  fi
  # shellcheck disable=SC2086 # paths from git apply --numstat, one per line, no spaces in this kit
  commit_push "Apply H$n: $title ($fs)" FINDINGS.md HARNESS_CHANGELOG.md $paths
else
  commit_push "Record H$n applied in $(basename "$dest"): $title ($fs)" FINDINGS.md HARNESS_CHANGELOG.md
  echo "apply-proposal: applied H$n in $dest; its supervisor commits: $(printf '%s ' $paths)"
fi
