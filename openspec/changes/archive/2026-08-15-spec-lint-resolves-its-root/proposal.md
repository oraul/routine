# Proposal — spec-lint-resolves-its-root

## Why

Law 6: *"Every script resolves its state root from `ROUTINE_ROOT`
(default `$CLAUDE_PLUGIN_ROOT`, fallback this repo's root). A hardcoded
state path is a bug. This is what makes scripts testable against
fixture directories."*

`bin/routine-spec-lint:126` reads:

```sh
caffeine_root="$(cd "$(dirname "$0")/.." && pwd)/caffeine"
```

The script that enforces the ticket grammar violates the law it enforces
alongside. Every newer script — `routine-caffeine-lint`,
`routine-script-lint`, `routine-test-lint`, `routine-record-lint` —
resolves through `routine_root()`; spec-lint predates the discipline.

The cost is not tidiness. Law 6 names the consequence itself: a
hardcoded path cannot be pointed at a fixture. So spec-lint's manifest
resolution — the check that refuses a task naming a topic that does not
exist — has only ever run against the real corpus. A caffeine tree that
would break it cannot be constructed in a test.

Found by a contributor extracting the resolver into `lib/caffeine.sh`;
it flagged the divergence and correctly left it out of scope.

## What Changes

- `routine-spec-lint` resolves its caffeine root through `routine_root()`
  like its siblings.
- A pin proves the consequence rather than the line: a fixture
  `ROUTINE_ROOT` redirects manifest resolution, so the check can be
  tested against a constructed corpus.

## Impact

- Affected specs: `spec-grammar`
- Affected code: `bin/routine-spec-lint`, `test/spec_lint.bats`
- No behaviour change against the real corpus: `routine_root()` falls
  back to this repo's root, which is what the hardcoded path computed.
