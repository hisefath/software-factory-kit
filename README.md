# factory-kit

My AI-native software factory: a supervisor `CLAUDE.md`, one skill per SDLC phase, and the scripts that make the
boundaries real. Human defines intent and approves decisions at **human approval gates**; agents investigate, plan,
build and test; **automated quality gates** verify; every failure improves the system.

- **Spec:** [docs/WORKFLOW.md](docs/WORKFLOW.md) — phases, gates, tracks, dispatch policy, contracts, failure routing
- **Skill standard:** [docs/SKILL_STANDARD.md](docs/SKILL_STANDARD.md)
- **Skills:** [skills/](skills/) — verb-object names, one declared output each
- **Project scaffolding:** [templates/](templates/) via `bash scripts/init-repo.sh <repo>`
- **Layer-5 log:** [FINDINGS.md](FINDINGS.md) · adopted changes: [HARNESS_CHANGELOG.md](HARNESS_CHANGELOG.md)

## Install

```bash
bash scripts/install.sh --dry-run   # shows the symlinks it would create
bash scripts/install.sh             # ~/.agents/skills/<name> (Codex, Cursor, Antigravity, Chops) + ~/.claude/skills/<name>
bash scripts/init-repo.sh ../my-project   # scaffold AGENTS.md, CLAUDE.md, .handoff/, hooks, templates
```

## Phases at a glance

```
/sharpen-brief → /gather-evidence → /write-prd ─G1─ /design-hld ─(draw-diagrams ∥)─G2─ /design-lld ─(draw-diagrams ∥)─G3─
/define-acceptance → /slice-tasks ─G4─ implement-task ∥ (worktrees, any harness) → verifier ∥ /check-security →
/report-milestone ─G5 merge─ /ship-milestone ─G-live─ /garden-docs · /route-failure · /quiz-me · /write-demo-script → /record-demo
```
