## Context

The analyst authors manifests against a hidden vocabulary with a hard
failure budget; discovery emits names content doesn't have. K1 gave the
corpus a contract; K4 makes it navigable and makes discovery honest.

## Goals / Non-Goals

- **Goals**: a browsable computed catalog; teaching refusals;
  discovery output that resolves.
- **Non-Goals**: new topics (K5); a stored INDEX.md (computed beats
  stored, and a depth-one `.md` would fight the topic contract's own
  layout rule).

## Decisions

- **The catalog is a script, not a file** — same law as retro: computed,
  never stored, so it cannot drift. One line per topic:
  `<topic>  <pair|doc-only>  <lede>`, lede taken from the first prose
  line after the metadata header.
- **Aliases are a TSV at `caffeine/aliases.tsv`** (`<emitted>	<topic>
  [<topic>…]`): data consulted by `routine-deps` after extraction, awk
  only. One-to-many rows express "implies" (rails also loads
  active_record). Unknown names pass through — the alias table narrows
  nothing, it only lands known packages on real topics.
- **The lint failure enumerates the vocabulary** from the same walk the
  catalog uses — the analyst's revise attempt starts from the menu, not
  a guess.
- **deps.bats stops asserting dead strings**: `rspec-rails` now asserts
  `ruby/rspec`; the Rails Gemfile asserts `ruby/active_record` rides
  along.

## Risks / Trade-offs

- [An alias row can hide a legitimate new topic name] → aliases map
  names that will never be topics (gem spellings); the lint still
  refuses a manifest topic that resolves nowhere.
- [Implies-rows grow opinionated] → each row is reviewable data in one
  file; the caffeinate skill owns additions.

## Migration Plan

Additive scripts and data; discovery output changes only where it was
dead. Rollback = revert the merge commit.
