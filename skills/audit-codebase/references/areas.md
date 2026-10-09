# Audit areas

Load this in `audit-codebase` step 5. Every area id below must end up in AUDIT.md `## Coverage` as findings
(`A<n>`), `clean` (with how you checked), or an `N<n>` row under `## Not audited`. Depth follows the Q-d answer:
deep = trace and read every hop; shallow = inventory plus the greps below.

All probes are read-only. Exclude vendored and generated code in every search:
`--exclude-dir={vendor,node_modules,.git,dist,build,storage,coverage}` (sensitive-data lists what is tracked
inside those). The greps are starting points that find places to read; a grep hit is never a finding until you have
read the code around it. Exception: a hit in a credential file or on a secret line is judged by key name, file,
commit status and value length only, never by opening the line (SKILL.md, You own / You never touch).
Record each command you run as `C<n>` in AUDIT.md `## Scope and method`.

## stack
- Look at: language, framework and runtime versions in manifests, lockfiles, Dockerfiles, CI images.
- Risk: a version past end-of-life (no security patches), or manifest and Docker image disagreeing. An EOL claim
  cites the target's docs or a `docs/research/R*` file; from memory it is `⚠ Q<n> EOL unverified` (new releases,
  such as Laravel 13 or PHP 8.5, may postdate what you know).
- Probe: read the manifest's version constraints; compare with the runtime the deploy config pins.

## build-run
- Look at: how the README says to build and run it vs what CI and the Dockerfile actually do; lockfile present
  and committed; pinned versions.
- Risk: a build nobody can reproduce; a README that is the only record of a manual step.
- Probe: list the target's own scripts (manifest `scripts`, Makefile targets, `bin/`, `scripts/`) by reading
  them. Write the ones you would run under `## Commands I would run`; never run them.

## dependencies
- Look at: direct dependency count, abandoned or forked packages, vendored copies, git-URL dependencies,
  licenses that conflict with how we ship.
- Risk: known-vulnerable or unmaintained packages; a fork nobody remembers why.
- Probe: count from the lockfile; the ecosystem's audit command (`composer audit`, `npm audit`, `pip-audit`, ...)
  goes under `## Commands I would run`, because it may execute or fetch code.

## architecture
- Look at: entry points (HTTP routes, CLI commands, queue workers, cron/schedulers), module boundaries, the
  biggest files and classes, circular dependencies, business logic in controllers or views.
- Risk: one change ripples everywhere; hidden entry points nobody secures (debug routes, old endpoints).
- Probe: `wc -l` sorted on source files for hot spots; `git log --format= --name-only | sort | uniq -c | sort -rn
  | head` for churn; read the route definitions completely.

## data
- Look at: schema and migrations (count, order, reversible?), seeders or fixtures containing real-looking data,
  soft deletes, constraints enforced in app code but not the database, backups.
- Risk: data loss on deploy, drift between migrations and the live schema, real records in the repo.
- Probe: list the migrations directory; read the newest and any that drop or alter columns.

## auth
- Look at: login, sessions, tokens, password storage, role or permission checks per route, tenant/patient
  isolation (can user A read user B's record by changing an id?), OAuth/SMART scopes, admin backdoors.
- Risk: a route with no check; authorization done in the UI only; ids that are guessable and unchecked.
- Probe: list every route and its middleware/guard; trace one read and one write of a protected record.

## secrets-config
- Look at: committed `.env` or credential files, keys in code, debug-mode defaults, config that differs silently
  between environments. Every probe below prints names, line numbers, kinds or lengths, never a value.
- Risk: a live credential in the repo or its history; debug on in production.
- Probe:
  - Committed now or ever (names only): `git -C <target> ls-files | grep -iE '(^|/)\.env|secret|credential|\.pem$|\.key$|\.p12$|auth\.json$'`
    and `git -C <target> log --all --name-only --format= | sort -u | grep -iE '<same pattern>'`.
  - Key names in code and config (`-o` prints the key and `=`/`:`, not what follows):
    `grep -rnoIiE "(api_?key|secret|passw|token)[A-Za-z_]*[\"']?[[:space:]]*[:=]" --exclude-dir={vendor,node_modules,.git,dist,build,storage,coverage} <target>`
  - Known key shapes (`-o` prints only the prefix that names the kind):
    `grep -rnoIE 'AKIA|sk_live_|sk_test_|-----BEGIN [A-Z ]*PRIVATE KEY|xox[abprs]-|gh[pousr]_' --exclude-dir={vendor,node_modules,.git,dist,build,storage,coverage} <target>`
  - Env-style file, key and value length: `awk '!/^[[:space:]]*#/ && (i=index($0,"=")) {print FILENAME":"FNR": "substr($0,1,i-1)" len="length($0)-i}' <file>`;
    a file in history: `git -C <target> show <sha>:<path> | awk '<same program>'`.
  - One code hit, literal or env read: `awk -v n=<line> 'FNR==n {r=substr($0,match($0,/[=:]/)+1); gsub(/^[>[:space:]]+/,"",r); print FILENAME":"n": " (r ~ /^(env|getenv|config|process\.env|os\.environ)/ ? "reads env/config" : "literal len=" length(r))}' <file>`.
- Judge: len 0 or a placeholder-sized value in an example file is fine; a long literal in a committed non-example
  file, or a `sk_live_`/private-key hit, is a P0 candidate. Record `file:line`, key name and kind, never the value.

## input-handling
- Look at: request validation, raw SQL or query building from strings, output escaping in templates, file
  uploads, mass assignment, URLs fetched from user input (SSRF), deserialization.
- Risk: injection, XSS, overwriting fields the user should not control.
- Probe: grep for raw-query and unescaped-output helpers of the target's framework; read each hit's caller.

## integrations
- Look at: every external API, webhook and SDK (the EHR, payments, email, storage): auth method, webhook
  signature checks, timeouts, retries, idempotency keys, what happens when the other side is down.
- Risk: unsigned webhooks accepted; a timeout that hangs a request; a retry that charges twice.
- Probe: grep for HTTP client construction and webhook routes; trace one outbound and one inbound call.

## sensitive-data
- Look at: where patient (PHI) and personal (PII) data enters, is stored, logged, cached, exported and deleted;
  encryption in transit and at rest; retention.
- Risk: PHI in logs, error trackers, analytics or URLs; no way to delete a record.
- Probe: trace one patient record from entry to storage; grep logging calls near those fields (PHI-in-logs risk
  is judged from those calls, never by opening a log). Tracked data the excluded dirs hide, paths only, contents
  never opened: `git -C <target> ls-files storage public/uploads uploads logs exports | grep -vE '(^|/)\.git(ignore|keep)$'`
  and `git -C <target> ls-files | grep -iE '\.(sql|csv|xlsx?|sqlite|db|dump|bak|log)$'`. Any tracked log, export,
  upload or dump is a finding cited by path (and `wc -c` size), never by content.

## errors-observability
- Look at: exception handling, logging, health and version endpoints, alerting, failed-job handling.
- Risk: **silent failure** (score +1): empty `catch`, error suppression, a default returned on error, a queue job
  or cron with no failure handler or alert, ignored return values.
- Probe: grep for empty catch blocks and suppression operators of the target language; read each hit.

## tests
- Look at: test count and kinds, which critical paths have none, skipped or flaky markers, whether CI runs them,
  fixtures that hit real services.
- Risk: green CI that proves nothing about the paths we will change.
- Probe: count test files and test cases by grep; map the traced critical paths to tests (or their absence).
  Running the suite goes under `## Commands I would run`.

## ci-deploy
- Look at: pipelines, deploy target and method, who can deploy, how migrations run on deploy, rollback path,
  how secrets reach production.
- Risk: manual deploys from a laptop; migrations that cannot roll back; no record of what SHA is live.
- Probe: read every CI and deploy file; compare the live `/version` (if any) with `target_sha`.

## money-state
- Look at: payments, orders, inventory, any state machine; double-submit and concurrency handling; rounding and
  currency; refunds.
- Risk: charging twice, orders stuck in a state with no way out, totals computed in floating point.
- Probe: trace checkout or the main state change end to end; list every state and every transition you find.

## docs-drift
- Look at: README, docs and comments that claim behaviour; compare with the code you read.
- Risk: the team (and the next agent) trusts a claim that is false.
- Probe: for each claim the brief relies on, cite the code that confirms or contradicts it.

## live-surface
- Only if Q-c cleared the URL. GET requests with TLS verification on; never log in, POST, scan or load.
- Look at: TLS validity, security headers, stack traces or framework debug pages on error, directory listings,
  `/health`, `/version`, `robots.txt`, and admin or debug paths the route list shows exist.
- GET an admin or debug path only after reading its handler and confirming it has no side effect (no write, queue
  dispatch, outbound call, or artisan/console command); cite that handler's `file:line` next to the GET. Legacy apps
  often change state on GET (cache clear, migrate, resend, sync). A path you have not cleared goes under
  `## Commands I would run`, never into a request.
- Risk: debug pages leaking config; a live version that is not the code you audited.
- Probe: `curl -sS -D - -o /dev/null <url>` per page; evidence as `GET <url> (<date>) → <status/header>`.
