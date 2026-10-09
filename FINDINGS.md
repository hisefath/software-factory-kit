# FINDINGS (layer 5)

Every agent failure worth remembering. A new skill, hook, lint rule or eval needs a row here first.
Guard = the check that would catch a recurrence.

| F# | Date | Project | Symptom | Layer | Proposed fix | Status | Guard |
|---|---|---|---|---|---|---|---|
| F1 | 2026-10-08 | research | Ponytail's session injection reached a research subagent and pushed "minimal docs" | Settings | disable superpowers/ponytail/hf-cli per factory repo (`templates/.claude/settings.json`) | adopted | settings template + init-repo.sh |
| F2 | 2026-10-08 | research | Codex followed a skill marked `allow_implicit_invocation: false` when the prompt matched it | Policy (hard) | treat manual-only as convenience; boundaries = scope-guard + make check | adopted | scope-guard.sh in pre-push |
| F3 | 2026-10-09 | cerbo-supplement-store | Briefs and PRDs had no business-value metric tree (North Star, supporting, vanity vs actionable, grounded targets) and no hiring-partner lens; v1 Cerbo never read the partner portal, whose stack list contradicts the Laravel choice (ev: TRACKER Approvals 2026-10-09 17:11 CDT decision F4) | Skill | Shared docs/METRICS.md (Byron, Defining Metrics) + Hiring partner and Value and metrics sections in sharpen-brief, partner/metric sourcing in gather-evidence, metric-tree SCs in write-prd; see H1 | proposed (H1) | sharpen-brief Done-when: Value and metrics has exactly 1 NS- row; write-prd: grep -c "North Star" docs/product/prd.md ≥ 1 |
