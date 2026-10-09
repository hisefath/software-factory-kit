---
milestone: M{{N}}
slug: {{kebab-case-outcome}}
artifact: brief
written_by: sharpen-brief (software-factory-kit 0.1)
written_at: {{output of date '+%Y-%m-%d %H:%M %Z (UTC%z)'}}
assignment: {{each official source as a repo-relative path, or the name the human gives it if it lives outside the repo; never an absolute or home path}}
track_recommended: {{Full | Standard | Fix}}
track_decided_in: "G0 row in .handoff/TRACKER.md ## Approvals; this brief holds only the recommendation"
problem_allowlist: {{none, or Term|Term: unavoidable proper names allowed in Problem and Job stories, shown to the human at G0}}
gate: G0
---

# M{{N}} brief: {{product or milestone name in plain words}}

## Ask

> {{one sentence: who needs what, by when, in plain words}}

The human's original words: "{{verbatim ask; secret or personal values → [redacted: what it was]}}"

## Problem

{{quotes that describe only the pain, the people or the moment (the human's words and the assignment's), each followed by its source (Q#, file p./§); an uncleared source is `(paraphrase, U-##) <text>`; a sentence naming a technology is not quoted here but cited by its id (see REQ-## / P-##)}}

**Restated, no solution or tech words:** {{who struggles, in what moment, what they do today instead, what that costs them}}

- **Who has it:** {{people or roles}}
- **What they do today instead:** {{the workaround}}
- **Cost of doing nothing:** {{time, money, errors or risk, in their terms}}

## Job stories

| ID | When… | I want… | so I can… | Who | Source |
|---|---|---|---|---|---|
| JS-01 | {{situation}} | {{motivation, never a feature or screen}} | {{outcome}} | {{role}} | {{ids only: REQ-## / Q#}} |

## Hiring partner

Who we are building for and what should impress them (`docs/METRICS.md` §5). Facts with a source; unknowns go to
Research questions. Not a partner project: one row `none: <why>`.

| Aspect | What we know | Source | What the project should show them |
|---|---|---|---|
| {{who they are: product, customers, size, eng team, stack}} | {{fact, or ⚠ (→ R<NN>)}} | {{source name/§}} | {{how the build, docs or demo shows it}} |

## Value and metrics

Candidates for `write-prd`, not decisions (`docs/METRICS.md` §1-3). Targets are set in the PRD.

- **Underlying problem in the business's terms:** {{what leaks or costs, in the partner's own metric words, quoted with source}}

| ID | Candidate metric | Role | Actionable or vanity ("if bad, what would we fix?") | Leading or lagging | Data that would measure it |
|---|---|---|---|---|---|
| NS-01 | {{the one number that shows the core promise is kept}} | North Star | {{actionable: …}} | {{lagging}} | {{source, or ⚠ (→ R<NN>)}} |
| SM-01 | {{supporting metric}} | explains / guards NS-01 | {{…}} | {{leading}} | {{…}} |

Vanity traps considered and rejected: {{metric: why it tells nobody what to fix}}

## Appetite and deadlines

- **Now:** {{output of date}}
- **Appetite:** {{the time the human chose to spend}}: "{{their exact words}}" ({{Q#}})
- **Timebox:** {{start → end, local time}}

| Checkpoint | As written in the source | Local time (converted by date) | Source |
|---|---|---|---|
| {{checkpoint name}} | {{verbatim, with its timezone}} | {{YYYY-MM-DD HH:MM TZ, or ⚠ timezone? (→ G0)}} | {{file p./§}} |

## Spec is law

Sources read in full: {{each source by its header name, with its page or section count}}.
Requirements extracted: {{count}}. Second pass: {{no new rows | n new rows added}}.

| ID | Requirement (verbatim; uncleared source: `(paraphrase, U-##) <text>`) | Source | Deliverable (assignment's exact filename, or observable proof) | Owning phase / skill | Due | Status |
|---|---|---|---|---|---|---|
| REQ-01 | "{{quote}}" | {{file p./§}} | `{{exact/path.ext}}` | {{phase # skill-name (+ U-##)}} | {{checkpoint}} | {{mapped, or ⚠ question (→ G0)}} |

Conflicts between sources: {{none, or ⚠ conflict (→ G0)}}

## User-owned steps

Things only the human can do. Earliest-blocking first. Every source outside the repo adds a row: "May the brief quote
<source> word for word, and may a copy be committed? ⚠ confidential? (→ G0)".

| ID | Step | Why only the human | Due | Blocks |
|---|---|---|---|---|
| U-01 | {{step}} | {{their account, face, voice, money or authority}} | {{date or checkpoint}} | {{phase / skill / REQ-##}} |

## Track

**Recommended: {{Full | Standard | Fix}}**, because {{the WORKFLOW.md §3 rule that decides it}}.
Greenfield or brownfield: {{greenfield | brownfield: audit-codebase runs before write-prd}}.
Track announced by the supervisor: {{track from .handoff/TRACKER.md, or "not announced"}}.
Existing PRD: {{none | docs/product/prd.md exists; write-prd extends it}}.

| Option | What you get | What it costs, in plain words | Fits this ask? |
|---|---|---|---|
| Full | Every phase from this brief to ship: PRD, UX, HLD, LLD, diagrams, acceptance, tasks, gates | {{cost for this ask}} | {{why or why not}} |
| Standard | Starts from an existing PRD: design delta, acceptance, tasks, build | {{cost for this ask}} | {{why or why not}} |
| Fix | One failing repro and the smallest fix, ≤2 files, no API/data/auth/payment change | {{cost for this ask}} | {{why or why not}} |
| Do nothing | No build; the time goes elsewhere | {{cost for this ask}} | {{why or why not}} |

## Research questions

For `gather-evidence`. Questions only: no answers, no recommended solutions.

| ID | Question | Decision it unblocks | Answered when | From |
|---|---|---|---|---|
| R01 | {{question}} | {{decision, REQ-## or JS-##}} | {{the evidence that would settle it}} | {{REQ-## / JS-## / ⚠ line}} |

## Parking lot

Solution ideas heard during discovery, kept verbatim and not evaluated. Design phases may pick them up.

| ID | Idea (verbatim) | Raised by | When | Need behind it |
|---|---|---|---|---|
| P-01 | "{{quote}}" | {{human / assignment / agent}} | {{date}} | {{JS-##, or ⚠ question (→ G0)}} |

## Interview log

One question at a time, each with a recommendation; answers verbatim, with secret or personal values replaced by
`[redacted: <what it was>]`. Pass {{k}}, {{date}}.

| Q# | Question | Recommended (and why) | Answer (verbatim) | Landed in |
|---|---|---|---|---|
| Q1 | {{question}} | {{recommendation, because …}} | {{"exact words" (redacted), or skipped → ⚠}} | {{section / id}} |
