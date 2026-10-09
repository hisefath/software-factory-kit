---
name: record-demo
description: "Use when docs/demo/SCRIPT.md has status: approved (after G-demo) and its grader cut and social cut must be recorded, assembled and checked into upload-ready video, or when the human asked to re-take or re-cut a recorded shot. Produces docs/demo/SMOKE.md, docs/demo/RECORDING.md and docs/demo/out/ (grader and social *.mp4 and *.srt, thumb.png). Do NOT use for writing or changing the script or the post copy (use write-demo-script) or for fixing a defect the demo smoke finds (use fix-bug)."
disable-model-invocation: true
metadata:
  software-factory-kit: "0.1"
  phase: "18"
  gate: "none"
---

# record-demo

**Outcome:** both cuts of the approved `docs/demo/SCRIPT.md` are on video, every shot (`G-nn`, `S-nn`) as written,
its on-screen text rendered. `docs/demo/SMOKE.md` shows the target green before a single frame was shot;
`docs/demo/out/` holds `grader.mp4`, `social.mp4`, their `.srt` captions and `thumb.png`; `docs/demo/RECORDING.md`
(`status: ready-for-human`) proves how — every command run, tool versions, durations and checks. When the target is
red, a tool is missing or a shot cannot be made as written, the outcome is SMOKE.md and RECORDING.md with a
`blocked-…` status, no video, and nothing posted.

## You own / You never touch

- You own `docs/demo/SMOKE.md`, `docs/demo/RECORDING.md`, `docs/demo/out/**` and the gitignored scratch area
  `docs/demo/raw/**` (takes, sources, frames, the status snapshot) fully; you never edit `docs/demo/SCRIPT.md`,
  `docs/demo/POSTS.md`, app code, seeders, tests, `.gitignore`, `AGENTS.md`, `specs/**` or `.handoff/**`. A script
  problem becomes a `DEV-n` row; a missing ignore line is a stop.
- You own copying the script's Voiceover and On-screen text cells verbatim into captions, overlays and cards; you
  never reword, reorder, cut or add a claim, not even a "small fix". Changing what the video says or shows is
  write-demo-script's job and needs G-demo again.
- You own running tools that are already installed (`ffmpeg`, `ffprobe`, `vhs`, the project's own Playwright,
  `whisper-cli` with a model already on disk, `tesseract`), AGENTS.md's run command (background, stopped before you
  finish), its seed command after the human's explicit yes, and a Proof shot's command on camera; you never install,
  upgrade or download anything (`brew`, `npm i`, bare `npx`, `playwright install`, `pip`, a whisper model,
  `curl | bash`) and never seed, migrate or reset a shared environment.
- You own driving the app with the script's clicks as a synthetic demo user, credentials read from env vars named in
  AGENTS.md or the seeder and kept in memory; you never write a credential or session value down, sign in through a
  third-party identity provider, use a real person's account or data, or turn TLS verification off. A shot that
  needs a real sign-in is a human shot.
- You own looking at every sampled frame and recommending; you never declare the video clean on your own review.
  The human watches both cuts end to end at the STOP (nothing grades its own work).
- You own producing upload-ready files and an upload checklist; you never upload, post, schedule, log in to a
  platform, commit or push. The human uploads and posts.

## Inputs

Read these before writing; record each in RECORDING.md §2 with its version.

| Input | Needed | If missing or wrong |
|---|---|---|
| `docs/demo/SCRIPT.md`: frontmatter `status: approved`; committed (`git status --porcelain -- docs/demo/SCRIPT.md` prints nothing); `## Grader cut` and `## Social cut` shot tables; `### 3. Demo beats`; `### 5. Proof` | always | Stop: "docs/demo/SCRIPT.md is not approved (status: <value>). record-demo only shoots an approved script: run write-demo-script, review it, flip `status: approved` at G-demo and commit, then run me again." Uncommitted edits → stop: "SCRIPT.md changed after approval; commit it and re-confirm G-demo." |
| G-demo row in `.handoff/TRACKER.md ## Approvals` (read-only) | if present | Present and stale (step 1) → stop: "G-demo approval is stale (approved @<X>, script now @<Y>); re-approve G-demo." Absent → carry `⚠ no G-demo Approvals row` into the STOP. |
| `docs/demo/POSTS.md`: platforms, which cut each gets | if present | Interview question 4. |
| `AGENTS.md`: Commands (run locally), Project specifics (demo accounts, sign-in screen) | always | Stop: "AGENTS.md is missing; run scripts/init-repo.sh first." |
| How demo data is made (local target): a seed or demo-data command in AGENTS.md, else a seeder or fixture file you cite `path:line` and propose a command for | always | Neither → `Q-n` row, stop: "I can't find how this project makes synthetic demo data. Add a seed command to AGENTS.md (or name it), then run me again." |
| `M<N>` = the last entry of SCRIPT.md `shipped:`; its `MILESTONES.md` row has status `merged` or `done` and a merge SHA | always | Stop: "M<N> has no merged row with a merge SHA in MILESTONES.md, so I can't prove which code is on screen." |
| `specs/M<N>-*/acceptance.md ## Demo smoke` | always | Absent, target deployed and `scripts/smoke.sh` exists → run that alone, mark ⚠. Otherwise stop: "No demo smoke list exists (define-acceptance writes one). I won't record a product nobody has checked." |
| `docs/milestones/M<N>.md` (the Proof shots' command, result and SHA) | when a Proof shot is planned | Stop: "The Proof shot has no milestone report to check against; run report-milestone first." |
| `scripts/smoke.sh` (written by ship-milestone; https only) | deployed target | Local target → SMOKE.md §3 "not applicable". Absent → "none". |
| `docs/design/screens.md ## Demo layout` | if present | Context only; SCRIPT.md wins every difference. |
| `docs/demo/RECORDING.md`, `docs/demo/out/` | if present | Re-run: keep every id, overwrite only what changed, add a run-history line. |
| `references/recipes.md` (commands, sources, cards), `references/checks.md` (platforms, privacy, captions) | at steps 2-12 | — |

## The one rule

Shoot only what the approved script says, shot by shot in both cuts, on a target proven green and filled only with
synthetic data, and back every claim about the video — length, resolution, nothing secret or patient-identifying
on screen — with a command's output or a frame you looked at.

## Steps

1. **Clock, gate, snapshot.** Run `date`. `git check-ignore -q docs/demo/raw/probe` must exit 0, else stop:
   "docs/demo/raw/ is not gitignored, so raw takes could land in a public repo. Supervisor: add `docs/demo/raw/` to
   .gitignore (scripts/init-repo.sh does this), then run me again." Then `mkdir -p docs/demo/raw && git status --porcelain
   --untracked-files=all > docs/demo/raw/.before-status.txt`. Check the script:
   `awk 'NR==1&&/^---$/{f=1;next} f&&/^---$/{exit} f' docs/demo/SCRIPT.md | grep -qx 'status: approved'`. If a G-demo
   row exists, take its SHA (`grep -E '^\|[^|]*\| *G-demo *\|' .handoff/TRACKER.md | tail -1 | grep -oE
   'SCRIPT\.md@[0-9a-f]{7,40}' | cut -d@ -f2`); `git diff --quiet <it> HEAD -- docs/demo/SCRIPT.md` must exit 0,
   else the approval is stale. Pass every "always" row of Inputs or stop with its message. Script SHA =
   `git log -1 --format=%h -- docs/demo/SCRIPT.md`.
2. **Plan the shots.** Read every input and both shot tables. For each shot note cut, part, time range, Screen /
   URL, Action, and the Voiceover and On-screen text cells verbatim. Give it a **source** (the footage it is cut
   from): a Demo shot → its beat `B<n>` from `### 3. Demo beats`, recorded once and trimmed into both cuts; any other
   shot → its own id, or the other cut's shot with the same Screen / URL and Action (reuse it). Give each source a
   kind (`references/recipes.md` §0): **browser** (the app), **terminal** (a command, e.g. a Proof re-run),
   **static** (a page outside the app: rendered diagram, milestone report, README; or a plain card) or **human** (a
   person on camera, or a screen behind a real sign-in). Classify, never rewrite. A shot that cannot be made as
   written gets a `DEV-n` (§9). **Blocking rule:** a DEV whose Needs is `write-demo-script revision` → finish
   planning, record nothing, write both files (SMOKE.md `Verdict: NOT RUN`), use STOP D. Timing-only and platform
   DEVs → continue.
3. **Interview the gaps.** Ask only what SCRIPT.md, POSTS.md and AGENTS.md do not answer, **one question per reply,
   each with a recommended answer and its tradeoff in plain words**, at most 5, in this order. Unanswered → use the
   recommendation, label it `assumed`, add a `Q-n` row — except question 1: seeding wipes data, so wait for the
   human's own words.

   | # | Question | Recommended answer (and the tradeoff to explain) |
   |---|---|---|
   | 1 | Which target do we record, and may I run the seed command (it resets the local database)? | The local app at M<N>'s code, started with AGENTS.md's run command and seeded with the seed command. You control synthetic data and can reset it between takes. A deployed URL proves "this is live", but you cannot reset it and any real record could leak; anything touching patients is never recorded where real records might exist. |
   | 2 | Voice-over after the picture, live narration, or captions only? | Voice-over after picture lock, one read per cut, plus captions. The picture can be re-shot without re-recording the voice; a human shot with live speech keeps its sound and the reader stays silent over it. Live narration of everything needs perfect takes; captions only is fastest but flat. |
   | 3 | Captions as a sidecar `.srt`, burned in, or both? | Both: the `.srt` for platforms that accept caption files (viewers toggle it, search engines read it), a burned copy for feeds that autoplay muted. Burned text cannot be turned off or fixed without re-encoding. |
   | 4 | Which platforms get which cut, with which length limits? | Grader cut → the assignment submission; social cut → POSTS.md's platforms (X, LinkedIn), with `references/checks.md` §1 defaults; the assignment's own limit wins. Limits change, so each length row (CHK-1a, CHK-1b, …) records where and when it was checked. |
   | 5 | Frame shape and thumbnail? | 1920×1080 (16:9) at 30 fps; thumbnail = the success screen of the spine story. Vertical 9:16 only if a listed platform needs it: cropping a desktop UI makes its text unreadable. |

4. **Bring the target up and prove what it runs.** *Local:* start AGENTS.md's run command in the background (log
   it as a CMD-n with its PID); after the human's yes to question 1, run the seed command. Prove the code is M<N>'s
   in one shell call (`<merge-sha>` from MILESTONES.md; the excludes are docs and records written after the merge):

   ```
   X=(':(exclude)docs' ':(exclude)specs' ':(exclude).handoff' ':(exclude)MILESTONES.md' ':(exclude)README.md' ':(exclude)ARCHITECTURE.md' ':(exclude)scripts/smoke.sh' ':(exclude).gitignore')
   git merge-base --is-ancestor <merge-sha> HEAD && git diff --name-only <merge-sha> HEAD -- . "${X[@]}" && git status --porcelain -- . "${X[@]}"
   ```

   Match = exit 0 and nothing printed. *Deployed:* `curl --fail --silent --show-error --proto '=https'
   <url>/version` must show the merge SHA. Read the seeder or fixture source and confirm every on-screen record is
   synthetic (cite `path:line`). Fill SMOKE.md §1-§2. No match or real data → SMOKE.md RED, STOP B.
5. **Demo smoke, before any frame.** Deployed https target only: `bash scripts/smoke.sh <url> <merge-sha>`, paste its
   last line (a local target writes §3 "not applicable"). Walk each `## Demo smoke` step as `SMK-<n>` (n = its step
   number): with a throwaway headless Playwright script (`docs/demo/raw/smoke/walk.*`, one screenshot per step) when
   Playwright is installed, otherwise ask the human to walk it and record their exact words. A step passes only with
   evidence. Write the verdict in SMOKE.md §5 (its guide has the GREEN rule). Red → RECORDING.md
   `status: blocked-smoke-red`, STOP B.
6. **Inventory the tools** (`references/recipes.md` §1) for the kinds you planned: always `ffmpeg`, `ffprobe` and,
   when any On-screen text cell is not `—`, an overlay filter (`ass`, `subtitles` or `drawtext`); browser or static →
   Playwright plus one test browser launch; terminal → `vhs` and `ttyd`; optional `whisper-cli` with a model on disk
   and `tesseract`. Record each in RECORDING.md §3. A required tool missing → STOP C.
7. **Pick a tool per source and teach the choice.** Tell the human one sentence per source and write it in §4:
   - **browser or static → Playwright video.** Repeatable, a re-take costs nothing, and it records only the page, so
     tabs, bookmarks and the address bar cannot leak. Tradeoff: no mouse pointer and a softer image, so hold each
     screen at least 2 s after an action. A plain card is made by ffmpeg alone.
   - **terminal → VHS tape.** Crisp text at a steady typing speed, re-run from a file. Tradeoff: a fresh shell shows
     whatever it prints, so set a neutral prompt in a hidden block and never print env or config.
   - **human → QuickTime or Screen Studio.** A real voice and real judgment. Tradeoff: it records the whole screen and
     every re-take costs the human time, so it gets a shot card with a hygiene checklist.
8. **Write the sources** in `docs/demo/raw/src/` from `references/recipes.md` §2-§3 (1920×1080, state reset before
   each take, holds sized to the longest range that uses the source, credentials from env var names, sign-in
   details from AGENTS.md or the app's own views cited `path:line`). Embed each verbatim in RECORDING.md §5.
9. **Record.** Run each source; takes go to `docs/demo/raw/<source>/take-<k>.<ext>`. Log every command as `CMD-n`
   in §11 (time, exit code, `ffprobe` duration). At most 3 takes per scripted source; still wrong → `DEV-n` (and the
   blocking rule of step 2). A Proof re-run whose result differs from SCRIPT.md §5 is a DEV needing a script
   revision. For each human source send the shot card (`references/recipes.md` §4) and wait for "<source> saved".
10. **Review the takes.** Extract frames (`references/recipes.md` §5) to `docs/demo/raw/frames/<source>/` and open
    every one: does it match the shots, and does it show anything on the privacy list in `references/checks.md` §3?
    Pick one take per source. A take showing a secret or real data is `quarantined` in §4, never used; ask the human
    to delete it, and to rotate the secret if it is real.
11. **Assemble each cut** with `references/recipes.md` §5, grader then social: trim each shot from its source's pick
    inside the shot's range, concat in shot order, burn the On-screen text cells at their shots' final ranges (that
    is the picture lock), send the voice-over card and mix the read (`references/recipes.md` §4-§5), final mux to
    `out/<cut>.mp4`, then `out/<cut>.srt` from the Voiceover cells verbatim, timed from the recorded audio. Burn
    `out/<cut>-captioned.mp4` if question 3 says so. Grab `out/thumb.png`. Make `out/<cut>-<shape>.mp4` only for a
    platform that needs a different shape.
12. **Check** every row of RECORDING.md §8 (`references/checks.md`): one length row per platform from `ffprobe`,
    codec and resolution, audio, captions and their timing, a frame review of each final cut (one every 2 s into
    `docs/demo/raw/frames/final/<cut>/`), on-screen text, the OCR sweep if `tesseract` exists, the secret grep, file
    size, raw footage ignored. Over a platform's limit: trim holds within the script's ranges only; still over →
    that platform is ✗ plus a `DEV-n`. Never speed up footage or drop a line.
13. **Write and close.** Stop the background app server (`kill <PID>`, logged as a CMD-n). Fill RECORDING.md
    (status, upload checklist per platform in §10), run every Done-when check, fix what fails, send one STOP variant
    and stop.

## Output

- `docs/demo/SMOKE.md` and `docs/demo/RECORDING.md`: fill the two parts of `assets/template.md` (each starts at a
  `<!-- file: <path> -->` line; copy the part without that line). Every heading stays, in order; every `{{…}}` is
  replaced; every `<!-- guide:` comment is deleted. Unknowns are `⚠ <question>` with a `Q-n` row, never invented.
- `docs/demo/out/`: `grader.mp4`, `grader.srt`, `social.mp4`, `social.srt`, `thumb.png` (not when blocked);
  `<cut>-captioned.mp4` and `<cut>-<shape>.mp4` only when questions 3 and 5 call for them. Nothing else goes in `out/`.
- Ids: `SMK-n`, `CMD-n`, `CHK-n` (length rows `CHK-1a`, `CHK-1b`, …), `DEV-n`, `Q-n`; shots and beats keep SCRIPT.md's
  ids. Never renumber; retire with `~~ID~~ (removed <date>: reason)`. Scratch lives only in `docs/demo/raw/`. The
  supervisor commits; you do not.

## Done when

Run from the project root; `S=docs/demo/SMOKE.md R=docs/demo/RECORDING.md O=docs/demo/out B=docs/demo/raw/.before-status.txt`.
Rows marked *video* apply to STOP A only.

- [ ] Files exist: `test -f $S && test -f $R`; *video*: `for f in grader.mp4 grader.srt social.mp4 social.srt thumb.png; do test -f $O/$f || echo "missing $f"; done` prints nothing.
- [ ] Headings: `grep -cE '^## [1-5]\. ' $S` prints `5`; `grep -cE '^## ([1-9]|1[0-2])\. ' $R` prints `12`.
- [ ] Filled: `grep -nE '\{\{|<!-- (guide|file):' $S $R` prints nothing.
- [ ] Frontmatter is valid YAML (no unquoted `: ` inside a value): `for f in $S $R; do awk 'NR>1&&/^---$/{exit} NR>1' $f | grep -E '^[a-z_]+: [^"].*: '; done` prints nothing.
- [ ] Script untouched: `git status --porcelain -- docs/demo/SCRIPT.md docs/demo/POSTS.md` prints nothing.
- [ ] *video* — smoke was green: `grep -c '^Verdict: GREEN' $S` prints `1`.
- [ ] Every shot planned: `ids(){ grep -oE '^\| [GS]-[0-9]{2} ' "$@" | grep -oE '[GS]-[0-9]{2}' | sort -u; }`, then
      `comm -23 <(ids docs/demo/SCRIPT.md) <(awk '/^## 4\./,/^## 5\./' $R | ids)` prints nothing.
- [ ] Every source has its block: `src(){ grep -oE '^(\| |### )(B[0-9]+|[GS]-[0-9]{2})' | grep -oE '(B[0-9]+|[GS]-[0-9]{2})$' | sort -u; }`, then
      `comm -23 <(awk '/^### Sources/,/^### Grader cut/' $R | src) <(awk '/^## 5\./,/^## 6\./' $R | src)` prints nothing.
- [ ] *video* — spec: `for f in $O/*.mp4; do ffprobe -v error -select_streams v:0 -show_entries
      stream=codec_name,width,height,pix_fmt,avg_frame_rate -of csv=p=0 $f; done` prints `h264,1920,1080,yuv420p,30/1`
      per file (or the shape question 5 set), and §7 shows the same strings.
- [ ] *video* — captions end inside each cut: `for c in grader social; do echo "$c $(awk -F' --> ' '/-->/{e=$2} END{split(e,a,/[:,]/); print a[1]*3600+a[2]*60+a[3]+a[4]/1000}' $O/$c.srt) $(ffprobe -v error -show_entries format=duration -of csv=p=0 $O/$c.mp4)"; done`
      shows the first number ≤ the second on both lines.
- [ ] *video* — thumbnail: `ffprobe -v error -show_entries stream=width,height -of csv=p=0 $O/thumb.png` prints `1280,720`.
- [ ] *video* — size: `find $O -type f -size +50M` prints nothing (or a CHK-8 row says why and stays under 100 MB).
- [ ] *video* — frames reviewed: `find docs/demo/raw/frames/final -name '*.png' | wc -l` equals the count in CHK-5.
- [ ] No secrets: `grep -nEi '(password|secret|token|api[_-]?key)[[:space:]]*[:=][[:space:]]*[^[:space:]<{⚠|]{8,}|[a-z]+://[^/[:space:]:@]+:[^@[:space:]]+@|BEGIN [A-Z ]*PRIVATE KEY' $S $R $O/*.srt`
      prints nothing (a variable *name* is fine, a value never is).
- [ ] Raw stays local: `git check-ignore -q docs/demo/raw/probe` exits 0 and
      `git status --porcelain --untracked-files=all docs/demo/raw` prints nothing.
- [ ] Ids defined once: `grep -ohE '^\| (SMK|CMD|CHK|DEV|Q)-[0-9]+[a-z]? ' $S $R | sort | uniq -d` prints nothing.
- [ ] App server stopped: the PID from step 4 is gone (`kill -0 <PID>` fails), or no server was started.
- [ ] Only your files changed: `test -f $B || echo "snapshot missing"; git status --porcelain --untracked-files=all |
      diff $B - | grep '^>' | grep -vE ' docs/demo/(SMOKE\.md|RECORDING\.md|out/)'` prints nothing.

## STOP

Fill the brackets from pasted output (durations and sizes from `ffprobe` and `wc -c`, never memory), send exactly
one variant, and stop. This phase has no gate id: WORKFLOW.md §4 row 18 ends with "human uploads and posts".

**A — recorded and checked:**

```
record-demo (<date>): recorded docs/demo/SCRIPT.md@<sha> against <target> (app @ <short sha>).
Wrote: docs/demo/SMOKE.md (GREEN, <p>/<n> steps), docs/demo/RECORDING.md, docs/demo/out/<files>
Grader cut: grader.mp4 <m:ss> of <target> · <g> shots   Social cut: social.mp4 <m:ss> of 2:00 · <s> shots
Both: <WxH> · <fps> fps · captions <sidecar | sidecar + burned>, timed by <whisper | silence detection | shot ranges>
Fits: <platform> (<cut>) <m:ss> of <limit> ✓|✗ · …
Checks: <p>/<n> CHK pass · frames I reviewed: <f> · deviations: <DEV-n, … | none> · <⚠ no G-demo Approvals row>
Not verified: <list | none>

Human step (no gate id) — "Watch both cuts end to end, the social cut once muted: is every claim true, do the
captions match the voice, is nothing secret or patient-identifying on screen, and are they ready to post?"
  Approve — you upload and post yourself (RECORDING.md §10, POSTS.md); the supervisor records your words and runs
            log-decision. Cost: once posted, a mistake is public, so watch first.
  Revise — name the shot and the problem (e.g. "G-03 holds too long"); I re-take or re-cut only that. Cost: one
           more run (minutes for a scripted shot, your time for a human one). Changing what the video says or
           shows is a script change: write-demo-script, then G-demo again.
  Stop — the files stay unposted. Cost: no video for the submission or the posts.
Recommendation: <Approve | Revise: what>, because <plain words>.
Next skill: quiz-me — rehearse defending every decision this demo shows before it goes public. I will not start it.
```

**B — target not demo-ready (smoke red, code is not M<N>'s, or real data):**

```
record-demo (<date>): NOT recorded — <target> is not demo-ready: <SMK-n red | code differs from M<N> | real data>.
Wrote: docs/demo/SMOKE.md (RED), docs/demo/RECORDING.md (blocked-smoke-red)
Failing: <SMK-n — expected "<…>", saw "<…>" | changed since <merge sha>: <paths> | <data> from <source>, not synthetic>
Recording a red product would put a broken or unproven claim on video.
  Approve — take the fix route in "Next", then run record-demo again. Cost: the fix time; no video meanwhile.
  Revise — you judge the check wrong: say which and why, in your words. A wrong SMK step is marked `waived: "<your
           words>"` (the merged acceptance.md stays unchanged; a corrected step goes into the next milestone's
           acceptance); a newer shipped SHA or your statement of where the data comes from goes into §1-§2. Then I
           re-run the smoke. Cost: the video ships with a check you overrode, on your word.
  Stop — no recording. Cost: no video.
Recommendation: <Approve | Revise>, because <plain words>.
Next skill: <fix-bug — SMK-n is its red repro | fix-bug — make <seeder path> synthetic | none: you record from
M<N>'s merged code (a worktree at <merge sha>) or tell me the newer shipped SHA>. I will not start it.
```

**C — tools missing (nothing installed by me):**

```
record-demo (<date>): NOT recorded — required tools are missing.
Wrote: docs/demo/SMOKE.md (<GREEN | RED>), docs/demo/RECORDING.md (blocked-tools-missing, §3)
Missing: <tool — needed for <source ids> — the install command you would run>
  Approve — you install them yourself, then run me again. Cost: minutes; a project dev dependency such as
            Playwright is an "ask first" change, so log-decision records it.
  Revise — I re-plan those sources as human screen recordings. Cost: no new tools, but every re-take costs your
           time (impossible for ffmpeg: nothing can be assembled without it).
  Stop — no video. Cost: no video for the submission or the posts.
Recommendation: <Approve | Revise>, because <plain words>.
Next skill: record-demo — run it again after the installs or the re-plan answer. I will not start anything.
```

**D — a shot cannot be made as written (any DEV needing a script revision):**

```
record-demo (<date>): NOT recorded — the approved script asks for something the app or the clock cannot give.
Wrote: docs/demo/SMOKE.md (<GREEN | RED | NOT RUN>), docs/demo/RECORDING.md (blocked-script, §9)
<DEV-n: <shot ids> — script says "<…>", the app <does/shows> "<…>">
I recorded nothing further and did not change the script.
  Approve — revise those shots in write-demo-script, then flip status: approved again at G-demo. Cost: one script
            pass and a re-approval; the video stays true.
  Revise — tell me how to shoot it inside the current words (e.g. a different seeded record); I re-plan. Cost:
           nothing to the script, and it works only if every word still holds.
  Stop — no recording. Cost: no video.
Recommendation: <Approve | Revise>, because <plain words>.
Next skill: write-demo-script — revise <shot ids> only. I will not start it.
```

## Red flags

| Thought you might have | What to do instead |
|---|---|
| "This caption or on-screen text reads badly; I'll tidy the wording." | Both are the script's words, verbatim. Write a `DEV-n`; wording changes go through write-demo-script and G-demo. |
| "The social cut is just the grader cut trimmed to 2:00." | It has its own shots, words and on-screen text. Reuse beat footage; assemble S-01… from the Social cut table. |
| "ffmpeg isn't installed, but `brew install` is one line." | Never install. List what is missing with the command the human would run, and use STOP C. |
| "One smoke step is red, but the demo path still works." | A red smoke means the video could show a broken product. Use STOP B; the red step is fix-bug's repro, and only the human's words can waive it. |
| "The deployed site has nicer data; I'll record there." | Real data on screen can be PHI. Record synthetic seeded data on a target you control, unless the human confirms in words that the deployed data is synthetic. |
| "I checked the frames and it's clean, so it's ready to post." | Your review is evidence, not the verdict. The human watches both cuts end to end at the STOP, and only the human uploads and posts. |
