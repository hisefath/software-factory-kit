#!/usr/bin/env bash
# measure-usage.sh — tokens, human touches and wall-clock for one project over a time window.
#
# Why this exists: gates can't be removed safely without measuring what they cost (FINDINGS F47). The per-run
# events.jsonl files only cover delegated workers; the supervisor session and in-session subagents were
# "not measured". Claude Code and Codex already log every turn's token usage on disk, so this reads those logs.
set -euo pipefail
usage() {
  cat <<'EOF'
usage: scripts/measure-usage.sh <repo-dir> <since> [<until>]
  <since>/<until>: ISO 8601 times (e.g. 2026-10-14T09:00:00-05:00); <until> defaults to now.
  Reads Claude Code transcripts (~/.claude/projects/**/*.jsonl, subagents included) and Codex sessions
  (~/.codex/sessions/**/*.jsonl) whose working directory is <repo-dir> or a sibling/nested worktree of it.
  Prints a markdown table: tokens per harness and model, human touches (prompts you typed), and wall-clock.
  Tokens are the signal; a Max plan bills no per-token cost, so no dollar figure is printed.
  Env: CLAUDE_PROJECTS_DIR, CODEX_SESSIONS_DIR override the log roots (used by test.sh).
EOF
}
case "${1:-}" in -h | --help) usage; exit 0 ;; esac
[ $# -ge 2 ] && [ $# -le 3 ] || { usage >&2; exit 2; }
repo=$(cd "$1" && pwd -P)
python3 -I - "$repo" "$2" "${3:-}" "${CLAUDE_PROJECTS_DIR:-$HOME/.claude/projects}" "${CODEX_SESSIONS_DIR:-$HOME/.codex/sessions}" <<'PY'
import json, sys, glob, os
from datetime import datetime, timezone
repo, since, until, claude_root, codex_root = sys.argv[1:6]
def ts(s):
    d = datetime.fromisoformat(s.replace("Z", "+00:00"))
    return d if d.tzinfo else d.astimezone()
t0 = ts(since); t1 = ts(until) if until else datetime.now(timezone.utc)
def mine(cwd):  # the repo, anything inside it, or a sibling worktree named <repo>-<id>
    return bool(cwd) and (cwd == repo or cwd.startswith(repo + "/") or cwd.startswith(repo + "-"))
def inwin(s):
    try: return t0 <= ts(s) <= t1
    except Exception: return False
rows = {}  # (harness, model) -> [in, cache_write, cache_read, out]
def add(h, m, a, b, c, d):
    r = rows.setdefault((h, m or "unknown"), [0, 0, 0, 0]); r[0] += a; r[1] += b; r[2] += c; r[3] += d
seen, touches, sessions = set(), 0, set()
for f in glob.glob(os.path.join(claude_root, "**", "*.jsonl"), recursive=True):
    try: fh = open(f, encoding="utf-8", errors="replace")
    except OSError: continue
    for line in fh:
        try: e = json.loads(line)
        except ValueError: continue
        if not mine(e.get("cwd")) or not inwin(e.get("timestamp", "")): continue
        t = e.get("type")
        if t == "user" and e.get("turnOrigin") == "human" and not e.get("isSidechain"):
            touches += 1
        elif t == "assistant":
            msg = e.get("message") or {}
            key = (msg.get("id"), e.get("requestId"))
            u = msg.get("usage")
            if not u or key in seen: continue  # streamed blocks repeat one message's usage
            seen.add(key); sessions.add(e.get("sessionId"))
            add("claude", msg.get("model"), u.get("input_tokens", 0), u.get("cache_creation_input_tokens", 0),
                u.get("cache_read_input_tokens", 0), u.get("output_tokens", 0))
codex_sessions = 0
for f in glob.glob(os.path.join(codex_root, "**", "*.jsonl"), recursive=True):
    cwd = model = None; counted = False
    try: fh = open(f, encoding="utf-8", errors="replace")
    except OSError: continue
    for line in fh:
        try: e = json.loads(line)
        except ValueError: continue
        p = e.get("payload") or {}
        if e.get("type") == "session_meta":
            cwd = p.get("cwd"); model = p.get("model") or model
        elif e.get("type") == "turn_context":
            model = p.get("model") or model
        elif e.get("type") == "event_msg" and p.get("type") == "token_count" and mine(cwd) and inwin(e.get("timestamp", "")):
            u = ((p.get("info") or {}).get("last_token_usage")) or {}
            if not u: continue
            cached = u.get("cached_input_tokens", 0)
            add("codex", model, u.get("input_tokens", 0) - cached, u.get("cache_write_input_tokens", 0), cached, u.get("output_tokens", 0))
            counted = True
    codex_sessions += counted
print(f"Window: {t0.isoformat(timespec='minutes')} → {t1.isoformat(timespec='minutes')} · wall-clock {(t1 - t0).total_seconds() / 3600:.1f} h")
print(f"Human touches: {touches} prompts typed · Claude sessions: {len(sessions)} · Codex sessions: {codex_sessions}")
print()
print("| Harness | Model | Input | Cache write | Cache read | Output |")
print("|---|---|---|---|---|---|")
tot = [0, 0, 0, 0]
for (h, m), r in sorted(rows.items()):
    print(f"| {h} | {m} | " + " | ".join(f"{x:,}" for x in r) + " |")
    tot = [a + b for a, b in zip(tot, r)]
print("| **total** | | " + " | ".join(f"**{x:,}**" for x in tot) + " |")
PY
