---
task: M{{N}}-T{{###}}
harness: {{claude | codex, the one delegate.sh ran you on; cursor/antigravity are v2, WORKFLOW §6}}
model: {{model id your harness reports, or unknown; never a guess}}
status: {{done | human_review | relaunch}}
reason: "{{one line: why this status, e.g. Done-when and make check green; or stuck on <error> after 2 corrections}}"
base_sha: {{fresh run: HEAD before your first edit; resumed run: parent of this task's first commit (SKILL.md step 2)}}
head_sha: {{HEAD at the end of the run; equals base_sha when nothing was ever committed}}
changes: [{{path}}, {{path}}]
tests: "{{fresh Done-when or make check command}} -> {{exit code}} ({{counts copied from the output, e.g. 42 passed, 0 failed}})"
not_verified: [{{what no command in this run proves, e.g. layout in a real browser}}]
---

<!-- guide: Superset of specs/_templates/result.md (same frontmatter keys, same three ## sections). Replace every
     {{…}} and delete every guide comment. One key per frontmatter line: scripts/delegate.sh parses `task` and
     `status`, and marks the run invalid if `task` is not this task's id or `status` is not one of the three. -->

# M{{N}}-T{{###}} {{the commit summary, also used after `feat(m<N>/t###): `}}

## Changes

<!-- guide: One bullet per changed path. Every path is inside the task's Owns line. Say what changed in plain words
     and which approved artifact section it was ported from, so the human can defend it in an interview. -->

- `{{path}}`: {{what changed, plain words}}. Ported from `{{artifact path}}#{{section}}` (covers {{FR-### / AE-###}}).
- `{{test path}}`: {{which behaviours and edge cases the unit tests pin down}}.
- Commits on `{{branch}}`: `{{short sha}} feat(m{{N}}/t{{###}}): {{summary}}` (trailer `Task: M{{N}}-T{{###}}`), or
  "none: {{why nothing was committed}}".
- Resumed: {{fresh run | the commits and Owns-only uncommitted paths kept from the earlier attempt}}.
- Uncommitted: {{none | the `git status --porcelain` lines left in the worktree (human_review / relaunch only)}}.

## Tests run

<!-- guide: Every command, in the order run: the command, its exit code, and the last ~40 lines of real output
     (keep the summary and counts; write "[... trimmed ...]" where you cut). Never retype or paraphrase output.
     Redact any secret or personal data. Delete no heading: write "not run: <why>" under one you could not reach.
     A command the harness denied is "not run: harness blocked", with the denial under Questions. -->

### 1. Baseline: `make check` (fresh run: on base_sha · resumed run: starting state)

```
$ make check
{{pasted output}}
exit {{code}}
```

### 2. Done-when before any change (fresh run: must fail · resumed run: starting state, may pass)

```
$ {{Done-when command, verbatim from the task file}}
{{pasted output: on a fresh run it fails for the reason the task exists}}
exit {{code}}
```

### 3. Red: new unit tests before the code

```
$ {{narrow test command from AGENTS.md, filtered to your test file}}
{{pasted output: fails because the behaviour is missing, not because the test is broken}}
exit {{non-zero code}}
```

### 4. Green: unit tests

```
$ {{same command as 3}}
{{pasted output}}
exit 0
```

### 5. Green: Done-when, first pass

```
$ {{Done-when command}}
{{pasted output}}
exit 0
```

### 6. Fresh proof after the last change (and after any `git restore`)

```
$ {{Done-when command, verbatim; slice-tasks ends it in && make check}}
{{pasted output}}
exit {{code}}
```

Separate `make check`: {{not needed, the Done-when runs it | its pasted run, in a block like the one above}}.
New failures versus section 1: {{none | list}}.

### 7. Scope guard, staged, before the commit

```
$ git add -- {{explicit Owns paths}}
$ bash scripts/scope-guard.sh {{task file}}
{{pasted output}}
exit {{code}}
```

### 8. After commit

```
$ git status --porcelain -- . ':!.handoff'
{{empty, or the lines and why}}
$ git rev-parse HEAD
{{head_sha}}
```

## Questions

<!-- guide: Unattended runs never ask in chat: every question lives here. Keep only the row kinds that apply (repeat
     a kind as Q2, Q3 …); write "- none" when there are none. Rows starting with ⚠ block `done`; they use the gate
     shape so the human can decide in one read. -->

- ⚠ **Q1** {{question}}? Why it matters: {{plain words}}. Options: A {{option}} (cost: {{…}}); B {{option}}
  (cost: {{…}}); do nothing (cost: {{…}}). Recommend: {{A}}, because {{plain words}}. Default if unanswered: {{…}}.
- ⚠ **Owns gap** the task also needs `{{path}}` because {{reason}}. Widen Owns (slice-tasks), or move it to another task?
- ⚠ **Harness blocked** `{{exact command}}` was denied: `{{pasted denial}}`. Next: route-failure widens the allow-list
  or sandbox; nothing above claims this command's result.
- **Answered** {{question id}} from answers.md ({{time, approver}}): {{what you did with it}}.
- **Assumed** {{a local, non-contract choice you made without asking, and the option you passed over}}. Confirm?
- **Manifest gap** read `{{path}}` (not on the give: line) to find `{{symbol}}`. Add it to the manifest?
