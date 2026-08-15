# Proposal — template-delegation-payloads

## Why

`widen-developer-context` gave the developer's closed context list its
own task's `briefing.md`. The skill still tells the driver to hand over
"the task path, the ticket directory, and `TARGET`". **The agent now
expects an artifact the driver is not told to pass** — an inconsistency
this repository created two changes ago and has not closed.

Underneath it sits the wider problem. Both payloads are described in
prose, so every driver composes them from scratch. Across this session's
proving runs the payloads I wrote varied between invocations of the same
role: some carried resolved absolute paths, some did not; one carried
the surviving-record handoff on a revise, another did not.

That variance is the same defect `.claude/agents/contributor.md` fixed
for the development loop: the invariant half of a delegation belongs in
a file, and only what varies belongs in the call. The delegation payloads
are that problem one level up, still unfixed.

## What Changes

- The skill's specify and develop steps carry **literal payload
  templates** rather than prose descriptions of what to include.
- The develop template passes the task's `briefing.md`, closing the
  inconsistency `widen-developer-context` opened.
- The templates carry what the runs proved a payload needs: resolved
  absolute paths, since a stateless agent cannot resolve "the ticket
  directory" relatively; the surviving-record handoff on a revise
  (`grounding.md`, `lint.log`, every `defect.md`), which run 0003's
  zero-revise analyst gate is the evidence for; and the re-served-task
  diff note the prose already carries.

## Impact

- Affected specs: `operation`
- Affected code: `skills/routine/SKILL.md`, `test/agents_content.bats`
- A pin can check the template exists and names its parts. It cannot
  check a driver used it — the same ceiling every prose contract here
  states.
