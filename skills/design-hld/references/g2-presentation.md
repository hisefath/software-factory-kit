# G2 presentation (design-hld)

Load at Step 12 to write the STOP message's decision block. After STOP, the supervisor reuses this file to present
the remaining decisions and the closing question; design-hld itself is finished by then.

## Order of G2 (after design-hld's STOP)

1. The supervisor commits `docs/architecture/hld.md` (design-hld never commits). Nothing is dispatched and no
   answer is recorded before that commit exists: an answer must bind to `artifact@sha` (WORKFLOW §2 rule 6).
2. The supervisor dispatches the three §14 `draw-diagrams` jobs in parallel. Each job file's sources are the §14
   "Draw from" anchors.
3. While the jobs run, decisions go one per reply, in hld.md order, read from `hld.md ### D<n>` in the shape
   below. The STOP message already carried the first one. For each answer, the supervisor writes the Approvals
   row against the committed sha, then runs log-decision. The journal may give the decision a different id.
   The Approvals row and log-decision's "ids differ" line record which journal id matches which hld.md id.
4. When the diagrams are back, the supervisor runs `bash scripts/embed-diagrams.sh docs/architecture/hld.md` and
   commits. Embedding changes the file, so the per-decision answers are now provisional.
5. A Revise on any decision or diagram: the human types `/design-hld`, which runs in revision mode and edits the
   file. The supervisor re-commits and re-dispatches the diagram jobs that the revision STOP names, then carries
   on from the revised decision.
6. When every D<n> has an answer and the diagrams are embedded and committed, the supervisor asks the closing
   question below. That one answer binds every earlier answer to the final sha.

## Decision shape (one per reply)

Teach the tradeoffs in plain words; the human must defend each choice in an interview. Every value comes from
the `### D<n>` section. Never add an option at the gate that the file does not contain.

```
Decision <k> of <m> — D<n> <title>
Type <1|2>: <1 = one-way door, expensive to undo | 2 = two-way door, cheap to change later> · confidence <low|med|high>
Question: <the choice in one line>
Background: <2-3 plain sentences: what forces it, with FR/NFR/C ids>
Options:
  a) Do nothing / simplest — you get <…>, you pay <…>, you'd regret it when <…>. Cost: <build + $/month>
  b) <option> — you get <…>, you pay <…>, you'd regret it when <…>. Cost: <…>
  c) <option> — …
Recommendation: <option>, because <Basis>.
Default if you don't answer: stays proposed; nothing downstream may build on it.
Interview line: "<one sentence>"
```

The reply prompt is not part of the shape. The message that carries the decision ends with exactly one line:
`Reply Approve / Revise (say what to change) / Stop for D<n>.`

## Closing G2 question (supervisor, last)

```
Closing G2 — "docs/architecture/hld.md @ <sha>, diagrams embedded: do these containers, connections, trust
boundaries and invariants match your intent, with D<a>–D<z> as answered?"
Reply Approve / Revise (say what to change) / Stop.
```

Per-decision answers are provisional until this answer is recorded against `<sha>`. design-lld needs this recorded
Approve: every earlier G2 row is on an older sha.
