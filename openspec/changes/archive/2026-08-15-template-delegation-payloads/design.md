# Design — template-delegation-payloads

## The contributor precedent, one level up

`.claude/agents/contributor.md` exists because two hand-written
delegation prompts for the same role differed. The fix was not better
discipline; it was moving the invariant half into a file so only the
variable half is composed each time.

The skill's payloads are the same shape. The invariant half — which
handles, which artifacts, which resolution rules — is identical every
run. The variable half is the requirement, the ticket, the task path.
A template splits them; prose does not.

## Why absolute paths are in the template, not left to the driver

"The ticket directory" is resolvable only by someone who already knows
where it is. A stateless agent has no cwd it can trust and no
environment it inherits — the skill's own text says a payload is the
agent's whole world. Every payload this session that worked carried
resolved paths; writing that into the template makes it a property of
the interface rather than of the driver's memory.

## Why the revise handoff is a template line

The skill already says recovery reads `grounding.md`, `lint.log` and the
`defect.md` files rather than re-running the gate. Run 0002's analyst
lost its only revise to a rule its payload never mentioned; run 0003's
analyst received the lesson and gated clean on the first pass. Same
agent, same tier — the difference was the payload.

A rule stated in the skill's prose but absent from the payload template
is a rule the driver must remember. A rule in the template is one it
cannot forget to pass.

## What the pin cannot do

It can assert the template exists and names its parts. It cannot assert
a driver used it, because nothing observes a delegation — the same limit
the skill's other pins carry, and the same reason `contributor.md` is
checked for content and never for use.

## Non-Goals, with what would earn each

- **A script that composes the payload.** The driver is a session, not a
  script; a composer would need to read the ticket and guess intent.
  Earned if payload variance is ever observed *despite* the template.
- **Templating the scout payload.** Scouts are permissive and their
  prompts are transcript-only by contract — nothing downstream depends
  on their text.
- **Passing `grounding.md` to the developer.** Refused in
  `widen-developer-context` and unchanged here: the briefing is the
  analyst's deliberate export.
