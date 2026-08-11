## Context

See proposal.md — Why. The developer agent's context is a closed list; the
doc is its only teacher for the topic, so density of transferable structure
matters more than rule count.

## Goals / Non-Goals

- **Goals**: one skeleton per topic that an agent can adapt in place;
  comments as the insight channel; an rspec pair on Better Specs.
- **Non-Goals**: exhaustive API tours; project-specific style (the target's
  own conventions still win where they conflict); factory/fixture
  libraries (target-dependent).

## Decisions

- **Comments carry the judgment**: each skeleton line that embodies a rule
  gets the rule as its comment, so structure and reasoning transfer
  together — the agent reads comments as context, not decoration.
- **Skeletons stay under ~25 lines**: long templates get copied blindly;
  short ones get understood.
- **rspec sidecar scopes to `spec/`**: `sleep` and focus marks are only
  spec hygiene inside spec files; elsewhere other topics own them.
- **`any_instance` is flagged flat**: it stubs objects the example never
  built — the escape hatch is redesigning the seam, and the doc says so.

## Risks / Trade-offs

- [Skeleton idiom vs target idiom conflicts] → each doc states the
  target's conventions outrank the skeleton.

## Migration Plan

Docs plus one additive pair. Rollback = revert the merge commit.
