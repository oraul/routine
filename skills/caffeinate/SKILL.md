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

For each topic `<eco>/<name>`, create the pair the caffeine spec demands:

- **`caffeine/<eco>/<name>.md`** — judgment guidance: the practices an
  experienced reviewer checks that no grep can, written for the developer
  agent who will load it mid-task.
- **`caffeine/<eco>/<name>.sh`** — a sidecar following the existing
  contract exactly (see `caffeine/ruby/rails.sh` as the reference):
  bash 3.2 + BSD grep, `TARGET`-parameterized, 3–5 rules that are
  genuinely mechanical (grep-able), every hit printed with file, line, and
  rule, exit 0 only when clean.
- **one bats fixture per rule** in `test/` — each rule must demonstrate a
  real catch and the clean fixture must pass. No rule without a fixture.

Rules must encode the package's documented footguns, not invented style
opinions. When you cannot find 3 genuinely mechanical rules for a topic,
say so and write only the `.md` — a weak sidecar is worse than none.
Doc-only topics are first-class: the developer gate accepts a topic whose
`.md` exists without a `.sh` (the `architecture/` namespace is doc-only by
design — judgment in any language, no fake greps).

## 4. Accept

Run `bin/routine-selfcheck`. Generation is complete **only** when it exits
0 — shellcheck-clean sidecars, every fixture green. Then take the generated
pair through the normal OpenSpec change loop (propose → apply → PR); never
commit generated caffeine straight to main.
