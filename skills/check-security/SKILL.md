---
name: check-security
description: Use when a milestone branch is at G5 prep and needs baseline security evidence for code this project wrote. Produces docs/security/CHECKLIST.md. Do NOT use for inherited code before the PRD (use audit-codebase), for gaps between code and approved specs (use verifier), or to fix a finding (the supervisor routes a fix-bug or implement-task fix).
disable-model-invocation: true
metadata:
  factory-kit: "0.1"
  phase: "11"
  gate: "G5"
---

# check-security

**Outcome:** `docs/security/CHECKLIST.md` (`status: draft`) shows, for milestone M<N> at one commit, every security
row as `pass`, `fail` or `n.a.` with evidence anyone can re-check, a secret scan and a dependency audit with their
exact commands, and every failure as a `SEC-<n>` finding whose disposition is left to the human inside G5.

## You own / You never touch

- You own `docs/security/CHECKLIST.md` fully (create it; rewrite it on every run, keeping ids); you never edit any
  other path: not app code, config, tests, lockfiles, CI, `.gitignore`, other docs or `.handoff/`. A failing row
  becomes a finding; the fix is a separate task the human approves.
- When dispatched with a job file (`.handoff/runs/<id>/task.md` or `specs/M<N>-<slug>/tasks/T###.md`), you also own
  the result file at its `## Return` path (`$HANDOFF_DIR/runs/<id>/result.md`, WORKFLOW.md §7 result contract,
  status `done | human_review`) and one commit of the checklist on your own task branch; you never write anything
  else under `.handoff/` and never commit on a shared branch. Attended, you change no git state (the supervisor
  commits).
- You may run read-only commands (`git grep`, `git log`, `git diff`, `git show`, `git ls-files`, `grep`, `find`,
  `sed -n`, `wc`), the scanners already on PATH (`gitleaks`, `composer audit`, `npm audit`, `pnpm audit`,
  `osv-scanner`) and the project's own `make check`; you never install, upgrade or download a tool or package
  (`brew`, `composer install|require|update`, `npm install`, `npx`, `pipx run`, `docker run <scanner image>`,
  `curl | bash`) and never run migrate, seed, serve or deploy commands.
- You may let a scanner fetch advisory data over the network; you never send requests to this app's deployments or
  its third-party APIs (the live TLS and header probe belongs to ship-milestone).
- You may record where a secret sits (`path:line`, scanner rule, kind of credential); you never write, echo or quote
  its value: scanners run with redaction on, grep output is cut to `path:line`.
- You recommend a disposition for each finding; you never set one. New findings stay `pending G5`; later
  dispositions are copied verbatim from `.handoff/TRACKER.md ## Approvals` and the decision journal.
- You check code this project wrote, at the milestone head; you never audit inherited code before the PRD (that is
  audit-codebase) or judge whether the code matches the specs (that is verifier).

## Inputs

Run `date` first and use its output for every time you write. Ask the human nothing while working: this skill runs
in parallel with verifier and report-milestone at G5 prep (WORKFLOW.md §6). An unknown becomes `⚠ <question>` in
its cell plus a `## Questions` row. Dispatched, every "stop" below means: write no checklist, write a `human_review`
result whose reason is the stop sentence, then STOP. Shells may not keep variables between calls: set `DEF`, `MB`,
`BASE` and `P` again in every command that uses them. A command your harness denies is `not run: denied by
<harness>`, the same as an absent tool. Read, in order:

1. `AGENTS.md`: stack, commands, rules, and the default branch its "Git" section names (`DEF`; none named:
   `git symbolic-ref --short refs/remotes/origin/HEAD` minus `origin/`). Missing → stop: "AGENTS.md is missing; run
   scripts/init-repo.sh first."
2. **The milestone.** Dispatched: take M<N> and the milestone branch `MB` from the job file's `milestone:` and
   `milestone_branch:`; its `Owns:` must be exactly `docs/security/CHECKLIST.md` and `git rev-parse HEAD` must equal
   `git rev-parse "$MB"` (your worktree starts at the milestone head); else stop and name which. Attended:
   `MB=$(git branch --show-current)` must match `milestone/m<N>-<slug>`; else stop: "check-security runs on the
   milestone branch; the current branch is <name>." Either way
   `git status --porcelain -- . ':!docs/milestones' ':!.handoff' ':!docs/security/CHECKLIST.md'` must print nothing,
   because `git grep` reads the working tree and the evidence must match the commit you name (the excluded paths
   are the parallel siblings' outputs and yours); else stop: "uncommitted changes at <paths>; commit or stash them,
   then re-run." Then `specs/M<N>-<slug>/` (tasks, acceptance).
3. The milestone diff, in full: `BASE=$(git merge-base "$DEF" "$MB")`, `git diff --stat "$BASE" "$MB"`, then
   `git diff "$BASE" "$MB"`. The stat is a map; the diff is the evidence. The milestone is **docs-only** when
   `git diff --name-only "$BASE" "$MB" | grep -vE '^(docs|specs|\.handoff)/|\.md$'` prints nothing (step 4).
4. `docs/architecture/hld.md` §5 Trust boundaries & threats (`TB-n`, `TH-n`) and §7 Invariants (`INV-n`). Missing
   → stop: "docs/architecture/hld.md is missing; check-security checks the boundaries design-hld defines." A
   docs-only milestone before the HLD exists continues; its trace says `none: no HLD yet (docs-only milestone)`.
5. `specs/M<N>-<slug>/change-plan.md`, its security field (brownfield only). Absent on greenfield is normal: write
   "no change plan (greenfield)".
6. Manifests and lockfiles:
   `git ls-files | grep -E '(^|/)(composer\.(json|lock)|package(-lock)?\.json|pnpm-lock\.yaml|yarn\.lock|go\.sum|Cargo\.lock|poetry\.lock|uv\.lock|Gemfile\.lock|requirements[^/]*\.txt)$'`.
7. `docs/decisions/DECISION_JOURNAL.md` and `.handoff/TRACKER.md ## Approvals` (dispatched:
   `$HANDOFF_DIR/TRACKER.md`): dispositions already decided. A G5 row's gate cell names its finding (`G5 SEC-3`).
8. `docs/audit/AUDIT.md` if present: findings whose Downstream is `check-security` join the trace.
9. `docs/security/CHECKLIST.md` if present: this is a re-run (step 10).
10. `references/rows.md` (this skill): what `pass` looks like per row. Load it at step 4.

## The one rule

Every row is `pass`, `fail` or `n.a.` with evidence a stranger can re-check (`path:line`, or a `CMD-<n>` and its
output); no evidence is a `fail`, never a `pass`, and every `fail` is a finding for the human, never a fix.

Why, in interview words: a checklist is worth exactly the evidence behind it. "The framework handles that" cannot
be re-checked by a reviewer; a `path:line` or a command and its output can. Keeping findings apart from fixes means
the person who decides which risk ships is the human who will own it, not the agent that found it.

## Steps

1. **Snapshot.** Record `git rev-parse "$MB"` (the head you check), `$BASE`, the empty Inputs-2 status and
   `git diff --name-only "$BASE" "$MB"`. Number every command whose output you cite as `CMD-<n>` under
   `## Commands run`.
2. **Map the attack surface from the design.** Every `TH-n` and `INV-n` in the HLD, the change plan's security
   field and AUDIT findings routed here get a `## Threat and invariant trace` row naming the CK row that checks it.
   A designed mitigation with no code behind it is a `fail`.
3. **Read the whole diff** and fill `## Diff coverage`: each changed path (or a directory entry ending in `/` that
   covers it) maps to the rows it touches, or to `none` with why.
4. **Walk CK-01 to CK-13** with `references/rows.md`: status, evidence, and a `SEC-<n>` for every `fail`. Prefer
   evidence in the changed code, then the app-wide control the change relies on plus proof the diff does not turn it
   off. `n.a.` needs evidence too: the command showing the surface does not exist. Add CK-14 to CK-16 only when the
   HLD or the diff has that surface. **Docs-only milestone:** every CK row is `n.a.` with the step-3 name-only CMD
   as evidence, except CK-07, which takes the secret-scan result; the LLM section is n.a. on the same CMD; the
   dependency audit is `not run: docs-only milestone`; say so in the Summary. The secret scan still runs.
5. **LLM section.** Look for a model call in code, not in factory docs:
   `git grep -nIiE 'openai|anthropic|bedrock|generativelanguage|vertexai|gemini|mistral|groq|ollama|openrouter|huggingface|api\.cohere|cohere-ai|replicate\.com|together\.(ai|xyz)|chat/completions|v1/messages|langchain|llamaindex' -- . ':!vendor' ':!node_modules' ':!docs' ':!specs' ':!.handoff' ':!*.md' | cut -d: -f1-2`,
   and check the HLD containers. A hit in a lockfile, manifest or env example counts (the app ships that client).
   Found → fill LLM-01 to LLM-10 from `references/rows.md`. None, or only hits you can show are not model calls →
   the section is the single n.a. line the template gives, naming those paths.
6. **Secret scan** (below). Triage every hit.
7. **Dependency audit** (below). One row per lockfile.
8. **Score every finding** with the rubric below; set Reachable and Recommend.
9. **Raise a P0 at once**: a hit triaged `secret`, an authentication bypass or IDOR, or exposed patient or customer
   data. Give the `SEC-<n>`, `path:line` and kind, never the value. Attended: print the one P0 line immediately,
   then keep working without waiting for an answer. Dispatched: put it first in the STOP and in the result. A secret
   in a pushed commit is already leaked (the remotes include a public mirror): deleting the line does not un-leak
   it, so the human rotates it (human-only) and a fix task removes it.
10. **Re-run rules.** Keep every `SEC-<n>`, `H<n>`, `N<n>` and `Q<n>` id; never renumber or delete. A finding whose
    row now passes → State `fixed @<sha> (CMD-<n>)`; a wrong one → `withdrawn <date>: <why>`. Copy dispositions
    and `## Accepted risks` verbatim from the journal and from Approvals rows whose gate cell names the finding
    (`G5 SEC-<n>`); a row naming no finding maps to none (keep `pending G5`, add a `Q<n>`). A `secret` hit the human
    confirms rotated in such a row, with no hit left at the head, → triage `revoked` (secret scan). An accepted
    risk whose "revisit if" has happened becomes a decision again.
11. **Write `## Not checked`** (what, why, risk of the gap, who closes it), then **`## Summary` last**, from the
    counts the Done-when block computes.
12. **Run the Done-when block** and fix the checklist until it prints `ALL CHECKS PASSED`.
13. **Dispatched only: commit, then write the result.** `git add docs/security/CHECKLIST.md`; commit
    `docs(security): check-security M<N>` with trailer `Task: <id>` on your task branch (never on `$MB`). Write the
    result at the job's `## Return` path from `specs/_templates/result.md` (missing: the §7 keys), never commit it:
    `base_sha` = the head you checked, `head_sha` = your commit, `changes: [docs/security/CHECKLIST.md]`, `tests` =
    the `make check` CMD or `not run: <why>`, `not_verified` = the `N<n>` ids. Status `human_review` for a stop or a
    P0 (reason = that line), else `done`. `## Questions`: the P0 line first, then every `Q<n>`, then the counts.
14. Run the dispatched Done-when items, then send the STOP message.

### Secret scan (step 6)

- **gitleaks on PATH (verified scan):** `gitleaks version`; if `gitleaks git --help` works use
  `gitleaks git --redact --no-banner -v .`, else `gitleaks detect --redact --no-banner -v` (v8.19 renamed it).
  Exit 1 means hits. `--redact` is never optional.
- **No gitleaks (grep heuristic, write "unverified"):** set (in the same call as each grep)
  `P='AKIA[0-9A-Z]{16}|(sk|rk)_(live|test)_[0-9A-Za-z]{10,}|whsec_[0-9A-Za-z]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY|xox[abprs]-[0-9A-Za-z-]{10,}|gh[pousr]_[0-9A-Za-z]{20,}|glpat-[0-9A-Za-z_-]{20,}|sk-(proj|ant|svcacct)-[0-9A-Za-z_-]{20,}|AIza[0-9A-Za-z_-]{35}|eyJ[0-9A-Za-z_-]{10,}\.[0-9A-Za-z_-]{10,}|(password|passwd|secret|api_?key|app_key|private_key|token)[a-z0-9_]*.{0,3}[:=]>?.{0,2}[0-9A-Za-z/+_=:-]{16,}'`, then run:
  - tree: `git grep -nIiE "$P" -- . ':!vendor' ':!node_modules' ':!*.lock' ':!package-lock.json' ':!*.min.js' | cut -d: -f1-2`
  - tracked env files: `git ls-files | grep -E '(^|/)\.env' | grep -vE '\.(example|sample|dist|template)$'`
  - history: `git log --all -E -i -G"$P" --format='%h %ad' --date=short --name-only -- . ':!vendor' ':!node_modules' ':!*.lock' ':!package-lock.json'`
    lists commits that added or removed a secret-like line, without values. For a listed file with no tree hit,
    find the line without printing the file: for `<rev>` = `<commit>` (it added the line) and `<commit>^` (it
    removed it), `git show <rev>:<path> 2>/dev/null | grep -niE "$P" | cut -d: -f1` prints line numbers only; read
    just that line (`git show <rev>:<path> | sed -n '<line>p'`) and triage it like any hit, Location
    `<path>:<line> @<rev>`.
- **Triage** each hit by reading the line without copying it:
  - `secret`: a live-looking credential (critical finding, State open). If you cannot tell, it is `secret`.
  - `revoked: rotated <date> per Approvals <time>`: only when an Approvals row (`G5 SEC-<n>`) holds the human's own
    words confirming rotation and the head has no hit for it (history only). Its finding becomes State
    `fixed @<head_sha> (revoked, Approvals <time>)` and no longer counts as a secret. Never call a rotated key a
    false positive. Afterwards a fix task (not you) may add its gitleaks fingerprint to `.gitleaksignore`.
  - `false positive: <reason>`: an `env()` lookup, a placeholder, a provider's published documentation value, a
    public key.
  Never install gitleaks to upgrade the scan; add an `N<n>` row instead.

### Dependency audit (step 7)

Per lockfile, the first tool on PATH: `composer audit --locked --no-plugins` (composer.lock);
`npm audit --package-lock-only`, then again with `--omit=dev` to tell dev-only from shipped (package-lock.json);
`pnpm audit` (pnpm-lock.yaml); otherwise `osv-scanner scan source -r .` (v2) or `osv-scanner -r .` (v1) for any
lockfile. These read the lockfile; never use a tool that installs or resolves packages to audit them (`pip-audit -r`
builds a virtualenv). No tool → `not run: <tool> not on PATH`, CK-12 `fail`, and a medium finding "dependency audit
not run" whose fix is the command in CI. A network error or timeout: record exit and error once, no retry loop; an
outbound firewall may be blocking the tool. Also a finding: a manifest without a committed lockfile, or a package
the diff adds with no `D<n>` (AGENTS.md "ask first").

### Severity and disposition (step 8)

| Severity | Plain meaning | Examples |
|---|---|---|
| critical | anyone on the internet can do it now, and it exposes a secret, patient or customer data, or money, or runs code; or a tool rates an advisory critical | a secret in the repo; IDOR on orders with no login; SQL injection; an unsigned webhook that ships orders |
| high | the same harm, but it needs a logged-in user or a specific condition; or a tool rates an advisory high | one patient reading another's orders; stored XSS; TLS verification off to the payment API |
| medium | weakens a defense or helps an attacker, no direct harm; any row failed for lack of evidence | no CSP; verbose errors; audit not run; no login rate limit |
| low | a hardening gap with no plausible path to harm | missing `Referrer-Policy`; an abandoned dev-only package |

Keep a tool's severity (moderate = medium) and never downgrade it; write reachability (`yes`, `no: dev-only`,
`unknown`) in its own column. Doubt goes into Reachable, never into Severity. Recommend one disposition, the same
ones the human picks from inside G5:

| Disposition | Plain meaning | Cost |
|---|---|---|
| `fix` | a fix task lands before this milestone merges (the supervisor routes it) | the merge waits; the risk never ships |
| `accept` | merge with the risk; log-decision records a `D<n>` with a "revisit if" trigger and any follow-up | cheapest now; the risk ships and you own it by name |
| `investigate` | too unsure to decide; a question or a spike first | time now; avoids deciding on a guess |

A finding triaged `secret` is never `accept`: rotation by the human plus a fix task, or `investigate` if triage is
unsure. Once the human confirms rotation in Approvals, the next run triages it `revoked`.

## Output

Write `docs/security/CHECKLIST.md` by filling this skill's `assets/template.md`. Every section is required, in
template order, with headings verbatim. Write an unknown as `⚠ <question>` with a `## Questions` row instead of
inventing. No `|` inside table cells: cite a command as `CMD-<n>` and keep the command itself in
`## Commands run`. Quote at most 3 lines of evidence, secrets and patient data as `<redacted: kind>`. Keep
`status: draft` and every new Disposition `pending G5`. Dispatched: also the result file (step 13).

## Done when

- [ ] This block, run in bash from the repo root in one call with its first line filled, prints
      `ALL CHECKS PASSED` (each failure prints a named `FAIL` line). Its counts are the Summary's and the STOP's.

```bash
S='<folder you read this SKILL.md from>'; DEF='<default branch>'; MB='<milestone branch>'
cd "$(git rev-parse --show-toplevel)" || exit 1; C=docs/security/CHECKLIST.md; f=0; fail() { echo "FAIL $*"; f=1; }
sha() { git rev-parse -q --verify "${1:-none}^{commit}" 2>/dev/null || echo "bad:$1"; }
[ -s "$S/assets/template.md" ] || fail "S: no assets/template.md under '$S'"
[ -s "$C" ] || { echo "FAIL MISSING $C"; exit 1; }
BASE=$(sed -n 's/^base_sha: *//p' "$C" | head -1); HEAD_SHA=$(sed -n 's/^head_sha: *//p' "$C" | head -1)
[ "$(sha "$BASE")" = "$(git merge-base "$DEF" "$MB" 2>/dev/null || echo no-merge-base)" ] || fail "base_sha is not merge-base $DEF $MB"
[ "$(sha "$HEAD_SHA")" = "$(sha "$MB")" ] || fail "head_sha is not the tip of $MB"
diff <(grep '^## ' "$S/assets/template.md") <(grep '^## ' "$C") >/dev/null || fail "headings differ from the template"
[ "$(grep -oE '^\| CK-(0[1-9]|1[0-3]) ' "$C" | sort -u | wc -l | tr -d ' ')" = 13 ] || fail "CK-01..CK-13 not all present"
d=$(grep -oE '^\| ((CK|LLM|SEC)-[0-9]+|[HNQ][0-9]+) ' "$C" | sort | uniq -d | tr -d '|\n'); [ -z "$d" ] || fail "duplicate ids:$d"
r=$(awk -F'|' '$2 ~ /^ *(CK|LLM)-[0-9]+ *$/ {s=$5; gsub(/ /,"",s); if (s!="pass" && s!="fail" && s!="n.a.") print "STATUS",$2; if ($6 !~ /:[0-9]+|CMD-[0-9]+/) print "EVIDENCE",$2; if (s=="fail" && $7 !~ /SEC-[0-9]+/) print "FINDING",$2}
  $2 ~ /^ *SEC-[0-9]+ *$/ {v=$4; gsub(/ /,"",v); if (v !~ /^(critical|high|medium|low)$/) print "SEV",$2; if ($6 !~ /:[0-9]+|CMD-[0-9]+/) print "EVIDENCE",$2; if ($9 !~ /pending G5|D[0-9]+|fix \(|investigate \(/) print "DISP",$2; if ($10 !~ /open|fixed @|withdrawn/) print "STATE",$2; if ($3 ~ /secret/ && $9 ~ /D[0-9]+/) print "SECRET-ACCEPTED",$2}' "$C"); [ -z "$r" ] || fail "rows:" $r
m=$(comm -23 <(grep -oE 'SEC-[0-9]+' "$C" | sort -u) <(grep -oE '^\| SEC-[0-9]+' "$C" | tr -d '| ' | sort -u)); [ -z "$m" ] || fail "cited but not in Findings:" $m
if [ -f docs/architecture/hld.md ]; then
  m=$(comm -23 <(grep -oE '^\| (TH|INV)-[0-9]+ ' docs/architecture/hld.md | tr -d '| ' | sort -u) <(awk -F'|' '/^## Threat and invariant trace/{c=1;next} /^## /{c=0} c {gsub(/ /,"",$2); print $2}' "$C" | sort -u)); [ -z "$m" ] || fail "untraced:" $m
else grep -q '^- \*\*Milestone kind:\*\* docs-only' "$C" || fail "no docs/architecture/hld.md on a code milestone"; fi
files=$(git diff --name-only "$BASE" "$HEAD_SHA") || fail "git diff base_sha head_sha failed"
m=$(printf '%s\n' "$files" | awk -v doc="$C" 'BEGIN{while((getline l < doc)>0){if(l ~ /^## Diff coverage/){c=1;continue} if(l ~ /^## /)c=0; if(c && l ~ /^\| `/){split(l,x,"|"); p=x[2]; gsub(/[ `]/,"",p); e[p]=1}}} NF {ok=0; for(p in e) if($0==p || (p ~ /\/$/ && index($0,p)==1)) ok=1; if(!ok) print $0}'); [ -z "$m" ] || fail "uncovered paths:" $m
[ "$(grep -cE '^- \*\*Scanner:\*\* (gitleaks .+ \(verified\)|grep heuristic \(unverified\))' "$C")" = 1 ] || fail "Scanner line missing or not labelled"
m=$(grep -nE 'AKIA[0-9A-Z]{16}|(sk|rk)_(live|test)_[0-9A-Za-z]{10,}|whsec_[0-9A-Za-z]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY|xox[abprs]-[0-9A-Za-z-]{10,}|gh[pousr]_[0-9A-Za-z]{20,}|glpat-[0-9A-Za-z_-]{20,}|sk-(proj|ant|svcacct)-[0-9A-Za-z_-]{20,}|AIza[0-9A-Za-z_-]{35}|eyJ[0-9A-Za-z_-]{10,}\.' "$C" | cut -d: -f1 | tr '\n' ' '); [ -z "$m" ] || fail "secret-like value on line(s) $m"
read -r p x a cr hi me lo s u <<<"$(awk -F'|' '$2 ~ /^ *(CK|LLM)-[0-9]+ *$/ {s=$5; gsub(/ /,"",s); r[s]++} $2 ~ /^ *SEC-[0-9]+ *$/ && $10 ~ /open/ {v=$4; gsub(/ /,"",v); n[v]++; if ($3 ~ /secret/) k++; if ((v=="critical" || v=="high") && $9 !~ /D[0-9]+/) u++} END{print r["pass"]+0, r["fail"]+0, r["n.a."]+0, n["critical"]+0, n["high"]+0, n["medium"]+0, n["low"]+0, k+0, u+0}' "$C")"
[ "$s" = 0 ] && [ "$u" = 0 ] && g=met || g="not met"
echo "counts: pass=$p fail=$x na=$a critical=$cr high=$hi medium=$me low=$lo open_secrets=$s unaccepted_high_critical=$u condition=$g"
grep -qxF -- "- **G5 security condition:** $g: secrets $s, unaccepted high/critical $u" "$C" || fail "Summary condition line != the counts"
grep -qxF -- "- **Rows:** $p pass · $x fail · $a n.a. (of $((p + x + a)))" "$C" || fail "Summary Rows line != the counts"
grep -qxF -- "- **Open findings:** $cr critical · $hi high · $me medium · $lo low" "$C" || fail "Summary Open findings line != the counts"
m=$(git status --porcelain -- . ':!docs/milestones' ':!.handoff' ':!docs/security/CHECKLIST.md'); [ -z "$m" ] || fail "changed outside your path:" $m
[ "$f" = 0 ] && echo "ALL CHECKS PASSED"
```

- [ ] Dispatched, after step 13: `git status --porcelain` prints nothing; `git diff --name-only <checked head> HEAD`
      prints only `docs/security/CHECKLIST.md`; `grep -cE '^(task|status): ' <Return path>` prints `2`.
- [ ] You installed, downloaded and deployed nothing this session (check your own command list, not your memory).

## STOP

Send exactly this message, every `<...>` filled, then stop. Do not start report-milestone. One decision per reply
(WORKFLOW.md §5), in this order: each `secret`, then each critical, then each high, then every medium and low
finding as one block on their recommended dispositions. Offer `investigate` when Reachable is `unknown`. With no
findings, Decision 1 is approving this checklist as G5's security evidence.

> <P0 line first if step 9 found one: "P0: SEC-<n> <kind> at `<path>:<line>`; rotate it now (human-only).">
> Wrote `docs/security/CHECKLIST.md` for M<N> @ `<head_sha>` (diff from `<base_sha>`, <f> files<, docs-only>):
> <p> pass, <x> fail, <a> n.a.; LLM section <filled | n.a.>.
> Secret scan: <gitleaks <version> (verified) | grep heuristic (unverified)>, <s> open secrets. Dependency audit:
> <tools | not run>, <d> advisories. Open findings: <c> critical, <h> high, <m> medium, <l> low; unaccepted
> high/critical: <u>. Result: <done | human_review: <stop reason or P0>><; dispatched: commit <sha> on <branch>,
> result at <Return path>>.
> Words: an *advisory* is a published warning that a package version has a known vulnerability; *reachable* means
> an attacker could actually get to that code in the deployed app; *ASVS Level 1* is OWASP's baseline checklist
> for any internet-facing app.
>
> **Gate G5 (security part): "Zero unaccepted high/critical; accept listed risks?"**
> In plain words: the milestone cannot merge while a secret sits in the repo, or while any high or critical finding
> has neither a merged fix nor your recorded acceptance.
>
> **Decision 1 of <k>: SEC-<n> <short title>** (<severity>, reachable <yes | no: <why> | unknown>)
> Background: <one plain sentence: what an attacker could do, to whom, and the evidence>
> - fix: <the fix task in one line> · cost: <plain words>
> - accept (do nothing now, recorded as a D-id): revisit if <trigger> · cost: <plain words>
> - investigate: <the question to answer first> · cost: <plain words>
>
> Recommendation: <option>, because <reason>. Default if you don't answer: it stays `pending G5` and the
> milestone does not merge.
>
> Reply **Approve** (take my recommendation), **Revise** (pick another option, or name what to check deeper), or
> **Stop**. For a secret, say in your reply when you have rotated it ("Approve, rotated <date>"): that sentence is
> what lets the next run mark it revoked.
>
> Supervisor: commit `docs/security/CHECKLIST.md` (dispatched: squash this run's commit) before recording any
> answer, because approvals bind to its sha. Present decisions 2 to <k> one per reply in the order above, same
> format, wording from `## Findings`. Record each answer in Approvals with gate cell `G5 SEC-<n>`, and run
> log-decision for each accept. After the fix tasks land, re-run check-security (it marks fixes and copies the
> answers); then the next skill is **report-milestone**.

## Red flags

| Thought you might have | What to do instead |
|---|---|
| "It's one missing middleware; I'll add it while I'm here." | Never edit code. It is a `SEC-<n>` with Recommend `fix`; the fix is a task the human approves. |
| "The framework does CSRF and escaping by default" or "nothing looked wrong here", so pass. | Looking is not evidence. Cite the `path:line` where the default is on and a `CMD-<n>` showing the diff adds no opt-out (exempt routes, `{!! !!}`, `v-html`); otherwise `fail` with a finding naming what is missing. |
| "gitleaks isn't installed; `npx` or `docker run` will get it." | That is an install. Run the heuristic, write "unverified", add an `N<n>` row naming the command for the human or CI. |
| "I'll quote the key so the human believes it's real." | `path:line`, rule and kind only; raise the P0 now; rotation is the human's job. |
| "The advisory is high but it's a dev dependency; call it low." | Keep the tool's severity; write `no: dev-only` in Reachable; the human decides. |
| "It was rotated, so call it a false positive." | Use `revoked` with the Approvals row that holds the human's words; never false positive. |
