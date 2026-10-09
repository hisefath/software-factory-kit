# Wireframes, variants, states and edge data

Loaded by `map-ux-flows` steps 6 and 10. A wireframe is a sketch of what the user sees, not a build plan.

## ASCII legend

```text
1280 px
+--------------------------------------------------------------+  frame; write the width above it
| Order history                                  [Export v]    |  [Label] button · [Label v] menu or select
| Search orders                                                |  a visible label above every input
| [________________________________________]  [Search]         |  [____] text input
| (•) All   ( ) Open   ( ) Shipped                             |  (•)/( ) pick one · [x]/[ ] pick many
| ------------------------------------------------------------ |  divider
| Vitamin D3 2000 IU          Qty 2       $24.00   [Reorder]   |  one row; fake data only
| > View all orders                                            |  > link
| [img: bottle photo]                                          |  image; it needs a text alternative
| ! Card was declined. Try another card.                       |  ! error text, beside its cause
| (i) Saved.                                                   |  (i) status message
+--------------------------------------------------------------+
```

- Draw 1280 px about 64 characters wide and 375 px about 34; it is a sketch, not to scale.
- Number callouts `(1)`, `(2)` inside the frame and explain them under it when a part needs words.
- Write the visible words, not descriptions of them: `[Place order]`, not `[primary button]`.
- Mark the page title once; keep heading levels obvious from indentation or a note.
- Never draw `<` (write `[Back]` or `[Prev]`, not `< Back`): the placeholder check reads `<…>` as an unfilled field.

## What makes a real variant

Pick one or two axes per key screen. Each axis below gives two ends and the tradeoff in plain words.

| Axis | One end | Other end | Tradeoff in plain words |
|---|---|---|---|
| What comes first | Search box first | Browse list first | Search is fastest when people know what they want; browsing helps people who don't. |
| Number of steps | One long page | Three short steps | One page means fewer clicks but more to read; steps are easier to follow but need a progress cue and a back path. |
| Density | Compact rows | Large cards | Rows scan fast and fit 375 px well; cards show pictures and feel friendlier, but fewer fit on screen. |
| Detail | List, then a separate detail screen | List with rows that expand in place | A separate screen stays clean but means back-and-forth; expanding keeps context but the page gets long. |
| Where actions sit | An action on every row | Select rows, then one action bar | Per-row is obvious for one item; a bar is better for many items but is one more idea to learn. |
| Disclosure | Everything visible | Advanced options tucked away | Visible means nothing to hunt for; tucked away is calmer but people may miss it. |

Not variants: color, font, icons, corner radius, spacing alone, or swapping two buttons. A drawing that drops a
story is not a variant either — that is a scope change: a `write-prd` revision and a new G1 approval.

## State prompts (every screen)

- **Empty** — first use, filtered to nothing, and cleared are three different moments; give each the right copy
  and always offer the next action. They share the Empty row as labelled strings:
  `First use: "…" / Filtered: "…" / Cleared: "…"` (a moment that can't happen: `Filtered: n/a — no filter`).
- **Loading** — what stays on screen while waiting; what appears after about 1 second; what is explained after
  about 10 seconds. Never a blank page.
- **Error** — the user's mistake (point to the field and how to fix it), our failure (try again; say whether
  their input was kept), no connection. Never a raw code. Same labelled form in one row:
  `Their mistake: "…" / Our failure: "…" / No connection: "…"`.
- **Success** — what proves it worked, where they go next, and whether it can be undone.
- **Permission denied** — signed out, session expired, role lacks access, feature off for this account. Say what
  happened and who can help; never reveal what is hidden.
- **Edge data** — see below; pick the cases this screen can actually meet.

## Edge-data prompts

- Very long text (a 60+ character name) — wrap, or shorten with the full text still reachable.
- 0, 1 and many (200 items) — counts, paging or "Show more".
- Limits — maximum quantity, minimum order, zero price, out of stock, discontinued.
- Missing optional data — no image, no description.
- The same action twice — double click on "Place order", back button after submitting.
- Stale data — someone else changed it (price changed, item removed) while the screen was open.
- Names with accents and symbols (José, O'Brien); currency and date formats for the users' region.
