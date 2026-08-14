# Design — declare-agent-tiers

## The split follows who grades the output

Not seniority, not cost. The developer writes code that a failing test,
a passing test, a gate and an audit all judge mechanically — a weaker
model there is caught by the rails within one task. The analyst writes
the contract those rails enforce; a structural lint can say the grammar
is satisfied and nothing can say the decomposition is right. Judgment
that only a human grades is judgment that must not be pinned below the
session supplying the requirement, which is what inheriting expresses.

## Assumptions

The host honours a `model:` field in an agent file's frontmatter.
Routine cannot test that — no script here can observe which model
answered — so the claim is recorded here rather than asserted as a
guarantee, and the lint checks only what routine owns: that the field
is present and its value is one this repository recognises. If the host
ignores the field, the declaration remains an accurate record of intent
and nothing in the loop breaks.

## Liveness is evidence, not a heartbeat

The proposal that prompted this change included treating a slow agent
as offline. It is not implementable as described: a caller blocked on a
delegation is not running code that could time it out, and there is no
status to poll — the call returns or it errors. The repository already
answers the real question from script-owned state: telemetry stops
advancing, `routine-health` reports the phase and what is in flight,
and `routine-next` hands the interrupted task back. Liveness here is a
property of the record, not of a timer.

## Non-Goals, with what would earn each

- **A supervisor process, retries, or respawns.** Earned when the retro
  records repeated interrupted runs whose recovery cost is measurable —
  the re-specify cost section is where that would show.
- **A heartbeat daemon or any delegation telemetry event.** Earned when
  a consumer exists that would read it; the rejected `spec.grounding`
  event is the precedent for refusing an event nothing reads.
- **A spawn budget or concurrency cap.** Earned when WIP=1 is relaxed;
  today one ticket is in flight by construction.
- **`agents/scout.md`.** The non-goal recorded in
  `2026-08-13-admit-scout-evidence` still stands: scouts are admitted as
  a source of evidence, and a dedicated agent file waits for a run that
  used them.
- **A per-task or per-phase model override.** One tier per role until a
  task type demonstrably needs a different one.
- **A `model` key in telemetry.** The fixed key order is a spec
  guarantee and both readers parse it positionally; the price is a spec
  amendment plus repairs to two awk parsers, for a question nobody has
  asked. The cost is that the retro cannot adjudicate the tiers, which
  the proposal states plainly.

## Delegation is not free

A subagent that greps for files is usually slower and dearer than the
caller running grep. Delegation earns its cost when the work is large
enough to be worth a separate context — a survey across many files, an
independent judgment — not when it is one tool call. That is guidance
for the driver, deliberately prose: no script can judge it.
