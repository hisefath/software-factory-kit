---
artifact: security-checklist
milestone: M<N>
branch: milestone/m<N>-<slug>
base_sha: <full sha: git merge-base <default branch> <milestone branch>>
head_sha: <full sha: git rev-parse <milestone branch>>
checked: <output of `date`>
checker: check-security (<harness>, <model id>)
standard: OWASP ASVS 5.0 Level 1, chapter-level mapping
gate: G5
status: draft
---

# Security checklist: <project name> M<N>

## Summary

<2-3 plain sentences: what this milestone changed that matters for security, and whether it meets the G5 security
condition. Write this section last, from the count command in Done when.>

- **G5 security condition:** <met | not met>: secrets <s>, unaccepted high/critical <u>
- **Rows:** <p> pass · <f> fail · <a> n.a. (of <r>)
- **Open findings:** <c> critical · <h> high · <m> medium · <l> low
- **Secret scan:** <gitleaks <version> (verified) | grep heuristic (unverified)>: <n> hits: <t> secret, <v> revoked,
  <fp> false positive
- **Dependency audit:** <tool + result per lockfile | not run: <why>>
- **Accepted risks:** <D<n> SEC-<n>, ... | none>
- **Biggest gap:** <N<n> or Q<n>: what is least checked and why it matters>

## Scope and method

- **Milestone:** M<N> `<branch>`; diff `<base_sha>`..`<head_sha>`, <f> files changed (CMD-<n>)
- **Milestone kind:** <code | docs-only: only docs/, specs/, .handoff/ or *.md changed (CMD-<n>)>
- **Trust boundaries in play:** <TB-n: what crosses it>; <TB-n ...> (from `docs/architecture/hld.md` §5)
- **Change plan security field:** <quoted, from `specs/M<N>-<slug>/change-plan.md` | no change plan (greenfield)>
- **Inherited findings routed here:** <AUDIT A<n>, ... | none | no AUDIT.md>
- **Tools on PATH:** <gitleaks, composer, npm, pnpm, osv-scanner: version or "absent" each> (CMD-<n>)
- **Tests cited:** <`make check` at <sha> → <result> (CMD-<n>) | not run: <why>>

## Checklist

Status: `pass`, `fail` or `n.a.`; no evidence is `fail`. Evidence: `path:line` or `CMD-<n>` plus its result.
Add CK-14 File handling (V5), CK-15 APIs and webhooks (V4), CK-16 Tokens, OAuth and OIDC (V9, V10) only when the
HLD or the diff has that surface; otherwise leave them out.

| ID | Area | ASVS 5.0 | Status | Evidence | Finding |
|---|---|---|---|---|---|
| CK-01 | Authentication | V6 | <pass> | `<path>:<line>` <what it shows> | <— or SEC-<n>> |
| CK-02 | Session management | V7 | <...> | <...> | <...> |
| CK-03 | Access control and IDOR | V8 | <...> | <...> | <...> |
| CK-04 | Input validation and injection | V1, V2 | <...> | <...> | <...> |
| CK-05 | Output encoding and XSS | V1, V3 | <...> | <...> | <...> |
| CK-06 | CSRF | V3 | <...> | <...> | <...> |
| CK-07 | Secrets and cryptography | V11, V13 | <...> | <...> | <...> |
| CK-08 | Errors and logging (no PII or secrets) | V16 | <...> | <...> | <...> |
| CK-09 | Data protection | V14 | <...> | <...> | <...> |
| CK-10 | TLS verified | V12 | <...> | <...> | <...> |
| CK-11 | Configuration and headers | V13, V3 | <...> | <...> | <...> |
| CK-12 | Dependencies | V15 | <...> | <...> | <...> |
| CK-13 | Business logic and money integrity | V2 | <fail> | CMD-<n> → <result> | SEC-<n> |

## LLM risks

<If step 5 found no model call, replace everything below this line with exactly one line:
`n.a.: no model call in code (CMD-<n> → <0 matches | only non-code hits: <paths, why each is not a model call>>; no
model container in docs/architecture/hld.md).`>

Model call found: <`path:line`, provider, model id> (CMD-<n>). OWASP Top 10 for LLM Applications 2025.

| ID | Risk | OWASP ref | Status | Evidence | Finding |
|---|---|---|---|---|---|
| LLM-01 | Prompt injection | LLM01:2025 | <...> | <...> | <...> |
| LLM-02 | Sensitive information disclosure | LLM02:2025 | <...> | <...> | <...> |
| LLM-03 | Supply chain | LLM03:2025 | <...> | <...> | <...> |
| LLM-04 | Data and model poisoning | LLM04:2025 | <...> | <...> | <...> |
| LLM-05 | Improper output handling | LLM05:2025 | <...> | <...> | <...> |
| LLM-06 | Excessive agency | LLM06:2025 | <...> | <...> | <...> |
| LLM-07 | System prompt leakage | LLM07:2025 | <...> | <...> | <...> |
| LLM-08 | Vector and embedding weaknesses | LLM08:2025 | <...> | <...> | <...> |
| LLM-09 | Misinformation | LLM09:2025 | <...> | <...> | <...> |
| LLM-10 | Unbounded consumption | LLM10:2025 | <...> | <...> | <...> |

## Secret scan

- **Scanner:** <gitleaks <version> (verified) | grep heuristic (unverified)>
- **Scope:** <git history of all branches (gitleaks git) | working tree + tracked env files + history commit list>
- **Commands:** CMD-<n> → exit <code>, <summary line>; CMD-<n> → <...>
- **History (heuristic only):** <commits that touched secret-like lines in files with no tree hit, each as an H<n>
  row | none> (CMD-<n>)
- **Open secrets:** <s> (triaged `secret`, not revoked)

Locations only. Never a value: write `<redacted: kind>` if you must describe one. Triage: `secret` (critical, open);
`revoked: rotated <date> per Approvals <time>` (only with an Approvals row `G5 SEC-<n>` holding the human's words
that it was rotated, and no hit left at the head; its finding is `fixed`); `false positive: <reason>`.

| Hit | Location | Rule or kind | Triage | Finding |
|---|---|---|---|---|
| H1 | `<path>:<line>` (history: `<path>:<line> @<rev>`) | <gitleaks rule id or pattern kind> | <secret, or revoked: rotated <date> per Approvals <time>, or false positive: <reason>> | <SEC-<n> or —> |

## Dependency audit

| Lockfile | Tool + version | Command | Exit | Result | Findings |
|---|---|---|---|---|---|
| `<composer.lock>` | <composer 2.x> | CMD-<n> | <0> | <n advisories: c critical, h high, m medium, l low; abandoned: n> | <SEC-<n>, ... or —> |
| `<package-lock.json>` | <not run> | — | — | <not run: npm not on PATH, or: docs-only milestone> | <SEC-<n>> |

- **Packages added or upgraded in this milestone:** <name version: D<n> | ⚠ no decision: SEC-<n>> (CMD-<n>)
- **Manifests without a committed lockfile:** <none | path: SEC-<n>>

## Threat and invariant trace

Every `TH-n` and `INV-n` in `docs/architecture/hld.md`, plus AUDIT findings and change-plan items routed here.
A docs-only milestone before the HLD exists replaces the table with one line: `none: no HLD yet (docs-only milestone)`.

| HLD id | What the design says (mitigation or invariant, short) | Checked in | Result |
|---|---|---|---|
| TH-<n> | <design mitigation> | <CK-<nn>> | <pass, or fail: SEC-<n>, or n.a.: <why>> |
| INV-<n> | <invariant> | <CK-13> | <...> |

## Diff coverage

Every path in `git diff --name-only <base_sha> <head_sha>`, or a directory entry ending in `/` covering it.

| Path | Rows touched | Note |
|---|---|---|
| `<app/Http/Controllers/OrderController.php>` | <CK-03, CK-13> | <what the change does to security> |
| `<docs/>` | none | <documentation only> |

## Findings

Source: CK-<nn>, LLM-<nn>, secret, dependency, AUDIT A<n>. Severity: critical, high, medium, low (rubric in the
skill). Reachable: yes, no: <why>, unknown.
Recommend: fix, accept, investigate. Disposition: `pending G5` until the human answers inside G5, then copied
from the Approvals row whose gate cell names it (`G5 SEC-<n>`) as `fix (<task id or bug slug>)`, `accepted (D<n>)`
or `investigate (Q<n>)`. State: open, fixed @<sha> (CMD-<n>), fixed @<sha> (revoked, Approvals <time>) for a
rotated secret, withdrawn <date>: <why>.

| ID | Source | Severity | Finding | Evidence | Reachable | Recommend | Disposition | State |
|---|---|---|---|---|---|---|---|---|
| SEC-1 | <CK-03> | <high> | <what is wrong, one sentence, no pipes> | `<path>:<line>` | <yes> | <fix> | pending G5 | open |
| SEC-2 | <dependency> | <medium> | <package version: advisory id, title> | CMD-<n> | <no: dev-only> | <accept> | pending G5 | open |

## Accepted risks

Copied verbatim from `docs/decisions/DECISION_JOURNAL.md` and `.handoff/TRACKER.md ## Approvals`, never from
memory. Before the first G5 answer this table has no rows; write `none yet` under it.

| D-id | Finding | Severity | Human's words (verbatim) | Revisit if | Follow-up |
|---|---|---|---|---|---|
| D<n> | SEC-<n> | <high> | "<exact words>" | <trigger> | <task id, milestone, or none> |

## Not checked

| ID | What | Why not | Risk of the gap | Who closes it |
|---|---|---|---|---|
| N1 | <live TLS certificate and response headers> | <needs the deployed app> | <a proxy or host setting could differ from config> | <ship-milestone (G-live)> |

## Questions

| ID | Question | Why it matters | Recommended answer | Blocks |
|---|---|---|---|---|
| Q1 | ⚠ <question> | <which row or finding depends on it> | <your recommendation and why> | <G5, SEC-<n>, or nothing> |

## Commands run

Every command whose output is cited above, in run order. Output is the exit code and the summary line only, with
secret values removed. The heuristic pattern is written as `"$P"` (defined in check-security), never expanded.

- **CMD-1** `date` → exit 0 · <output>
- **CMD-2** `git rev-parse <milestone branch>` → exit 0 · <sha>
