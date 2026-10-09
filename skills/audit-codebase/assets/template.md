---
artifact: audit
target: <local path and/or deployed URL>
target_sha: <git -C <target> rev-parse HEAD, or "not a git repo">
mode: <change-in-place | rebuild-reference>
audited: <output of `date`>
auditor: audit-codebase (<harness>, <model id>)
gate: G-audit
status: draft
---

<!-- Fill every <...>; replace the example rows (A1, A2, N1, Q1 and the C list) with real ones. Angle brackets
     survive only inside fenced quote blocks and as <redacted: kind>. status: draft until audit-codebase record
     sets approved. Delete this comment. -->

# Audit: <target name>

## Summary

<2-3 plain sentences: what this codebase is, what it does for whom, and the overall verdict on the risk we
inherit. Write this section last.>

- **Findings:** <h> high · <m> medium · <l> low (from the band-count command in Done when)
- **Top risks:** A<n> <short title> (Sev <n>) · A<n> <short title> (Sev <n>) · A<n> <short title> (Sev <n>)
- **Biggest unknown:** <N<n> or Q<n>: the gap most likely to hide a high finding>
- **What this means for the build:** <one line per Downstream phase that has a high finding>

## Scope and method

- **Target:** `<path>` @ `<sha>`; `<URL>` probed <date> with GET only, or not probed: <why>
- **Mode:** <change-in-place | rebuild-reference>: <why, from the brief or the Q-b answer>
- **Deep:** <area ids> · **Shallow:** <area ids> · **Timebox:** <minutes>
- **Critical paths traced:** <P1: entry `path:line` → ... → datastore>; <P2 ...>
- **Read-only commands** (cells below cite these ids; pipes are fine here, never in a table cell):
  - C1: `<command>`
  - C2: `<command>`
- **Toolchain commands not run:** see `## Commands I would run`
- **Interview answers (verbatim):** Q-a <answer or "answered by the brief">; Q-b ...; Q-c ...; Q-d ...; Q-e ...

## Inventory

| Item | Value | Evidence |
|---|---|---|
| Language + version | <version; EOL date + source (target docs or R<NN>), else ⚠ Q<n> EOL unverified> | `<manifest>:<line>` |
| Framework + version | <...> | `<lockfile>:<line>` |
| Package manager + lockfile | <tool; lockfile committed yes/no> | `<path>` |
| Datastore(s) | <...> | `<config path>:<line>` |
| Entry points | <n HTTP routes, n CLI commands, n workers, n schedules> | C<n> |
| Migrations | <count; newest date> | C<n> |
| Tests | <framework; n test files; n test cases> | C<n> |
| CI | <system; what it runs> | `<path>` |
| Deploy target | <host/platform; method> | `<path>:<line>` |
| Size | <n source files, n lines, vendored dirs excluded> | C<n> |
| History | <last commit date; n commits; n authors> | C<n> |

## Findings

Sev = Impact (1-3) x Likelihood (1-3), +1 if silent. Bands: high 6-10, medium 3-5, low 1-2.
Conf: high = traced end to end or observed live; med = read, not fully traced; low = inferred.
Recommend and Disposition use: constrain, fix-first, accept, investigate. Evidence: `path:line`, a dated GET, or C<n>.
Disposition stays `pending G-audit` until `audit-codebase record` copies the human's answer as `<word> (D<n>)`.

| ID | Area | Finding | Evidence | Sev (IxL+s) | Conf | Downstream | Recommend | Disposition |
|---|---|---|---|---|---|---|---|---|
| A1 | <area id> | <what is wrong, one sentence, no pipes> | `<path>:<line>` | 3x2+1=7 | <high> | <design-hld (invariant)> | <constrain> | pending G-audit |
| A2 | <area id> | <what is wrong> | GET <url> (<date>) → <status or header>; handler `<path>:<line>` if not a public page | 2x2=4 | <med> | <define-acceptance> | <accept> | pending G-audit |

## Finding details

<One block per finding with Sev 6 or more, or Conf low. Plain words: someone new to the codebase should
understand why it matters and be able to repeat the tradeoff in an interview.>

### A1 <short title>

- **What:** <one or two sentences>
- **Evidence:** `<path>:<line>`

  ```
  <at most 3 quoted lines; secrets and patient data as <redacted: kind>>
  ```

- **How it fails:** <trigger> → <effect> → <who notices, or "nobody: silent">
- **Why it matters for us:** <link to the brief's goal, or FR id if one exists>
- **Options:**
  - constrain: <the rule later phases must obey> · cost: <plain words>
  - fix-first: <the task before new work> · cost: <plain words>
  - accept (do nothing, recorded): revisit if <trigger> · cost: <plain words>
  - investigate: <the question to answer first> · cost: <plain words>
- **Recommendation:** <option>, because <reason>. **Default:** pending G-audit (nothing proceeds on silence).

## Coverage

| Area | Result | How checked |
|---|---|---|
| stack | <A<n>, ... or clean or N<n>> | <C<n> or path:line range read> |
| build-run | <...> | <...> |
| dependencies | <...> | <...> |
| architecture | <...> | <...> |
| data | <...> | <...> |
| auth | <...> | <...> |
| secrets-config | <...> | <...> |
| input-handling | <...> | <...> |
| integrations | <...> | <...> |
| sensitive-data | <...> | <...> |
| errors-observability | <...> | <...> |
| tests | <...> | <...> |
| ci-deploy | <...> | <...> |
| money-state | <...> | <...> |
| docs-drift | <...> | <...> |
| live-surface | <...> | <...> |

## Not audited

| ID | What | Why not | Risk of the gap | How to close it |
|---|---|---|---|---|
| N1 | <area id or path> | <no access, timebox, needs the code running> | <what could hide here> | <command, access needed, or follow-up skill> |

## Commands I would run

Not run on the host: they execute the target's code or fetch packages.

| Command | Purpose | Where to run it safely | Evidence it would give |
|---|---|---|---|
| `<command from the target's manifest, Makefile or README>` | <e.g. known-vulnerable packages> | <throwaway container or CI job with no real .env> | <confirms or withdraws A<n>; closes N<n>> |

## Questions

| ID | Question | Why it matters | Recommended answer | Blocks |
|---|---|---|---|---|
| Q1 | <question; cells elsewhere cite it as ⚠ Q1> | <what decision or finding depends on it> | <your recommendation and why> | <write-prd, A<n>, or nothing> |
