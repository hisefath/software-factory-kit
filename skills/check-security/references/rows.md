# check-security row guide

Load at step 4 (CK rows) and step 5 (LLM rows). One block per row: what `pass` means, where to look, what a fail
looks like, when `n.a.` is honest, and one sentence to say out loud in an interview. Stack examples are examples,
not the method: read the project's own AGENTS.md for its framework and find the equivalent.

ASVS = OWASP Application Security Verification Standard 5.0 (May 2025). Rows cite chapters (V1-V17), not
requirement numbers. Cite a requirement id (format `v5.0.0-<chapter>.<section>.<req>`) only if you read that
requirement in the ASVS text this session. Level 1 = the baseline every internet-facing app should meet.

Evidence rule for every row: prefer the code the milestone changed; then the app-wide control the change relies on
(middleware, config, base class) plus proof the diff does not switch it off. "The framework does it by default" is
a pass only with the `path:line` where the default is on and a `CMD-<n>` showing no opt-out in the code.

## CK-01 Authentication (V6)

- **Pass:** every non-public route requires an authenticated identity; passwords, if the app has any, use the
  framework's adaptive hash (bcrypt or argon2); login and reset are rate-limited; no default or seeded accounts
  reach production; an identity handed over by another system (SSO, an EHR launch, a signed link) is verified
  server-side (signature, issuer, audience, expiry) before the app trusts it.
- **Look at:** route files and middleware groups; auth config; login, reset and launch handlers; rate limiters;
  seeders. Laravel: `routes/*.php` `->middleware('auth')`, `RateLimiter::for`. Node: route-level auth middleware.
- **Fail signs:** a data or state-changing route outside the auth group; a user or patient id taken from the query
  string, a header or a hidden field as proof of identity; md5/sha1 passwords; unthrottled login.
- **n.a. when:** the app has no user identity and serves no user-specific data (cite the route list).
- **Say it out loud:** "Authentication answers who you are, and the server checks it on every request, not only at
  the login page."

## CK-02 Session management (V7)

- **Pass:** the session id is regenerated at login; logout invalidates the session server-side; session cookies are
  `Secure`, `HttpOnly` and `SameSite` (Lax or Strict); idle and absolute timeouts are set; no session id or token
  ever travels in a URL. An app embedded in another site's iframe (an in-EHR app) needs `SameSite=None; Secure`,
  which is acceptable only with CK-06 tokens in place.
- **Look at:** session config (Laravel `config/session.php`: `secure`, `http_only`, `same_site`, `lifetime`;
  `.env.example` defaults); login and logout handlers.
- **Fail signs:** `secure` false, or read from an env var whose default is false; tokens in query strings;
  logout that only deletes the client cookie.
- **n.a. when:** no cookies and no server sessions at all (a pure bearer-token API: then CK-16 covers tokens).
- **Say it out loud:** "A session cookie is a bearer password, so it is Secure, HttpOnly, short-lived and replaced at
  login."

## CK-03 Access control and IDOR (V8)

- **Pass:** every read or write of a record checks, on the server, that this caller may touch *this* record (owner,
  practice or tenant, role); queries are scoped to the caller; admin actions require an admin role; access is denied
  by default. A test proves user A gets 403 or 404 on user B's record.
- **Look at:** every handler that takes an id from the route or body; policies and guards (Laravel Policies,
  `$this->authorize()`, `Gate`); query scopes; tests named like `cannot`, `forbidden`, `other user`.
- **Fail signs:** `Model::find($id)` or `findOrFail($id)` with no ownership check; role checks only in the UI;
  tenant tables with no tenant scope; sequential ids exposed with no check (IDOR = insecure direct object
  reference: changing the id in the URL shows someone else's data).
- **n.a. when:** never, if the app stores any data.
- **Say it out loud:** "Logged in is not the same as allowed: every record access checks that this user may touch
  this record."

## CK-04 Input validation and injection (V1, V2)

- **Pass:** all input crossing a trust boundary is validated server-side against an allow-list (type, length, range,
  format) before use; database access is parameterized (ORM or prepared statements); no shell, `eval` or
  deserialization of untrusted input; mass assignment is limited to named fields.
- **Look at:** request validation (Laravel FormRequest or `$request->validate()`, `$fillable` / `$guarded`); raw
  queries (`DB::raw`, `whereRaw`, `selectRaw`, string-built SQL); `exec`, `shell_exec`, `system`, `proc_open`,
  `eval`, `unserialize`, `child_process`.
- **Fail signs:** input interpolated into SQL or a shell command; `$guarded = []`; quantity or amount accepted
  without a range; validation only in the browser.
- **n.a. when:** never for an app that accepts input.
- **Say it out loud:** "Validate on the server with an allow-list, and keep data out of the code channel: bound
  parameters, never string-built queries."

## CK-05 Output encoding and XSS (V1, V3)

- **Pass:** templates auto-escape and no untrusted value is rendered raw; a Content-Security-Policy limits where
  scripts load from; API responses send the right `Content-Type`.
- **Look at:** raw-output constructs: Blade `{!! !!}`, Vue `v-html`, React `dangerouslySetInnerHTML`, `innerHTML =`,
  `|safe`, `|raw`; the CSP header (middleware, web server config, meta tag).
- **Fail signs:** user- or EHR-supplied text (names, notes, reviews, product copy from an admin) rendered raw; no
  CSP at all (medium on its own).
- **n.a. when:** the app renders no HTML (an API only): cite the route list.
- **Say it out loud:** "XSS is data being run as code in the browser, so every value is escaped for where it lands,
  and CSP is the seatbelt if one slips through."

## CK-06 CSRF (V3)

- **Pass:** every state-changing request authenticated by a cookie needs an anti-CSRF token or a strict
  Origin check; GET never changes state; the only exemptions are webhooks that verify a signature (CK-15).
- **Look at:** the CSRF middleware and its exception list (Laravel `validateCsrfTokens(except: [...])` in
  `bootstrap/app.php`, `@csrf` in forms); routes where GET writes; SPA token headers.
- **Fail signs:** broad exemptions (`api/*`, `*`); GET routes that create, update or delete; an iframe-embedded app
  with `SameSite=None` cookies and no token.
- **n.a. when:** no cookie-based authentication anywhere (pure bearer-token API): cite the auth config.
- **Say it out loud:** "The browser attaches cookies to forged requests too, so a write must carry a token the
  attacker's page cannot read."

## CK-07 Secrets and cryptography (V11, V13)

- **Pass:** secrets come from the environment or a secret store, never the repo; `.env` is gitignored and untracked;
  the secret scan has zero open hits triaged `secret` (a `revoked` one, rotated per the human's Approvals row, does
  not count); crypto uses the platform's vetted primitives (no homemade crypto, no md5/sha1 for passwords or
  signatures); tokens come from a CSPRNG; signatures compare in constant time.
- **Look at:** `## Secret scan`; `git ls-files` for env files; `.gitignore`; config reading `env()`; `md5(`, `sha1(`,
  `rand(`, `mt_rand(`, `uniqid(`, `Math.random(` used for tokens; `==` on signatures (PHP: `hash_equals`; Node:
  `crypto.timingSafeEqual`).
- **Fail signs:** a tracked `.env`; a key literal in config or tests; an app key committed; predictable reset tokens.
- **n.a. when:** never.
- **Say it out loud:** "Secrets live in the environment, not the repo, and once one is pushed the fix is rotation,
  because deleting the line does not un-leak it."

## CK-08 Errors and logging, no PII or secrets (V16)

- **Pass:** users see generic errors (no stack traces, SQL, file paths); debug is off by default; security events
  (failed login, denied access, payment and order state changes) are logged with who, what and when; no log line
  carries secrets, tokens, passwords, card data or PHI (patient names, dates of birth, conditions, orders tied to a
  patient).
- **Look at:** the debug default (Laravel `APP_DEBUG` in `config/app.php` and `.env.example`); the exception handler;
  **every log call the diff adds** (`Log::`, `logger(`, `console.log`, `print`, `error_log`): read its arguments.
- **Fail signs:** logging a whole request, response, header set or model; the `Authorization` header in logs;
  exception messages returned to the client; debug on by default.
- **n.a. when:** never.
- **Say it out loud:** "Logs are a second database that many people can read, so nothing goes in them that I would
  not publish."

## CK-09 Data protection (V14)

- **Pass:** the app stores only the personal or patient data an FR needs; sensitive fields are known and listed;
  data sent to each third party matches the data list on that HLD connection (`L-n`); sensitive pages send
  `Cache-Control: no-store`; card data never touches the app (the payment provider tokenizes it).
- **Look at:** migrations and models for sensitive columns; outbound calls the diff adds; analytics or tracking
  scripts; response caching; what goes into payment metadata.
- **Fail signs:** PHI in analytics, URLs or payment metadata; a stored card number; a collected field no FR needs.
- **n.a. when:** the app handles no personal data at all (rare; cite the models).
- **Say it out loud:** "The safest patient data is data we never collected, and each partner gets only the fields
  the design says it needs."

## CK-10 TLS verified (V12)

- **Pass:** every outbound call uses `https` with certificate verification on; production forces HTTPS (redirect
  plus HSTS); no third-party base URL in config or `.env.example` is `http://`.
- **Look at:** HTTP client calls: Laravel `Http::withoutVerifying()`, Guzzle `'verify' => false`, curl
  `CURLOPT_SSL_VERIFYPEER => false` or `CURLOPT_SSL_VERIFYHOST => 0`, Node `rejectUnauthorized: false` or
  `NODE_TLS_REJECT_UNAUTHORIZED`, Python `verify=False`; base URLs; proxy and URL-forcing config.
- **Fail signs:** verification off anywhere, including "only in dev" behind a flag whose default is off.
- **n.a. when:** never for a deployed app. The live certificate and header probe is ship-milestone's job (G-live);
  list it under `## Not checked`.
- **Say it out loud:** "TLS without certificate verification is encryption to whoever answers, so verification is
  never switched off, not even in dev."

## CK-11 Configuration and headers (V13, V3)

- **Pass:** production defaults are safe: debug off, no default credentials, developer tools and debug routes not
  reachable (Laravel Telescope, Debugbar, `phpinfo`), dev-only packages in dev dependencies; security headers set
  (CSP with `frame-ancestors`, `X-Content-Type-Options: nosniff`, `Referrer-Policy`, HSTS); CORS limited to known
  origins; an embedded app allows framing only by its host's origin.
- **Look at:** config defaults and `.env.example`; header middleware; CORS config; `require` vs `require-dev` (or
  `dependencies` vs `devDependencies`); debug routes.
- **Fail signs:** CORS `*` with credentials; a debug tool in production dependencies; `frame-ancestors *` or no
  framing control on an embedded app.
- **n.a. when:** never.
- **Say it out loud:** "Secure defaults mean a fresh deploy with no extra setting is already safe."

## CK-12 Dependencies (V15)

- **Pass:** every manifest has a committed lockfile; the dependency audit ran and shows no unaccepted high or
  critical advisory; every package the diff adds has a decision (`D<n>`), per the AGENTS.md "ask first" rule.
- **Look at:** `## Dependency audit`; `git diff "$BASE" "$MB" -- <manifests>` for added or upgraded packages; the
  decision journal for their `D<n>`.
- **Fail signs:** the audit could not run (no tool on PATH): fail, with a finding that says so; an advisory with
  no disposition; a new package with no `D<n>`; an abandoned package.
- **n.a. when:** the project has no third-party dependencies (cite the manifests).
- **Say it out loud:** "Most of the code we ship we did not write, so the lockfile pins it and an audit reads it
  every milestone."

## CK-13 Business logic and money integrity (V2)

- **Pass:** prices, totals, discounts, tax and stock are computed on the server from trusted data, never taken from
  the client; money is integer minor units (cents) or a fixed-point decimal, never a float; every HLD invariant
  (`INV-n`) is held by its named enforcer (DB constraint, transaction, idempotency key) and a test proves it
  (charged at most once, quantity never negative, order states move only along allowed transitions); payment
  webhooks verify the provider's signature and are idempotent.
- **Look at:** checkout and order code; request fields named like price, amount, total, discount, status;
  migrations (column types, unique constraints); the webhook handler; tests for double submit and replay.
- **Fail signs:** a price read from the request body; a float money column; a replayed webhook that charges or
  ships twice; an order status the client sets.
- **n.a. when:** the app has no money, stock or multi-step state (cite the PRD scope).
- **Say it out loud:** "The client can lie about anything it sends, so the server recomputes every number that
  moves money, and the database refuses a second charge."

## Optional rows: add only when the HLD or the diff has the surface

- **CK-14 File handling (V5):** uploads checked by size and real type, stored outside the web root under generated
  names, never executed or served inline as HTML; downloads authorized like CK-03.
- **CK-15 APIs and webhooks (V4):** every API route authenticated and rate-limited; responses return only the
  fields the caller needs; inbound webhooks verify the signature with the provider's library, reject old
  timestamps (replay) and process each event id once.
- **CK-16 Tokens, OAuth and OIDC (V9, V10):** tokens checked on the server for signature, issuer, audience and
  expiry; OAuth flows use `state` and PKCE; refresh tokens stored server-side and encrypted; scopes requested are
  the minimum the FRs need (an EHR integration asks for the fewest patient scopes that work).

## LLM rows (OWASP Top 10 for LLM Applications 2025)

Fill only when step 5 found a model call. Each row: status, evidence, finding, the same as CK rows.

| Row | Ref | Pass means |
|---|---|---|
| LLM-01 Prompt injection | LLM01:2025 | Untrusted text (users, EHR notes, web pages, files) cannot change the instructions or trigger a tool without server-side checks; model output is treated as untrusted input. |
| LLM-02 Sensitive information disclosure | LLM02:2025 | Only the fields the HLD connection lists reach the provider; no secrets or unneeded PHI in prompts; provider data-retention terms recorded in a `D<n>`. |
| LLM-03 Supply chain | LLM03:2025 | Provider SDK pinned in the lockfile and audited; model id pinned in config, not "latest". |
| LLM-04 Data and model poisoning | LLM04:2025 | Fine-tune or retrieval sources are trusted, versioned and access-controlled; n.a. when the app neither trains nor retrieves. |
| LLM-05 Improper output handling | LLM05:2025 | Output is schema-validated before use and escaped for where it lands (HTML, SQL, shell, URLs). |
| LLM-06 Excessive agency | LLM06:2025 | Tools are least-privilege; a tool that writes, pays or sends needs a human confirmation and the caller's own authorization. |
| LLM-07 System prompt leakage | LLM07:2025 | No secrets, keys or access rules live only in the prompt; access control is enforced in code. |
| LLM-08 Vector and embedding weaknesses | LLM08:2025 | Retrieval filters by the caller's tenant and permissions before ranking; n.a. without retrieval. |
| LLM-09 Misinformation | LLM09:2025 | Claims shown to users are grounded and cited; health or supplement claims follow the PRD's review and disclaimer rules. |
| LLM-10 Unbounded consumption | LLM10:2025 | Max tokens, timeouts, per-user rate limits and a spend cap are set in code or provider config. |
