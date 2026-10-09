# Skill authoring standard

Every software-factory-kit skill follows this. A reviewer rejects a skill that breaks any MUST.

## Folder

```
skills/<verb-object>/
  SKILL.md                  # MUST, < 300 lines
  agents/openai.yaml        # MUST for phase skills (Codex manual-only)
  assets/template.md        # MUST when the skill writes a document: the exact output skeleton
  references/*.md           # optional: long checklists/question banks, loaded only when SKILL.md says so
```

`agents/openai.yaml` for a manual-only skill, exactly:

```yaml
policy:
  allow_implicit_invocation: false
```

## Frontmatter (portable: only these keys)

```yaml
---
name: <verb-object>            # MUST equal the folder name
description: Use when <trigger>. Produces <path>. Do NOT use for <nearest sibling> (use <sibling-skill>).
disable-model-invocation: true # phase skills: the human is the trigger between phases
metadata:
  software-factory-kit: "0.1"
  phase: "<phase # from WORKFLOW.md §4>"
  gate: "<gate id or none>"
---
```

- The description is the **trigger only**: when to use it, what file it produces, which sibling to use instead.
  Never summarize the steps (models then skip the body).
- `disable-model-invocation: true` on every phase skill. Only `log-decision` may omit it (the supervisor calls it
  after every gate).

## Body anatomy (in this order)

1. `# <name>` + one line: **Outcome** — the single artifact and the state it must be in.
2. `## You own / You never touch` — a **grant paired with every prohibition** ("You own `docs/architecture/**`
   fully; you never edit `app/` or `tests/`"). Prohibitions alone measurably underperform.
3. `## Inputs` — exact paths to read first; what to do if one is missing (stop and name it, never guess).
4. `## The one rule` — the governing principle of this phase in one sentence.
5. `## Steps` — numbered, positive, imperative. Interview steps ask **one question at a time, each with a
   recommended answer**, at most 5 per pass, after reading the repo (never ask what the repo already answers).
6. `## Output` — the exact path(s) and "fill `assets/template.md`"; every section required; mark unknowns with
   `⚠ <question>` instead of inventing.
7. `## Done when` — a checklist the agent verifies before stopping (files exist, headings present, ids unique,
   no forbidden content via a grep you name).
8. `## STOP` — the literal closing message: what was written (paths), the gate id + its question from
   WORKFLOW.md §4, the decision options (Approve / Revise / Stop), and the **one** next skill. Then stop — never
   start the next phase.
9. `## Red flags` — table: *thought you might have* → *what to do instead* (3-6 rows, specific to this phase).

## Writing rules

- Declarative about output: the template is the contract; the body explains how to fill it well.
- Reference other skills only by name (`run design-lld next`), never inline their procedure.
- Use ids consistently: FR-###, NFR-###, SC-###, AE-###, D<n>, R<NN>, M<N>-T###, R<n> (review rows).
- Times come from `date`. Counts come from commands, never memory.
- Brownfield: explore before asking; cite `file:line`.
- Teach while working: at gates, explain each option's tradeoff in plain words a beginner can follow — the human
  is learning to defend these decisions in interviews.
- No harness-specific instructions except where WORKFLOW.md §6 says a skill is delegatable (then the skill must
  work unattended: no questions, write `⚠` and a `human_review` result instead).
