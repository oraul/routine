## Why

The scripts are the protocol, but their contracts live in three drifting
places: prose comment headers (unchecked), restatements in skills and
agent prompts (the drift the agents council spent G1–G6 repairing), and
the reader's patience. An agent that wants to call `routine-next`
correctly today reads the whole implementation. The caffeine corpus
already solved this class of problem — fixed-form metadata lines
enforced by a lint, cataloged by a computed list — and `bin/` is the
last artifact class without that treatment.

## What Changes

- **Frontmatter on every `bin/` script**: fixed-form comment lines
  after the shebang — `routine-script`, `routine-description`,
  `routine-usage`, `routine-exit` (one per code), `routine-test`,
  `routine-env` — in the flat greppable grammar the caffeine headers
  established. `head` of a script is its full calling contract; no
  implementation reading required.
- **`bin/routine-script-lint`**: the contract as exit codes, all
  cross-checked against the body — name agrees with filename, usage
  agrees verbatim with the printed usage string, every literal exit
  code documented and every documented code real (a dynamic
  `exit "$var"` covers exactly 0 and 1), the named test file exists
  and mentions the script, `ROUTINE_TICKET_DIR`/`TARGET` declared iff
  referenced. Every violation in one run.
- **`bin/routine-manual`**: the whole script surface assembled from
  frontmatter alone — computed, never curated — so an agent loads one
  output instead of 22 files.
- **Selfcheck runs the script lint** after the caffeine lint, before
  shellcheck.

## Capabilities

### New Capabilities

- `script-contract`: the frontmatter grammar, its lint, and the
  computed manual.

### Modified Capabilities

- `selfcheck`: the script lint joins the gate order.

## Impact

- Added: `bin/routine-script-lint`, `bin/routine-manual`,
  `test/script_lint.bats`, `test/manual.bats`.
- Modified: every script in `bin/` (frontmatter only — no behavior),
  `bin/routine-selfcheck`.
