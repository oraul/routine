## Why

The Ruby caffeine docs list rules but show no shape: a developer agent
reads "fat models, thin controllers" and still has to invent the structure.
An annotated skeleton fixes both problems at once — the agent nearly
copy-pastes the structure, and the comments carry the judgment insights
into its context. Testing deserves its own topic: rspec, structured on
Better Specs.

## What Changes

- Every `caffeine/ruby/*.md` gains an **annotated skeleton**: a compact,
  idiomatic code template whose comments are the insights (the agent reads
  comments as context, not decoration).
- Add the `ruby/rspec` pair: `rspec.md` with the Better Specs file
  skeleton (`describe '#method'`, `subject`/`let`, `context 'when …'`,
  one-behavior examples) and `rspec.sh` with four mechanical rules —
  legacy `.should` syntax, leftover focus marks (`fit`/`fdescribe`/
  `fcontext`/`focus:`), `sleep` in specs, and `any_instance` stubbing.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `caffeine`: guidance docs must teach with annotated skeletons; the
  `ruby/rspec` pair joins the seeds.

## Impact

- Modified: `caffeine/ruby/{rails,active_record,sidekiq}.md`. New:
  `caffeine/ruby/rspec.{md,sh}`, `test/caffeine_rspec.bats`.
