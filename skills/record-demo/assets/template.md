<!-- guide: record-demo output skeleton. Two parts, each starting at a `<!-- file: <path> -->` line; copy each part
to its path without that line. Keep every heading, in order; replace every {{…}}; delete every guide comment.
Ids: SMK-n demo smoke steps (n = the step number in acceptance.md ## Demo smoke) · CMD-n commands (logged in
RECORDING.md §11, referenced from both files) · CHK-n checks (length rows CHK-1a, CHK-1b, …) · DEV-n deviations from
the script · Q-n open questions · shots (G-01…, S-01…) and beats (B1…) keep SCRIPT.md's ids. Never renumber; retire
with ~~ID~~ (removed <date>: reason). Unknowns are ⚠ <question> plus a Q-n row. Times come from `date`; durations,
sizes and counts from commands. Credentials appear as env var NAMES only; never a value, never real personal or
patient data. Frontmatter is YAML: a value containing ": " or "#" is double-quoted. -->

<!-- file: docs/demo/SMOKE.md -->
---
artifact: demo-smoke
script: "docs/demo/SCRIPT.md@{{short sha}} (status approved)"
milestone: {{M<N>}}
target: "{{local http://localhost:<port> | deployed https://<host>}}"
checked: "{{output of date}}"
checker: "record-demo ({{harness}}, {{model id}})"
---

# Demo smoke — {{project name}}

Checked before any recording. A RED verdict means no frame is shot.

## 1. Target

| Item | Value | Evidence |
|---|---|---|
| Target | {{url}} | interview Q1: "{{exact words}}" |
| Expected SHA | {{full merge SHA of M<N>}} | `MILESTONES.md` row {{M<N>}} (status {{merged \| done}}) |
| Running code | {{full sha}} | CMD-{{n}}: {{deployed: `curl --fail --silent --show-error --proto '=https' <url>/version` → pasted JSON \| local: `git merge-base --is-ancestor <merge sha> HEAD` exit 0; `git diff --name-only <merge sha> HEAD` and `git status --porcelain`, both outside docs and post-merge records, printed nothing}} |
| Match | {{yes \| no: <changed paths>}} | — |

## 2. Data check

<!-- guide: Prove every record that will be on screen is synthetic. Cite the seeder or fixture by path:line; never
paste a real value. One row per kind of data the shots show (patients, orders, products, users). -->

| Data on screen | Source | Synthetic because | Evidence |
|---|---|---|---|
| {{e.g. patients}} | {{e.g. database/seeders/DemoSeeder.php}} | {{e.g. "Test Patient" names, example.com emails, 555-01xx phones}} | {{path:line}} |

- Seed command: `{{command from AGENTS.md, or proposed from the seeder at path:line}}` (CMD-{{n}}, exit {{code}}), run after the human's "{{exact words}}" {{| not run: deployed target, data confirmed synthetic by the human: "exact words"}}
- Demo accounts: {{env var names, e.g. DEMO_EMAIL, DEMO_PASSWORD}} (names only)
- Real-data risk: {{none: local synthetic seed | ⚠ <what could be real and why>}}

## 3. Automated smoke

- Command: `{{bash scripts/smoke.sh <https url> <merge sha>}}` (CMD-{{n}}) {{| not applicable: local target (scripts/smoke.sh requires https); SMK walk only | none: scripts/smoke.sh absent}}
- Last line: `{{pasted last line | —}}` · exit {{code | —}}

## 4. Demo smoke steps

Source: `{{specs/M<N>-<slug>/acceptance.md}}` ## Demo smoke @ {{short sha}}, walked as a person does it.

| Step | Do (verbatim) | Expected (verbatim) | Seen | Result | Checked by | Evidence |
|---|---|---|---|---|---|---|
| SMK-1 | {{step text}} | {{expected text}} | {{what actually showed}} | {{pass \| fail \| waived: "the human's exact words"}} | {{agent (Playwright) \| human}} | {{docs/demo/raw/smoke/SMK-1.png (local, gitignored) \| "exact words"}} |

Walk script (verbatim; credentials as env var names):

```{{js | python | text}}
{{the throwaway Playwright script, or: none — walked by the human}}
```

## 5. Verdict

Verdict: {{GREEN | RED | NOT RUN}} — {{p}}/{{n}} steps pass{{; w waived}}{{; first red: SMK-n | §1 code mismatch | §2 real data | not run: blocked by DEV-n before the smoke}}
<!-- guide: The line above must start exactly `Verdict: GREEN`, `Verdict: RED` or `Verdict: NOT RUN` (only when a
blocking DEV stopped the run at step 2; then §1-§4 say "not run"). GREEN only when §1 matches, §2 has no
real-data risk, §3 passed (or is "not applicable: local target", or "none" with the ⚠ from Inputs), and every SMK row
is pass or waived with the human's exact words. A waiver never changes acceptance.md (specs are immutable after
merge); a corrected step belongs in the next milestone's acceptance. -->

- {{GREEN: the target runs M<N>'s code, its data is synthetic and every step passed, so recording may start.
  | RED: <what was expected vs what was seen>. Nothing was recorded.}}
- Not checked: {{list | none}}

<!-- file: docs/demo/RECORDING.md -->
---
artifact: demo-recording
status: {{ready-for-human | blocked-smoke-red | blocked-tools-missing | blocked-script}}
script: "docs/demo/SCRIPT.md@{{short sha}} (status approved; G-demo Approvals row {{time | ⚠ none}})"
target: "{{url}} @ {{running short sha | not started}} (docs/demo/SMOKE.md {{GREEN | RED | NOT RUN}})"
recorded: "{{output of date}}"
recorder: "record-demo ({{harness}}, {{model id}})"
run: {{k}}
---

# Demo recording — {{project name}}

## 1. Summary

{{2-3 plain sentences: what was recorded, how long each cut runs, what is left for the human. Write this last.}}

- **Files:** {{docs/demo/out/grader.mp4 (m:ss, WxH, MB), grader.srt, social.mp4 (m:ss, WxH, MB), social.srt, thumb.png, <cut>-captioned.mp4 | none: blocked}}
- **Fits:** {{platform (cut) m:ss of limit ✓ | ✗}} · {{…}}
- **Checks:** {{p}}/{{n}} CHK pass · frames reviewed: {{f}} · deviations: {{DEV-n, … | none}}
- **Left for the human:** watch both cuts end to end with sound (the social cut once muted), then upload and post (§10)
- **Run history:** {{run k — date — what changed (e.g. re-took B3, re-cut S-04)}}

## 2. Inputs read

| Input | Version | Used for |
|---|---|---|
| docs/demo/SCRIPT.md | @{{short sha}} | shots, beats, words, on-screen text, captions |
| .handoff/TRACKER.md ## Approvals (G-demo) | {{row time, artifact@sha \| ⚠ none}} | approval fresh: `git diff --quiet <sha> HEAD -- docs/demo/SCRIPT.md` → {{0}} |
| docs/demo/POSTS.md | @{{short sha \| absent}} | platforms, which cut each gets, upload copy |
| MILESTONES.md row {{M<N>}} | @{{short sha}} | merge SHA |
| {{specs/M<N>-<slug>/acceptance.md}} ## Demo smoke | @{{short sha}} | SMOKE.md §4 |
| {{docs/milestones/M<N>.md}} | @{{short sha \| not needed: no Proof re-run}} | Proof shots: command, expected result |
| AGENTS.md | @{{short sha}} | run and seed commands, demo accounts, sign-in screen |
| {{scripts/smoke.sh}} | @{{short sha \| not applicable: local \| absent}} | SMOKE.md §3 |
| {{docs/design/screens.md}} ## Demo layout | @{{short sha \| absent}} | context only |

Not read: {{path — why | none}}

## 3. Tools

| Tool | Version (pasted) | Command | Used for | Status |
|---|---|---|---|---|
| ffmpeg | {{first line}} | `ffmpeg -version` (CMD-{{n}}) | trim, concat, encode, captions, frames | {{present \| missing}} |
| ffmpeg overlay filter | {{ass \| subtitles \| drawtext}} | `ffmpeg -hide_banner -filters` (CMD-{{n}}) | on-screen text, burned captions | {{present \| missing \| not needed: no on-screen text}} |
| ffprobe | {{first line}} | `ffprobe -version` (CMD-{{n}}) | durations, specs, checks | {{present \| missing}} |
| Playwright + browser | {{version; launch ok}} | `./node_modules/.bin/playwright --version` (CMD-{{n}}) | browser and static sources, smoke walk | {{present \| missing \| not needed}} |
| VHS + ttyd | {{versions}} | `vhs --version`; `ttyd --version` (CMD-{{n}}) | terminal sources | {{present \| missing \| not needed}} |
| QuickTime Player / Screen Studio | human-operated | — | human sources, voice-over | {{used \| not needed}} |
| whisper-cli + model | {{version; model path}} | `command -v whisper-cli`; `ls -l <model>` (CMD-{{n}}) | caption timing, spoken-words check | {{present \| absent: timed by silence detection}} |
| tesseract | {{first line}} | `tesseract --version` (CMD-{{n}}) | OCR sweep of frames | {{present \| absent}} |

Missing and required: {{none | tool — needed for <source ids> — install command for the human (not run by record-demo)}}

## 4. Shots

<!-- guide: Sources = the footage, recorded once: one row per beat (B<n>, shared by both cuts) and per other shot that
needs its own footage (its shot id). Kind: browser | terminal | static | human. Then one row per SCRIPT.md shot, in
script order, in each cut table. The words stay in SCRIPT.md; these tables only say how each shot was made. Ranges
as m:ss.s. -->

### Sources

| Source | Kind | Tool (why, one line) | Used by | Takes | Picked | Raw length |
|---|---|---|---|---|---|---|
| {{B1}} | {{browser}} | {{Playwright — repeatable; records the page only}} | {{G-03, S-03}} | {{2}} | {{take-2}} | {{0:17.4}} |

Quarantined takes (secret or real data on screen; never used; the human deletes them): {{path — what — CHK-n | none}}

### Grader cut

| Shot | Part | Script range | Source | In → out (in the source) | Final range | On-screen text |
|---|---|---|---|---|---|---|
| G-01 | {{Hook}} | {{0:00-0:05}} | {{G-01}} | {{0:00.4 → 0:05.4}} | {{0:00.0-0:05.0}} | {{rendered \| — (none in script)}} |

### Social cut

| Shot | Part | Script range | Source | In → out (in the source) | Final range | On-screen text |
|---|---|---|---|---|---|---|
| S-01 | {{Hook}} | {{0:00-0:05}} | {{G-01 (reused)}} | {{0:00.4 → 0:05.4}} | {{0:00.0-0:05.0}} | {{rendered}} |

## 5. Sources

<!-- guide: Every source's script, tape or command, verbatim, so anyone can re-shoot it from this file. Human
sources: the shot card exactly as sent. Credentials as env var names only. One ### block per §4 Sources row, headed
by its source id. -->

### {{B1}} — {{Playwright | VHS | still | card | shot card}}

```{{js | tape | sh | text}}
{{verbatim source}}
```

## 6. Assembly

| Step | Grader cut | Social cut | What it did |
|---|---|---|---|
| Normalize + trim | CMD-{{n}} … CMD-{{m}} | CMD-{{n}} … CMD-{{m}} | {{one clip per shot: 1920×1080, 30 fps, yuv420p, AAC 48 kHz stereo; silent track unless the shot has live sound}} |
| Concat | CMD-{{n}} | CMD-{{n}} | {{docs/demo/raw/<cut>-concat.mp4, m:ss}} |
| On-screen text (picture lock) | CMD-{{n}} | CMD-{{n}} | {{<k> cells burned from docs/demo/raw/<cut>-ost.ass \| none in script}} |
| Voice-over | CMD-{{n}} | CMD-{{n}} | {{read once against the picture lock, mixed with live sound, loudnorm I=-16 \| none: captions only}} |
| Final mux | CMD-{{n}} | CMD-{{n}} | {{faststart, metadata stripped}} |
| Captions | CMD-{{n}} | CMD-{{n}} | {{<c> cues from the Voiceover cells verbatim, timed by whisper \| silence detection \| shot ranges}} |
| Burned copy | CMD-{{n}} | CMD-{{n}} | {{<cut>-captioned.mp4 \| not made: <why>}} |
| Thumbnail | CMD-{{n}} | — | {{frame at m:ss of grader.mp4 (shot G-nn), 1280×720}} |

## 7. Output files

| File | Duration (s) | Video: codec,W,H,pix_fmt,fps (ffprobe) | Audio | Size (bytes) | sha256 (first 12) |
|---|---|---|---|---|---|
| docs/demo/out/grader.mp4 | {{s}} | {{h264,1920,1080,yuv420p,30/1}} | {{aac 48000 \| none}} | {{wc -c}} | {{shasum -a 256}} |
| docs/demo/out/grader.srt | — | — | — | {{wc -c}} | {{…}} |
| docs/demo/out/social.mp4 | {{s}} | {{h264,1920,1080,yuv420p,30/1}} | {{aac 48000 \| none}} | {{wc -c}} | {{…}} |
| docs/demo/out/social.srt | — | — | — | {{wc -c}} | {{…}} |
| docs/demo/out/thumb.png | — | {{png,1280,720}} | — | {{wc -c}} | {{…}} |

## 8. Checks

<!-- guide: One length row per platform in §10, numbered CHK-1a, CHK-1b, … ; CHK-2 to CHK-11 keep their numbers
(Done-when and the STOP cite them). -->

| Check | What | Command | Result (pasted) | Status |
|---|---|---|---|---|
| CHK-1a | Length of {{grader.mp4}} fits {{platform}}: limit {{m:ss}} ({{source, date checked}}) | `ffprobe -v error -show_entries format=duration -of csv=p=0 <file>` | {{seconds}} | {{pass \| fail}} |
| CHK-2 | Video spec of every mp4 is {{h264,1920,1080,yuv420p,30/1}} | `ffprobe … stream=codec_name,width,height,pix_fmt,avg_frame_rate` | {{pasted}} | {{pass \| fail}} |
| CHK-3 | Audio present only if voice was planned (Q2) | `ffprobe -v error -select_streams a -show_entries stream=codec_name,sample_rate -of csv=p=0 <file>` | {{pasted \| empty}} | {{pass \| fail}} |
| CHK-4 | Captions per cut: every Voiceover cell verbatim; each cue inside its shot's final range; ≤ 2 lines × 42 chars; timed by {{whisper \| silence detection \| shot ranges}}; spoken words match the script {{(whisper) \| not checked: human spot-check at the STOP}} | {{commands from references/checks.md §4}} | {{pasted}} | {{pass \| fail}} |
| CHK-5 | Frames of both final cuts reviewed for secrets, PHI, real data (references/checks.md §3) | `ffmpeg -v error -i docs/demo/out/<cut>.mp4 -vf fps=1/2 docs/demo/raw/frames/final/<cut>/f%04d.png` → {{f}} frames, each opened | {{findings \| none}} | {{pass \| fail}} |
| CHK-6 | OCR sweep of the same frames | {{tesseract loop \| not run: tesseract absent}} | {{hits and how each was triaged}} | {{pass \| n.a.}} |
| CHK-7 | No secret patterns in SMOKE.md, RECORDING.md, *.srt | the Done-when grep | {{no output}} | {{pass \| fail}} |
| CHK-8 | Each file ≤ 50 MB (the GitHub mirror warns at 50, rejects at 100) | `find docs/demo/out -type f -size +50M` | {{no output \| file — why}} | {{pass \| fail}} |
| CHK-9 | Raw footage ignored and unstaged | `git check-ignore -q docs/demo/raw/probe; echo $?` | {{0}} | {{pass \| fail}} |
| CHK-10 | Thumbnail 1280×720 and ≤ 2 MB | `ffprobe … thumb.png`; `wc -c < docs/demo/out/thumb.png` | {{pasted}} | {{pass \| fail}} |
| CHK-11 | On-screen text per cut: every non-— cell is in `<cut>-ost.ass` verbatim and readable in a frame of its shot | {{commands from references/checks.md §4}} | {{pasted; frame paths}} | {{pass \| fail \| n.a.: none in script}} |

## 9. Deviations from the script

<!-- guide: Never fix the script here. One row per difference between SCRIPT.md and the video: a shot more than 2 s
or 20% off its range, a shot that could not be made as written, a Proof re-run whose result differs, a platform the
cut does not fit. Needs decides what happens: "write-demo-script revision" blocks (record nothing further, STOP D);
"nothing: timing only" and "platform: <name> ✗" continue to STOP A. Write "none" if there are none, and delete the
example row. -->

| Id | Shots | Script says | Video does | Why | Needs |
|---|---|---|---|---|---|
| DEV-1 | {{G-03, S-03}} | {{…}} | {{…}} | {{…}} | {{nothing: timing only \| platform: <name> ✗ \| write-demo-script revision}} |

## 10. Upload checklist (human-only)

record-demo never uploads or posts. One row per platform (POSTS.md and the assignment).

| Platform | Cut | Upload | Captions | Thumbnail | Post copy | Notes |
|---|---|---|---|---|---|---|
| {{e.g. assignment submission}} | {{grader}} | {{docs/demo/out/grader.mp4}} | {{upload docs/demo/out/grader.srt as English \| burned copy}} | {{docs/demo/out/thumb.png}} | {{docs/demo/POSTS.md § <platform> \| —}} | {{visibility, limit from CHK-1x}} |

- [ ] Watched both cuts end to end with sound (the social cut once muted): every claim true, captions match the voice, nothing secret or patient-identifying
- [ ] Uploaded and posted by the human; links: {{added by the human later | …}}

## 11. Command log

<!-- guide: Every command record-demo ran, in order, failed ones included, the background app server's start and
stop too. Env var names only, never values. -->

| Id | Time | Command | Exit | Result (one line: version, duration, size, last line) |
|---|---|---|---|---|
| CMD-1 | {{output of date}} | `{{command}}` | {{code}} | {{…}} |

## 12. Open questions

| Id | Question | Recommended answer | Status |
|---|---|---|---|
| Q-1 | {{⚠ question}} | {{recommendation and its tradeoff}} | {{open \| answered: "exact words" \| assumed}} |
