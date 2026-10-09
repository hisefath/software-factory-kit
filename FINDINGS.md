# FINDINGS (layer 5)

Every agent failure worth remembering. A new skill, hook, lint rule or eval needs a row here first.
Guard = the check that would catch a recurrence.

| F# | Date | Project | Symptom | Layer | Proposed fix | Status | Guard |
|---|---|---|---|---|---|---|---|
| F1 | 2026-10-08 | research | Ponytail's session injection reached a research subagent and pushed "minimal docs" | Settings | disable superpowers/ponytail/hf-cli per factory repo (`templates/.claude/settings.json`) | adopted | settings template + init-repo.sh |
| F2 | 2026-10-08 | research | Codex followed a skill marked `allow_implicit_invocation: false` when the prompt matched it | Policy (hard) | treat manual-only as convenience; boundaries = scope-guard + make check | adopted | scope-guard.sh in pre-push |
