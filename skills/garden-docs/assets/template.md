# garden-docs output skeletons

<!-- guide: garden-docs template. Five parts, one per output. Each skeleton sits inside a ````markdown fence here;
     the files you write have no outer fence. Replace every {{placeholder}}, delete every `<!-- guide:` comment,
     keep every heading in the order shown. Unknowns become `⚠ <question>`, never inventions.
     Part A's factory rows (everything above `## Project-specific`) are copied VERBATIM: check C5 diffs them
     against this file. They mirror factory-kit WORKFLOW.md §4, and factory-kit's templates/docs/README.md (what
     init-repo.sh scaffolds) must be byte-identical to Part A up to `## Project-specific`; a wrong row is a
     route-failure finding, fixed in both files at once. -->

## Part A — `docs/README.md` (the docs index)

````markdown
# Docs index

THE map of this repo's artifacts: one line per artifact type → where it lives, which skill writes it, and the
human approval gate that accepts it (factory-kit WORKFLOW.md §4). If an artifact is not reachable from this
page, agents will not find it. `garden-docs` keeps this file in sync; it lists paths, never counts.

`M<N>` = milestone number · `<slug>` = short kebab name · `T###` = task number · ids never get renumbered.

## Plan (Diamond 1: discover + define)

| Artifact | Path | Written by | Gate |
|---|---|---|---|
| Constitution (rules for every agent) | `AGENTS.md`, `CLAUDE.md`, `.claude/settings.json` | `scripts/init-repo.sh`, then human-only edits | G-init |
| Verifier subagent, MR template, pre-push hook | `.claude/agents/verifier.md`, `.gitlab/merge_request_templates/Default.md`, `.githooks/pre-push` | `scripts/init-repo.sh`, then human-only edits | G-init |
| Workflow scripts (scope guard, dispatch, diagram embedding) | `scripts/scope-guard.sh`, `scripts/delegate.sh`, `scripts/embed-diagrams.sh` | `scripts/init-repo.sh` | G-init |
| Milestone brief | `specs/M<N>-<slug>/brief.md` | `sharpen-brief` | G0 (Full track) |
| Research notes + source list | `docs/research/R<NN>-<slug>.md`, `docs/research/sources.md` | `gather-evidence` | feeds G1 |
| Inherited-code audit (brownfield) | `docs/audit/AUDIT.md` | `audit-codebase` | G-audit "Which findings constrain the build, which do I accept?" |
| Product requirements (living PRD) | `docs/product/prd.md` | `write-prd`, `clarify-spec` | **G1** |

## Design (Diamond 2: develop)

| Artifact | Path | Written by | Gate |
|---|---|---|---|
| UX flows and screens | `docs/design/flows.md`, `docs/design/screens.md` | `map-ux-flows` | G-ux |
| High-level design (HLD) | `docs/architecture/hld.md` | `design-hld` | **G2** |
| Low-level design (LLD) | `docs/architecture/lld.md` | `design-lld` | **G3** |
| API contract | `docs/architecture/contracts/openapi.yaml` | `design-lld` | G3 |
| Brownfield change plan | `specs/M<N>-<slug>/change-plan.md` | `design-lld` | G3 |
| Diagrams (Mermaid source of truth) | `docs/architecture/diagrams/<type>.mmd`, embedded under `<!-- diagram: <type> -->` by `scripts/embed-diagrams.sh` | `draw-diagrams` | inside G2 / G3 |
| Root architecture summary (when graded) | `ARCHITECTURE.md` | `garden-docs` | rides the MR |

## Deliver (Diamond 2: deliver)

| Artifact | Path | Written by | Gate |
|---|---|---|---|
| Acceptance criteria + failing tests | `specs/M<N>-<slug>/acceptance.md`, `tests/acceptance/**` | `define-acceptance` | folded into G4 |
| Task files (one per task) | `specs/M<N>-<slug>/tasks/T###.md` (from `specs/_templates/task.md`) | `slice-tasks` | **G4** |
| Milestone index | `MILESTONES.md` | `slice-tasks` (row), supervisor (status), the human (SHAs, tag) | — |
| Task code | commits on `m<N>/t###-<slug>`, squashed onto `milestone/m<N>-<slug>` | `implement-task` | automated: scope-guard + `make check` |
| Bug spec + regression test | `specs/bugs/<slug>.md` | `fix-bug` | rides G5 |
| Verifier review | `.handoff/reviews/M<N>-pass<k>.md` (input: `.handoff/reviews/M<N>-diff.patch`) | `verifier` subagent | human sets each row fix / file / keep / discard |
| Security evidence | `docs/security/CHECKLIST.md` | `check-security` | inside G5 |
| Milestone report (+ MR body) | `docs/milestones/M<N>.md` | `report-milestone` | **G5** |
| Deploy runbook, health, smoke test | `docs/runbooks/deploy.md`, `docs/ops/HEALTH.md`, `scripts/smoke.sh` | `ship-milestone` | G-live |

## Records, learning, demo

| Artifact | Path | Written by | Gate |
|---|---|---|---|
| Front page (what, demo, quickstart, links, milestones, AI usage) | `README.md` | `garden-docs` | rides the MR |
| Docs index (this page) | `docs/README.md` | `garden-docs` | rides the MR |
| Decision journal (+ one-way ADRs) | `docs/decisions/DECISION_JOURNAL.md`, `docs/decisions/NNNN-<slug>.md` | `log-decision` | none (it is the record) |
| Supervisor state | `.handoff/TRACKER.md` (Resume, Tasks, Approvals, Log) | supervisor, `scripts/delegate.sh` | — |
| Dispatch records | `.handoff/runs/<id>/{brief.md,cmd.txt,result.md}` (`events.jsonl` gitignored) | `scripts/delegate.sh`, the worker | automated |
| Pasted research digests | `.handoff/inbox/` | the human | candidate sources only |
| Durable learnings | `docs/learnings/<slug>.md` | `route-failure` | G-L5 |
| Demo script, posts, recording | `docs/demo/SCRIPT.md`, `docs/demo/POSTS.md`, `docs/demo/RECORDING.md`, `docs/demo/out/` (`docs/demo/raw/` gitignored) | `write-demo-script`, `record-demo` | G-demo |
| Superseded material (+ ledger `docs/archive/README.md`) | `docs/archive/` | `garden-docs` | rides the MR |

## Rules

- `docs/product/prd.md` is living; `specs/M<N>-<slug>/` is frozen once its milestone merges.
- Templates for the task and result contracts: `specs/_templates/task.md`, `specs/_templates/result.md`.
- Private reflections and quiz notes never live here: `~/factory-kit-private/<repo>/`.

## Project-specific

<!-- guide: one row per doc that is not a factory artifact type but stays (e.g. partner API notes, LICENSE.md,
     CONTRIBUTING.md). Owner = the skill or person who keeps it current. Keep a row only while its path exists.
     No such docs: a single row `| none yet | — | — | — |`. -->

| Artifact | Path | Owner | Why it is kept |
|---|---|---|---|
| {{what it is}} | `{{repo-relative path}}` | {{skill or person}} | {{one line}} |
````

## Part B — `README.md` (the front page; sections in exactly this order)

<!-- guide: Sources are fixed. Title = project name from AGENTS.md's H1 (check C6). The line under it =
     AGENTS.md's first sentence, verbatim, on ONE line (check C6; C3 exempts the title and this line from
     footnotes because C6 traces them). Demo = a URL that answered through `curl -fsSL` with TLS verified this
     pass, else exactly the line `Not live yet.` Quickstart = commands copied verbatim from AGENTS.md's Commands table
     (check C4), placeholders left out. Milestones = id, goal and status copied from MILESTONES.md at HEAD
     (check C7), a snapshot: MILESTONES.md stays the live status; a report link only for merged/done rows. AI usage = only harnesses/models seen in result.md files or a
     design doc's "Written by" line. Every number in prose carries a Part E footnote (check C3). -->

````markdown
# {{Project name, from AGENTS.md's H1}}

{{The first sentence of AGENTS.md, verbatim, on one line.}}

## Demo

- Live: [{{live URL}}]({{live URL}}) — running `{{deployed short sha, from docs/ops/HEALTH.md or the runbook}}` ([deploy runbook](docs/runbooks/deploy.md))
- Video: [{{recording title}}]({{video URL from docs/demo/RECORDING.md}})

<!-- guide: nothing live yet → replace both bullets with this exact line (check C11 looks for it):
Not live yet.
     Drop the Video bullet when there is no recording. -->

## Quickstart

From a clone of this repo; every command comes from [AGENTS.md](AGENTS.md):

```bash
{{Setup command, verbatim from AGENTS.md}}
{{Run-locally command, verbatim from AGENTS.md}}
make check
```

{{⚠ <Setup | Run locally> is still a placeholder in AGENTS.md (human-only edit) — or delete this line.}}

## Architecture

{{One or two sentences on the shape of the system, from docs/architecture/hld.md §1; numbers footnoted.}}
Read more: [{{ARCHITECTURE.md | High-level design}}]({{ARCHITECTURE.md | docs/architecture/hld.md}}) ·
[Low-level design](docs/architecture/lld.md) · [Diagrams](docs/architecture/diagrams/)

<!-- guide: link only files that exist (check C2). No hld.md yet → "Design in progress: see [docs/README.md](docs/README.md)." -->

## Docs

Every artifact (requirements, designs, diagrams, milestone specs, reports, runbooks) is indexed in
[docs/README.md](docs/README.md).

## Decisions

Why it is built this way, with the options and costs of each choice: [decision journal](docs/decisions/DECISION_JOURNAL.md).

## Milestones

| Milestone | Goal | Status | Report |
|---|---|---|---|
| {{M<N>}} | {{goal, verbatim from MILESTONES.md}} | {{status, verbatim from MILESTONES.md}} | {{[M<N>](docs/milestones/M<N>.md) when merged or done, else —}} |

Copied from [MILESTONES.md](MILESTONES.md) at `{{HEAD short sha}}`; that file holds the current status, merge SHAs,
gate approvals and tags.

## AI usage

<!-- guide: every sentence here is a claim, so each one stays only while its evidence exists at HEAD; delete any
     sentence whose evidence is absent (never soften it into a vaguer claim):
     S1 needs at least one row under `## Approvals` in .handoff/TRACKER.md.
     S2 needs at least one `### D<n>` entry in docs/decisions/DECISION_JOURNAL.md.
     The table lists only what each harness actually did: "implemented and tested" appears only on a row backed by
     an implement-task or fix-bug result.md; a docs-only milestone has design/planning rows only.
     S3 needs at least one `.handoff/reviews/M<N>-pass<k>.md` (name those milestones only, never "each milestone").
     S4 needs AGENTS.md's Never list to still name push, merge and deploy, and CLAUDE.md's human-only list to still
     name spending money; drop any word the file no longer backs. -->

Built with the factory-kit workflow. {{S1: A human answered the approval gates; the exact words are in
[.handoff/TRACKER.md](.handoff/TRACKER.md) (section Approvals).}} {{S2: Each recorded decision was made by that
human: [decision journal](docs/decisions/DECISION_JOURNAL.md).}}

| Harness | Model | Used for | Evidence |
|---|---|---|---|
| {{harness, e.g. Claude Code, Codex}} | {{model id, verbatim from result.md or "Written by"}} | {{skills it ran, with task ids, e.g. implement-task (M1-T001, M1-T003)}} | {{[path](path) to result.md files or the doc}} |

{{S3: No agent graded its own work: a separate verifier reviewed <each M<N> with a pass file, e.g. M1, M2>
([.handoff/reviews/](.handoff/reviews/)).}}
{{S4: Pushing, merging and deploying are human-only by policy ([AGENTS.md](AGENTS.md)), and so is spending money
([CLAUDE.md](CLAUDE.md)).}}

{{Part E footnotes, one per number, at the very end of the file.}}
````

## Part C — `ARCHITECTURE.md` (only when the project is graded or someone asked)

<!-- guide: ~500 words of prose (check C8 counts 350-650, excluding tables, the diagram and comments).
     Summarize the APPROVED hld.md and lld.md, never add a box, line, number or reason they do not contain.
     Approved = the latest G2 (G3) Approvals row names `<path>@<sha>` and
     `git cat-file -e <sha>:<path> && git diff --quiet <sha> HEAD -- <path>` exits 0; otherwise hld → no file,
     lld → header says `⚠ changed after G3@<sha>` or `not approved yet`. Cite ids so readers can jump to the source.
     Built vs planned (the evidence rule): CN-n is "Built in M<k>" when every FR id in its hld.md §3 Basis cell is
     listed as covered in §2 of docs/milestones/M<j>.md for milestones whose MILESTONES.md status is merged or done
     (and not on that report's "Not delivered" line), k = the latest such j needed. A CN-n whose Basis has no FR id
     takes the earliest Built tag of a container it shares an hld.md §4 L-row with. Otherwise "Planned", or
     "Planned (M<N>)" when a specs/M<N>-*/tasks/T*.md covers: line names its FRs.
     Keep the diagram placeholder only if docs/architecture/diagrams/hld-container.mmd exists, then run
     `bash scripts/embed-diagrams.sh ARCHITECTURE.md`. Trade-offs: exactly one row per `[status: accepted]` D-row
     whose phase bullet names design-hld or design-lld, or whose Reversibility is Type 1 (check C8); scope,
     slicing and go-live decisions stay in the journal. Condense the Y-statement without changing its meaning. -->

````markdown
# {{Project name}} — Architecture

> Summary for readers and graders. Sources of truth: [high-level design](docs/architecture/hld.md) @ `{{sha approved at G2}}`,
> [low-level design](docs/architecture/lld.md) @ `{{sha approved at G3 | ⚠ changed after G3@<sha> | not approved yet}}`,
> [decision journal](docs/decisions/DECISION_JOURNAL.md). Built vs planned as of `{{HEAD short sha}}` ({{date}}).
> Written by garden-docs from those files; change them, not this summary.

## What it does

{{Two or three sentences from hld.md §1: what it does, for whom, and the one quality that matters most (NFR ids).}}

## Containers and how they talk

<!-- diagram: hld-container -->

- **CN-{{n}} {{container name}}** ({{technology}}) — {{responsibility, from hld.md §3}}. {{Built in M<k> | Planned | Planned (M<N>)}}.
- **L-{{n}}** {{from}} → {{to}}: {{protocol}}, {{sync | async}}; on failure, {{what hld.md §4 says happens}}.

## Trust boundaries and invariants

- **TB-{{n}} {{boundary}}** — main threat TH-{{n}} {{threat}}, mitigated by {{mitigation, from hld.md §5}}.
- **INV-{{n}} {{invariant}}** — enforced by {{DB constraint | transaction | code + test}} (hld.md §7).

## Deployment

{{One to three sentences from hld.md §11: environments, where each runs, where secrets come from (names only).}}

## Trade-offs (accepted design decisions)

| D | Decision | Chose | Over | To get | Accepting | Type | Revisit if |
|---|---|---|---|---|---|---|---|
| D{{n}} | {{title}} | {{X}} | {{Y, the strongest rejected option}} | {{Z}} | {{W, the cost accepted}} | {{1 one-way / 2 two-way}} | {{revisit-if}} |

## Go deeper

[Docs index](docs/README.md) · [Diagrams](docs/architecture/diagrams/) · [Milestones](MILESTONES.md) ·
[README](README.md)
````

## Part D — `docs/archive/README.md` (archive ledger) and the archived-file banner

<!-- guide: Create the ledger the first time a file moves; append one row per move, never edit old rows.
     Archive path = docs/archive/<original path without a leading docs/>, with .<YYYY-MM-DD> before the
     extension (docs/research/R01-old.md → docs/archive/research/R01-old.2026-10-08.md; NOTES.md →
     docs/archive/NOTES.2026-10-08.md). Links in this ledger are relative to docs/archive/ (check C2).
     The "Was" cell keeps the backticks: check C9 uses it to accept the old path's deletion. -->

````markdown
# Archive

Superseded docs, kept for history and not maintained: links inside them may point to where things used to be.
garden-docs moves a file here only after the human says yes, and never deletes one. Current docs:
[docs index](../README.md).

| Archived file | Was | Archived on | Superseded by | Human's words |
|---|---|---|---|---|
| [{{path relative to docs/archive/}}]({{path relative to docs/archive/}}) | `{{original repo-relative path}}` | {{date}} | [{{replacement repo path}}]({{replacement path relative to docs/archive/}}) | "{{the human's exact words}}" |
````

Banner: inserted as line 1 of the archived file, followed by one blank line. Nothing else in the file changes.

````markdown
> **Archived {{date}}** from `{{original repo-relative path}}` by garden-docs: superseded by `{{replacement repo path}}`. Kept for history, not maintained; links below may point to old locations.
````

## Part E — README number footnote (one per number)

<!-- guide: Put `[^n<k>]` right after the number in prose, k = 1, 2, 3 … in order of appearance. Run the command
     this pass, at HEAD, on a clean tree; paste one output line verbatim. Check C3 parses this exact shape, so keep
     the backticks, the arrow, the "@" and the comma. A number no local command can measure is dropped. -->

````markdown
[^n{{k}}]: `{{exact command}}` → `{{one output line, verbatim}}` @ {{short sha of HEAD}}, {{YYYY-MM-DD}}
````

Example: `The test suite has 42[^n1] passing tests.` with
`` [^n1]: `php artisan test --compact` → `Tests: 42 passed (97 assertions)` @ 3f9c2ab, 2026-10-08 ``.
