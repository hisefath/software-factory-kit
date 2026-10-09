# draw-diagrams per-type rules

Read only "Mermaid rules" and your own type's section. Each type section has the same parts:
**Source** (the form the section must be in; another form → write no diagram, `human_review` "section is not in
design-<hld|lld> form"), **Kind**, **Required** (anything here the source does not state becomes a gap line),
**Notation** (how each piece of the design doc's text is drawn), **Never** (the usual invention for this type),
**Check** (what `dd_typecheck` and `dd_trace` enforce for this type; each prints nothing when the diagram is right),
**Ids drawn** (the id prefixes `dd_trace` requires in the diagram), **Count** (what `dd_counts` reports) and
**Reviewer's question** (the plain-language line for the STOP message, so the human learns what this kind of
diagram is for). The helpers live in `references/kit.md`.

## Mermaid rules (every type)

- **Ids.** An element with a source id uses it without the hyphen (`CN-1` → `CN1`, `BE-2` → `BE2`). An element
  without one uses its source name when that is a single word of letters, digits and `_` exactly as spelled
  (`DB`, `orders`, `draft`). Otherwise it gets a fallback id, numbered in order of first appearance: `P<n>` person,
  `X<n>` external system, `S<n>` state, `N<n>` anything else; its label carries the source words. Never use `end`,
  `graph`, `subgraph`, `class`, `style`, `state`, `note` or `default` as an id, and always put a space on both
  sides of a link (`A---oB` would draw a circle end).
- **Words.** Copy the source's words exactly, without markdown markup (drop backticks and `**`) and without
  adjectives of your own. The only other words allowed are Mermaid keywords and this file's fixed notation for
  your type (`dd_notation` lists them: e.g. `our system`, `owns:`, `main path (steps a-b)`, `ref`, `not null`).
  `dd_trace` reports any other word.
- **Escapes, everywhere text is copied** (labels, messages, transition labels, erd comments): `"` → `#quot;`,
  `;` → `#59;`, `#` → `#35;`. Mermaid turns them back in the picture and `dd_trace` ignores them, so they are
  neither raw breaking characters nor new words.
- **Labels.** Double quotes when a flowchart or class label holds spaces, punctuation or `<br/>`:
  `CN1["CN-1 Web app<br/>Laravel 13"]`. Line breaks inside a label: `<br/>`.
- **Comments.** `%%` at the start of their own line (indentation allowed). `%%{` starts a directive: never write
  one. Comments before the diagram keyword are fine (Mermaid strips them before detecting the type).
- **Shapes and lines, no colours** (GitLab and GitHub render in light and dark mode): rectangle = running code,
  cylinder `[( )]` = stores data, stadium `([ ])` = person, subroutine `[[ ]]` = external system, dashed border =
  trust zone, solid arrow = sync call, dotted arrow `-.->` = async hand-off.
- **Never truncate.** A diagram too big to read is a design question for Questions, not a reason to drop nodes.

## hld-context

- **Source:** hld.md §2 — one table `Element | Kind | Interaction with our system | Data exchanged | Owner | Basis`
  with exactly one `our system` row.
- **Kind:** `flowchart LR` (default). `C4Context` only when the job or source asks for it: Mermaid marks C4 as
  experimental and it renders differently across GitLab and GitHub versions, so a flowchart is the safer default
  for a doc people review in the browser.
- **Required:** exactly one box for our system; one node per §2 row; one arrow per row's Interaction (two when
  the row states both directions). A row without an Interaction is a gap on that node.
- **Notation:** ids here are always `SYS`, `P<n>`, `X<n>`.
  - Kind `our system` → `SYS["<Element><br/>our system"]`.
  - Kind `person` → `P<n>(["<Element><br/>person"])`.
  - Kind `external system` → `X<n>[["<Element><br/>external system · <Owner>"]]`.
  - Interaction "uses it to …" or "it calls us to …" → `<it> --> SYS`; "we call it to …" → `SYS --> <it>`.
  - Arrow label → `"<Interaction>: <Data exchanged>"`.
- **Never:** draw containers inside our system (that is `hld-container`), or add an identity provider, email or
  payment service the §2 table does not list.
- **Check:** exactly one our-system box (flowchart: one `<br/>our system"]`; C4: one `System(`); every §2 Element
  appears in the diagram.
- **Ids drawn:** none. **Count:** nodes, edges.
- **Reviewer's question:** "Is every outside party our system depends on in this picture, and is anything here
  that we do not actually talk to?"

## hld-container

- **Source:** hld.md §3 Containers (`Id | Container | Technology | Responsibility | Data owned | …`, rows `CN-n`),
  §4 Connections (`Id | From → To | Protocol | Sync / async | …`, rows `L-n`), §5 `### Boundaries`
  (`Id | Boundary | Less trusted side | More trusted side | Crossing connections`, rows `TB-n`).
- **Kind:** `flowchart LR`, one `subgraph` per trust zone.
- **Required:** every CN id as a node with its Technology; every L id as an edge labelled with its protocol and
  sync/async; every TB id as a dashed zone. A missing protocol or sync/async is a gap on that edge.
- **Notation:**
  - CN row → `CN<n>["CN-n <Container><br/><Technology>"]`; a cylinder `CN<n>[("…")]` when its Responsibility,
    Technology or Data owned says it stores data (database, cache, queue, object store).
  - L row → an edge From → To labelled `"L-n <Protocol>, <sync | async>"`; `sync` → `-->`, `async` → `-.->`.
    An actor or external system in From/To is a node outside every zone (`P<n>` stadium, `X<n>` subroutine).
  - TB row → `subgraph TB<n> ["TB-n <Boundary>"]` around the containers on its More trusted side, plus
    `style TB<n> stroke-dasharray: 5 5`. Nest a zone inside the zone it sits in (internet → app → database becomes
    TB-1 around the app and TB-2 inside it around the database), so every L edge that crosses a boundary visibly
    crosses a dashed line. Two boundaries whose trusted sides overlap without nesting: sibling subgraphs plus a gap
    line naming the overlap.
  - Brownfield `(existing)` / `(changed)` / `(new)` suffixes are copied as written.
- **Never:** add a load balancer, CDN, cache or queue not in §3; label an edge with an auth scheme (§4's Auth
  column stays in the table).
- **Check:** every `subgraph TB<n>` has its `style TB<n> stroke-dasharray` line; every CN, L and TB id is drawn.
- **Ids drawn:** `CN|L|TB`. **Count:** nodes, edges.
- **Reviewer's question:** "Follow each arrow that crosses a dashed line: what proves who is calling, and what
  happens to the user when the other side is down?"

## deployment

- **Source:** hld.md §11 — one table `Environment | Runs on | Containers | Deployed by | Secrets from | Data |
  Basis`.
- **Kind:** `flowchart TB`, one `subgraph` per environment.
- **Required:** every environment row; what it runs on; the CN ids it hosts; who deploys it; where its secrets
  come from. An empty cell is a gap on that environment.
- **Notation** (`<env>` = the Environment cell with every non-letter, non-digit as `_`):
  - Environment row → `subgraph ENV_<env> ["<Environment> · <Runs on>"]`.
  - Containers cell → one node per CN id inside it: `<env>_CN<n>["CN-n"]`, the id only, because §11 names no
    containers and §3 is not your source. One CN may appear in several environments.
  - Deployed by → `DEP_<env>(["<Deployed by>"]) -.->|"deployed by"| ENV_<env>`.
  - Secrets from → `SEC_<env>[/"secrets from: <Secrets from>"/] -.->|"secrets from"| ENV_<env>`: the source
    only (e.g. "Railway variables"), never key names or values.
  - Runs on `none — <reason>` → one node `<env>_none["<Environment>: none · <reason>"]`, never an empty subgraph.
  - The Data and Basis columns are not drawn; the table keeps them.
- **Never:** invent a staging environment, a CI runner or a region the table does not list.
- **Check:** no secret-looking `= <value>`; every Environment appears; every CN id is drawn.
- **Ids drawn:** `CN`. **Count:** nodes, edges.
- **Reviewer's question:** "Could someone redeploy production from this picture, and where does each environment
  get its secrets?"

## erd

- **Source:** lld.md §1 in design-lld form: one ``#### `<table>` …`` block per table with a
  `Column | Type | Null | Default | Constraint | Notes` table and `Primary key` / `Foreign keys` / `Unique`
  bullets, plus a `### Relationships` table `From | To | Cardinality | Via | Required? | Basis`. A section with no
  `#### ` column tables (only prose, or only a Mermaid block) is not in design-lld form.
- **Kind:** `erDiagram`.
- **Required:** every table; every column with its type and nullability; a `PK` on every table; `FK` on every
  foreign-key column; `UK` on every unique column; every relationship with cardinality at both ends. A table with
  no stated primary key, a column with an empty Null cell, or a relationship with no cardinality is a gap.
- **Notation** (attribute line `type name KEYS "comment"`, comment parts joined with ` · `):
  - ``#### `<table>` `` heading → entity `<table> { … }`.
  - Column row → type = the Type cell's first word (`bigint identity` → `bigint`, rest to the comment;
    `decimal(10,2)` → `decimal`, `(10,2)` to the comment, because a type is one token without commas).
  - Null `no` / `yes` → the comment starts `not null` / `nullable`.
  - Constraint `PK` (or the column in `Primary key`) → `PK`. Constraint `FK <name>` → `FK`, and the comment adds
    `ref <parent>.<col>` from the `Foreign keys` line. Combine keys as `PK, FK`.
  - `Unique: <name> (<cols>)` → `UK` on each member column, comment adds `<name> (<cols>)`; a partial unique
    (`WHERE …`) is a comment on the scoped column only. Defaults, CHECKs and indexes stay in the tables.
  - Relationships row → `<From> <left><line><right> <To> : "<Via column name>"`, ends from Cardinality read
    left to right: `1` → `||`; `0..1` → `|o` left, `o|` right; `0..N` → `}o` left, `o{` right; `1..N` → `}|`
    left, `|{` right. Label = the column in Via (`orders.customer_id` → `"customer_id"`), never an invented verb.
  - Line `--` (solid, identifying) only when the FK column is part of the child's primary key; otherwise `..`
    (dashed, non-identifying). Teach this at review: identifying means the child cannot exist, or be named,
    without its parent.
  - `N — M` via a join table → two relationships drawn from the join table's own FKs. No join table block in the
    section → gap line.
  - The FK's Null cell and the Cardinality disagree (Null `yes`, parent end `1`) → contradiction line, draw `|o`.
    An FK of unknown nullability → `parent |o..o{ child` plus a gap. `}o..o{` only when neither end is stated.
- **Never:** add `id`, `created_at`, `updated_at`, `deleted_at` or indexes the section does not list.
- **Check:** every relationship line has cardinality at both ends; every `table.column` of the section is drawn
  and none is invented.
- **Ids drawn:** none. **Count:** entities, relationships.
- **Reviewer's question:** "Each 'exactly one' end is a rule the database will enforce: is every one of them
  really never empty, and does every money or status column say where it comes from?"

## be-class

- **Source:** lld.md §2: one `### BE-n <Name> · <kind> · <CN-n> · <new | changed>` block per component, with a
  `Depends on:` bullet and a `Public method (signature only) | Called by | Returns | Raises | Covers` table.
- **Kind:** `classDiagram`.
- **Required:** every BE block; each of its public methods with parameters and return type as written; every
  dependency, inheritance or interface implementation it states. A method named without a signature is a gap on
  that class.
- **Notation:**
  - `### BE-n <Name> · <kind> · …` → `class BE<n>["BE-n <Name>"]` and `<<kind>> BE<n>` (e.g.
    `<<controller>> BE2`). If `mmdc` reports a parse error on class labels (older Mermaid), use `class <Name>`
    plus `note for <Name> "BE-n"` instead.
  - Method row `` `name(params): Ret` `` → `BE<n> : +name(params) Ret` (the return type moves after the
    parenthesis); generics `List~Order~`.
  - `Depends on:` a BE id → `BE<n> ..> BE<m> : depends on`. Other entries (framework services, request objects) →
    `note for BE<n> "depends on: <those entries>"`, never an invented class.
  - "extends X" → `X <|-- BE<n>`; "implements Y" → `Y <|.. BE<n>`; "owns the lifecycle of" → `*--`; "holds a
    reference to" → `o--`; each only when stated. `namespace X { … }` only if the section groups components.
- **Never:** add private fields, getters/setters, constructors or "obvious" DTOs the section does not name.
- **Check:** every method has its parentheses; every BE id and every method name in the tables is drawn.
- **Ids drawn:** `BE`. **Count:** classes, relationships.
- **Reviewer's question:** "Do the dependency arrows all point one way (no cycles), and does each class have a
  single reason to change?"

## fe-components

- **Source:** lld.md §3: `### Component tree` (nested list of `FE-n <Name>`), `### Components`
  (`Id | Component | Screen | Props in | Events out | Owns state | Screen states rendered`) and
  `### State ownership` (`Id | State | Kind | Owner | Consumers | How passed | …`). §3 `n/a — <reason>` has no job.
- **Kind:** `flowchart TD` (default; reads as a tree) or `classDiagram` when the job asks for a class view.
- **Required:** the tree from the root; every component under its stated parent; for each, the state it owns and
  the state it reads. An empty Owns state cell is a gap on that node.
- **Notation:**
  - Tree item → `FE<n>["FE-n <Name><br/>owns: <Owns state cell><br/>reads: <ST ids>"]`; `none (stateless)` stays
    `owns: none (stateless)`; an empty cell → a gap line directly above the node and no `owns:` line.
  - `reads:` = each ST id whose Consumers name this FE and whose Owner is not this FE; no such id → no line.
  - Nesting → `parent --> child`, labelled `"<child's Props in>"` unless it is `none`.
  - Events out (not `none`) → `child -.->|"<event>"| parent`.
  - Class view: `class FE<n>["FE-n <Name>"]`, `<<component>> FE<n>`, members `owns <ST ids>` / `reads <ST ids>`,
    `parent *-- child`.
- **Never:** add a store, context provider or state library the section does not name; move state to where you
  think it belongs.
- **Check:** every flowchart node has `owns:` unless a gap line sits directly above it; every FE and ST id is drawn.
- **Ids drawn:** `FE|ST`. **Count:** nodes, edges.
- **Reviewer's question:** "Is each piece of state owned by exactly one component, as low in the tree as it can
  live, and does every other component only read it?"

## sequence-<journey>

- **Source:** the one lld.md ``### SEQ-n <Title> · `sequence-<journey>` · …`` block: a `**Participants:**` line,
  numbered steps `n. From → To: message`, and zero or more `**alt <condition>** (replaces steps a-b)` blocks of
  `- aN. From → To: message`. No numbered steps → not in design-lld form.
- **Kind:** `sequenceDiagram`, with `autonumber` on the line after the keyword.
- **Required:** every participant; every step, in order; every alt branch with all its a-steps; at least one
  `alt` / `else`. No alt in the source → the template's gap `else`, so the gap shows in the rendered picture.
- **Notation:**
  - Participants line, in its order (then any participant first seen in a step) → `actor <Name>` for
    `(actor)`, `participant <ID> as <ID text>` for an id (`participant FE2 as FE-2 OrderPage`),
    `participant <Word>` for a single-word name (`DB`), `participant N<n> as <words>` otherwise.
  - Step `n. A → B: text` → one line `A->>B: text`. Use `-->>` when it answers an earlier `->>` from B to A that
    has no answer yet, and `-)` when the step ends `(async)`. A step without `From → To` (a remark) →
    `Note over <previous step's receiver>: text`. `[tx begin]` / `[tx commit]` stay in the message text.
  - Alt branches → the main-path steps a branch replaces go inside `alt main path (steps a-b)` (a fixed label:
    design-lld states no success condition), then one `else <condition>` per `**alt**` that replaces those steps,
    in source order, each holding its a-steps, then `end`. A branch replacing a different range gets its own
    `alt main path (…)` at its first replaced step; a range inside another range nests inside that range's main
    path; partly overlapping ranges → gap line and `human_review`. An alt without "replaces steps" → its own block
    around the last step plus a gap line; a branch named only in prose → `else <condition>` holding
    `Note over <participant>: ⚠ missing: messages for <condition>` plus a gap line.
  - `opt` for a step the source calls optional; `loop` only for a retry or poll the source states, with its
    limit. `autonumber` counts in drawing order; the `(steps a-b)` labels keep the source's numbers.
- **Never:** invent status codes, retries, timeouts or a "user sees an error" step.
- **Check:** `autonumber`, `alt`, `else` and `end` present; message + Note lines (gap Notes aside) equal the
  source's `n.` + `aN.` steps; every participant id drawn.
- **Ids drawn:** the id prefixes on the `Participants:` line. **Count:** participants, messages.
- **Reviewer's question:** "At each step that can fail, what does the person see, and which step is safe to
  retry without charging or writing twice?"

## state-<entity>

- **Source:** the one lld.md ``### SM-n <Title> · `<table>`.`<column>` · `state-<entity>` `` block: an
  `**Initial:** … · **Terminal:** …` line, a `State | Meaning` table and a
  `From | Event (trigger) | Guard | To | Side effects | If illegal` table.
- **Kind:** `stateDiagram-v2`.
- **Required:** every state; the start; every terminal state; every transition with its event and, if stated,
  its guard. A transition with no event, or a block with no Initial or Terminal, is a gap.
- **Notation:**
  - State row → the value as written is the id (`draft`); a value that is not a single word →
    `state "<value>" as S<n>`.
  - `Initial: x` → `[*] --> x`; each `Terminal: y` → `y --> [*]`.
  - Transition row → `<From> --> <To> : <Event cell> [<Guard cell>]`; Guard `—`, `none` or empty → no brackets.
  - Side effects and If illegal are not drawn (G3 reads them in the table). Composite states only when the
    section nests them; `<<choice>>` only for a branch on a stated guard.
- **Never:** add a "cancelled", "failed" or "expired" state the section does not list.
- **Check:** a start and an end (or a gap line naming the missing one); every State row drawn; transitions drawn
  (start and end arrows aside) equal the transition table's rows.
- **Ids drawn:** none. **Count:** states, transitions (start and end arrows aside).
- **Reviewer's question:** "Is there a way out of every state that is not final, and what happens if the same
  event arrives twice?"
