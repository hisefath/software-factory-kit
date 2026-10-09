# Silent success: how a test passes while the feature is wrong

Load at `define-acceptance` step 7. A red test today proves only that the feature is missing. The patterns below are
how the same test later turns green for the wrong reason. For every automated AT, name the patterns it is exposed
to and the guard it uses, and record each pattern once as an `SS-##` row.

## Three checks for every test

1. **Laziest-stub check.** Picture the laziest code that could pass the test: return the AE's literal value, always
   answer 200/201, always allow, echo the input back, or show the success message without saving anything. If any
   of those would pass, the test is too weak; strengthen it.
2. **Triangulation** (Kent Beck, *Test-Driven Development: By Example*, 2002). Give the same rule a second example
   with different numbers (2 × $18.00 → $36.00, and 3 × $7.25 → $21.75), so one hard-coded answer cannot pass both.
3. **Twin tests, live path first.** Every "refused" or "nothing happens" test has an "allowed" twin that differs
   in exactly one condition, and runs it first **in the same test**: the twin must succeed before the refusal is
   asserted. Without it, a test that expects "denied", 404 or "count stays 0" also passes when nothing is built (a
   greenfield app answers 404 to every unknown route) or when everything is broken. An exact refusal body (the
   `openapi.yaml` problem type, the `screens.md` copy) can replace the twin only when a missing route could not
   produce it. A refusal test that still passes today after this is deleted; its EDGE row reads
   `not tested: passes before the feature exists (<why>)`, plus `· BLOCKS G4` for an always-tested kind.

## Catalogue

| Pattern | What it looks like | Guard |
|---|---|---|
| Status-only assertion | `assertStatus(200)`, `expect(res.ok)` | Assert the AE's values in the body and the persisted state |
| Presence, not value | `assertNotNull($total)`, `assertSee('$')` | Assert the exact value (`$36.00`), and that a wrong value is absent |
| Message without effect | The success copy shows, nothing is saved | Read the store fresh after the action; the row count changed by exactly 1 |
| Mocked system under test | A component this system owns is faked | Fake only what is outside the system (partner API, payment, mail, clock), never an LLD component of this system |
| Tautological oracle | The expected value is computed with the same formula or code as production | Hard-code expected values from the AE, worked out by hand |
| Indistinct fixtures | Quantity 1, tax 0, a single patient, UTC everywhere, equal prices | Pick values where wrong logic gives a different answer: quantity ≥ 2, non-zero tax, a second patient and clinic present, a non-UTC zone |
| Conditional or looped assertion | `if ($x) { assert… }`, asserting inside a loop over a list that may be empty | Assert the count first; never assert inside an `if` |
| Swallowed failure | try/catch around the act or the assert; an un-awaited promise | No `catch` unless the test asserts that exception; await every async call |
| Not run at all | Wrong filename suffix, an `.only` elsewhere, skip/xfail/todo/incomplete markers, a `--filter` that matches nothing (or a directory outside the configured suites) and exits 0 with "No tests executed" | Every AT id appears in the red output; the single-test command is proven to exit non-zero on a missing id; the forbidden-marker grep below |
| Asserts nothing | `#[DoesNotPerformAssertions]`, `expectNotToPerformAssertions()`, an empty body | The forbidden-marker grep below; every test asserts the Then's values |
| Refusal passes on a missing path | "Another clinic's order → 404" or "out of stock → order count stays 0" passes before any code exists | The allowed twin succeeds first in the same test (own clinic's order → 200; in-stock order → count 1), then the refusal is asserted exactly |
| Test-mode bypass | Auth, CSRF, policies or a feature flag switched off in the test environment | Authorization tests run through the real middleware; the allowed twin proves the path works |
| Transaction-wrapped race | The test runs inside one database transaction, so locks and unique-key races never collide | Concurrency tests use separate connections or processes, or assert the database constraint directly |
| Leaking state | Passes only because an earlier test left data behind | Each test builds its own Given; run in random order if the runner supports it |
| Clock luck | Passes except near midnight, a daylight-saving change or a month end | Freeze the clock to a stated instant with the project's clock fake |
| Accept-anything snapshot | The first run writes the snapshot it then compares against | No snapshot assertions in acceptance tests |
| Over-broad match | `assertSee('Error')`, a loose regex, `toContain` on a whole page | Match the exact `screens.md` copy inside the named element |
| Order luck | Asserting an order the spec never defined, or not asserting one it did | Assert order only when an FR defines it; otherwise compare as sets |

## Forbidden markers

These make a test not run, or not able to fail. The Done-when grep in `SKILL.md` covers them; a hit is a place to
read, and only a non-marker you can name (a collection's `->skip(2)`) may stay.

| Framework | Markers |
|---|---|
| PHPUnit / Pest | `markTestSkipped`, `markTestIncomplete`, `#[DoesNotPerformAssertions]`, `expectNotToPerformAssertions(`, conditional `#[Requires…]` skips (`RequiresPhp`, `RequiresOperatingSystem`, `RequiresPhpExtension`…), `->skip(`, `->skipOnCi(`, `->skipOnWindows(`, `->skipOnMac(`, `->skipOnLinux(`, `->skipLocally(`, any other `->skip…(`, `->todo(`, a bare `todo(`, `->only(` |
| Jest / Vitest / Mocha / Playwright | `.skip(`, `.todo(`, `.only(`, `.fixme(`, `xit(`, `xtest(`, `xdescribe(`, `toMatchSnapshot` |
| pytest / unittest | `pytest.mark.skip`, `pytest.mark.skipif`, `pytest.mark.xfail`, `pytest.skip(`, `unittest.skip` |
| Go | `t.Skip(` |
| JUnit | `@Disabled`, `@Ignore`, `assumeTrue(`, `assumeThat(` |
| Any | `assertTrue(true)`, `expect(true)`, `assert True`, an empty test body |
