## Why

No script has ever read a caffeine `.md`. An empty guide, a zero-rule
sidecar, or a `.sh` without its doc all pass selfcheck today; two guides
still say "briefing's manifest" a change after the manifest moved to
tasks; the doc-recited rule lists are hand-copied from the code with
nothing checking agreement; no topic carries a source, version range, or
review date; and retro counts sidecar failures with no run denominator,
so the repo's own earned-from-evidence law cannot be applied to content.

## What Changes

- **A topic contract, lint-enforced**: depth-2 paths; H1 exactly
  `# caffeine: <ns>/<topic>` matching the path; a grep-only metadata
  header (`caffeine-topic`, `caffeine-applies`, `caffeine-source`,
  `caffeine-reviewed` in the doc; topic/applies/reviewed in the sidecar);
  every `.sh` has a sibling `.md`; a doc without a sidecar declares
  `caffeine-mode: doc-only`; sidecars carry 3–5 `check` rules whose rule
  strings appear verbatim in the doc; every sidecar has
  `test/caffeine_<ns>_<topic>.bats`; sidecar shape (`TARGET`, `set -u`,
  `exit "$fails"`).
- **`bin/routine-caffeine-lint`** walks `caffeine/` itself, reports every
  violation in one run, exits non-zero on any, runs inside selfcheck
  before shellcheck, and emits `harness.caffeine` evidence.
- **The corpus complies**: metadata backfilled on all six topics, rule
  lists made verbatim, the stale "briefing's manifest" wording fixed,
  doc-only markers added, and the four caffeine test files renamed to the
  namespaced `caffeine_ruby_<topic>.bats` derivation.
- **Retro gains the deepening queue**: per-script run counts and a
  fail-rate-ranked `caffeine topics:` section that includes doc-only
  topics (`gate.developer.doc` runs), with deterministic sorted output.
- **The spec stops growing O(n)**: the three per-topic requirements
  (ruby seeds, sidekiq pair, rspec pair) fold into the generic topic
  contract.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `caffeine`: the topic contract and its lint; per-topic requirements
  removed.
- `selfcheck`: the caffeine lint joins the integrity gate.
- `retro`: per-script runs and the ranked caffeine section.
- `telemetry`: `routine-caffeine-lint` joins the harness-evidence rule.

## Impact

- Added: `bin/routine-caffeine-lint`, `test/caffeine_lint.bats`.
- Modified: all six `caffeine/` topics (headers, wording, verbatim rule
  lists), `bin/routine-selfcheck`, `bin/routine-retro`,
  `test/retro.bats`, `test/selfcheck.bats`; four test files renamed.
