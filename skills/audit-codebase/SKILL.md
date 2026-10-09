---
name: audit-codebase
description: Use when the project inherits existing code or a deployed app (brownfield, including a rebuild that must learn from an old version) and you need to know what risk comes with it, before write-prd; also as `audit-codebase record` after each G-audit answer. Produces docs/audit/AUDIT.md. Do NOT use for code this project wrote (use verifier or check-security) or for open research questions (use gather-evidence).
disable-model-invocation: true
metadata:
  factory-kit: "0.1"
  phase: "2b"
  gate: "G-audit"
---

# audit-codebase

**Outcome:** `docs/audit/AUDIT.md` lists every inherited risk as a scored finding the human can open and check, and
says plainly what was not audited. Draft mode leaves it `status: draft` with new findings `pending G-audit`; record
mode (`audit-codebase record`) copies the human's recorded G-audit answers into it and sets `status: approved`.

## You own / You never touch

- You own `docs/audit/AUDIT.md` fully in draft mode (create it; rewrite it on a re-run) and only its Disposition
  cells and `status:` line in record mode; you never edit any other file: not the target's code, config, lockfiles,
  tests or git state, and not this project's PRD, designs, journal or `.handoff/`. Your one scratch file is the
  step-1 marker in `${TMPDIR:-/tmp}`.
- You may run read-only commands against the target (`ls`, `find`, `grep`, `wc`, `cat`, `sed -n`, `git log`,
  `git blame`, `git ls-files`, `git show`, `git rev-parse`, `git status`), running git as
  `GIT_OPTIONAL_LOCKS=0 git -c core.fsmonitor=false -C <target> ...` and adding `--no-ext-diff --no-textconv` to
  anything that prints a diff, so reading never rewrites `.git/index` or runs a program from the target's git
  config. You never run its install, build, test, migrate, seed, serve or project scripts on the host (`composer`,
  `npm`, `pip`, `artisan`, `make`, `docker compose up`, `./scripts/*`); you write them under
  `## Commands I would run` instead.
- You may learn a credential file's key names, line numbers and value lengths; you never put a value into your own
  context: no `cat`, `head`, `sed -n`, `git show`, `git log -p`, `git diff`, or `grep` without `-o`, `-l` or `-c`,
  on `.env*`, `*.pem`, `*.key`, `*.p12`, `credentials*`, `auth.json` or any file a probe flags, at any commit. Use
  `git ls-files <file>` to say whether it is committed, and only the probes in `references/areas.md`
  (secrets-config), which read such files straight into a program that prints names and lengths. A value in your
  context has already leaked: transcripts are stored, and on Codex the employer's admin console can read them.
- You may record where a secret or a patient/customer record sits (`file:line` plus its kind); you never copy its
  value into the doc, `.handoff/`, a commit or chat.
- You may send plain `GET` requests, TLS verification on, to a deployed URL the human cleared at Q-c: public pages,
  and admin or debug paths whose handler you have read and found free of side effects (no write, queue dispatch,
  outbound call or command run). You never request a path you have not cleared, log in, submit forms, send
  `POST`/`PUT`/`DELETE`, run scanners or fuzzers, or generate load.
- You recommend a disposition for each finding; you never choose one. Only record mode writes one, copied from an
  accepted journal entry.
- You audit code the project inherited; you never audit code written in this project, including a greenfield
  rebuild you just wrote (that is `verifier` or `check-security`).

## Inputs

Run `date` first and use its output for every time you write. Called as `audit-codebase record`: read inputs 6 and
7, then follow **Record mode** only. Otherwise read, in order:

1. `AGENTS.md`: this project's rules and commands. Missing → stop: "AGENTS.md is missing; run
   `scripts/init-repo.sh` first."
2. The brief: the path the human passes, else `ls specs/*/brief.md` (exactly one → use it; several → ask which,
   as your first question). None → stop: "No brief; `sharpen-brief` runs first." Read what we inherit, why,
   appetite, scope.
3. The target: a local path (a clone, or this repo itself) and/or a deployed URL, as the brief names them. Not
   named → ask Q-a; never guess. Named only as a remote repository → ask the human to clone it to a path outside
   this repo and name that path; never clone or fetch it yourself (a write outside your output).
4. The target's front door, read and never executed: README, its own AGENTS.md/CLAUDE.md, manifests, lockfiles,
   CI config, Dockerfiles, route definitions, the migrations directory, and `.env.example` through the length-only
   probe (example files often hold real values by mistake).
5. `docs/research/R*.md` if present: context, and with the target's own docs the only source for an end-of-life
   date.
6. `docs/audit/AUDIT.md` if present: in draft mode this is a re-run. Keep every `A<n>`, `N<n>`, `Q<n>` id; never
   renumber or delete; mark a dropped finding `[withdrawn <date>: why]` at the start of its Finding cell. A row
   already `<word> (D<n>)` keeps that Disposition only if the rest of the row is unchanged; a changed or new row gets
   `pending G-audit`, and `status:` goes back to `draft`. `C<n>` command ids are local to each run.
7. `docs/decisions/DECISION_JOURNAL.md`: record mode only.
8. `references/areas.md` (this skill): the audit areas. Load it at step 5.

## The one rule

Change nothing and run nothing of the target's: every finding is evidence the human can open (`file:line`, a dated
`GET`, or a listed read-only command), scored by the rubric, with the decision left to the human.

Why, in interview words: installing or testing inherited code runs code you have not read yet (package install
hooks, a committed `.env` pointing at a real database or API). An audit that can cause the incident it is looking
for is not an audit.

## Steps

1. **Snapshot the target.** Run `GIT_OPTIONAL_LOCKS=0 git -c core.fsmonitor=false -C <target> rev-parse HEAD`
   (not a git repo → `target_sha: not a git repo`), then `touch "${TMPDIR:-/tmp}/audit-codebase.start"`. Done when
   compares both; the marker catches any file created, changed or deleted after this point, even one already dirty.
2. **Inventory before asking.** Fill `## Inventory` from manifests, lockfiles, CI and deploy files: versions,
   lockfile, datastore, entry points, tests, CI, deploy target, size, history. List every command you run as
   `C<n>: <command>` under `## Scope and method` (pipes are fine there); table cells cite `C<n>`. Every count comes
   from a `C<n>`. Exclude `vendor`, `node_modules`, `.git`, `dist`, `build`, `storage` from searches (areas.md lists
   tracked files there separately). End-of-life only with a cited source (the target's docs or `docs/research/R*`);
   otherwise `⚠ Q<n> EOL unverified`, whose Questions row recommends a `gather-evidence` follow-up.
3. **Interview only what the brief and repo did not answer.** One question per message, each with your
   recommended answer and the reason, at most 5 per pass:
   - **Q-a Target:** "Where is the code, and which URL is live? Recommended: <paths and URL from the brief>."
   - **Q-b Mode:** "Are we changing this code in place, or rebuilding and using it as reference? Recommended:
     <from the brief>." Teach the difference: in place, findings shape the change plan `design-lld` writes; rebuild,
     findings become constraints, a don't-repeat list, and the data and contracts the new build must preserve.
   - **Q-c Live safety:** "Does <URL> serve real patient or customer data, and may I send GET requests to public
     pages only? Recommended: GET-only on public pages, no login; skip the URL if you are unsure."
   - **Q-d Depth:** "Which areas will the first milestone touch? Recommended: <areas from the brief> deep, the rest
     shallow, every gap listed under Not audited."
   - **Q-e Timebox:** "How long should I spend before writing up? Recommended: 90 minutes of agent time; whatever
     is not reached goes under Not audited."
4. **Trace 1-3 critical paths end to end.** Pick where failure costs most (money, auth, patient data, the
   integration the product depends on) and follow each from entry point to datastore and back, reading every hop.
   One traced path beats twenty skimmed files, and it is where silent failures hide.
5. **Walk every area in `references/areas.md`.** For each area write findings, or a Coverage row `clean` with
   how you checked, or an `N<n>` Not audited row with why. A grep hit is a place to read, not a finding.
6. **Probe the live URL** only if Q-c cleared it: GETs with TLS verification on (never `-k`): status, TLS,
   security headers, `/health`, `/version` against `target_sha`, error-page leakage, `robots.txt`. An admin or
   debug path only after reading its handler (cite its `file:line` next to the GET); one you have not cleared goes
   under Commands I would run. Evidence: `GET <url> (<date>) → <status or header>`.
7. **Score every finding** with the rubric below; set Confidence, Downstream and Recommend. Write a
   `## Finding details` block for every finding with Sev 6 or more, or Confidence low.
8. **Interrupt for a P0 now, not at the gate:** a live credential, exposed patient/customer data, or an auth bypass
   reachable from the live URL. Tell the human the `A<n>`, its location and its kind (never the value), then go on.
9. **Write down what you did not do:** `## Not audited` (`N<n>`: what, why, risk of the gap, how to close it),
   `## Commands I would run` (command, purpose, a safe place such as a throwaway container or CI job, the evidence
   it would give), `## Questions` (`Q<n>`, each with a recommended answer and what it blocks).
10. **Write `## Summary` last**, from the finished table, using the band-count command in Done when.
11. Run every Done-when check, fix what fails, then send the STOP message.

### Scoring rubric (step 7)

| Score | Impact | Likelihood |
|---|---|---|
| 1 | slows work or is cosmetic | needs unusual conditions or inside access |
| 2 | a feature is wrong or down but recoverable; security weakened | happens under plausible conditions (edge input, load, a specific deploy) |
| 3 | data loss; patient/customer data or a secret exposed; money wrong; auth bypass; outage | on the normal path, or already happening (seen live or in history) |

- **Sev** = Impact x Likelihood, **+1 if silent** (it fails with no error, log, alert or failing test). Write the
  arithmetic in ASCII: `3x2+1=7`, `2x2=4`. Bands: **high 6-10**, medium 3-5, low 1-2.
- **Confidence:** high = traced end to end or observed live; med = read the code but not every caller or config;
  low = inferred from names, docs or patterns. Doubt goes into Confidence, never into Sev.
- **Downstream** (the phase or decision it constrains): `write-prd` (Constraints, Non-goals), `design-hld`
  (invariant, trust boundary), `design-lld` (change plan, data model), `define-acceptance` (a check),
  `slice-tasks` (a fix-first task), `check-security`, `ship-milestone`, an existing `D<n>`, or `none`.
- **Recommend** one disposition, the same four the human picks from at the gate:

| Disposition | Plain meaning | Cost |
|---|---|---|
| `constrain` | becomes a rule later phases must obey (PRD constraint, HLD invariant, acceptance check) | narrows design options; adds checks to write |
| `fix-first` | a task that lands before any new feature | delays visible progress; stops the risk compounding under new code |
| `accept` | do nothing, but recorded with a "revisit if" trigger | the risk stays; cheapest today |
| `investigate` | too unsure to decide; becomes a question or a spike | time now; avoids deciding on a guess |

### Record mode (`audit-codebase record`, after each G-audit answer is in the journal)

R1. `git diff --quiet -- docs/audit/AUDIT.md` must exit 0 (else stop: "AUDIT.md changed after it was committed;
    the supervisor commits it and G-audit restarts on the new sha"). The draft sha is
    `git log -1 --format=%h -- docs/audit/AUDIT.md`.
R2. Read every G-audit entry: `grep -nE '^### D[0-9]+|G-audit (A[0-9]+|block|as-is)' docs/decisions/DECISION_JOURNAL.md`,
    then each hit's whole entry. A pending finding is decided by the newest entry that is `[status: accepted]`,
    whose Decided-by gate cell names it (`G-audit A3`, or a `G-audit block` list containing A3), and whose
    `artifact@docs/audit/AUDIT.md@<sha>` is the draft sha. Its disposition is that entry's Choice; in a block, each
    finding's Recommend unless the Choice names another for that id. A row already `<word> (D<n>)` stays decided
    while D<n> is still accepted. Anything else is still pending.
R3. Any finding still pending, or none was pending and no accepted `G-audit as-is` entry cites the draft sha →
    write nothing; send the next card in the queue (a `rejected` one again, quoting the human's reason).
R4. All decided → set each pending Disposition cell to `<constrain|fix-first|accept|investigate> (D<n>)` and
    `status: approved`, nothing else; run the record-mode checks in Done when; send the closed message.

## Output

Write `docs/audit/AUDIT.md` by filling this skill's `assets/template.md`. Every section is required, in template
order, with headings verbatim. Write an unknown as `⚠ Q<n> <question>` with a matching `## Questions` row instead
of inventing. No `|` inside table cells: commands live in the `C<n>` list and cells cite the id. Angle brackets
appear only inside fenced quote blocks and as `<redacted: kind>`. Quote at most 3 lines per piece of evidence,
with secrets and patient data as `<redacted: kind>`. Draft mode keeps `status: draft` and every new Disposition
`pending G-audit`.

## Done when

`<this-skill>` = the directory this SKILL.md was loaded from; `A=docs/audit/AUDIT.md`. Each check prints nothing.

- [ ] Headings match: `diff <(grep '^## ' <this-skill>/assets/template.md) <(grep '^## ' $A)`.
- [ ] Ids unique: `grep -oE '^\| [ANQ][0-9]+ ' $A | sort | uniq -d`.
- [ ] Every finding has openable evidence: `awk -F'|' '$2 ~ /^ *A[0-9]+ *$/ && $5 !~ /:[0-9]+|GET |C[0-9]+/' $A`.
- [ ] Sev arithmetic is valid (no `BAD` line) and the Summary counts equal the last line:
      `awk -F'|' '$2 ~ /^ *A[0-9]+ *$/ {s=$6; gsub(/ /,"",s); k=split(s,p,/[x+=]/); if (p[1]<1||p[1]>3||p[2]<1||p[2]>3||p[k]!=p[1]*p[2]+(k==4)) print "BAD",$2,s; n=p[k]+0; if(n>=6)h++; else if(n>=3)m++; else l++} END{printf "high=%d medium=%d low=%d\n",h,m,l}' $A`
- [ ] No disposition chosen by you: `awk -F'|' '$2 ~ /^ *A[0-9]+ *$/ && $10 !~ /pending G-audit|\(D[0-9]+\)/' $A`.
- [ ] Every area has a Coverage row:
      `diff <(grep '^## ' <this-skill>/references/areas.md | sed 's/^## //') <(awk -F'|' '/^## Coverage/{c=1;next} /^## /{c=0} c && $2 ~ /^ [a-z-]+ $/ {gsub(/ /,"",$2); print $2}' $A)`.
- [ ] No template placeholder left:
      `awk '/^ *```/{f=!f; next} !f {l=$0; gsub(/<redacted: [^>]*>/,"",l); if (l ~ /<[^>]+>/) print NR": "$0}' $A`.
- [ ] Every high or low-confidence finding has a details block:
      `comm -23 <(awk -F'|' '$2 ~ /^ *A[0-9]+ *$/ && $4 !~ /^ *\[withdrawn/ {id=$2; c=$7; gsub(/ /,"",id); gsub(/ /,"",c); k=split($6,p,"="); if (p[k]+0>=6 || c=="low") print id}' $A | sort) <(grep -oE '^### A[0-9]+' $A | cut -c5- | sort)`.
- [ ] Every `⚠` cites a Question, and every cited `N<n>`/`Q<n>` has its row:
      `awk '/^## /{q=($0 ~ /^## Questions/)} !q && /⚠/ && !/⚠ Q[0-9]+/ {print NR}' $A` and
      `for id in $(grep -oE '(^|[^A-Za-z0-9])[NQ][0-9]+' $A | grep -oE '[NQ][0-9]+' | sort -u); do grep -qE "^\| $id \|" $A || echo "no row $id"; done`.
- [ ] No secret values (line numbers only, so the check cannot leak what it finds):
      `grep -nE 'AKIA[0-9A-Z]{16}|sk_(live|test)_|-----BEGIN [A-Z ]*PRIVATE KEY|xox[abprs]-|gh[pousr]_[A-Za-z0-9]{20,}|eyJ[A-Za-z0-9_-]{10,}\.' $A | cut -d: -f1`.
- [ ] Nothing changed in the target: the step-1 `rev-parse HEAD` repeats, and
      `find <target> -newer "${TMPDIR:-/tmp}/audit-codebase.start" -not -path '*/.git/*'` (when the target is this
      repo, only `docs/audit` paths and their parent directories may appear).
- [ ] You ran no install, build, test, migrate, seed or serve command of the target, and no GET to an uncleared
      path (check your own command list, not your memory of it).

Record mode, after R4 (each prints nothing):

- [ ] Only Disposition cells and `status:` changed:
      `T='$2 ~ /^ *A[0-9]+ *$/ {$10=" "} /^status: /{$0="status:"} 1'; diff <(git show HEAD:$A | awk -F'|' -v OFS='|' "$T") <(awk -F'|' -v OFS='|' "$T" $A)`.
- [ ] Every live finding names an accepted journal entry that names it:
      `awk -F'|' '$2 ~ /^ *A[0-9]+ *$/ && $4 !~ /^ *\[withdrawn/ {a=$2; gsub(/ /,"",a); if ($10 ~ /^ *(constrain|fix-first|accept|investigate) \(D[0-9]+\) *$/) {match($10,/D[0-9]+/); print a, substr($10,RSTART,RLENGTH)} else print a, "none"}' $A | while read a d; do grep -A1 "^### $d " docs/decisions/DECISION_JOURNAL.md | tr '\n' ' ' | grep -qE "status: accepted.*G-audit[^\"]*[ ,]${a}[ ,]" || echo "not recorded: $a $d"; done`.

## STOP

Build the **decision queue** (WORKFLOW.md §5, one decision per reply) from rows still `pending G-audit`, withdrawn
rows excluded: high findings one card each, highest Sev first (ties: lower id), then every medium and low finding in
one block card. No pending rows in a draft → the single as-is card. Each card's bold title after `Decision <k>:` is
its gate id: the supervisor writes it verbatim as the gate cell of the `.handoff/TRACKER.md ## Approvals` row, so
log-decision records one `D<n>` per card and record mode can join on it. Fill every `<...>`, send, then stop. Never
start `write-prd`.

**Draft mode, and record mode R3**, send:

> <Draft: Wrote `docs/audit/AUDIT.md`: target `<path or URL>` @ `<sha>`, mode `<change-in-place or rebuild-reference>`.
> <n> findings (<h> high, <m> medium, <l> low), <k> areas not audited, <q> open questions.>
> <Record R3: Recorded so far: <A<n> → <word> (D<n>), ... or none>.> Queue: <every card title still open>.
>
> **Gate G-audit: "Which findings constrain the build, which do I accept?"**
>
> <the first open card, exactly one of the three below>
>
> Reply **Approve** (take my recommendation), **Revise** (name a different option, or what to audit deeper), or
> **Stop**. After the supervisor records your answer and log-decision logs it, the next skill is
> **`audit-codebase record`**: it shows the next card, or writes every disposition into AUDIT.md and names write-prd.

High-finding card (add the `investigate` line only when confidence is low):

> **Decision <k>: G-audit A<n>** <short title> (Sev <IxL+s>, confidence <c>)
> How to read it: Sev <n> = impact <I> (<what breaks>) x likelihood <L> (<how often>)<, +1 because nothing would
> alert us>; 6-10 is high. Confidence <c> means <high: I traced it end to end or saw it live | med: I read the code
> but not every caller or config, so the real reach may be smaller or larger | low: I inferred it from names or
> docs; it may not be real>.
> Background: <one plain sentence: what breaks, for whom, and how we know (`file:line`)>
> - constrain: <the rule it becomes, in which phase> · cost: <plain words>
> - fix-first: <the task> · cost: <plain words>
> - accept (do nothing, recorded): revisit if <trigger> · cost: <plain words>
> - investigate: <the question to answer first> · cost: <plain words>
>
> Recommendation: <option>, because <reason>. Default if you don't answer: it stays `pending G-audit` and
> write-prd does not start.

Block card (all medium and low findings):

> **Decision <k>: G-audit block A<x>,A<y>,A<z>** (medium and low findings, on their recommended dispositions)
> - A<x> <short title> (Sev <n>, confidence <c>): <recommend>, <the rule, task or revisit trigger in a few words>
> - <one line per finding in the block>
>
> Options: approve all as listed · change some (`Revise: A<y> fix-first`) · accept all (do nothing, recorded;
> cost: no later phase guards against these risks). Recommendation: approve as listed, because <reason>.
> Default: all stay `pending G-audit`.

As-is card (a draft with no findings):

> **Decision 1: G-audit as-is** (no findings in what I covered)
> Background: I covered <area ids>; not audited: <N<n> list>; the gap most likely to hide a high finding is <N<n>>.
> - accept as-is (do nothing): write-prd starts with no inherited constraints · cost: those gaps stay unknown
> - audit deeper: close <N<n>> by <how> · cost: <time>
>
> Recommendation: <option>, because <reason>. Default: `status: draft`, write-prd does not start.

**Record mode R4**, send:

> Updated `docs/audit/AUDIT.md` (<date>): `status: approved`; dispositions copied from the journal: <A<n> <word>
> (D<n>), ...>. G-audit is closed: every finding has your recorded answer.
> Check the Disposition column. **Approve** (the supervisor commits it), **Revise** (name the A<n>; a changed mind
> goes through log-decision as a superseding entry first), or **Stop**.
> Next: run **`write-prd`** and pass it `docs/audit/AUDIT.md` (in rebuild-reference mode too: its constrain
> findings feed Constraints and Non-goals). I am not starting it.

## Red flags

| Thought you might have | What to do instead |
|---|---|
| "I'll run the install or test suite, or hit that debug route, just to confirm." | Both run the target's code. Add it to `## Commands I would run` with a safe place; GET only a path whose handler you read and cleared. |
| "It's a two-line fix; I'll patch it while I'm here." | Never edit the target. It is a finding with Recommend `fix-first`. |
| "I've read enough to see this area is fine." | Write the Coverage row with how you checked, or an `N<n>` row. "Fine" with no method is not evidence. |
| "I'll grep for secrets and read the hits, or quote the key so they believe it's real." | Use `-o`/`-l`/`-c` or length-only output; a value that reaches your context has already leaked. In the doc: `file:line`, kind, `<redacted: kind>`, and interrupt now as a P0. |
| "Score it 3x3 to be safe." | Use the rubric; doubt goes in Confidence. Inflated scores bury the risks that matter. |
| "Let me audit the code we just wrote." | Wrong skill. That is `verifier` or `check-security`. |
