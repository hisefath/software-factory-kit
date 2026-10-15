---
name: plan-design
description: Use when a frozen PRD (GI approved) needs its UX, high-level and low-level design and diagrams worked out in one sitting, ending in one batched Design check (GD). Produces docs/design/*, docs/architecture/hld.md, lld.md, diagrams/*.mmd, contracts/openapi.yaml and .handoff/checkpoints/GD-M<N>.md. Do NOT use for requirements (use plan-product) or for building (use build-milestone).
disable-model-invocation: true
metadata:
  software-factory-kit: "0.2"
  phase: "session: ux + architect (WORKFLOW §4b)"
  gate: "GD"
---

# plan-design

**Outcome:** the design for one milestone (UX if UI-critical, HLD, LLD with change plan on brownfield, every
diagram embedded), drafted in one sitting, and one batched card where the human settles only the Type 1 design
choices while looking at the diagrams (Design check, GD).

## You own / You never touch

- You own running, in order, (`map-ux-flows` when the PRD has UI-critical stories) → `design-hld` → `design-lld`,
  each under its own "You own / You never touch", and dispatching `draw-diagrams` jobs in parallel after each design
  draft (WORKFLOW §6), then `bash scripts/embed-diagrams.sh`; you never write a path none of them declares, except
  the card at `.handoff/checkpoints/GD-M<N>.md`.
- You own deciding Type 2 design choices on the recommendation (`auto-T2` row + `log-decision`); you never decide a
  Type 1 choice (stack, data model shape, auth model, money rules, public contracts, spend): it goes in the card.
- You own continuing past each skill's STOP; you never start `build-milestone`.

## Inputs

1. `docs/product/prd.md` with a GI approval row at its current sha (MUST: missing or stale → "run `/plan-product`").
2. Everything each chained skill lists. "Start anywhere": reuse a current HLD/LLD and draw only what's missing.

## The one rule

Show the human the drawings and the few one-way choices; make every reversible choice yourself and log it.

## Steps

1. Run `date`; read `## Resume`; confirm the GI row and the PRD sha.
2. Run each chained skill by reading its `SKILL.md`. Where a skill presents "one decision per reply", decide Type 2
   items yourself and park Type 1 items for the card. Treat G-ux, G2 and G3 as checkpoints and continue.
3. After the HLD draft and again after the LLD draft: commit the draft, dispatch one `draw-diagrams` job per diagram
   type in parallel, verify each result, embed.
4. Write the card from `../plan-product/assets/card.md` (GD form) to `.handoff/checkpoints/GD-M<N>.md`: the summary
   names the hardest decision, the rejected alternatives and the least-confident part, and links every diagram.

## Output

`.handoff/checkpoints/GD-M<N>.md` plus each chained skill's own outputs, diagrams embedded.

## Done when

- [ ] Each chained skill's Done-when passed; `bash scripts/embed-diagrams.sh --check docs/architecture/*.md` exits 0.
- [ ] Every Type 2 choice taken has an `auto-T2` row and a journal entry; every Type 1 choice is in the card.

## STOP

> **Design check (GD), M<N>.** <summary + diagram links> · Type 2 decided for you: <n> · **Your decisions (<k>):**
> <numbered Type 1 cards>. Reply in one message, or Revise / Stop. Next after your answer: `/build-milestone`.

## Red flags

| Thought | Do instead |
|---|---|
| "I'll ask about each table." | Tables are Type 2 unless they change the data model's shape; decide and log. |
| "Diagrams can wait until after the card." | The human judges the design by the pictures; draw them first. |
| "The PRD looks wrong, I'll fix it here." | The PRD is frozen; note it in the card and route to clarify-spec. |
