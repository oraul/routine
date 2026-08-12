## Why

For any non-Ruby target the caffeine system degrades to two
architecture docs: `js/` and `python/` do not exist though discovery
emits them, and the loop's own central discipline — TDD, scripted as
`routine-tdd` — has no topic anywhere, its judgment locked inside the
Ruby rspec guide. The convention harness enforces secrets mechanically
with no teaching counterpart.

## What Changes

- **`testing/tdd`** (doc-only, language-agnostic): what makes a red
  that proves something, one behavior per example, naming after
  behavior, sizing a scenario to one `routine-tdd` cycle, and the
  characterization-vs-red distinction — loadable by every task in every
  ecosystem.
- **`security/secrets`** (doc-only): the teaching half of
  `routine-convention-check` — what counts as a secret, env
  indirection, leak response (rotate, then rewrite), and what secret
  scanning cannot catch.
- **First `js/` pairs**: `js/express` (sync-fs in request code,
  console.log, debugger, wildcard CORS) and `js/vitest` (`.only`,
  `.skip`, raw setTimeout, console.log in tests).
- **First `python/` pairs**: `python/django` (committed `DEBUG = True`,
  bare except, f-string SQL, print) and `python/pytest`
  (reasonless skip, `time.sleep`, placeholder asserts).
- All six through the existing rails: topic contract, provenance
  metadata with real sources, shared sidecar library with per-ecosystem
  include globs, per-rule fixtures.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `caffeine`: the corpus spans four namespaces and three ecosystems;
  the sidecar library's include globs become per-topic data.

## Impact

- Added: `caffeine/testing/tdd.md`, `caffeine/security/secrets.md`,
  `caffeine/js/{express,vitest}.{md,sh}`,
  `caffeine/python/{django,pytest}.{md,sh}`, four
  `test/caffeine_<ns>_<topic>.bats` files, content assertions.
