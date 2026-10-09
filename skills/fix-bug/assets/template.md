---
artifact: bug
slug: ⟦kebab-case, at most 5 words, names the symptom⟧
status: ⟦verified | partial | failed | escalated⟧
track: Fix
reported: ⟦output of `date '+%Y-%m-%d %H:%M %Z'`⟧ · source: ⟦human message | TRACKER row id | issue link | SM-n / SMK-n line⟧
tracker_row: ⟦TRACKER row id⟧
base_sha: ⟦git rev-parse --short HEAD before any edit⟧
base_branch: ⟦milestone/m<N>-<slug> | main⟧
branch: ⟦fix/<slug> | none (escalated or failed: no commit)⟧
fixer: fix-bug (⟦harness⟧, ⟦model id⟧)
gate: G5
---

<!-- fix-bug record skeleton. Replace every ⟦…⟧ placeholder (this delimiter is used because Blade, Twig, Vue,
     Jinja and Handlebars all use double braces, which real evidence may quote); delete every HTML comment,
     including the commit-message block at the end (it is the commit's skeleton, not part of this record).
     Ids: E1-E8 entry conditions (fixed), U<n> must-stay-unchanged behaviours, C<n> callers. Never renumber.
     Evidence: at most 3 quoted lines each; patient data and secrets as <redacted: kind>; all test data synthetic.
     Unknown: write the warning sign and a question; a verified record has none.
     Sections not reached (escalated or failed): "not reached: escalated at step N" or "not reached: failed at step N".
     Self-report: Regression test, Fix, Verification and Verdict are the fixer's own claims; the verifier is given
     only Report through Root cause. -->

# ⟦The Observed symptom in one plain sentence⟧

## Report

| Field | Value |
|---|---|
| Observed | ⟦What happens now, exactly as seen: the value, message or screen state⟧ |
| Expected | ⟦What should happen instead⟧ |
| Repro | ⟦Numbered steps or one command, with exact synthetic inputs, run locally; or the SM-n/SMK-n line and its environment⟧ |
| Evidence | ⟦Error text, log line, failing command output or screenshot path, at most 3 lines, redacted⟧ |

## Entry rule

<!-- WORKFLOW.md §3. Pass 1 from the report alone (step 4); Pass 2 after the root cause (step 7).
     Cell values: pass | fail | n/a (pass 1 only, for E1/E2 which need the root cause). Any fail = escalate.
     E2 reads §3's "≤2 files" as "≤2 product files (plus the regression test and this record)". PROVISIONAL until
     WORKFLOW.md §3 says so; if the owner rejects that reading, the test and record count toward the 2.
     E3 "provisional": the Repro needs an environment fix-bug may not use (production, device, external system);
     decided by the local red runs in step 9, and the verdict can then be at best partial. -->

| Id | Condition | Pass 1 | Pass 2 | Evidence |
|---|---|---|---|---|
| E1 | The diff fits in one sentence | n/a | ⟦pass/fail⟧ | "⟦fix point⟧ now ⟦expected⟧ when ⟦condition⟧ (was ⟦observed⟧)" |
| E2 | ≤2 product files (provisional: this record and the regression test don't count) | n/a | ⟦pass/fail⟧ | ⟦path⟧, ⟦second path or none⟧ |
| E3 | A repro exists and shows Observed on base every time | ⟦pass/provisional/fail⟧ | ⟦pass/fail⟧ | `⟦repro command⟧` → ⟦output, 1 line⟧ (×2), or ⟦pasted evidence⟧ + local red ×2 |
| E4 | No API / public contract | ⟦pass/fail⟧ | ⟦pass/fail⟧ | ⟦why not: file:line⟧ |
| E5 | No data model / migration | ⟦pass/fail⟧ | ⟦pass/fail⟧ | ⟦why not: file:line⟧ |
| E6 | No dependency | ⟦pass/fail⟧ | ⟦pass/fail⟧ | ⟦why not⟧ |
| E7 | No auth | ⟦pass/fail⟧ | ⟦pass/fail⟧ | ⟦why not: file:line⟧ |
| E8 | No payment | ⟦pass/fail⟧ | ⟦pass/fail⟧ | ⟦why not: file:line⟧ |

## Current behaviour

⟦What the code does today, traced hop by hop from the entry point the Repro hits to the first wrong value:
`file:line` → `file:line` → … Plain words a beginner could follow.⟧

## Expected behaviour

⟦What the code must do instead, stated as observable behaviour (input → output), not as code.⟧

- Intent evidence: ⟦FR-### or AE-### at docs/product/prd.md:L (or acceptance.md:L), quoted in one line | "the human's verbatim words" (date)⟧
- Decisions checked: ⟦D<n> that touch this behaviour, none reversed | none found in DECISION_JOURNAL.md⟧

## Must stay unchanged

| Id | Behaviour callers rely on | Guarded by |
|---|---|---|
| U1 | ⟦behaviour near the fix point, as input → output⟧ | ⟦existing test path::name run by make check, or pin test path::name (green on base and after), or unguarded → Not verified⟧ |

## Root cause

- Defect site: `⟦file:line⟧`: ⟦why the value goes wrong here, one or two sentences⟧
- Function touched: `⟦function or method⟧` · callers found with `⟦exact grep command(s)⟧` → ⟦n⟧ hits

| Id | Caller (file:line) | Routes through the fix point | Behaviour change for this caller |
|---|---|---|---|
| C1 | `⟦file:line⟧` | ⟦yes/no⟧ | ⟦gets the fix, or none (U<n> holds)⟧ |

- Fix point: `⟦file:function⟧`: ⟦why here: every affected caller passes through it, and no caller relies on the
  old behaviour⟧

## Regression test

- Test: `⟦path⟧::⟦name⟧` (⟦new file | new case appended to an existing file⟧; its comment points at this record)
- Command: `⟦one-test command from AGENTS.md⟧`
- Red run 1 on ⟦base_sha⟧: exit ⟦n⟧, `⟦failing assertion, showing the Observed value, at most 2 lines⟧`
- Red run 2 on ⟦base_sha⟧: exit ⟦n⟧, `⟦same assertion⟧`
- Right reason: ⟦why this is the reported bug and not a setup, import, fixture, syntax or timeout error⟧
- Pin tests: ⟦path::name green on base | none⟧
- Source: ⟦in the commit (verified or partial: delete the fence below) | kept below, because the file was removed
  from the tree (escalated or failed)⟧

```⟦language⟧
⟦the regression test and pin tests exactly as written, so a resume or the next track can rebuild them⟧
```

## Fix

- Sentence: ⟦the E1 sentence⟧
- Files: `⟦path⟧` (+⟦added⟧ −⟦removed⟧)⟦, second path (+a −r) | nothing else⟧
- Green run 1: exit 0, ⟦summary line⟧
- Green run 2: exit 0, ⟦summary line⟧

## Verification

| Check | Command | Before (base) | After |
|---|---|---|---|
| Regression test | `⟦one-test command⟧` | red ×2 (right reason) | ⟦green ×2⟧ |
| make check | `make check` | exit ⟦n⟧ (⟦summary; names of failing tests or none⟧) | exit ⟦n⟧ (⟦summary; failing tests or none⟧) |
| Original repro | `⟦command or steps⟧` | Observed | ⟦Expected now, or not re-run: why⟧ |
| Must stay unchanged | ⟦U ids and their guards⟧ | green | ⟦green, or U<n> unguarded⟧ |

## Verdict

**⟦verified | partial | failed | escalated⟧**: ⟦one line: why, from the table above⟧

- Not verified: ⟦each check that could not be proven, with why | none⟧
- Escalation or failure point: ⟦E<n> / step N and the exact reason | none⟧

## Also noticed

<!-- Bugs, smells or AGENTS.md gaps seen but deliberately not touched. Each gets a suggested track. -->

- ⟦file:line: what you saw → suggested track (Fix | Standard) | none⟧

<!-- COMMIT MESSAGE (verified or partial only). Not part of this record: delete this block from specs/bugs/<slug>.md.
     No make-check result or verdict here: those are self-report and stay in the record's last sections.

fix(⟦scope: module, lowercase kebab-case⟧): ⟦E1 sentence, imperative, at most 72 characters⟧

Root cause: ⟦file:function, one line⟧
Regression test: ⟦path::name⟧

Bug: specs/bugs/⟦slug⟧.md
-->
