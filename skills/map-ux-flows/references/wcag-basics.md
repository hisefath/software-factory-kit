# WCAG 2.2 AA basics for screens.md

Loaded by `map-ux-flows` step 12. Source: W3C, How to Meet WCAG 2.2 (Quick Reference),
https://www.w3.org/WAI/WCAG22/quickref/.

This is design-time intent. Colors are not chosen in this phase, so contrast is a requirement to state, not a
measurement. Write what each screen must do so these pass; later phases turn the notes into checks. Skip a row
only when the screen has nothing it applies to, and say so.

| Check | WCAG 2.2 success criterion (level) | What to write for each screen |
|---|---|---|
| Text contrast | 1.4.3 Contrast (Minimum) (AA): 4.5:1; large text (24 px, or 18.66 px bold) 3:1 | The low-contrast risks: helper text, placeholder text, text over images, muted labels |
| Control and focus contrast | 1.4.11 Non-text Contrast (AA): 3:1 | Input borders, the focus ring, icons that carry meaning |
| Not color alone | 1.4.1 Use of Color (A) | Every status (error, in stock, selected) also has text or a shape |
| Reflow | 1.4.10 Reflow (AA): no sideways scrolling at 320 CSS px | The 375 px note says what stacks; only a true data grid may scroll sideways |
| Keyboard | 2.1.1 Keyboard (A); 2.1.2 No Keyboard Trap (A) | How each action works without a mouse; how to leave every dialog (Esc and a close button) |
| Focus order | 2.4.3 Focus Order (A) | A numbered list of what Tab reaches, matching the reading order |
| Focus visible, not hidden | 2.4.7 Focus Visible (AA); 2.4.11 Focus Not Obscured (Minimum) (AA, new in 2.2) | Focus is always visible; sticky headers, footers or banners never cover the focused item |
| Headings and labels | 2.4.6 Headings and Labels (AA); 3.3.2 Labels or Instructions (A); 2.5.3 Label in Name (A) | One page title; every input has a visible label; an icon-only button's spoken name matches what it shows |
| Target size | 2.5.8 Target Size (Minimum) (AA, new in 2.2): 24×24 CSS px | The small targets at risk: row icons, close "x", quantity + and − |
| Dragging | 2.5.7 Dragging Movements (AA, new in 2.2) | Every drag (reorder, slider) also works with single clicks |
| Errors | 3.3.1 Error Identification (A); 3.3.3 Error Suggestion (AA) | Error text names the field and says how to fix it |
| Money and binding steps | 3.3.4 Error Prevention (Legal, Financial, Data) (AA) | Before a purchase or binding submit: a review step, a confirmation, or an undo |
| Don't ask twice | 3.3.7 Redundant Entry (A, new in 2.2) | Reuse what the user already entered in this flow ("Same as shipping address") |
| Sign-in | 3.3.8 Accessible Authentication (Minimum) (AA, new in 2.2) | No puzzles or memory tests; paste and password managers work |
| Consistent help | 3.2.6 Consistent Help (A, new in 2.2) | Help or contact sits in the same place on every screen |
| Status messages | 4.1.3 Status Messages (AA) | Which messages ("Added to cart", "Saved") are announced without moving focus |
| Images | 1.1.1 Non-text Content (A) | Meaningful images get a text alternative; decorative images are marked decorative |
