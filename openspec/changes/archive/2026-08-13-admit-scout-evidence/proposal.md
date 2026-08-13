## Why

The council weighed "the analyst dispatches haiku scouts" and found one
hard constraint: the analyst is itself a subagent, so nested delegation
cannot be promised until the host provides it. But the landing zone for
scout output already exists by design — grounding.md's claim-bearing
Evidence bullets — and the analyst requirement omits the two context
handles (TARGET, ROUTINE_TICKET_DIR) it factually uses, the same gap
G5 closed for the developer. The earned minimum: admit scout evidence
on the existing rails, promise no machinery.

## What Changes

- **The operation spec's analyst requirement** gains (a) the context
  handles — `TARGET` (the repo it grounds against) and
  `ROUTINE_TICKET_DIR` (where its artifacts land) — and (b) the scout
  clause: the analyst MAY use cheap read-only scouts to survey TARGET
  when the host provides delegation; scout prompts are transcript-only
  and never load-bearing; every accepted scout claim lands as an
  Evidence bullet naming a real path; unverified claims go under
  `## Assumptions`.
- **`agents/analyst.md`** says the same in a short Scouts note.
- **Deliberately not built** (council build-nothing verdicts): no
  `agents/scout.md`, no scout telemetry event, no scout scripts — all
  speculation until retro evidence demands them.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `operation`: the analyst requirement carries the handles and the
  scout evidence clause.

## Impact

- Modified: `agents/analyst.md`, `test/agents_content.bats`.
