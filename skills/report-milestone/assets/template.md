# M{{N}} {{goal in a few words}} — milestone report

<!-- guide: report-milestone template (factory-kit WORKFLOW.md §4 phase 12). This file is also the merge request
     description, unchanged: GitLab-flavoured Markdown, no front matter.
     Keep every `## ` and `### ` heading exactly as written and in this order (Summary, 13 numbered sections,
     Appendix A). Replace every {{placeholder}} and delete every `<!-- guide:` comment when filling.
     Write `n/a — <why>` or `⚠ <question>` instead of deleting a row or section.
     Every count, rate, SHA and status comes from a command pasted in the SAME section as a ```console block:
     `$ <command>` on the first line, the real output below, trimmed only with `[... trimmed ...]`.
     Never paste raw events.jsonl lines, secrets, tokens, PHI or real personal data (the MR is public).
     Ids: M<N>-T### tasks, D<n> decisions, R<n> verifier rows (p<k>-R<n> when there is more than one pass),
     DV-n deviations (local to this report, never renumbered on a re-run). -->

| Field | Value |
|---|---|
| Milestone | M{{N}} — {{goal, copied from the MILESTONES.md row}} |
| Branch / MR | `milestone/m{{N}}-{{slug}}` · MR !{{iid}} ({{draft / ready}}) — {{web url, or "⚠ no MR found"}} |
| Verified head | `{{short sha}}` (§4.1), branched from `main` at `{{merge-base short sha}}` |
| Specs | `specs/M{{N}}-{{slug}}/` (brief, acceptance, tasks; frozen after merge) |
| Written | {{`date` output}} by report-milestone ({{harness}}, {{model id}}) |
| Confidence | {{low / med / high}} — {{one line: the weakest proof, which caps it}} |
| G5 readiness | {{k}}/4 clauses yes (§13, recipe 12 `g5_clauses_yes`) · recommendation: {{Merge / Revise / Stop}} |

## Summary

<!-- guide: three bullets, plain words, no adjectives the evidence can't back ("robust", "complete"). -->

- Shipped: {{what a user can now do, with FR ids}}
- Not shipped: {{cut or missing tasks and FRs, with why; or "nothing planned was left out"}}
- Watch: {{the riskiest Not verified item (§11), in one line}}

## 1. Delivered vs planned

<!-- guide: one row per task file in specs/M<N>-<slug>/tasks/, in id order. Fill it after §4. Status vocabulary:
     delivered = squash commit with its Task: trailer + scope-guard exit 0 (§4.3) + its AEs pass, i.e. make check
     exit 0 in §4.2 (it runs tests/acceptance/**); a red make check means no task is delivered;
     partial = commit landed but make check is non-zero (name the AE lines §4.2 shows failing), or result.md is human_review;
     cut = no commit AND a D-row or Approvals row says so (cite it); missing = no commit and no record (a DV row).
     Evidence names proof a reviewer can re-run; a worker's result.md is labelled "worker claim". -->

| Task | Status | Squash commit | Covers | Evidence |
|---|---|---|---|---|
| M{{N}}-T{{###}} | {{delivered / partial / cut / missing}} | `{{short sha}}` | {{FR-###, AE-###}} | {{scope-guard exit 0 (§4.3) · AE-### passes (§4.2) · result.md status done (worker claim)}} |

Unplanned commits on the milestone branch (no `Task:` trailer):

| Commit | Subject | Kind |
|---|---|---|
| `{{short sha}}` | {{subject}} | {{fix-bug (`specs/bugs/<slug>.md`) / sync from main / docs / handoff / stray → DV-n}} |

```console
$ {{recipe 2 commands, verbatim}}
{{pasted output}}
```

## 2. Why (requirements covered)

<!-- guide: every FR/AE id from the tasks' covers: lines, with its title from docs/product/prd.md. -->

- {{FR-###}} — {{title}} (`docs/product/prd.md`) — covered by {{M<N>-T###}} · {{AE-###}}
- Not delivered: {{none | FR-### / AE-### because … (DV-n)}}

```console
$ {{recipe 3 commands}}
{{pasted output: the AE comparison must print nothing, or each printed AE is a DV row}}
```

## 3. Decisions (D-ids)

<!-- guide: D-rows added or re-statused on this branch (recipe 5), copied from docs/decisions/DECISION_JOURNAL.md.
     A D-row still `proposed` at G5 is undecided: write `proposed (⚠ undecided)` and give it a DV row in §5. -->

| D-id | Title | Status | Choice in one line | Type |
|---|---|---|---|---|
| D{{n}} | {{title}} | {{accepted / superseded-by D<m> / rejected / proposed (⚠ undecided)}} | {{choice}} | {{Type 1 / Type 2}} |

```console
$ {{recipe 5 commands}}
{{pasted output}}
```

## 4. Verification

Run by report-milestone on the milestone head at {{`date` output}}; nothing below is copied from a worker.

### 4.1 Head and tree

```console
$ git rev-parse --short HEAD; git branch --show-current
{{pasted output}}
$ git status --porcelain -- . ':!.handoff' ':!docs/milestones/M{{N}}.md'
{{pasted output: empty}}
```

### 4.2 make check

```console
$ make check
{{pasted tail, including the test and assertion counts; on a non-zero exit also recipe 4's AE lines}}
exit {{code}}
```

### 4.3 Scope guard per squash commit

```console
$ {{recipe 4 scope-guard loop}}
{{pasted output: one block per task commit, every exit=0}}
```

### 4.4 Acceptance tests untouched by implementers

```console
$ {{recipe 4 acceptance command}}
{{pasted output: empty}}
```

### 4.5 Diagrams in sync

```console
$ {{recipe 4 diagrams command}}
{{pasted output}}
```

### 4.6 Branch contains main

```console
$ {{recipe 1 ancestry commands}}
{{pasted output: "contains main"; otherwise the merge result is untested (DV row and §11)}}
```

## 5. Deviations from plan

<!-- guide: every difference between the G4-approved plan and what landed: task cut or missing, unplanned commit,
     AE uncovered, task file edited after its G4 sha, harness used ≠ task file harness, scope-guard failure,
     acceptance test touched, main moved, D-row still proposed. "Why" cites a D-row, an Approvals row or a Log line, or the human's answer
     to step 12 (quoted with its date). No record → `⚠ why not recorded` and Decision `⚠ needs log-decision`. -->

| Id | Deviation | Kind | Why (source) | Decision |
|---|---|---|---|---|
| DV-{{n}} | {{what differs from the plan}} | {{cut / missing / added / changed / Owns / AE / harness / scope / main moved}} | {{reason — D<n> / Approvals <time> / Log <line> / human, <date>: "<words>"}} | {{D<n> / ⚠ needs log-decision / none needed: <why>}} |

```console
$ {{recipe 5 G4-approved sha and task-file drift commands}}
{{pasted output: the G4-approved sha, then task files edited after approval}}
```

## 6. Verifier dispositions

Review file(s): {{`.handoff/reviews/M<N>-pass<k>.md`, …}} · {{k}} pass(es) · reviewer: {{each review's `Reviewer:` line}}
· worker self-reports quoted to the verifier: {{what each review's Not-reviewed list says about them / "none quoted"}}
(recipe 7) · task authors: §10.

<!-- guide: one row per verifier row. "Suggested" is the verifier's; "Disposition" is ONLY the human's word, copied
     verbatim from .handoff/TRACKER.md ## Approvals with its time; none recorded → `⚠ pending`.
     Where handled: fix → the commit after the review that fixes it; file → the issue the human named;
     keep / discard → the human's reason. -->

| Row | Axis | Severity | Suggested | Disposition (human, verbatim) | Where handled |
|---|---|---|---|---|---|
| R{{n}} | {{axis}} | {{P0-P3}} | {{fix / file / keep / discard}} | {{fix — "<exact words>" (Approvals {{time}}) / ⚠ pending}} | {{`<sha>` / issue #<n> / reason}} |

```console
$ {{recipe 7 commands}}
{{pasted output}}
```

## 7. Security

- Checklist: `docs/security/CHECKLIST.md` @ `{{short sha}}` — {{fresh / stale: code changed after it (paths below)}}
- G5 security condition (as the checklist states it): {{pasted `G5 security condition` line}}
- Unaccepted high/critical findings and secrets: {{u}} and {{s}} (recipe 8 count line) — {{each SEC id, or "none"}}
- Accepted risks: {{each as the checklist records it, `SEC-<n> accepted (D<n>)`, or "none"}}
- Secret scan: {{gitleaks <version> → <result> / NOT INSTALLED: covered only by the checklist}}
- Dependency changes: {{none / the manifest and lock paths changed, with their D-id or Approvals row}}

```console
$ {{recipe 8 commands}}
{{pasted output}}
```

## 8. Factory metrics

<!-- guide: copy the numbers from recipe 9 and recipe 6; rates round DOWN. Then 1-2 plain sentences on what they
     teach and which FAIL lines are candidates for route-failure.
     Plain words: first-pass = an agent finished the task in one run with nothing to repair; it is the factory's
     north-star number because every repair costs human attention. -->

| Metric | Value | How it is counted |
|---|---|---|
| First-pass acceptance rate | {{fp}}/{{n}} dispatched = {{p}}% (rounded down) · {{x}} unknown · not dispatched: {{ids / none}} | one DISPATCH; no FAIL/ESCALATE; no human_review/relaunch in Log or Tasks; last RESULT line `status=done timeout=no tree=clean`; squash commit landed ÷ dispatched tasks. A RESULT line without those fields is unknown, counted as not first-pass |
| Fix loops | {{l}} re-dispatches · worst: {{M<N>-T###}} ({{k}}) | DISPATCH count − 1 per task (archived attempts included) |
| Verifier passes | {{v}} | review files for M{{N}} |
| Gate Revise count | {{r}} of {{g}} gate answers | `## Approvals` rows of this milestone whose words say Revise |
| Scope-guard blocks | {{b}} logged · {{x}} failing now (§4.3) | FAIL lines naming scope-guard + non-zero exits in §4.3 |
| Rework after merge | n/a — measured at the next milestone | — |

```console
$ {{recipe 9 loop}}
{{pasted output: one line per task + the totals line}}
$ {{recipe 6 scoped / Revise count}}
{{pasted output}}
```

What the numbers say: {{plain words, e.g. "T002 needed a second run because its Owns missed a test path:
a slice-tasks gap, worth a route-failure row"}}

## 9. Cost and usage

<!-- guide: one row per run dir (archived attempts included) plus the supervisor session. Claude's
     total_cost_usd is an API-equivalent figure (a Max subscription does not bill it); Codex on the seat reports
     tokens only. Unmeasured → "not measured: <why>", never an estimate. -->

| Run | Harness | Tokens in / cached / out | Reported cost | Source |
|---|---|---|---|---|
| {{M<N>-T### or M<N>-T###.attempt-<ts>}} | {{claude / codex}} | {{in}} / {{cached}} / {{out}} | {{$x.xxxx API-equivalent / seat: not metered per run}} | `events.jsonl` {{result / turn.completed}} |
| supervisor session | Claude Code | not measured: {{why}} | not measured | — |

Totals: {{claude API-equivalent $ over n runs}} · {{codex tokens over n runs}} · {{n}} runs not measured.

```console
$ {{recipe 10 usage loop and total}}
{{pasted output}}
```

## 10. Agent disclosure (harness and model per task)

| Task | Skill | Harness (cmd.txt) | Model (events / result.md) | Checked by |
|---|---|---|---|---|
| M{{N}}-T{{###}} | implement-task | {{harness + version}} | {{model id}} ({{events / worker claim}}) | {{its VERIFY Log line (recipe 10) / ⚠ no VERIFY line}} |
| — | supervisor, report-milestone | Claude Code | {{model id}} | the human at G5 |

Gate answers recorded for this milestone in `.handoff/TRACKER.md ## Approvals`: {{recipe 6 "gate answers per gate"
line, e.g. G4=1 G5=0}}; a gate missing from that line has no recorded human answer.

```console
$ {{recipe 10 harness/model loop}}
{{pasted output}}
```

## 11. Not verified

<!-- guide: everything no command in this report proves. Sources: each result.md not_verified (worker claim),
     the verifier's "Not reviewed", recipes that could not run, Approvals rows with no resolvable sha, cost not
     measured, merge result untested. Riskiest first. Never empty without saying what was checked. -->

- {{item}} — {{why nothing proves it}} — source: {{M<N>-T### result.md (worker claim) / verifier Not reviewed / this report}}

## 12. Rollback

- Merge method: {{merge / rebase_merge (semi-linear): one merge commit / ff: no merge commit, rollback is NOT one revert / not checked: why}}
- One command, after the merge:
  `m=$(git log main --first-parent --merges -1 --format=%H --grep="milestone/m{{N}}-{{slug}}"); [ -n "$m" ] && git revert -m 1 "$m" || echo "no merge of milestone/m{{N}}-{{slug}} on main yet"`
- Why one revert is enough: the merge commit has two parents, main as it was (parent 1) and this branch (parent 2);
  `-m 1` undoes exactly what the merge added on top of parent 1, which is this milestone's work. Syncs from main
  inside the branch ({{n}}, information only) are already in parent 1, so they stay.
- Data, migrations, config a revert does not undo: {{none / each path, and the AGENTS.md command that reverses it, in order / ⚠ no reverse command in AGENTS.md}}

```console
$ {{recipe 11 commands}}
{{pasted output}}
```

## 13. G5 readiness

| Clause | Answer | Evidence |
|---|---|---|
| Evidence pasted | {{yes / no}} | {{§4 fresh on the head; branch contains main; every status in §1 has its command}} |
| Dispositions done | {{yes / no}} | {{§6: <k> of <r> rows have a recorded human disposition; every fix row has a commit}} |
| Nothing graded its own work | {{yes / no}} | {{§4.2 run by report-milestone; verifier ≠ authors (§6, §10); §4.4 empty; every task dispatched (§8)}} |
| One-revert rollback | {{yes / no}} | {{§12: merge method creates a merge commit; data/migration/config steps listed with reverse commands}} |

Security (check-security's question, inside G5): {{u}} unaccepted high/critical, {{s}} secrets — {{yes / no: SEC ids}} (§7)

Open P0/P1 rows: {{n}} · Undecided deviations: {{n}} · Proposed D-rows: {{n}} (all from recipe 12 below) ·
Recommendation: {{Merge / Revise: <smallest change that turns each "no" into "yes"; each SEC id to fix or accept> /
Stop: <why>}}

<!-- guide: paste the SECOND run of recipe 12 (after the table above is filled). The header and the STOP message
     take their numbers only from this block, §4.2 and recipe 9's lines in §8. Merge only when every clause is yes
     and open_p0_p1, undecided_deviations, proposed_d_rows, pending_markers, unaccepted_high_critical and secrets
     are all 0. -->

```console
$ {{recipe 12 tallies}}
{{pasted output}}
```

## Appendix A. Task ledger

<!-- guide: the M<N> rows of .handoff/TRACKER.md ## Tasks, verbatim. The supervisor clears them from TRACKER after G5. -->

| id | ask (link) | track/phase | harness+model | state | since | owns | result |
|---|---|---|---|---|---|---|---|
| {{verbatim row}} |
