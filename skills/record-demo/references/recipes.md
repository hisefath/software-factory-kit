# record-demo recipes

Commands and skeletons for steps 2-11. Paths are relative to the project root. Replace every `<…>` with a value
from SCRIPT.md, AGENTS.md or the app's own source (cite `path:line` for anything taken from the source); keep
everything else. Every command you run goes into RECORDING.md §11 as a `CMD-n` row.

`<source>` is a source id from RECORDING.md §4 (`B<n>` for a beat, or a shot id such as `G-04`); `<cut>` is
`grader` or `social`; `<shot>` is a shot id.

## 0. Kinds (step 2)

Read the shot's Screen / URL and Action cells; the first matching row wins.

| Screen / URL and Action say | Kind | Made with |
|---|---|---|
| A person on camera, a live voice the script wants heard, or a screen behind a real sign-in (an EHR's own login, a CI page that needs an account) | human | QuickTime Player or Screen Studio, shot card (§4) |
| A command and its output: a terminal, or a Proof shot whose Screen is the command (SCRIPT.md §5) | terminal | VHS tape (§3) |
| A screen or URL path of the app | browser | Playwright video (§2) |
| A page outside the app that opens without a sign-in: the rendered diagram where SCRIPT.md §4 says it is shown, the milestone report or README on the public repo, a public CI page | static | Playwright video when the Action scrolls or points, else a Playwright screenshot held as a still (§2, §5) |
| `—`, or a plain title card | static (card) | ffmpeg colour background; the On-screen text cell is the content (§5) |

A Demo shot's source is its beat `B<n>`, shared by both cuts. A non-Demo shot whose Screen / URL and Action equal a
shot in the other cut reuses that shot's source.

## 1. Version and presence checks (step 6)

Never use bare `npx` (it downloads a package when one is missing). Never run an install command; list it for the
human instead.

| Tool | Check (run it) | Install command for the human (never run it) |
|---|---|---|
| ffmpeg | `ffmpeg -hide_banner -version \| head -1` | `brew install ffmpeg` |
| ffprobe | `ffprobe -hide_banner -version \| head -1` | ships with ffmpeg |
| overlay filters | `ffmpeg -hide_banner -filters 2>/dev/null \| grep -wE 'ass\|subtitles\|drawtext'` prints at least one line | an ffmpeg build with libass (or libfreetype for `drawtext`) |
| Playwright (Node) | `./node_modules/.bin/playwright --version` | `npm i -D playwright` (a new dev dependency: an "ask first" decision) |
| Playwright browser | launch once: `node -e "import('playwright').then(async p=>{const b=await p.chromium.launch();console.log(b.version());await b.close()})"` | `./node_modules/.bin/playwright install chromium` |
| Playwright (Python) | `python3 -m playwright --version` | `pip install playwright` then `python3 -m playwright install chromium` |
| VHS | `vhs --version` | `brew install vhs` |
| ttyd (VHS needs it) | `ttyd --version` | `brew install ttyd` |
| whisper-cli | `command -v whisper-cli` and `ls -l <model path the human gives>` | `brew install whisper-cpp` plus a ggml model the human downloads |
| tesseract | `tesseract --version \| head -1` | `brew install tesseract` |

If the project uses `@playwright/test` instead of `playwright`, import `chromium` from `@playwright/test`; the binary
check is the same.

## 2. Browser and static sources: Playwright video (step 8)

One file per source: `docs/demo/raw/src/<source>.mjs`. Node resolves `playwright` from the project's `node_modules`
because the file sits inside the project. Run it with `TAKE=<k> DEMO_URL=<url> node docs/demo/raw/src/<source>.mjs`.

```js
// <source> — used by <shot ids> — longest range <m:ss-m:ss>. Copied verbatim into RECORDING.md §5.
import { chromium } from 'playwright';

const source = '<source>';
const take = process.env.TAKE ?? '1';
const base = process.env.DEMO_URL;               // e.g. http://localhost:8000
const W = 1920, H = 1080;
const out = `docs/demo/raw/${source}`;

// Sign-in details: AGENTS.md Project specifics, else the app's own sign-in view: <path:line>.
const LOGIN_PATH = '<sign-in path>';
const USER_VAR = '<env var NAME holding the demo user>';      // a name, never a value
const PASS_VAR = '<env var NAME holding the demo password>';

const browser = await chromium.launch({ slowMo: 200 });  // slowMo makes clicks and typing visible

// Sign in OFF camera: a context without video signs in; the recorded context reuses the session from memory.
const login = await browser.newContext();
const lp = await login.newPage();
await lp.goto(`${base}${LOGIN_PATH}`);
await lp.getByLabel('<user field label>').fill(process.env[USER_VAR]);
await lp.getByLabel('<password field label>').fill(process.env[PASS_VAR]);
await lp.getByRole('button', { name: '<submit button label>' }).click();
await lp.waitForURL((u) => !u.pathname.startsWith(LOGIN_PATH));
const state = await login.storageState();      // in memory only: a session is a credential, never written to disk
await login.close();

const context = await browser.newContext({
  viewport: { width: W, height: H },
  recordVideo: { dir: `${out}/tmp-${take}`, size: { width: W, height: H } },
  storageState: state,
  locale: 'en-US', timezoneId: 'America/New_York', colorScheme: 'light',
});
const page = await context.newPage();
const hold = (ms) => page.waitForTimeout(ms);

try {
  await page.goto(`${base}/<path from the shot's Screen / URL>`);
  await hold(2500);                                            // the viewer reads the screen
  await page.getByRole('button', { name: '<label from the Action cell>' }).click();
  await hold(2000);                                            // ≥ 2 s after every action: no pointer is drawn
} finally {
  const video = page.video();
  await context.close();                                       // flushes the video file
  await video.saveAs(`${out}/take-${take}.webm`);
  await browser.close();
}
```

- Size the holds so the source covers the longest shot range that uses it; each cut trims its own range from it.
  The first ~0.5 s of a Playwright video is often blank (trim it in §5).
- Reset state before every take (re-run the seed command on a local target, or use a fresh seeded record) so a
  re-take starts from the same screen.
- No login in the app (or login is the demo), and every **static** page: drop the sign-in block and `storageState`.
- Static page that scrolls to a result: `await page.getByText('<result text from SCRIPT.md §5>').scrollIntoViewIfNeeded()`.
  "Point at" a diagram box: outline it, hold, remove the outline — the page's content never changes:
  `const box = page.getByText('<label as the diagram writes it>'); await box.evaluate(e => e.style.outline = '6px solid #f59e0b'); await hold(2000); await box.evaluate(e => e.style.outline = '');`
- Static still (the Action only shows the page): `await page.screenshot({ path: out + '/still.png' })` instead of
  a video; §5 holds it for the shot's length.
- Sign-in through a third-party identity provider (for example an EHR's SMART launch): the agent never does it. Make
  that part a human source, or start the recorded context on a screen past it.
- Python: `browser.new_context(viewport={...}, record_video_dir=..., record_video_size={"width": 1920, "height": 1080},
  storage_state=login.storage_state())`, then `page.video.save_as(...)` after `context.close()`.
- Smoke walk (step 5): the same shape without `recordVideo`, one `page.screenshot({ path:
  'docs/demo/raw/smoke/SMK-<n>.png' })` per step, and a check of the step's Expected text
  (`await page.getByText('<expected>').waitFor()`).

## 3. Terminal source: VHS tape (step 8)

One file per source: `docs/demo/raw/src/<source>.tape`, with the literal `take-TAKE` in its Output line. Each take
gets its own copy, so a re-take never overwrites an earlier one:

```
mkdir -p docs/demo/raw/<source>
sed "s/take-TAKE/take-<k>/" docs/demo/raw/src/<source>.tape > docs/demo/raw/<source>/take-<k>.tape
vhs docs/demo/raw/<source>/take-<k>.tape
```

```
# <source> — used by <shot ids> — longest range <m:ss-m:ss>. Copied verbatim into RECORDING.md §5.
Output docs/demo/raw/<source>/take-TAKE.mp4
Require <each program the source types, e.g. make>
Set Shell "bash"
Set FontSize 24
Set Width 1920
Set Height 1080
Set Padding 48
Set TypingSpeed 55ms

Hide
Type "export PS1='$ ' HISTFILE=/dev/null; cd <absolute project root>; clear"
Enter
Show

Type "<command from the shot, or SCRIPT.md §5 Command for a Proof shot>"
Sleep 600ms
Enter
Sleep <seconds the output needs>s
```

- The hidden block keeps your user name, host name and history off screen.
- If `vhs manual` lists `Wait`, prefer `Wait /<regex of the last output line>/` over guessing a `Sleep`.
- **Proof re-run** (a long command such as `make check`): type it on camera, then `Hide`, wait for the result line
  (`Wait+Screen@10m /<regex of SCRIPT.md §5's copied result>/`, else a `Sleep` measured from one off-camera run),
  `Show`, `Sleep 4s`. The jump cut skips only the waiting; the command really runs. Note the cut in RECORDING.md §4.
  A result that differs from SCRIPT.md §5 (another count, or red) is a DEV-n needing a script revision.
- Never type a command that prints the environment, `.env`, tokens, keys or connection strings (`env`, `printenv`,
  `cat .env`, `--verbose` auth output). If the script needs one, it is a `DEV-n`. Output that prints a home path
  (`/Users/<name>/…`) is a privacy hit in the frame review.

## 4. Human source: shot card and voice-over card (steps 9 and 11)

Send the card, then wait for the human's "<source> saved". Copy the words from SCRIPT.md verbatim.

```
Shot card <source> — human pass (<QuickTime Player | Screen Studio>) — used by <shot ids>
Show:   <Screen / URL and state from SCRIPT.md>
Do:     <the Action cell, verbatim>
Say:    "<the Voiceover cells, verbatim>" | nothing: the voice-over covers this shot
Length: about <s> s (longest range <m:ss-m:ss>)
Before you press record:
  [ ] Do Not Disturb on; mail, chat and calendar apps closed
  [ ] One browser window, only the demo tab; bookmarks bar hidden; no password-manager pop-ups
  [ ] Signed in as the demo user only; synthetic data on screen (SMOKE.md §2)
  [ ] Desktop clear; terminal prompt neutral; page zoom set so text reads at 1080p
  [ ] Record a 16:9 area (or the window) — not a full Retina screen
Record: QuickTime Player → File → New Screen Recording → Options → Microphone: <device | None> → record.
Save to: docs/demo/raw/<source>/human-take-<k>.mov  (gitignored), then reply "<source> saved".
```

One voice-over card per cut, sent after its picture lock exists:

```
Voice-over card — <cut> cut — read once against the picture lock
Play:   docs/demo/raw/<cut>-lock.mp4 (sound off) and read along with it
Read:   each line when its shot starts, verbatim: <shot> <m:ss> — "<Voiceover cell>" · … ; stay silent at <shots with live sound | none>
Record: QuickTime Player → File → New Audio Recording → Microphone: <device>; quiet room; one take.
        Press record first, then play, and start the first line as its shot starts.
Save to: docs/demo/raw/vo/<cut>.m4a, then reply "VO <cut> saved".
```

## 5. ffmpeg assembly (steps 10-11), once per cut

Probe (durations and specs; paste the output):

```
ffprobe -v error -show_entries format=duration -of csv=p=0 <file>
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height,pix_fmt,avg_frame_rate -of csv=p=0 <file>
```

Frames for review (one every 2 s, then the first and last frame of each take):

```
mkdir -p docs/demo/raw/frames/<source>
ffmpeg -y -v error -i <take> -vf fps=1/2 docs/demo/raw/frames/<source>/f%04d.png
ffmpeg -y -v error -i <take> -frames:v 1 -update 1 docs/demo/raw/frames/<source>/first.png
ffmpeg -y -v error -sseof -0.1 -i <take> -frames:v 1 -update 1 docs/demo/raw/frames/<source>/last.png
```

One clip per shot, trimmed from its source's pick at the shot's In → out (silent stereo track added so every clip
has the same streams):

```
mkdir -p docs/demo/raw/norm/<cut>
ffmpeg -y -v error -ss <in s> -to <out s> -i docs/demo/raw/<source>/take-<k>.<ext> \
  -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=48000 \
  -map 0:v -map 1:a -shortest \
  -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,fps=30,format=yuv420p" \
  -c:v libx264 -preset medium -crf 18 -c:a aac -b:a 160k -ar 48000 docs/demo/raw/norm/<cut>/<shot>.mp4
```

- A human take with live sound: drop the `anullsrc` input, use `-map 0:v -map 0:a` and add
  `-af "aresample=48000,aformat=channel_layouts=stereo,loudnorm=I=-16:TP=-1.5:LRA=11"`.
- A static still: replace the take input with `-loop 1 -framerate 30 -t <shot length s> -i docs/demo/raw/<source>/still.png`
  and drop `-ss`/`-to`.
- A card: replace the take input with `-f lavfi -i color=c=0x111111:s=1920x1080:r=30:d=<shot length s>` and drop
  `-ss`/`-to`.

Concat in shot order (identical encodes, so stream copy is safe):

```
for s in <shot ids of this cut, in order>; do echo "file '$PWD/docs/demo/raw/norm/<cut>/$s.mp4'"; done > docs/demo/raw/<cut>-concat.txt
ffmpeg -y -v error -f concat -safe 0 -i docs/demo/raw/<cut>-concat.txt -c copy docs/demo/raw/<cut>-concat.mp4
```

On-screen text → the picture lock. Write `docs/demo/raw/<cut>-ost.ass`, one Dialogue line per shot whose On-screen
text cell is not `—`, timed to the shot's Final range (`H:MM:SS.cc`), the cell verbatim; top centre, so captions
keep the bottom:

```
[Script Info]
ScriptType: v4.00+
PlayResX: 1920
PlayResY: 1080

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: OST,Helvetica,64,&H00FFFFFF,&H000000FF,&H00000000,&H66000000,1,0,0,0,100,100,0,0,3,18,0,8,80,80,60,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
Dialogue: 0,<0:00:00.00>,<0:00:05.00>,OST,,0,0,0,,<On-screen text cell, verbatim>
```

```
ffmpeg -y -v error -i docs/demo/raw/<cut>-concat.mp4 -vf "ass=docs/demo/raw/<cut>-ost.ass" \
  -c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -c:a copy docs/demo/raw/<cut>-lock.mp4
```

Only `subtitles` exists: use `-vf "subtitles=docs/demo/raw/<cut>-ost.ass"`. Only `drawtext` exists: one
`drawtext=textfile=docs/demo/raw/ost/<shot>.txt:enable='between(t,<start s>,<end s>)':x=(w-tw)/2:y=60:fontsize=64:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=24`
per shot, joined with commas (add `fontfile=<a font file on this machine>` if ffmpeg cannot find a font). No
On-screen text in the cut: copy `<cut>-concat.mp4` to `<cut>-lock.mp4`.

Voice-over: align, then mix with the lock's own sound (silent except live human shots), so live speech survives.
Offset = the first speech in the read (`silence_end` from the silence command below, run on the `.m4a`) minus the
first spoken shot's Final start, minus 0.3 s (readers start a little late); positive → trim it from the read with
`-ss <offset>` before its `-i`; negative → add `adelay=<ms>:all=1` at the start of `[1:a]`'s chain.

```
ffmpeg -y -v error -i docs/demo/raw/<cut>-lock.mp4 -ss <offset s> -i docs/demo/raw/vo/<cut>.m4a \
  -filter_complex "[1:a]aresample=48000,aformat=channel_layouts=stereo[vo];[0:a][vo]amix=inputs=2:duration=first:normalize=0,loudnorm=I=-16:TP=-1.5:LRA=11[a]" \
  -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 160k -ar 48000 docs/demo/raw/<cut>-with-vo.mp4
```

Final mux (web-ready, device and location metadata stripped):

```
ffmpeg -y -v error -i docs/demo/raw/<cut>-<with-vo | lock>.mp4 -c copy -map_metadata -1 -movflags +faststart docs/demo/out/<cut>.mp4
```

Captions — `docs/demo/out/<cut>.srt`. The text of each cue is a Voiceover cell, verbatim (shots with `—` get no
cue). The times come from the recorded audio, never from guessing, using the first method that applies:

1. **whisper-cli and a model on disk:** word times, and a check that the words said are the script's words.

   ```
   mkdir -p docs/demo/raw/asr
   ffmpeg -y -v error -i docs/demo/out/<cut>.mp4 -vn -ar 16000 -ac 1 -c:a pcm_s16le docs/demo/raw/asr/<cut>.wav
   whisper-cli -m <model path> -f docs/demo/raw/asr/<cut>.wav -l en -ml 1 -sow -osrt -of docs/demo/raw/asr/<cut>-words
   ```

   Cue = from the first to the last word heard inside the shot's Final range. List every word that differs from
   the cell in CHK-4; a different word said means re-read that line (or a DEV-n), never edit the caption to match.
2. **Silence detection** (no whisper): where speech starts and stops.

   ```
   ffmpeg -hide_banner -nostats -i docs/demo/out/<cut>.mp4 -map 0:a:0 -af silencedetect=noise=-35dB:d=0.3 -f null - 2>&1 \
     | grep -oE 'silence_(start|end): [0-9.]+'
   ```

   Cue start = the shot's Final start, or the `silence_end` of a silence covering it; cue end = the shot's Final
   end, or the `silence_start` of a silence covering it. No speech inside the window → use the window and flag the
   shot in CHK-4 (the line may be missing from the read).
3. **Captions only** (no voice, question 2): cue = the shot's Final range, 0.2 s in from each end.

A cell longer than 2 × 42 characters splits at a phrase boundary into two cues, the time divided by character
count; each cue stays 1-7 s on screen. SRT format:

```
1
00:00:00,500 --> 00:00:04,000
<line 1, at most 42 characters>
<optional line 2, at most 42 characters>
```

Burned copy (only if question 3 asks and `subtitles` exists); captions sit at the bottom, under nothing:

```
ffmpeg -y -v error -i docs/demo/out/<cut>.mp4 \
  -vf "subtitles=docs/demo/out/<cut>.srt:force_style='FontName=Helvetica,FontSize=22,Outline=2,MarginV=48'" \
  -c:v libx264 -preset slow -crf 20 -pix_fmt yuv420p -c:a copy -map_metadata -1 -movflags +faststart \
  docs/demo/out/<cut>-captioned.mp4
```

Thumbnail (the frame question 5 chose, from the grader cut):

```
ffmpeg -y -v error -ss <m:ss.s> -i docs/demo/out/grader.mp4 -frames:v 1 -update 1 -vf scale=1280:720 docs/demo/out/thumb.png
```

Over 50 MB: re-encode the lock with a higher `-crf` (22-26 keeps UI text sharp) rather than lowering the
resolution, then re-run the steps after it and the checks.
