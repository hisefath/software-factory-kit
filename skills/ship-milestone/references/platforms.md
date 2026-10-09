# ship-milestone reference: platforms, endpoints, SLO arithmetic

Load when writing deploy.md §2-§5 and HEALTH.md. Every command below is a starting point, not a source: before you
write one into a runbook, run `<cli> <subcommand> --help` (read-only), paste the relevant lines, and record the CLI
version in the runbook header. A command that has not yet run once outside production stays `⚠ unverified`.

## 1. How the merged SHA reaches the platform

Explain this choice to the human in plain words; it decides whether "what is live" can drift from `main`.

| Method | You get | You pay | Pick when |
|---|---|---|---|
| Upload a clean export of the SHA (`git archive <sha>` → platform CLI upload) | An explicit deploy step after merge; exactly the committed files ship | The app cannot read git at runtime, so the deploy writes a small build-info file; a few more commands | The platform is not connected to the repo, or you want deploy separate from merge (default for software-factory-kit) |
| Git-connected deploy from `main` | No deploy command at all; the platform usually exposes the commit to the app | Whatever reaches the watched repo and branch deploys. With GitLab canonical and a GitHub push mirror (WORKFLOW §8), that is the push of `main` to the mirror, not the merge: the push is the deploy and needs the deploy yes. A lagging mirror shows up as SM-1 red (old code live) | The platform already watches the branch you merge to |
| Upload the working tree | Fastest to type | Can ship uncommitted or git-ignored files; nobody can say which commit is live | Never |

## 2. Railway (CLI 5.57.7, help read 2026-10-08)

**Preflight (read-only):**

| Purpose | Command | Note |
|---|---|---|
| CLI version | `railway --version` | write it in the runbook header |
| Logged in? | `railway whoami` | not logged in → the human runs `railway login`. `railway up` while logged out starts a sign-in that can create an account and a new project |
| Linked project, environment, service | `railway status` | the link is stored per directory: run every command from the repo root. Not linked, or an empty deployment list → first deploy (below) |
| What is live (rollback target) | `railway deployment list --service <svc> --environment <env> --limit 5 --json` | the newest `SUCCESS` row is live; its commit comes from `/version` (or the deploy message, if the list shows it) |
| Logs | `railway logs --service <svc> --environment <env> --lines 200` | add `--build` for build logs, `--http --filter '@httpStatus:>=500' --lines 100` for failing requests |

**First-time setup (FS-n rows; human-only, `--help` read on CLI 5.57.7, 2026-10-08).** The agent prints these and
waits; the human runs them or clicks them. Each one creates something on the owner's account or handles a secret.

| FS | Command or dashboard path | Note (from `--help`) |
|---|---|---|
| Project | `railway init --name <project>` | "creates a project and links the current directory to the project's default environment" |
| Web service, database | `railway add --service <svc>`; `railway add --database postgres` (or `mysql`) | the database name comes from hld.md §11 |
| Link | `railway link --project <p> --environment <env> --service <svc>` | then `railway status` must show all three |
| Variables | dashboard → service → Variables, or `railway variable set <NAME> --stdin` typed by the human | values never pass through the agent. Laravel: the human runs `php artisan key:generate --show` locally and pastes it as `APP_KEY`; the agent never runs it (it prints the key). Database settings are dashboard references to the database service: describe them in words in deploy.md, because Railway's reference syntax uses double braces, which the placeholder check flags |
| Domain | `railway domain --service <svc>` | "generates a Railway-provided service domain"; it becomes `URL`; HTTPS is automatic |
| Source (git-connected only) | dashboard → service → Settings → Source | names the GitHub repo and branch the service watches |

**Deploy the exact SHA (clean export upload)** — ⚠ unverified until it has run once in a non-production
environment; `--path-as-root` makes the export folder the root of the upload:

```bash
SHA=<full merge sha>; ENV=production; SVC=<service>
EXPORT="$(mktemp -d)/release-$SHA" && mkdir -p "$EXPORT"
git archive "$SHA" | tar -x -C "$EXPORT"                       # only committed files, no .git, no .env
printf '{"commit":"%s","built_at":"%s"}\n' "$SHA" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$EXPORT/build-info.json"
railway up "$EXPORT" --path-as-root --service "$SVC" --environment "$ENV" --detach --message "deploy $SHA"
```

- `--detach` returns before the deploy finishes: poll `railway deployment list ... --json` until the new row is
  `SUCCESS` (or `FAILED`/`CRASHED` → rollback), then smoke.
- Never add `-y`/`--yes` or `--new` to `railway up`: with nothing linked they create a new project.
- The build-info path must match what the `/version` handler reads (the GAP task names the same path), and must not
  be excluded by `.dockerignore`.

**Git-connected deploys:** the service's source is a GitHub repo and branch; a push to that branch deploys. Before
the deploy ask, `git ls-remote <github mirror url> refs/heads/main` shows what the platform will build: if it already
holds the merge SHA, the deploy has happened; if not, DEP-1 is the (human-only) push, and `origin/main` must equal
the merge SHA or the push ships more than this milestone.
Railway documents a `RAILWAY_GIT_COMMIT_SHA` variable for these deployments that `/version` can read; confirm it by
reading `/version` after the first such deploy. `railway redeploy --from-source` pulls the latest commit again.

**Rollback:**

- Fast (RB-1, Executor `human (UI)`): in the dashboard, the service's Deployments list → the previous successful
  deployment → Rollback. The CLI 5.57.7 has no rollback subcommand, so the agent prints this click path and waits;
  ⚠ confirm the menu item exists on the account before relying on it.
- Rebuild (RB-2, Executor `agent (CLI)`): run the export-upload block with `SHA=<previous good sha>`. This is the
  recovery the agent can run itself, so on Railway the deploy ask's option b is "I run RB-2".
- First deploy: RB-1 and RB-2 are `n/a: nothing was live before`. A red first deploy is taken down by the human in
  the dashboard (the service's deployment → Remove).
- `railway down` removes the most recent deployment; it is not a tested rollback. Do not use it in production until
  it has been tried in another environment.
- `railway redeploy` redeploys the *latest* deployment; it does not go back in time.

**Never run:** `railway variable list`, `railway variable --kv`, `railway variable list --json` (all print raw
values); `railway run` or `railway shell` (they load secrets into a process whose output may be pasted);
`railway login` (human-only); `railway up -y`. Never run as the agent: `railway init`, `railway add`,
`railway link`, `railway domain`, `railway variable set` (first-time setup is the human's).

**Healthcheck on deploy:** Railway can hold a deploy until a healthcheck path answers (service settings, or
`deploy.healthcheckPath` in `railway.json`). That protects the moment of deploy; it does not watch production
afterwards, so it is not the probe. Changing it is a config change: file it as a GAP task, never edit it here.

## 3. Any other platform: what to find before writing the runbook

For each item write the command with its `--help` source, or `⚠ unverified` and a `Q-n` row.

1. How to check you are logged in, and which project/environment/service a command will hit.
2. How to deploy one specific commit or build artifact (not a working tree), with a message naming the SHA.
3. How to list deployments with their status, and which one is live.
4. How to put the previous build back quickly, and whether that also restores old configuration.
5. How to read app, build and HTTP logs, and which command would print secret values (never run it).
6. Whether migrations run on deploy, and where (start command, release phase, manual).
7. First-time setup: how to create the project, the database, the link, the variables (by name) and the HTTPS domain.
   All human-only (FS-n rows).
8. Which rollback the CLI can do (Executor `agent (CLI)`) and which needs the dashboard (`human (UI)`).

## 4. Health and version endpoints

- **Shallow health** answers "is the process up?" (returns 200 without touching anything). **Deep health** also
  runs one cheap dependency check, such as `SELECT 1` with a short timeout, and returns 503 when it fails. Recommend
  deep-but-cheap for the probe path: a site whose database is down is down for users. Never return versions,
  stack traces, hostnames or configuration from either.
- Frameworks often ship one: Laravel 11+ registers `/up` in `bootstrap/app.php` (`health: '/up'`), which by
  default proves the app boots, not that the database answers. Using it is fine (record the real path in
  HEALTH.md §1); a database check on top of it is a non-blocking GAP task (`Blocks: nothing (follow-up)`), not a
  rename. Only a missing `/version` `{commit, built_at}` or no health route at all blocks the deploy.
- **`/version`** returns `{"commit": "<40 hex>", "built_at": "<ISO-8601 UTC>"}` with `Cache-Control: no-store`,
  read from build metadata (the build-info file or a platform variable). Never run `git` at runtime: images have no
  `.git`, and shelling out from a web request is an attack surface.
- Why both: health says *something* answers; version says *your merged code* answers. Neither says the journey
  works; the smoke's SM-3+ lines do.

## 5. SLO arithmetic (show the human the `WHY:` line)

Error budget = (1 − target) × window. A 5-minute probe makes 288 checks a day, 8,640 in 30 days.

| Target | Budget per 30 days | Failed 5-minute probes allowed | Plain words |
|---|---|---|---|
| 99% | 7.2 hours | 86 | fine for a demo; users notice a bad evening |
| 99.5% | 3.6 hours | 43 | the solo-project default: one slow recovery a month |
| 99.9% | 43 minutes | 8 | needs someone who answers alerts at night |

One probe location measures "reachable from there", not every user's experience: name that blind spot in §4.

## 6. Probe options (interview question 5)

| Option | You get | You pay |
|---|---|---|
| Do nothing | nothing to set up | you learn about an outage from a user, after the demo |
| Platform deploy healthcheck only | bad deploys are held back | nothing watches after the deploy succeeds |
| External uptime monitor on `/healthz` every 5 minutes (recommended) | independent of your own infrastructure; alert by email; history to compute the SLO | the human creates a free account; checks health, not the journey |
| Scheduled CI job running `scripts/smoke.sh` | checks the journey too, reuses the smoke | needs a CI change (a GAP task); if CI is down, nothing alerts |
