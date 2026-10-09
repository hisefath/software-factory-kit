# Post copy (POSTS.md)

Read this in step 9. The posts carry the social cut to people who did not ask to see it, so they follow the same
two laws as the script: plain words (`references/plain-words.md`) and nothing the Claims table can't back.

## Everywhere

- The fenced `text` block is **exactly what the human pastes**: hashtags included at the end, [video link] where
  the link goes. Nothing outside the fence gets posted.
- Every post lists its claim ids on the line under its fence (`Claims: C2, C4`). Numbers only from claims.
- No emojis (screen readers read them out by name, and they inflate X's character count).
- Write as the human, first person, calm: what you built, for whom, one moment that shows it, one proof, what you
  learned. No hype words.
- Name a partner, client or company only if the brief, assignment or a `U-##` row says it may be named in
  public; otherwise describe it ("a clinic software partner") and leave a `⚠` asking. Never tag people or
  accounts: that is the human's choice when posting.
- Never a real patient, customer, screenshot with real data, private repo link, or token-bearing URL.

## X post

- At most 280 characters as X counts them: every URL is 23 characters, so is [video link]. `xchars '## X post'`
  counts the way X does.
- Shape: hook line (the person's pain or the result) → what it is in one line → one proof → [video link] →
  1-2 hashtags.

## X thread (optional, exactly 3 posts)

- Write it when you have at least 3 claims worth a post each; otherwise replace it with `Skipped: <reason>.`
- 1/3 hook and problem · 2/3 how it works (the one picture in two sentences) · 3/3 proof, call to action,
  [video link]. Each post makes sense alone; each is at most 280 characters including its "1/3".

## LinkedIn post

- 150-300 words (`post '## LinkedIn post' | wc -w`).
- The first 2 lines show before "…see more": the hook must land there.
- Short paragraphs of 1-2 sentences. One demo moment, one proof line, one thing you learned, one call to action.
- 3-5 hashtags at the end.
- The link: [video link] in the text. If the human prefers the link in the first comment, they change it when
  posting; note it under Open questions only if the brief says so.

## Alt text

- One row per media item: the social cut video, and each image the posts use.
- Describe what happens and what text matters, as you would to a friend on the phone: "A clinic app. The doctor
  clicks Store, picks Vitamin D for test patient Ana Ruiz, and the order shows as Paid."
- Do not start with "Image of" or "Video of". At most 250 characters. Never real names or health details.

## Hashtags

- X: 1-2. LinkedIn: 3-5. Prefer tags people actually follow (`#BuildInPublic`, `#HealthTech`, `#Laravel`) over
  invented ones; when the assignment or school names a tag, use it.
- Write multi-word tags in CamelCase (`#BuildInPublic`) so screen readers say the words.
