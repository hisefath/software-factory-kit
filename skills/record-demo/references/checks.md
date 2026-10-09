# record-demo checks

Loaded at steps 3, 10 and 12. Every check lands in RECORDING.md §8 with its command and pasted result.

## 1. Platform defaults (question 4, CHK-1a, CHK-1b, …)

Starting points only: platforms change limits, so open the platform's help page on the day, and write the limit,
the source and the date checked in that platform's length row. The assignment's or POSTS.md's own limit always
wins. One row per platform in RECORDING.md §10, numbered CHK-1a, CHK-1b, … in that order; each names the cut it
measures.

| Platform | Usual cut | Default max length | Shape | Captions | Why it matters |
|---|---|---|---|---|---|
| Assignment / Gauntlet submission | grader | the assignment text | 16:9 | sidecar or burned | the grader's limit is the one that counts |
| YouTube | grader | 15 min (unverified account) | 16:9, 1920×1080 | upload `.srt` | custom thumbnail 1280×720, ≤ 2 MB |
| YouTube Shorts | social | 3 min | 9:16 vertical | burned | only if POSTS.md asks for a vertical cut |
| LinkedIn | social | 10 min (longer on desktop upload) | 16:9 or 1:1 | upload `.srt`; feed autoplays muted | the on-screen text carries the story when muted |
| X | social | 2 min 20 s (non-Premium) | 16:9 | burned; feed autoplays muted | the shortest common limit |
| Loom | either | plan-dependent | 16:9 | automatic | check the human's plan |

## 2. Video spec (question 5, CHK-2, CHK-3)

- 1920×1080, 30 fps, H.264, `yuv420p` (plays everywhere), AAC 48 kHz stereo when there is sound.
- `ffprobe` must print `h264,1920,1080,yuv420p,30/1` for every mp4 in `docs/demo/out/` (or the shape question 5 set).
- Audio stream present only if a voice was planned; a silent demo is fine when captions carry it.
- `+faststart` and `-map_metadata -1` on every output (starts playing before fully downloaded; no device names,
  dates or locations from a screen recorder).

## 3. On-screen privacy list (steps 4, 9, 10; CHK-5)

Before recording, every item in "never on screen" must be impossible for the planned shots. While reviewing, open
every frame and look for each one. One hit: quarantine the take (never trim around a secret: the frame may still be
in a thumbnail or a re-cut), add a CHK-5 finding, ask the human to delete the file and rotate the value if it is a
real credential.

Never on screen:
- Real people's data: names, dates of birth, addresses, phone numbers, emails, record numbers (MRN), insurance ids,
  diagnoses, medications, photos. In a health product, assume any non-obvious name is real until SMOKE.md §2 cites
  the seeder that made it.
- Secrets: API keys, tokens, passwords, session cookies, connection strings, `.env` contents, private keys, OAuth
  client secrets, signed URLs or query strings carrying tokens.
- The machine around the app: OS user name or home path in a prompt or in command output, other tabs, bookmarks,
  notifications, chat or mail previews, password-manager pop-ups, other windows, the dock with private app badges.
- Real third-party accounts: a real clinic, practice or customer name from a partner sandbox, unless SMOKE.md §2
  shows it is a test tenant.

Allowed: synthetic records from the seeder ("Test Patient …", `example.com`, `*.test`, 555-01xx numbers), env var
*names*, localhost URLs, the product's own name and the partner's public brand name.

## 4. Caption and on-screen text checks (CHK-4, CHK-11)

Run each for `grader` and `social` (`<cut>`).

- Every Voiceover cell appears verbatim: for each cell `L` that is not `—`, `grep -cF "<L>" docs/demo/out/<cut>.srt`
  is at least 1 when `L` fits in one cue; for a cell split across two cues, check its words in order by eye and
  say so in the CHK-4 row.
- Each cue lies inside its shot's Final range (RECORDING.md §4), the last cue ends inside the video (the Done-when
  awk command), and cues never overlap. Name the timing method (whisper, silence detection, shot ranges).
- At most 2 lines per cue, at most 42 characters per line:
  `awk 'length($0) > 42 && $0 !~ /-->/ && $0 !~ /^[0-9]+$/' docs/demo/out/<cut>.srt` prints nothing.
- Spoken words: with whisper, every word that differs from the cell is listed in the CHK-4 row (a different word
  said is a re-read or a DEV-n, never a caption edit). Without whisper, CHK-4 says "spoken words not checked: human
  spot-check at the STOP".
- On-screen text (CHK-11): for each On-screen text cell `T` that is not `—`, `grep -cF "<T>" docs/demo/raw/<cut>-ost.ass`
  is 1, and one frame from that shot's Final range (`ffmpeg -y -v error -ss <s> -i docs/demo/out/<cut>.mp4
  -frames:v 1 -update 1 docs/demo/raw/frames/ost/<shot>.png`) shows it readable and not covering a caption. Paste
  the frame paths in the row.

## 5. OCR sweep (CHK-6, only if tesseract is installed)

```
for f in $(find docs/demo/raw/frames -name '*.png'); do
  tesseract "$f" - 2>/dev/null \
  | grep -nEi 'password|secret|token|api[_-]?key|bearer|BEGIN .*PRIVATE|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}|\b(DOB|MRN|SSN)\b|[0-9]{3}-[0-9]{2}-[0-9]{4}|/Users/[^/ ]+|/home/[^/ ]+' \
  | grep -vEi '@(example\.(com|org|net)|[a-z0-9.-]+\.test)\b' \
  | sed "s|^|$f: |"
done
```

Every hit is triaged in the CHK-6 row (a field label such as "Password" next to masked dots is fine; a value is
not). OCR misses small or stylised text, so it adds to the frame review and never replaces it.
