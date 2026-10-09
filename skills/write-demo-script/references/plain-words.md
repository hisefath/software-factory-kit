# Plain words (grade 6)

Read this in step 10, and whenever a sentence feels hard. The test for every line: **would a bright 12-year-old
who has never seen the product follow it on the first hearing, without pausing the video?** Graders, hiring
managers and engineers from other fields are busy; plain words are faster for them too, and they make you sound
sure of yourself in an interview.

## Rules

1. **One idea per sentence.** At most 15 words; aim for 8-10. Split on "and", "which", "so that".
2. **Say who does what.** Active voice, a person or the app as the subject: "The doctor picks a vitamin", not
   "A vitamin is selected".
3. **Concrete beats abstract.** "Ana gets her vitamins in 2 days" beats "improved fulfillment experience".
4. **Numbers as digits**, only from the Claims table, never rounded up ("41 of 42 tests", not "all tests").
5. **No hype.** Cut: revolutionary, seamless, robust, game-changing, cutting-edge, leverage, utilize, simply,
   just, magic. Show the result instead.
6. **No unexplained jargon.** First choice: swap it (table below). Second: keep it, add a `W` row, and say the
   meaning out loud the first time ("an EHR, the app a clinic uses for patient charts").
7. **Acronyms** are spelled out or swapped, every time they are new to the viewer.
8. **Speak at 150 words a minute** (2.5 a second) at most. After a result appears on screen, leave a beat of
   silence (`—` or a shorter line) so the viewer can see it.
9. **The first 5 seconds are the hook.** Never "Hi, I'm … and today I'll show you …". Open on the person and
   their pain, or the result: "Maria runs a clinic. Her patients wait two weeks for vitamins." (only if a
   claim backs it).
10. **On-screen text** is a caption, not a paragraph: at most 7 words, readable with the sound off.

## Swaps

| Instead of | Say |
|---|---|
| EHR / EMR | the app a clinic uses for patient charts |
| API | a way for two programs to talk |
| endpoint | a door into the app that other programs knock on |
| database | where the app keeps its records |
| authentication / OAuth / SSO | signing in safely |
| SMART on FHIR launch | our app opens inside the clinic's app, already signed in |
| authorization / permissions | who is allowed to do what |
| deploy / ship to production | put it online |
| CI pipeline | a robot that runs every test on every change |
| test suite passes | all the checks pass |
| integration | connecting to another app |
| webhook | a message one app sends another when something happens |
| latency | how long it takes |
| scalable | still fast when many people use it |
| idempotent | safe to do twice |
| migration | a change to how records are stored |
| PHI | private health details |
| tenant / multi-tenant | each clinic's own space |
| LLM / model | an AI that writes text |
| RAG / retrieval | the AI looks things up before it answers |
| agent / supervisor | an AI helper / the AI that hands out the work |
| architecture | how the parts fit together |

## Fixing a high grade

The estimate in `references/checks.md` (`grade`) is the Flesch-Kincaid grade: long sentences and long words push
it up. It is a heuristic — it miscounts some syllables — so treat it as a smoke alarm, not a judge:

- **Above 7.0: fix it.** Split the longest sentences first (`long` lists them), then swap 3+ syllable words.
- Product and domain names you must keep (a partner's name, "supplement") count too; make the sentences
  around them shorter instead of dropping the name.
- A low grade with a confusing line is still a fail. Read it aloud; if you stumble, rewrite it.

## Reading it aloud (the human's 10-minute check at G-demo)

1. Start a timer and read only the Voiceover column of the grader cut. Did you finish inside its target?
2. Read the social cut with the sound "off": only the On-screen text. Does the story still make sense?
3. Ask: which word would a 12-year-old ask about? Swap it or add a `W` row.
