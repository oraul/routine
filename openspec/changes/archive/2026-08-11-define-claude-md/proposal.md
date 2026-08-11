## Why

Claude Code sessions load `CLAUDE.md` before anything else; today this
repository has none, so every session rediscovers the rules by reading
around — or worse, vibes. The session contract deserves the same treatment
as every other guarantee: spec'd first, then written.

## What Changes

- Define a `guidance` capability: what `CLAUDE.md` must contain — the
  spec-first rule, the hard rules on sensitive data, the laws pointer, the
  mechanical commands, the conventions pointer, and the script-owned-state
  prohibition.
- Write `CLAUDE.md` to that contract.

## Capabilities

### New Capabilities

- `guidance`: the session contract — what every Claude Code session working
  on this repository must know before touching anything.

### Modified Capabilities

<!-- none -->

## Impact

- New: `CLAUDE.md`. No behavior changes; validation is
  `openspec validate --strict` plus a green selfcheck.
