## Why

Caffeine pairs are hand-written today; a target project's dependency
manifest already says which topics matter. Discovering dependencies is
mechanical and belongs in a script; drafting a package's best practices is
judgment and belongs to the LLM — but only behind the existing gates, so a
generated sidecar is held to exactly the standard of a hand-written one.

## What Changes

- Add `bin/routine-deps`: detects the target's package manager manifest
  (`Gemfile`, `package.json`, `requirements.txt`), extracts direct
  dependency names with grep/awk only, and prints one caffeine topic per
  line (`ruby/<gem>`, `js/<package>`, `python/<package>`). No manifest →
  non-zero naming what it looked for. Multiple manifests → all of them.
- Add `skills/caffeinate/SKILL.md` (`/caffeinate`, human-invoked): runs
  `routine-deps` on the target, lets the human pick which topics to
  generate, then for each drafts `caffeine/<topic>.md` (judgment guidance)
  and `caffeine/<topic>.sh` (3–5 mechanical grep-able rules) plus one bats
  fixture per rule — and refuses to declare success until
  `routine-selfcheck` is green over the generated scripts.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `caffeine`: gains dependency discovery (scripted) and the generation
  contract (LLM drafts, selfcheck gates).

## Impact

- New: `bin/routine-deps`, its bats suite and manifest fixtures,
  `skills/caffeinate/SKILL.md`.
- No existing script changes; generated pairs land in `caffeine/` through
  the normal change loop like any other code.
