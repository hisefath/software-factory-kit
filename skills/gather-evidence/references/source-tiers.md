# Source tiers and grading words

Loaded by `gather-evidence` at step 3. Grade every source the moment you read it.

| Tier | What counts | Can it carry a load-bearing claim? |
|---|---|---|
| **A** primary / official | the assignment or partner spec; official docs and API references; standards and specs (RFC, HL7/FHIR, W3C); regulation text; peer-reviewed papers; the source code, release notes or changelog of the thing itself | yes, alone |
| **B** reputable secondary | books; engineering blogs of the organisation that runs the system; recognised industry analyses; major publications; recorded conference talks | only with a second, independent B |
| **C** community / generated | forums, Stack Overflow, Reddit, personal blogs, Medium, vendor marketing claims (their docs stay A for how their own product works), any LLM output: Grok, ChatGPT, deep-research reports, your own memory | never; colour or a lead only |

- **Load-bearing** (`[LB]`): if the claim were false, a requirement, scope line, constraint or design option would
  change.
- **Independent:** different publishers, neither citing nor copying the other. Five pages repeating one press
  release are one source.
- **Read:** you opened the page or file and read the section that holds the claim. A search snippet, a result
  title, an AI overview, an inbox digest or another source's summary is not reading. Could not open it (paywall,
  403, JS-only, no web tool in this run): it is unread, goes in Gaps, and is never cited.
- **Dated:** versions, prices, limits and policies change. Record the date read and any "as of" or version the
  page states.
- **Your memory is not a source.** Use it to know where to look, then read and cite that.
- **Quoting a source is not recommending.** "FDA recommends X" in a finding reports what the source says; it is
  not your advice. Your own advice never appears anywhere in an R file.
