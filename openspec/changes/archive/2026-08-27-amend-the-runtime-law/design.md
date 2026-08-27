## Decision: amend to the invariant, not the target state

The migration analysis drafted Law 5 as "Compiled core, scripted
seams" — present tense, describing a binary that does not exist at this
commit. A law false at HEAD is a false claim in a published record. The
amendment therefore states what is invariant across the migration (zero
setup, exit-code semantics, the bash seam, no interpreter runtimes) and
names the compiled core as the sanctioned destination, not the present
runtime. The laws stay true at every commit; the migration, if it
proceeds, changes the core's realization without touching the law
again.

## Alternatives considered

- Amend to the target state now: rejected — false until the binary
  lands, and the interim could be long or never.
- Leave the laws alone and propose the migration under current Law 5:
  rejected — the first migration proposal would violate the laws it is
  validated against.
