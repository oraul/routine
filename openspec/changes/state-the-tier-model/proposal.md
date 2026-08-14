# Proposal — state-the-tier-model

## Why

Routine now runs on three declared tiers, and a reader can only discover
that by opening three agent files one at a time. `CLAUDE.md` is what a
session reads before touching anything; it says the loop is two-agent
and says nothing about who runs at which tier or why. A session that
reads only the contract will not know a third agent exists, nor that
delegating the record is forbidden.

The same gap sits in `README.md`, which describes the operational loop
as two agents. That was true and is now incomplete.

## What Changes

- `CLAUDE.md` gains the delegation model in the contract's own register:
  the three tiers, the rule that picks them (who grades the output),
  the writes boundary, and the honest limit — routine checks that a
  tier is declared and recognised, and nothing here can observe which
  model answered.
- `README.md`'s loop description admits the scout as the read-only
  third, distinct from the two agents that drive phases.
- The guidance spec requires both, so the contract cannot silently drift
  back to two.

## Impact

- Affected specs: `guidance`
- Affected code: `CLAUDE.md`, `README.md`, `test/conventions.bats`
- No script changes and no behavior change to the loop; this change
  makes an existing mechanism legible where sessions actually read.
