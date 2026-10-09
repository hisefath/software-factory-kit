# AGENTS.md — factory-kit

This repo is the factory itself (skills, templates, scripts), not a product.
- `docs/WORKFLOW.md` is the source of truth; skills/templates/scripts implement it. Change WORKFLOW.md first.
- Every skill follows `docs/SKILL_STANDARD.md`. Skill folder name = frontmatter `name`, verb-object.
- `bash scripts/test.sh` must pass before committing script changes.
- No skill change without a `FINDINGS.md` row and a `HARNESS_CHANGELOG.md` entry with the owner's approval.
- Stage files explicitly; never commit secrets.
