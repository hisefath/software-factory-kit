# Routing reference (route-failure)

Load at step 3: §1 decides what is a failure. Use §2-§4 at steps 5-7, §5 for the STOP metrics and §8 whenever
you set a status. WORKFLOW.md §10 is the source of truth for the symptom → layer table; this file explains how to
choose when more than one row fits, how wide a fix should reach, how to count rules, how to compute the metrics,
and shows one worked example per kind of fix.

## 1. Is it a failure?

| Source | A failure when… | Not a failure (list under "Not routed") when… |
|---|---|---|
| `FAIL` log line | always: something the agent claimed or attempted did not hold | never skip; a transient cause makes it a one-off, still a row |
| `ESCALATE` log line | the failure ladder ran out (stuck, `human_review`) | it was a planned interrupt: a gate, spend, a new dependency, a P0/P1 finding |
| Gate answer Revise | the approved inputs already held what the agent missed or got wrong | the human changed their mind or learned something new: that is the gate working |
| Gate answer Stop | the artifact was unusable | the human parked the work for time or priority |
| Verifier row the human set to `fix` / `file` in `## Approvals` | always: a defect got past `make check` and the task's own tests | no disposition recorded: `⚠ pending` (the `suggested` column is the verifier's guess, not the human's word) |
| Verifier row the human set to `discard` | always a row: `logged` (nothing durable) the first time, so a repeat can be found; the same false alarm again routes to `agents/verifier.md` | — |
| Verifier row the human set to `keep` | never | always: the finding was right and accepted as is |
| Human correction | the agent had what it needed and still did the wrong thing | the human added a new requirement mid-stream (route it as a scope change instead) |
| `specs/bugs/*-r2` | always: a regression means the first fix's test did not guard it | — |

## 2. Preference order (when more than one §10 row fits)

Walk down; take the first step that would have stopped the failure for any model, on any day.

| Step | §10 layers | Why it ranks here, in plain words |
|---|---|---|
| 1 checks | Tests/types · Lint / structural test · Policy (hard) · Verification/hooks | It fails loudly on every run whatever the model does. Nobody has to remember anything. |
| 2 tools | Script · Environment · Settings · Agent policy | It makes the right path the default: the agent calls a script or gets a working setup instead of improvising. |
| 3 artifacts | Spec · Architecture | The agent built what it was told; what it was told was wrong. No check catches what nobody specified. These are product fixes: route them to the owner skill. |
| 4 prompts | AGENTS.md · Skill · Skill description/routing | It works only if the model reads it, notices it applies, and obeys. Cheapest to write, weakest to rely on. |
| 5 none | Session hygiene · nothing durable | The cause was this session's context or chance. Log it; change nothing. |

**How this matches WORKFLOW.md §10.** §10 says both "prefer earlier rows" and "fix environment and tools before
rewording prompts", and its row order puts AGENTS.md and Skill above Script and Environment, so the two clauses
disagree. This table applies the specific clause as the step order (tools before prompts) and uses §10's row order
as the tiebreak inside a step. Until §10 itself says so, say this in the H block's "Why this layer" line whenever
the choice depends on it.

Two more tie-breakers: a check that is cheap to write beats a prompt line even when the §10 symptom names the
prompt layer (a lint rule that bans a deprecated call beats an AGENTS.md line asking agents not to use it); and a
rule the file already states but the agent ignored never gets a second sentence, it moves to step 1 or 2.

## 3. Reach (narrowest durable)

| Reach | Files | Choose when |
|---|---|---|
| task | one `specs/M<N>-<slug>/tasks/T###.md` (route to `slice-tasks`; frozen after merge) | the gap is in one task's `Owns:` or Done-when |
| project | the project's `AGENTS.md`, `CLAUDE.md`, `Makefile`, `.claude/settings.json`, `.githooks/`, `scripts/` | the cause is a fact about this stack, repo or domain |
| factory template | `$KIT/templates/**` | every future project needs it; `init-repo.sh` never overwrites, so existing projects also need their own project-reach block |
| factory skill | `$KIT/skills/<name>/**`, `$KIT/agents/**`, `$KIT/scripts/**` | the phase procedure itself is wrong for any project |
| WORKFLOW.md | `$KIT/docs/WORKFLOW.md` | a rule of the factory is wrong; change it first, in the same diff as the skills that implement it |

## 4. Rule ceilings and counting

| Target | What counts as a rule | Count command | Ceiling |
|---|---|---|---|
| `AGENTS.md`, `CLAUDE.md` (project or template) | each list item | `grep -cE '^[[:space:]]*([-*]\|[0-9]+\.) ' <file>` | ~20 |
| `SKILL.md` | lines; red-flag rows | `wc -l < <file>`; `awk '/^## Red flags/{r=1;next} /^## /{r=0} r && /^\| / && !/^\|---/ && !/^\| Thought/' <file> \| wc -l` | under 300 lines; 3-6 rows |
| a skill's question bank | numbered questions | `grep -cE '^[0-9]+\. ' <file>` | the bank's own "How this bank grows" rule |
| scripts, hooks, settings | none | none | smallest diff; in software-factory-kit, `bash scripts/test.sh` must still pass |

(In the commands above, `\|` is the table's escape; type a plain `|` in the shell.)

Pruning moves, best first: delete a rule a check now enforces (point to the check); merge two rules into one
sharper rule; replace a long procedure with a script and a one-line pointer; delete a rule no FINDINGS row has
needed and a capable newcomer would follow anyway.

## 5. Metrics (for the STOP message)

These cover the **whole tracker**, not only the retro window: label them that way in STOP. Run in the project
root, in bash, after `. <env file> &&`. Task ids look like `M1-T003`. software-factory-kit mode has no tracker: write
`n/a in software-factory-kit mode`.

```bash
T=.handoff/TRACKER.md
verified=$(grep -oE ' VERIFY M[0-9]+-T[0-9]+' "$T" | awk '{print $2}' | sort -u)
failed=$(grep -oE ' FAIL M[0-9]+-T[0-9]+' "$T" | awk '{print $2}' | sort -u)
echo "first-pass: $(comm -23 <(echo "$verified") <(echo "$failed") | grep -c .)/$(echo "$verified" | grep -c .)"
echo "fix loops: $(grep -c ' FAIL ' "$T") FAIL lines"
awk -F'|' '/^## Approvals/{a=1;next} /^## /{a=0} a && $2 ~ /[0-9]/ {n++; if ($5 ~ /^ *"?[Rr]evise/) r++} END{print "gate Revise: " r+0 "/" n+0}' "$T"
echo "scope-guard blocks: $(grep -cE ' FAIL .*scope-guard' "$T")"
```

At milestone close the supervisor moves `## Tasks` rows into `docs/milestones/M<N>.md`; the Log keeps every line,
so the commands above still work. If the Log has no VERIFY lines, write `first-pass: ⚠ no VERIFY lines`.

## 6. Worked examples (one per kind of fix)

F1 and F2 in `$KIT/FINDINGS.md` are real; the rest show the shape.

| Symptom (ev) | Why-chain ends at | Layer (runner-up) | Fix | Guard | Status |
|---|---|---|---|---|---|
| A plugin's session text pushed a research subagent to "minimal docs" (F1) | the plugin is enabled in every repo | Settings (AGENTS.md line) | `enabledPlugins: false` in the settings template | settings template + `init-repo.sh` test | adopted |
| Codex ran a skill marked manual-only (F2) | invocation flags are advice to the model, not a wall | Policy (hard) (Skill description) | boundaries are `scope-guard.sh` + `make check` in pre-push | `scope-guard.sh` in the pre-push hook | adopted |
| Worker wrote `status: done`; the supervisor's `make check` was red | nothing stops a worker finishing on red | Verification/hooks (Skill red flag) | a Stop hook that runs `make check` | a `scripts/test.sh` case: the hook blocks a red check | proposed |
| `make check` failed twice in a delegated worktree: `<tool>: command not found` | the worktree has no toolchain; Setup assumes the host | Environment (AGENTS.md line) | a `make doctor` target that names each missing tool; `delegate.sh` runs it first | `make doctor` exits non-zero and names the tool | proposed |
| The agent called a deprecated API three times after being told | no check bans the call | Lint (AGENTS.md line) | a lint rule whose message names the replacement | lint fails on a fixture using the old call | proposed |
| `slice-tasks` put every migration in T001 (horizontal slicing) | the recipe does not test "user-visible after this task?" | Skill (none cheaper) | one recipe step plus a red-flags row | ⚠ no mechanical guard: G4 card lists each task's visible outcome | proposed |
| `write-prd` fired when the human asked to fix one vague line | the description did not name its sibling | Skill description/routing | "Do NOT use for one open question (use clarify-spec)" | the supervisor routing table row | proposed |
| Built to the PRD; at G5 the human said a reviewer must approve first, and the brief never asked who approves | no question on approval chains | Spec (Skill) | routed → `clarify-spec docs/product/prd.md`; plus H: one question for `sharpen-brief`'s bank | the bank entry ends `(added <date>, FINDINGS.md F<n>)` | routed → clarify-spec + proposed (H<n>) |
| The queue design could not meet the retry NFR | the HLD assumed one worker | Architecture | routed → `log-decision` superseding `D<n>`, then `design-lld` | an acceptance check on the NFR | routed |
| The human corrected the same agent twice in one session about scope | the context drifted after long back-and-forth | Session hygiene | `/clear`, restart from the task file | the failure ladder's "fresh session after 2 corrections" | logged |
| The model truncated one file once; the retry was fine; no earlier row | none found | nothing durable | none | a second occurrence promotes it | logged |
| The verifier flagged a missing CSRF token on a token-auth JSON route; the human set `discard`; no earlier row | none yet: one false alarm | nothing durable | none | the same false alarm in a later pass routes to `agents/verifier.md` | logged |

## 7. The durable-learning test

Write `docs/learnings/<slug>.md` only when both answers are yes:

1. **Durable:** would this recur on another task or project if nothing changed? (One-off quirks and session
   hygiene: no.)
2. **Non-obvious:** would a capable newcomer who read `AGENTS.md` and the PRD still get it wrong? (Restating a rule
   the project already has: no.)

The learning is for the human and the next project: what happened, why, and the rule now, in words they could
say in an interview. The FINDINGS row is the factory's index; the learning is the story behind it.

## 8. Status lifecycle

The `(H<n>)` part of an F row follows its block; a `routed → <skill> +` prefix stays as it is.

| Event | H block heading | F row Status |
|---|---|---|
| filed this pass | `proposed` | `proposed (H<n>)`, or `routed → <skill> + proposed (H<n>)` |
| Approve, bound, not yet applied | `approved` | `approved (H<n>)` |
| Approve, bound, applied (`apply --check -R` exits 0) | `adopted` + Part 3 row | `adopted (H<n>)` |
| Stop | `rejected` | `rejected (H<n>)` |
| Revise | `revise`, then `superseded by H<m>` once H<m> is filed | `proposed (H<m>)`; H<m>'s `F#:` names this same row |
| Approve, but the diff bytes no longer hash to the approved `H<n>@<hash>` | `stale`; re-ask on the current bytes | unchanged |
| Approve, bound, but the diff no longer applies either way | `stale`, then `superseded by H<m>` (regenerated) | `proposed (H<m>)` |
| the row itself was wrong | unchanged | `superseded by F<m>` |

Rules: one H block per F per repo; two fixes in one pass that touch the same file share one block whose `F#:` names
both rows; a filed block's diff never changes; only blocks whose `Project:` is this project are processed, the rest
are listed as "waiting in <project>".
