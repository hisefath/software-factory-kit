---
name: build-milestone
description: Use when a milestone's PRD and design are approved (GI and GD) and it should be built, reviewed and handed to the human to try, ending in the Try-it check (GT) and merge on green. Produces acceptance tests, task files, task commits, review files, docs/milestones/M<N>.md and .handoff/checkpoints/GT-M<N>.md. Do NOT use for planning (use plan-product or plan-design) or for a one-sentence bug (use fix-bug).
disable-model-invocation: true
metadata:
  software-factory-kit: "0.2"
  phase: "session: dev + qa (WORKFLOW §4b)"
  gate: "GT"
---

# build-milestone

**Outcome:** one milestone built, checked by machines and three review lenses, and put in front of the human as a
running app with a per-role try-it checklist; it merges when checks are green and the human says "works".

## You own / You never touch

- You own running, in order, `define-acceptance` → `slice-tasks` (its analyze pass is the readiness check) →
  `implement-task` per ready task (dispatched, parallel when `Owns:` are disjoint) → three `verifier` lenses in
  parallel ∥ `check-security` → fixes → `garden-docs` → `report-milestone`; you never write a path none of them
  declares, except `.handoff/**` (tracker, reviews, the GT card at `.handoff/checkpoints/GT-M<N>.md`).
- You own merging on green after the human's GT "works" (record their words first); you never merge on a red check,
  an open P0/P1, readiness FAIL, or without GT; you never push to protected `main` directly.
- You own turning verifier "fix" rows into fix tasks under scope-guard; you never ask the human to triage rows below
  P1.

## Inputs

1. GI and GD Approvals rows at the current PRD/LLD shas (MUST: missing → "run `/plan-product` / `/plan-design`").
2. `AGENTS.md` commands, a working `make check`, and how to run the app locally or as a preview.

## The one rule

Machines judge "broken", the human judges "wrong" by using the app; nobody reads markdown to approve a build.

## Steps

1. Run `date`; read `## Resume`; create `milestone/m<N>-<slug>` and its draft MR (WORKFLOW §8).
2. `define-acceptance` (red tests first), then `slice-tasks`. Readiness = its analyze result: PASS → go on;
   CONCERNS → go on and list them in the GT card; FAIL → stop and ask the human (the only stop before GT).
3. Dispatch `implement-task` for every ready task; verify each result the CLAUDE.md way (result → scope-guard →
   your own `make check` → diff); squash onto the milestone branch.
4. Review: write `.handoff/reviews/M<N>-diff.patch`; run the `verifier` subagent three times in parallel with the
   lens named in its prompt — `spec-fidelity`, `correctness-security`, `adversarial` (must report ≥1 finding or say
   why none exists; hunts tests that lie) — alongside `check-security`. Merge their rows into
   `.handoff/reviews/M<N>-pass<k>.md`. Fix rows → fix tasks (step 3 again); file/keep/discard are yours to set
   unless a row is P0/P1, which goes to the human immediately.
5. `garden-docs`, then `report-milestone`.
6. Run the app (local or preview deploy), smoke it yourself, then write the GT card to
   `.handoff/checkpoints/GT-M<N>.md`: the link, and for each role a numbered checklist of 4-8 steps that walk the
   milestone's new behaviour end to end, including one error case per role.
7. On "works" (recorded): merge on green, then `ship-milestone`. On anything wrong: turn it into fix tasks or
   `fix-bug`, repeat 3-6 for just that, and send a checklist for just that.

## Output

Each chained skill's outputs, `.handoff/reviews/M<N>-pass<k>.md`, `.handoff/checkpoints/GT-M<N>.md`.

## Done when

- [ ] `make check` green on the milestone head (pasted), no open P0/P1, readiness not FAIL.
- [ ] All three lenses ran; the adversarial lens reported ≥1 finding or a reason.
- [ ] The GT card has a working link and a checklist per role, and the human's GT words are recorded before merge.

## STOP

> **Try-it check (GT), M<N>.** Open <link>. As **<role>**: 1. … 2. … (per role). Machines: make check green,
> <n> review rows (<fixed>/<filed>), readiness <PASS|CONCERNS: …>. Reply **works**, or tell me what's wrong.
> After "works": I merge on green and ship. Next milestone: `/build-milestone` (or `/plan-design` if it needs design).

## Red flags

| Thought | Do instead |
|---|---|
| "Tests pass, so it works." | Try it yourself first, then hand the human the checklist. |
| "I'll ask the human to triage these P2 rows." | Set them yourself; only P0/P1 interrupt. |
| "The adversarial lens found nothing, fine." | Make it say why, or run it again with the diff's riskiest files. |
| "The human said works earlier on a different build." | GT binds to this milestone head's sha. |
