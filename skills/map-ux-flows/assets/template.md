<!--
map-ux-flows output template. It holds TWO files: copy each block between the FILE markers into its path.
Keep every heading, in this order. Replace every <placeholder>.
Unknown → "⚠ <question>" (dispatched runs: "⚠ <question> — assumed: <recommended answer>").
Cannot apply → "n/a — <why>". Never delete a section.
Ids: screens S1, S2, … (never zero-padded: S01 is a gather-evidence source id; cite research as R<NN>, never
[S<NN>]) · flows F1, F2, … · variants S<n>-V1…V3 · demo beats B1, B2, …
Story ids are copied exactly from docs/product/prd.md and must be in this milestone's scope.
Never put "<" inside a wireframe (write [Back], not < Back): the placeholder check reads it as unfilled.
Pass 1 writes: all of flows.md; in screens.md ONLY the header, Global conventions, each screen's header line and
its Variants section, and Open questions. Pass 2 adds every other section and flips both status lines to complete.
Delete every comment block when filling.
-->

<!-- ======================== FILE 1: docs/design/flows.md ======================== -->

# UX flows — <product name>

status: <variants-proposed | complete>
Milestones: <M ids covered, e.g. M1> · PRD: docs/product/prd.md@<short sha> (G1 approved <date>)
Updated: <output of date>

## Scope

- UI-critical because: <one sentence: which P1 stories a person does on a screen>
- Primary width: <375 | 1280> px — <why: from the PRD's users or the human's answer>
- Runs inside: <its own browser tab | another product's frame, and that frame's width in px>
- Demo spine story: <story id> — <story title>
- Stories covered: <story ids>
- Stories with no screen: <story id — why (background work, later milestone)> | none
- Inputs read: <paths read> · absent: <optional inputs that did not exist> | none

## Screen inventory

| Screen | Name | Purpose (user words, one line) | Stories | Key screen |
|---|---|---|---|---|
| S1 | <screen name> | <what the user gets done here> | <story id> | <yes \| no> |
| S2 | <screen name> | <what the user gets done here> | <story id>, <story id> | <yes \| no> |

## Flows

### F1 <flow name in user words> — <story ids>

Actor: <who> · Trigger: <what makes them start> · Goal: <what they want>

1. [S1] <what the user does> → <what they see>
2. [S2] <what the user does> → <what they see>
   - 2a. [S2 · Error] <condition> → <what they see> → <what they can do>
   - 2b. [S2 · Permission denied] <condition> → <what they see> → <what they can do>
3. [S3] <what the user does> → <what they see>

Ends when: <the outcome the user can see>

### F2 <flow name in user words> — <story ids>

<same shape as F1>

## Traceability

| Story | Priority | Flows | Screens |
|---|---|---|---|
| <story id> | <P1 \| P2 \| P3> | F1 | S1, S2, S3 |

## Open questions

- ⚠ <question> | none
- ⚠ scope request: <screen> because <reason> — needs a new PRD story (revise with write-prd, re-approve at G1) | none
- ⚠ access rule for <screen>: <recommended> — needs a PRD requirement (write-prd revision) | none

<!-- ======================= FILE 2: docs/design/screens.md ======================= -->

# Screens — <product name>

status: <variants-proposed | complete>
Milestones: <M ids covered> · Flows: docs/design/flows.md · PRD: docs/product/prd.md@<short sha>
Updated: <output of date>

## Global conventions

- Widths designed: 375 px and 1280 px · Host frame: <none | its width in px>
- Voice: <e.g. plain, calm, second person, no jargon or codes>
- Error pattern: <what happened> + <what to do next>, beside its cause, in text (never color alone)
- Loading pattern: <e.g. keep the layout; show progress after 1 s; explain the delay after 10 s>
- Help: <where help or contact lives — the same place on every screen>
- Sample data: obviously fake names and values only

## S1 <screen name>

Stories: <story ids> · Flows: <F1 steps 1-2> · Key screen: <yes | no>

### Variants

<!-- Key screens: 2-3 variants written in pass 1. Other screens: the single line "n/a — not a key screen".
     Everything below Variants (Layout to Responsive, and Demo layout) is written in pass 2 only. -->

#### S1-V1 <short name>

```text
1280 px
+--------------------------------------------------------------+
| <title>                                          [<action>]  |
| <first thing the user sees>                                  |
| <rest of the layout>                                         |
+--------------------------------------------------------------+
```

- Idea: <one line>
- Best when: <plain words>
- Costs: <plain words>
- Fails for: <who, or which situation>

#### S1-V2 <short name>

<same shape as S1-V1; a different structure, not a different color>

**Recommendation:** S1-V<k> — <why, in plain words>

**Chosen:** ⚠ awaiting your pick

<!-- Pass 2 replaces the Chosen line above and adds the two lines below. -->
<!-- **Chosen:** S1-V<k> — "<exact words from the G-ux Approvals row>" (<that row's time>) -->
<!-- **Rejected:** S1-V<k> — <one-line why not> (one line per rejected variant) -->
<!-- **Why this layout (say it out loud):** <one sentence the human could defend in an interview> -->

### Layout

<!-- Pass 2. Key screens: the chosen variant refined. Other screens: one wireframe in the same pattern. -->

```text
<primary width> px
+--------------------------------------------------------------+
| <final wireframe>                                            |
+--------------------------------------------------------------+
```

### States

<!-- Several moments in one state share its row as labelled strings. A moment that cannot happen here:
     "Filtered: n/a — no filter on this screen". Never leave a cell blank. -->

| State | When it happens | What the user sees | Microcopy (exact) | What they can do |
|---|---|---|---|---|
| Empty | First use: <when> / Filtered: <when> / Cleared: <when> | <layout change> | First use: "<text>" / Filtered: "<text>" / Cleared: "<text>" | <next action> |
| Loading | <what they are waiting for> | <what stays; what shows after 1 s and 10 s> | "<text>" | <cancel, keep working> |
| Error | Their mistake: <when> / Our failure: <when> / No connection: <when> | <where the message sits; is input kept> | Their mistake: "<text>" / Our failure: "<text>" / No connection: "<text>" | <fix, retry> |
| Success | <what finished> | <proof it worked> | "<text>" | <next step, undo> |
| Permission denied | <signed out, session expired, role lacks access> | <what shows; nothing hidden is revealed> | "<text>" | <sign in, ask whom> |
| Edge data | <long text, 0/1/many, limits, stale, double submit> | <how the layout holds> | "<text>" | <recovery> |

### Microcopy

| Element | Text |
|---|---|
| Page title | "<text>" |
| Primary action | "<verb + result>" |
| Secondary action | "<text>" \| n/a |
| Field labels and helper text | "<label>" — helper: "<text>" |
| Confirmation | "<text>" \| n/a |

### Accessibility

WCAG 2.2 AA — planned, not verified.

- Focus order: 1. <first stop Tab reaches> 2. <next> 3. <next>
- Labels: <each input and its visible label; each icon-only button and its spoken name>
- Keyboard: <how every action works without a mouse; how to leave any dialog>
- Contrast and color: <text 4.5:1, large text 3:1, controls and focus ring 3:1; where status relies on text, not color>
- Targets: <controls at risk of being under 24×24 px and how they meet it>
- Errors and status: <where errors appear and how they suggest a fix; which messages are announced without moving focus>
- Focus not hidden: <sticky bars or banners that could cover focus, and how they don't>

### Responsive

| Width | Layout | What changes |
|---|---|---|
| 375 px | <e.g. one column> | <what stacks, what moves behind a disclosure; the primary action stays reachable; nothing scrolls sideways> |
| 1280 px | <e.g. list beside detail> | <what shows side by side; reading width kept comfortable> |

## S2 <screen name>

<same shape as S1: header line, ### Variants, ### Layout, ### States, ### Microcopy, ### Accessibility, ### Responsive>

## Demo layout (90 seconds)

| Beat | Time | Screen · state | What the viewer sees | Action |
|---|---|---|---|---|
| B1 | 0:00-0:15 | S1 · Success | <what is on screen> | <the one click, or the line said> |
| B2 | 0:15-0:35 | S2 · Error | <the error and its fix> | <the one click, or the line said> |

Total: <m:ss> (at most 1:30) · Non-happy state shown in: <beat id> · Key screens shown: <every key screen id>

## Open questions

- ⚠ <question> | none
