# Proposal — the-ruling-stands-until-moved

## Why — a standing ruling is re-demanded as ceremony

The per-question approve gate (#100) fixed the one-word bypass, and
its first epic promptly measured the cost of its bluntness. Ticket
0008's `approve.md` holds four proceeds. The first asked three real
questions and got three real answers. The next three re-demanded
every question each time — twelve `<n>: <answer>` lines across the
three re-approvals, of which exactly two carried an operator
judgment (the Q4 override in the second entry, the A2 amendment in
the fourth). The other ten re-affirmed rulings already on the record,
in filler the driver typed to satisfy the gate — "A1: ruled and
reconciled", "A3: a — seal hole out of scope" three times over
(measured: `runs/shopapp/tickets/archive/0008/approve.md`). A gate
that demands answers carrying no judgment teaches the operator to
type without reading — the exact habit #100 was built to break.

The mechanism already half-exists. When 0008's rulings were baked
back into the grounding, the reconciliation appended
`RULED at approve (approve.md A<n>): ...` to each ruled bullet — but
that form was invented ad hoc mid-run: no contract teaches it and no
script reads it (measured: `grep -rn 'RULED' agents/ skills/ bin/
lib/ openspec/` matches nothing). The record knows which questions
are ruled; the gate cannot see it.

## What changes

- **The gate lets a standing ruling stand.** A non-floor `## Questions`
  bullet carrying the ruled marker no longer demands an `<n>:` line:
  unanswered, the proceed records with an `A<n>:` line saying the
  ruling stands; answered, the answer records verbatim — answering a
  ruled question is how the operator moves its ruling. Ruled bullets
  keep their positions, so no sibling's index ever shifts. Unruled
  questions refuse exactly as today.
- **The marker becomes contract.** The analyst's reconciliation
  obligation names the exact form —
  `RULED at approve (approve.md A<n>): <the standing reading>`,
  appended to the bullet with its provisional text kept in place —
  canonizing the form already on the 0008 record rather than minting
  a second one.
- **The skill teaches it at the checkpoint.** The approve phase says
  which questions demand answers and that answering a ruled one moves
  its ruling.

## What is not built

- **No check that the marker's cited answer exists.** A bullet could
  claim `RULED at approve (approve.md A2)` while no proceed ever
  recorded an A2, and this gate would honour it. That is the
  ruling-vs-artifact consistency seam — the 0008 A2 collision had no
  detector — and it is queued as its own change; earning condition:
  a recorded marker whose cited ruling is absent or contradicts it.
- **No machine judgment of ruling content.** Whether a standing
  ruling still fits an amended requirement stays the operator's read
  at the checkpoint, where the questions are shown either way.

## Impact

- `bin/routine-approve` — ruled bullets stop blocking; entry lines for
  standing rulings; behavior pinned in `test/approve.bats`
- `agents/analyst.md` — the marker grammar in the reconciliation rule;
  pinned in `test/agents_content.bats`
- `skills/routine/SKILL.md` — the approve phase teaching; pinned in
  `test/agents_content.bats`
- specs: `tickets` (Approval is recorded evidence — MODIFIED),
  `operation` (The analyst decomposes and never implements — MODIFIED)
