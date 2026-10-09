<!-- write-demo-script template (software-factory-kit 0.1). Three parts:
     Part A -> docs/demo/SCRIPT.md · Part B -> docs/demo/POSTS.md · Part C -> the job's ## Return path (dispatched only).
     Copy the part inside its fence, keep every heading in this order, replace every {{…}}.
     Unknowns are "⚠ <question>", never a guess. Table cells never contain "|".
     Ids: shots G-01… (grader cut) and S-01… (social cut), two digits · beats B1… · claims C1… · words W1… .
     Every shot names its beat (B<n>): the footage record-demo plans, shoots and checks by id. Shots in both cuts
     that show the same footage share a beat id; beats are numbered in grader-cut order (B1 is the hook).
     Times are m:ss-m:ss. Silence in a Voiceover cell is "—". A shot that states no fact has "—" in Claims.
     Parts, in this order in both cuts: Hook · Problem · Demo · How it works · Proof · Next · Call to action.
     [video link] is the one marker you leave in place: the human swaps it for the real link after uploading. -->

## Part A — `docs/demo/SCRIPT.md`

````markdown
---
status: draft
product: {{product name, as AGENTS.md line 1 names it}}
written: {{output of date}} by write-demo-script ({{harness}}, {{model id}})
evidence_sha: {{git rev-parse --short HEAD when you started}}
shipped: [{{M1}}]
grader_cut: "{{m:ss}}"
social_cut: "{{m:ss}}"
reading_grade: "{{spoken: n.n · posts: n.n}}"
---

# Demo script — {{product}}

> **Draft.** To approve: read the voiceover aloud once, open every `path:line` in Claims, then change line 2 to
> `status: approved`. Any edit after approval makes the approval stale. You record and post; the factory never does.

## At a glance

- The one thing a viewer should remember: {{one sentence, ≤ 15 words, plain words}}
- Grader cut is for: {{who grades it, from the assignment}} · Social cut is for: {{people who know nothing about the domain}}
- Spine story: {{story id}} — {{story title}} (beats from {{docs/design/screens.md#demo-layout-90-seconds | specs/M<N>-<slug>/acceptance.md#demo-smoke | docs/product/prd.md}})
- Test data on screen: {{synthetic people and records named in acceptance.md or the seeders}} — never a real patient, customer or account
- Where it runs for recording: `{{Run locally command from AGENTS.md}}` at `{{base URL named in AGENTS.md or the design docs}}` (or `⚠ base URL for recording`; record-demo runs it, this script never does)
- Screens and reference frames: {{S-ids from docs/design/screens.md, screenshot paths found under docs/, or "none found"}}

## Demo requirements

Copied from the brief's `## Spec is law` rows exactly as the brief records them: a quote, or `(paraphrase, U-##)`.
Never quote a source the brief only paraphrases.

| Source | Requirement (as the brief records it) | Met by |
|---|---|---|
| {{REQ-## (specs/M<N>-<slug>/brief.md:<line>)}} | {{"quote" or (paraphrase, U-##) text, copied from that row}} | {{G-03, G-04 (and S-02 if the social cut also meets it)}} |

## Words we explain

Every word a 12-year-old might not know, said with its meaning the first time it is heard. Prefer swapping it for
a plain word; keep it only when the product's name or the assignment needs it.

| W | Word | Plain meaning (said aloud, one line) | First heard in |
|---|---|---|---|
| W1 | {{EHR}} | {{the app a clinic uses to keep each patient's chart}} | {{G-02}} |

## Script

The story both cuts tell. The spoken words live in the shot lists below; this section says what each part must
do and what backs it.

### 1. Hook

- Grader cut: {{G-01}} · Social cut: {{S-01}} — both end by 0:05.
- What grabs the viewer: {{the person's moment of pain, or the surprising result, in plain words}}
- First frame: {{what is on screen in the first second}}

### 2. The problem

- Who hurts: {{a real role, in plain words}} [{{C1}}]
- How it hurts today: {{what goes wrong, in plain words}} [{{C2}}]
- Why it matters: {{time, money or risk, only if a claim backs it, else drop this line}} [{{C3}}]

### 3. Demo beats

One beat = one action and the result the viewer sees = one shot per cut. This table lists the Demo part's beats;
the other parts' beats (hook, problem, picture, proof, next, call to action) appear only in the shot lists' Beat
column. A Demo shot's Beat cell equals its row id here.

| Beat | What the viewer sees happen | Story | Proven by | Grader cut | Social cut |
|---|---|---|---|---|---|
| B3 | {{the action and its visible result}} | {{story id}} | {{C4}} | {{G-03 · 0:20-0:35}} | {{S-03 · 0:15-0:27 or —}} |

At least one beat shows a non-happy state handled well ({{beat id}}), if the shipped milestone covers one.

### 4. How it works in one picture

- Diagram: `docs/architecture/diagrams/{{type}}.mmd`, shown rendered ({{where the viewer sees it rendered}})
- In three plain sentences: 1. {{…}} 2. {{…}} 3. {{…}}
- Point at, in order: {{box and arrow labels exactly as the diagram writes them}}

### 5. Proof

Copied from the milestone report, never re-run by this skill. record-demo re-runs it on camera if a shot shows it.

| Claim | Command | Result (copied) | Pasted at | SHA |
|---|---|---|---|---|
| {{C5}} | `{{make check}}` | `{{e.g. Tests: 42 passed}}` | `{{docs/milestones/M1.md:57}}` | {{sha the report names}} |

### 6. What's next

- {{next milestone goal, in plain words}} [{{C6}}] — planned, not built; never said as done.

### 7. Call to action

- Grader cut: {{the one thing the grader should do or look at, e.g. "open the repo's README"}}
- Social cut: {{the one thing a viewer should do}}
- Link: {{URL found at path:line | [video link] | ⚠ no public link yet}}

## Grader cut

Target: {{m:ss}} from {{REQ-## (its length as the brief records it) | ⚠ assumed: 3:00, the brief names no length}}. Runs {{m:ss, from runtime G}}.

| Shot | Time | Part | Screen / URL | Action | Voiceover | On-screen text | Claims | Beat |
|---|---|---|---|---|---|---|---|---|
| G-01 | 0:00-0:05 | Hook | {{screen id and state, or URL path}} | {{what the presenter does}} | {{≤ 12 words, ends with . ! ?}} | {{≤ 7 words}} | {{C2 or —}} | {{B1}} |
| G-02 | {{0:05-0:20}} | Problem | {{…}} | {{…}} | {{…}} | {{…}} | {{C1, C2}} | {{B2}} |
| G-03 | {{…}} | Demo | {{…}} | {{…}} | {{…}} | {{…}} | {{C4}} | {{B3}} |
| G-04 | {{…}} | How it works | {{docs/architecture/diagrams/<type>.mmd, rendered}} | {{point at the boxes in order}} | {{…}} | {{…}} | {{—}} | {{B<n>}} |
| G-05 | {{…}} | Proof | {{milestone report or CI page}} | {{scroll to the pasted result}} | {{…}} | {{…}} | {{C5}} | {{B<n>}} |
| G-06 | {{…}} | Next | {{…}} | {{…}} | {{…}} | {{…}} | {{C6}} | {{B<n>}} |
| G-07 | {{…}} | Call to action | {{…}} | {{…}} | {{…}} | {{…}} | {{—}} | {{B<n>}} |

### Grader storyboard

One line per shot: id · start · what the viewer sees · first words said.

- G-01 · 0:00 · {{picture in one line}} · "{{first words…}}"

## Social cut

Target: at most 2:00. Runs {{m:ss, from runtime S}}. For {{platforms}}; plays muted at first, so the on-screen text carries the story.

| Shot | Time | Part | Screen / URL | Action | Voiceover | On-screen text | Claims | Beat |
|---|---|---|---|---|---|---|---|---|
| S-01 | 0:00-0:05 | Hook | {{…}} | {{…}} | {{…}} | {{…}} | {{…}} | {{B1, or a new id for new footage}} |

### Social storyboard

- S-01 · 0:00 · {{picture in one line}} · "{{first words…}}"

## Claims

Every fact said, shown or posted. Evidence is a committed `path:line` a reviewer can open; for a run, add the
command, its result and the SHA it ran at.
Kind: `problem` (who hurts and how) · `does` (what it does) · `proof` (a command and its result) · `next`
(planned). A `does` or `proof` claim cites a shipped milestone's `docs/milestones/M<N>.md` or
`specs/M<N>-*/acceptance.md`, never the PRD, research or a planned `MILESTONES.md` row.

| C | Kind | Claim (plain words, as said) | Evidence | Used in |
|---|---|---|---|---|
| C1 | {{problem}} | {{e.g. Clinics sell supplements to patients.}} | `{{docs/product/prd.md:14}}` | {{G-02, S-02, X post}} |
| C4 | {{does}} | {{e.g. The doctor orders a vitamin in two clicks.}} | `{{docs/milestones/M4.md:31}}` | {{G-03, S-03}} |

## Cut claims

Things worth saying that the repo cannot back yet. They stay out of the video and the posts.

| What we wanted to say | Missing evidence | Who could add it |
|---|---|---|
| {{e.g. "Saves clinics an hour a day"}} | {{no measurement in docs/milestones/}} | {{report-milestone after measuring, or nobody}} |

<!-- no rows: replace the table with the single line "- none" -->

## Open questions

- {{⚠ <question> — assumed: <recommended answer>, or the single line "- none"}}

## Review notes

<!-- Human: write one bullet per change you want, then run write-demo-script again. The next run applies each
     note and answers it here with "→ done: <what changed>" or "→ not done: <why>". -->
- none
````

## Part B — `docs/demo/POSTS.md`

````markdown
---
script: docs/demo/SCRIPT.md
written: {{output of date}} by write-demo-script ({{harness}}, {{model id}})
---

# Posts — {{product}}

> **Draft.** Approved together with SCRIPT.md at G-demo. You post; the factory never does. Swap each
> [video link] for the real link after you upload. Plain words, no emojis, nothing the Claims table can't back.

## X post

```text
{{≤ 280 characters: hook line, what it does, one proof, [video link]}}
```

Characters: {{n, from xchars}} · Claims: {{C2, C4}} · Media: {{social cut video}}

## X thread (optional)

### 1/3

```text
{{the X post's hook, expanded; ≤ 280 characters}}
```

### 2/3

```text
{{how it works in two sentences; ≤ 280 characters}}
```

### 3/3

```text
{{proof and the call to action, [video link]; ≤ 280 characters}}
```

Characters: {{n1}} / {{n2}} / {{n3}} · Claims: {{C1, C5}}

<!-- No thread: delete 1/3, 2/3, 3/3 and their Characters line, and write one line "Skipped: <reason>." -->

## LinkedIn post

```text
{{150-300 words: the person and their problem, what you built, one demo moment, one proof line, what you
learned, the call to action, [video link]. Short paragraphs, plain words.}}
```

Words: {{n, from wc -w}} · Claims: {{C1, C2, C4, C5}}

## Alt text

| Media | Alt text (what someone who cannot see it needs, ≤ 250 characters) |
|---|---|
| {{Social cut video}} | {{plain description of what happens on screen}} |

## Hashtags

- X: {{1-2, e.g. #buildinpublic}}
- LinkedIn: {{3-5}}
````

## Part C — result contract (dispatched only; at the job's `## Return` path)

```markdown
---
task: {{job id, e.g. M1-D01}}
harness: {{codex | claude}}
model: {{model id}}
status: {{done | human_review | relaunch}}
reason: {{one line: "script and posts drafted, 0 ⚠" | "<count_warn> ⚠ open, first: <question>" | "SCRIPT.md already approved" | "Owns: does not match" | "<input> missing" | "scratch dir not writable" | "commit blocked: <first error line>; files uncommitted in <worktree>"}}
base_sha: {{short sha before the run}}
head_sha: {{short sha of your commit, or base_sha if not committed}}
changes: [docs/demo/SCRIPT.md, docs/demo/POSTS.md]
tests: "{{write-demo-script checks -> 0 problems; reading grade spoken n.n, posts n.n}}"
not_verified: [{{that the app shows each screen as written (record-demo checks it live)}}]
---

## Changes

- `docs/demo/SCRIPT.md` — grader cut {{runtime G}} ({{count_shots G}} shots), social cut {{runtime S}} ({{count_shots S}} shots), {{count_claims}} claims, {{count_cut}} cut claims, {{count_warn}} ⚠
- `docs/demo/POSTS.md` — X {{n}} chars, thread {{yes | skipped}}, LinkedIn {{n}} words

## Tests run

    $ . "${TMPDIR:-/tmp}/write-demo-script/checks.sh"; headings; timing G {{max}} {{min, or nothing}}; timing S 120; parts G; parts S; beats; reqs; claims; evidence; numbers; picture; counts
    {{pasted output, or "(no output)"}}
    $ . "${TMPDIR:-/tmp}/write-demo-script/checks.sh"; posts; privacy; emoji; hype; opener; partner '{{names, or nothing}}'
    {{pasted output, or "(no output)"}}
    $ . "${TMPDIR:-/tmp}/write-demo-script/checks.sh"; spoken | grade; posted | grade
    {{pasted output}}

## Questions

- {{each ⚠ from Open questions, or "none"}}
```
