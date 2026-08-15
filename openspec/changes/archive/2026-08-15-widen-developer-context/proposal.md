# Proposal — widen-developer-context

## Why

The analyst surveys the target and records what it found: `grounding.md`
carries claim-bearing Evidence bullets, and the briefing carries the
conventions in force. Both archived proving runs wrote them.

Neither reaches the developer. Its closed context list is task.md, the
requirement's typed section, the caffeine manifest and the calibration —
`grep briefing agents/developer.md` returns nothing. So the developer
re-reads the target to re-learn what the analyst already established,
and the briefing is read by the human at approve and then by no one.

The cost is measurable: run 0003's second developer spent part of 37
tool calls re-deriving minitest conventions that sat in the briefing it
could not see. The analyst compensates by hand-copying conventions into
task prose — uncontracted, so it happens when the analyst remembers.

Every persistent error across three proving runs traced to an
interface, not to an agent. This closes the widest one.

## What Changes

- The developer's closed context list gains **its own task's
  `briefing.md`** — the slice it is implementing inside, nothing wider.
- The analyst contract requires the briefing to carry the conventions in
  force for its slice, promoting an existing habit to contract.
- The developer contract states the precedence: the briefing's
  conventions sit with the target's own conventions, below the task's
  own text.

## Impact

- Affected specs: `operation`
- Affected code: `agents/developer.md`, `agents/analyst.md`,
  `test/agents_content.bats`
- The list stays closed: one briefing, not the ticket. A developer still
  cannot see other tasks, the index, or `grounding.md` directly — the
  briefing is the analyst's deliberate summary for that slice.
