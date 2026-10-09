<!-- guide: ship-milestone template. This file holds THREE output skeletons. Each starts at a line
     `<!-- file: <path> -->`; copy that part (without the file line) to that path.
       part 1 → docs/runbooks/deploy.md   (9 numbered sections; how to deploy and roll back, plus the release log)
       part 2 → docs/ops/HEALTH.md        (7 numbered sections; how we know production is healthy)
       part 3 → scripts/smoke.sh          (copy ONLY the lines inside its ```bash fence; then chmod +x)
     Keep every `## ` heading exactly as written and in order. Replace every {{placeholder}}; delete every
     `<!-- guide:` comment. Unknowns become `⚠ <question>` plus a Q-n row, never inventions.
     Ids (permanent; never renumber; retire with ~~ID~~ (removed {{date}}: reason)):
       FS-n first-time setup · PRE-n preflight · DEP-n deploy step · RB-n rollback · SM-n smoke check · SLO-1 ·
       SIG-n signal · GAP-n readiness gap · Q-n open question.
     Names of secrets only, never values. No PHI or real personal data anywhere.
     Every curl starts `curl -q` (it must be the first argument): it makes curl ignore ~/.curlrc, where a line
     `insecure` would silently switch TLS verification off. -->

<!-- file: docs/runbooks/deploy.md -->
# Deploy runbook — {{project name}}

<!-- guide: the exact, copy-pasteable way to put a merged SHA live and to take it back. Deploy and rollback are
     human-only actions: an agent runs them only after a `deploy-<env>` / `rollback-<env>` row with the human's exact
     words exists in .handoff/TRACKER.md ## Approvals. Every command cites its source (AGENTS.md, `--help` output
     with CLI version, or a doc URL); a command not yet run once outside production is marked `⚠ unverified`. -->

| Field | Value |
|---|---|
| Platform | {{e.g. Railway, CLI 5.57.7}} |
| Services | {{e.g. app (web), Postgres (managed database)}} |
| Environments | {{production at https://… ; staging at https://… or "none"}} |
| Method | {{clean `git archive` upload of the merge SHA / git-connected deploy from main}} |
| Current release | {{M<N> @ short sha — see §8}} |
| Last updated | {{output of `date`}} |
| Written by | ship-milestone ({{harness}}, {{model id}}) |
| Approvals | deploy and rollback yes-es live in `.handoff/TRACKER.md ## Approvals` (never in this file) |

## Inputs read

| Path | Version (sha or date) | Used for |
|---|---|---|
| `AGENTS.md` | {{sha}} | platform, services, deploy row |
| `MILESTONES.md` | {{sha}} | merge SHA, main-check SHA |
| {{path}} | {{sha}} | {{what it informed}} |

**Not read:** {{path — why not read}} | none

## 1. What gets deployed and how

<!-- guide: plain words a beginner can follow. Say why this method keeps "what is live" equal to a commit on main. -->

- **Release:** {{M<N>}} at merge SHA `{{full 40-character sha}}` (merged {{date}}, G5 approved {{Approvals row time}}).
- **Live before this release:** {{short sha (the rollback target) | nothing: first deploy, see the first-time setup in §2}}
- **How the SHA reaches the platform:** {{e.g. a clean `git archive` of the SHA is uploaded with the platform CLI | git-connected: the platform watches <repo>/<branch>, so the push of main there is the deploy}}
- **Why this method:** {{plain words: it ships exactly the merged commit, never uncommitted or ignored files}}
- **Build and start:** {{e.g. Dockerfile at the repo root builds the image; start command runs migrations then the web server}} (source: `{{file:line}}`)
- **How the app knows its version:** {{e.g. DEP-2 writes build-info.json {"commit","built_at"} into the upload; GET /version reads it}}
- **Migrations in this release:** {{list of migration files from `git diff --name-only <live-sha> <sha> -- <migrations dir>`, or "none"}}

## 2. Preflight (read-only, before every deploy)

| Id | Command | Expect | If not |
|---|---|---|---|
| PRE-1 | `git fetch origin main && git merge-base --is-ancestor "$SHA" origin/main && echo on-main` | `on-main` | Stop: the SHA is not merged. |
| PRE-2 | `grep -F "${SHA:0:7}" MILESTONES.md` | the M<N> row shows this merge SHA and a main-check SHA | Stop: run `make check` on main first (Done = merged + green on main). |
| PRE-3 | `{{cli}} --version` | {{version written in the header}} | Re-read `--help` for every command below before using a different version. |
| PRE-4 | `{{auth status command, e.g. railway whoami}}` | logged in as {{the owner's account name}} | The human logs in; never let a deploy command start a login or sign-up. |
| PRE-5 | `{{link status command, e.g. railway status}}` | the project, environment and service of §3 | Stop: a deploy command run unlinked can create a new project. **First deploy:** do the first-time setup below first. |
| PRE-6 | `{{list deployments command}}` | the live deployment and its SHA (= rollback target) | Stop: unknown live state means unknown rollback target. **First deploy:** an empty list is expected; rollback target = none. |
| PRE-7 | `bash scripts/smoke.sh "$URL" "$SHA"` (baseline) | SM-1 fails with the old SHA; every other check passes | Production is already broken or the smoke list is wrong: fix that first. **First deploy:** skip (nothing answers yet). |
| PRE-8 | `git diff --name-only "$LIVE_SHA" "$SHA" -- {{migrations dir}}` | {{the list in §1}} | Anything not additive makes RB-1 unsafe (§5). **First deploy:** every migration is new; list them in §1. |

### First-time setup (human-only, once, before the first deploy)

<!-- guide: everything that must exist before the first DEP step. Every row is human-only: it creates resources on
     the owner's account, may cost money, or handles secret values. The agent prints the rows and waits; the human
     says when each is done. Variable VALUES are typed by the human into the platform, never shown to the agent.
     Later deploys keep these rows as the record of how production was set up. -->

| Id | Setup action | Command or dashboard path | Source | Done when |
|---|---|---|---|---|
| FS-1 | Create the project | {{e.g. `railway init --name <project>` (also links this directory)}} | {{`railway init --help` (CLI version)}} | {{link status names the project}} |
| FS-2 | Add the web service and the database | {{e.g. `railway add --service <svc>` and `railway add --database postgres`}} | {{`railway add --help` (CLI version)}} | {{both services are listed}} |
| FS-3 | Link this repo directory to project, environment and service | {{e.g. `railway link --project <p> --environment production --service <svc>`}} | {{…}} | {{PRE-5 shows all three}} |
| FS-4 | Set every §6 variable by name (values typed by the human) | {{e.g. dashboard → service → Variables}} | {{…}} | {{the human confirms each §6 name is set (names only)}} |
| FS-5 | Generate the public HTTPS domain | {{e.g. `railway domain --service <svc>` (a generated subdomain)}} | {{…}} | {{the domain is known; it becomes `URL` in §3}} |
| FS-6 | {{git-connected only: connect the repo and branch the platform watches; else "n/a: clean export"}} | {{dashboard → service → Settings → Source}} | {{…}} | {{…}} |

## 3. Deploy commands (human-only — run only after a recorded yes)

<!-- guide: set the variables once, then numbered steps. Pin everything to $SHA. Never deploy a working tree.
     Never add flags that auto-confirm creating projects or accounts. -->

```bash
SHA={{full merge sha}}            # from MILESTONES.md
ENV={{production}}                # platform environment name
URL={{https://…}}                 # public HTTPS base URL of $ENV (first deploy: from FS-5)
LIVE_SHA={{sha live before this deploy, or "none" on a first deploy}}   # from PRE-6; the rollback target
{{deploy commands, one per line, numbered in the table below}}
```

| Id | Command (short) | What it does | Expected output | Source |
|---|---|---|---|---|
| DEP-1 | {{e.g. export the SHA to a clean directory}} | {{plain words}} | {{…}} | {{AGENTS.md / `--help` (CLI version) / doc URL}} |
| DEP-2 | {{e.g. write build-info.json with commit + built_at}} | {{…}} | {{…}} | {{…}} |
| DEP-3 | {{e.g. upload and deploy to $ENV with a message naming $SHA}} | {{…}} | {{…}} | {{…}} |

## 4. Verify

- **Wait:** `{{status / deployment list command}}` until the new deployment reports {{SUCCESS}}; at most {{10}} minutes.
  {{FAILED / CRASHED}} → §5.
- **Version:** `curl -q --fail --silent --show-error --proto '=https' "$URL/version"` → `"commit"` equals `$SHA`.
- **Smoke:** `bash scripts/smoke.sh "$URL" "$SHA"` → last line starts `SMOKE GREEN`. Paste the full output into §8.

<!-- guide: SM-3 onward come from specs/M<N>-<slug>/acceptance.md ## Demo smoke: one row per step an anonymous GET
     can prove. Covers = "demo <step #>" plus that step's Re-checks ids. -->

| Id | Request | Expect | Proves | Covers |
|---|---|---|---|---|
| SM-1 | `GET /version` | 200, `commit` = `$SHA`, `built_at` present | the merged code is what runs | release identity |
| SM-2 | `GET {{/healthz}}` | 200{{, body contains "ok"}} | the process is up{{ and reaches the database}} | SLO-1 |
| SM-3 | `GET {{/path}}` | {{200, contains "stable copy"}} | {{journey step in plain words}} | {{demo 1 · AE-###, AT-###}} |
| SM-4 | `GET {{/login-guarded path}}` | {{302 to /login}} | routing and the auth guard work without credentials | {{demo 6 · AE-###}} |

**Not in the smoke** (Demo smoke steps that need a login or a write; the smoke never logs in or changes data):

| Demo step | Why not in the smoke | Covered by |
|---|---|---|
| {{e.g. 4 — place an order}} | {{writes production data}} | {{AT-### in tests/acceptance (green at G5) and the recorded demo}} |

## 5. Rollback (human-only — run only after a recorded yes)

<!-- guide: Executor is `agent (CLI)` only when a CLI command does it; a dashboard click is `human (UI)`, and the
     agent prints its click path and waits. First deploy: RB-1 and RB-2 read "n/a: nothing was live before"; a red
     first deploy is recovered by the human taking the service down in the dashboard. -->

| Id | Path | Command | Executor | Time to restore | Safe when |
|---|---|---|---|---|---|
| RB-1 | Fastest: put the previous build back | {{e.g. dashboard → Deployments → the $LIVE_SHA deployment → Rollback}} | {{human (UI)}} | {{~1-2 min}} | {{no migrations, or additive-only}} |
| RB-2 | Rebuild the previous good SHA | §3 with `SHA=$LIVE_SHA` | {{agent (CLI)}} | {{build time, ~N min}} | {{same as RB-1}} |
| RB-3 | Durable: make `main` match production | `git revert -m 1 {{merge sha}}` on a branch → MR → G5 → §3 with the revert SHA | human merges; agent runs §3 after a recorded yes | {{hours}} | always (a new reviewed commit) |

- **Roll back when:** {{any SM-n red after deploy; or SIG-1/SIG-3 fires within 1 hour of a deploy}}.
- **Data and migrations:** {{none in this release | which migration, whether old code still works against the new
  schema, and why RB-1 is or is not safe}}
- **After a rollback:** `bash scripts/smoke.sh "$URL" "$LIVE_SHA"` must go green; record it in §8.

## 6. Configuration and secrets (names only)

| Name | Needed by | Set where | Rotated how | Source of truth |
|---|---|---|---|---|
| {{APP_KEY}} | {{app boot}} | {{platform variables, environment $ENV}} | {{…}} | {{.env.example line / hld.md §11}} |

## 7. Gotchas

- {{e.g. the platform CLI link is per directory: run deploy commands from the repo root}}
- {{e.g. never run the variables listing: it prints raw secret values}}

## 8. Release log

<!-- guide: append one row per deploy and per rollback, newest last. Cells come from pasted output, never memory. -->

| Date (`date`) | Env | Milestone | SHA | Approval (row time) | /version commit | Smoke (last line) | Outcome |
|---|---|---|---|---|---|---|---|
| {{date}} | {{env}} | {{M<N>}} | {{short sha}} | {{time}} | {{commit}} | {{SMOKE GREEN: n passed, 0 failed …}} | {{live / rolled back to sha}} |

## 9. Open questions

| Id | Question | Recommended answer | Blocks |
|---|---|---|---|
| {{Q-1}} | {{…}} | {{…}} | {{DEP-n / RB-n / nothing}} |

<!-- file: docs/ops/HEALTH.md -->
# Production health — {{project name}}

<!-- guide: how anyone can tell, in production, that the system is working, which code runs, and where to look when
     it is not. One SLO, not ten. Plain words: the owner must explain every line in an interview. -->

| Field | Value |
|---|---|
| Environment | {{production at https://…}} |
| Live release | {{M<N> @ short sha}} (see `docs/runbooks/deploy.md` §8) |
| Owner | {{the human's name or handle; how alerts reach them — a channel name, never a phone number}} |
| Last updated | {{output of `date`}} |
| Written by | ship-milestone ({{harness}}, {{model id}}) |

## 1. Health and version endpoints

| Endpoint | Contract | What it proves | What it does NOT prove | Status |
|---|---|---|---|---|
| `{{/healthz}}` | {{200 + "ok"; 503 when the database is unreachable; answers in < 1 s; no versions, stack traces or config}} | {{the process answers and reaches its database}} | that the merged code runs; that the journey works | {{present at `file:line` / GAP-n}} |
| `/version` | 200 JSON `{"commit": "<40 hex>", "built_at": "<ISO-8601 UTC>"}`, `Cache-Control: no-store`, no other fields | which build is running | that it works | {{present at `file:line` / GAP-n}} |

## 2. SLO

| Field | Value |
|---|---|
| SLO-1 | {{≥ 99.5% of 5-minute probes of /healthz succeed}} |
| SLI (what we count) | {{successful probes ÷ all probes, from the probe's history}} |
| Window | {{30 days, rolling}} |
| Error budget | {{3.6 hours}} |
| When the budget is spent | {{stop feature deploys; the next milestone starts with reliability work}} |
| Why this target | {{plain words: what users need vs what one person can keep up}} |

  WHY: {{(1 − 0.995) × 30 days × 24 h = 3.6 h; 30 days ÷ 5 min = 8,640 probes, so 43 may fail}}

## 3. How we would know it is broken

| Id | What users see | Signal | Where to look | Threshold | First action |
|---|---|---|---|---|---|
| SIG-1 | site down | probe fails | {{probe alert / dashboard}} | {{2 consecutive failures}} | {{deploy in the last hour → RB-1; else read logs (§5)}} |
| SIG-2 | old or wrong code live | `/version` ≠ merge SHA in MILESTONES.md | `bash scripts/smoke.sh <url> <sha>` (SM-1) | any mismatch | {{redeploy the right SHA with deploy.md §3}} |
| SIG-3 | errors | {{HTTP 5xx in access logs}} | `{{logs command filtered to status >= 500}}` | {{> 1% of requests over 15 min}} | {{read the error; roll back if it started at a deploy}} |
| SIG-4 | health green but the journey broken | SM-3… red | `bash scripts/smoke.sh <url> <sha>` | any red | {{fix-bug with the failing SM-n as the repro}} |

## 4. Probe

| Field | Value |
|---|---|
| Probe | {{service or tool}} |
| Checks | `GET {{https://…/healthz}}` expects {{200 (and "ok")}}, TLS verified |
| Interval and locations | {{5 minutes, 1 region}} |
| Alerts to | {{the owner's channel, by name}} |
| Set up by | human, {{date}} (accounts are human-only) |
| First pass | {{time from the probe's own history}} · seen in {{where}} |
| Blind spots | {{e.g. one region; checks health, not the journey — the smoke covers the journey after each deploy}} |

## 5. Logs

| What | Where | How to read it | Retention | Never contains |
|---|---|---|---|---|
| Application logs | {{platform log stream (stderr)}} | `{{logs command}}` | {{…}} | secrets, tokens, PHI, card data |
| Build logs | {{…}} | `{{build logs command}}` | {{…}} | secrets |
| HTTP access logs | {{…}} | `{{http logs command}}` | {{…}} | query strings with personal data |

- **Log level in production:** {{e.g. info; debug never in production}}
- **Find one failing request:** {{e.g. filter the HTTP logs by path and status, then match the request id in the app logs}}

## 6. Readiness gaps (filed as tasks)

<!-- guide: "none" if nothing is missing. Otherwise one `### GAP-n` per missing endpoint or signal, each with a fenced
     WORKFLOW.md §7 task contract the supervisor copies verbatim into .handoff/runs/<id>/task.md (a supervisor job
     file, which implement-task accepts) once the human approves it at STOP B. Owns lists app paths that
     implement-task (not ship-milestone) will change.
     Blocks is exactly one of: `G-live` (no route reports {commit, built_at}, or no health route at all: no deploy)
     or `nothing (follow-up)` (shallow health instead of deep, a missing no-store header and the like: the release
     ships and the gap is listed under "Not verified" at G-live).
     Ids: GAP-n becomes task M<N+1>-T90n (the 900s never collide with slice-tasks' T001-T010). M<N+1> is the next
     milestone in MILESTONES.md; the GAP code rides its branch milestone/m<N+1>-<slug> and its MR through G5, on task
     branch m<N+1>/t90n-<slug>. Example block: -->

### GAP-1 {{e.g. /version does not report the build commit}}

Blocks: {{G-live | nothing (follow-up)}} · Why: {{plain words}}

```markdown
---
id: {{M<N+1>-T901}}   milestone: {{M<N+1>}}   skill: implement-task   covers: [{{FR/NFR id or "ops"}}]   after: []
harness: claude   mode: workspace-write   hitl: false   parallel: true   budget: 1 run, 20 min
---
Owns: {{route file}}, {{handler file}}, {{test file}}
## Ask
{{GET /version returns 200 JSON {"commit": "<40 hex>", "built_at": "<ISO-8601 UTC>"} read from <build-info path or
platform variable>; no auth; Cache-Control: no-store; no other fields; never runs git at runtime.}}
Contract home: this Ask until design-lld adds the path to docs/architecture/contracts/openapi.yaml (it owns that
file); the worker never edits docs/**.
## Done-when
{{`make check` exits 0, including a test that asserts the JSON shape and the no-store header}}
## Must not change
{{every path outside Owns; existing routes' behaviour}}
## Consumes / Produces
{{Consumes: the build-info file deploy.md DEP-n writes. Produces: the contract scripts/smoke.sh SM-1 checks.}}
## Context manifest
give: docs/ops/HEALTH.md#1-health-and-version-endpoints, docs/runbooks/deploy.md#1-what-gets-deployed-and-how ; never give: other runs/, worker self-reports
## Return
write $HANDOFF_DIR/runs/{{M<N+1>-T901}}/result.md
```

## 7. Open questions

| Id | Question | Recommended answer | Blocks |
|---|---|---|---|
| {{Q-1}} | {{…}} | {{…}} | {{…}} |

<!-- file: scripts/smoke.sh -->
```bash
#!/usr/bin/env bash
# scripts/smoke.sh — written by ship-milestone (software-factory-kit 0.1) for {{project name}}.
# Proves that the deployment at <base-url> runs <expected-sha> and that its core journey answers.
# Usage: bash scripts/smoke.sh <https-base-url> <expected-sha>
# Exit:  0 every check passed · 1 at least one check failed · 2 bad arguments
# Rules: TLS verification always on; GET only; no credentials; never creates orders, payments or accounts.
#        curl -q (first argument) ignores ~/.curlrc, so no config file can switch TLS verification off.
# Check ids map to acceptance ids in docs/runbooks/deploy.md §4.
set -euo pipefail

usage="usage: bash scripts/smoke.sh <https-base-url> <expected-sha>"
if [ "$#" -ne 2 ]; then
  echo "$usage" >&2; exit 2
fi
BASE_URL="${1%/}"
EXPECTED_SHA="$(printf '%s' "$2" | tr 'A-F' 'a-f')"

case "$BASE_URL" in
  https://*) ;;
  *) echo "FAIL arguments: base url must start with https:// (verified TLS is part of the check)" >&2; exit 2 ;;
esac
if ! printf '%s' "$EXPECTED_SHA" | grep -Eq '^[0-9a-f]{7,40}$'; then
  echo "FAIL arguments: expected sha must be 7-40 hex characters" >&2; exit 2
fi

HEALTH_PATH="{{/healthz}}"
CURL=(curl -q --silent --show-error --proto '=https' --tlsv1.2 --max-time 15
      --retry 2 --retry-delay 3 --user-agent 'software-factory-kit-smoke/0.1')

passed=0
failed=0
pass() { passed=$((passed + 1)); printf 'PASS %s\n' "$1"; }
fail() { failed=$((failed + 1)); printf 'FAIL %s\n' "$1"; }

# check <id> <path> <expected http status> [<text the body must contain>]
check() {
  local id="$1" path="$2" want="$3" needle="${4:-}" body code
  body="$(mktemp "${TMPDIR:-/tmp}/smoke.XXXXXX")"
  if ! code="$("${CURL[@]}" --output "$body" --write-out '%{http_code}' "$BASE_URL$path")"; then
    fail "$id GET $path: no HTTP answer (TLS, DNS, connection or timeout error above)"
  elif [ "$code" != "$want" ]; then
    fail "$id GET $path: HTTP $code, want $want"
  elif [ -n "$needle" ] && ! grep -qF -- "$needle" "$body"; then
    fail "$id GET $path: HTTP $code but the body lacks \"$needle\""
  else
    pass "$id GET $path -> $code"
  fi
  rm -f "$body"
}

# check_version <id>: GET /version must report the expected commit and a built_at time
check_version() {
  local id="$1" body commit built_at
  if ! body="$("${CURL[@]}" --fail -H 'Accept: application/json' "$BASE_URL/version" | tr '\n' ' ')"; then
    fail "$id GET /version: no 2xx answer (error above)"
    return 0
  fi
  commit="$(printf '%s' "$body" | sed -nE 's/.*"commit"[[:space:]]*:[[:space:]]*"([0-9a-fA-F]{7,40})".*/\1/p' | tr 'A-F' 'a-f')"
  built_at="$(printf '%s' "$body" | sed -nE 's/.*"built_at"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p')"
  if [ -z "$commit" ]; then
    fail "$id GET /version: no \"commit\" field in: ${body:0:200}"
  elif [ -z "$built_at" ]; then
    fail "$id GET /version: no \"built_at\" field"
  elif [[ "$commit" == "$EXPECTED_SHA"* || "$EXPECTED_SHA" == "$commit"* ]]; then
    pass "$id GET /version -> commit $commit, built_at $built_at"
  else
    fail "$id GET /version: live commit $commit, expected $EXPECTED_SHA"
  fi
}

echo "smoke: $BASE_URL expecting $EXPECTED_SHA at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# ---- release identity and health: always ----
check_version SM-1
check SM-2 "$HEALTH_PATH" 200 "{{text the health body contains, or leave empty quotes}}"

# ---- core journey, read-only: one line per Demo smoke step an anonymous GET can prove (deploy.md §4) ----
check SM-3 "{{/path}}" {{200}} "{{stable copy on that page}}"   # demo {{1}} {{AE-###, AT-###}}
check SM-4 "{{/login-guarded/path}}" {{302}}   # demo {{6}} {{AE-###}} logged out -> redirect to login

if [ "$failed" -gt 0 ]; then
  echo "SMOKE RED: $failed failed, $passed passed against $BASE_URL (expected $EXPECTED_SHA)"
  exit 1
fi
echo "SMOKE GREEN: $passed passed, 0 failed against $BASE_URL at $EXPECTED_SHA (TLS verified)"
```
