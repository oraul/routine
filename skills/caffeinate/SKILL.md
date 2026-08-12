---
name: caffeinate
description: Discover a target project's dependencies and generate caffeine topic pairs (best-practices doc + mechanical sidecar) for the ones the human selects.
disable-model-invocation: true
---

# /caffeinate — grow caffeine from the target's own dependencies

> **Script paths**: every `routine-*` script lives in this plugin's `bin/`.
> In an installed plugin session invoke them as
> `"$CLAUDE_PLUGIN_ROOT/bin/<script>"`; in this repository, `bin/<script>`.
> The names below are shorthand for that resolved path.

Discovery is a script; drafting is you; acceptance is the harness. Never
skip a step.

## 1. Discover

Run `routine-deps` (with `TARGET` set to the target project). It prints one
topic per line — `ruby/<gem>`, `js/<package>`, `python/<package>` — or
exits non-zero when the target has no known manifest; relay that and stop.

## 2. Select — with the human

Show the topic list. Most dependencies deserve no sidecar. Recommend the
few where mechanical rules pay (frameworks, ORMs, HTTP clients, anything
with well-known footguns) and let the human pick. Skip any topic whose
pair already exists in `caffeine/`.

## 3. Generate — per selected topic

For each topic `<ns>/<topic>`, create the pair `routine-caffeine-lint`
enforces (it runs first in selfcheck; see `caffeine/ruby/rails.*` as the
reference):

- **`caffeine/<ns>/<topic>.md`** — judgment guidance: the practices an
  experienced reviewer checks that no grep can, written for the developer
  agent who will load it mid-task. The lint demands its shape: the exact
  H1 `# caffeine: <ns>/<topic>`, then the metadata comment headers
  `caffeine-topic`, `caffeine-applies`, `caffeine-source`, and
  `caffeine-reviewed`. Every sidecar rule string appears **verbatim** in
  the doc — the lint rejects a doc drifted from its sidecar.
- **`caffeine/<ns>/<topic>.sh`** — a sidecar sourcing `lib/sidecar.sh`:
  bash 3.2 + BSD grep, `set -u`, 3–5 rules that are genuinely mechanical,
  each a `check <id> "<rule>"` call, ending `exit "$fails"`. The library
  owns TARGET resolution, vendor excludes, and the
  `caffeine/<ns>/<topic>[<id>]` hit format.
- **one bats fixture per topic** at `test/caffeine_<ns>_<topic>.bats` —
  it must demonstrate a real catch and a clean pass. No sidecar without
  its fixture.

Rules must encode the package's documented footguns, not invented style
opinions. When you cannot find 3 genuinely mechanical rules for a topic,
say so and write only the `.md`, declaring `caffeine-mode: doc-only` in
its headers — a weak sidecar is worse than none, and doc-only topics are
first-class in any manifest (the `architecture/` namespace is doc-only by
design — judgment in any language, no fake greps).

## 4. Accept

Run `bin/routine-caffeine-lint`, then `bin/routine-selfcheck`. Generation
is complete **only** when both exit 0 — lint-clean pairs, shellcheck-clean
sidecars, every fixture green. Then take the generated pair through the
normal OpenSpec change loop (propose → apply → PR); never commit generated
caffeine straight to main.
