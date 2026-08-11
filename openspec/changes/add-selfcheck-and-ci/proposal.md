## Why

routine's guarantees live in deterministic bash scripts, so the repo needs its
enforcement harness before any other script exists: a selfcheck that proves the
scripts and tests are green, and a CI pipeline that makes that check (plus spec
validation) the merge decision. Nothing else can be built test-first until this
scaffold exists.

## What Changes

- Scaffold the plugin repo layout: `.claude-plugin/plugin.json`, `bin/`,
  `lib/`, `test/`, `.gitignore` with the single entry `runs/`.
- Add `bin/routine-selfcheck`: runs shellcheck over `bin/`, `lib/`, and
  caffeine sidecars (when present), then the full bats suite; exit-code
  semantics, `ROUTINE_ROOT`-resolved.
- Add the bats harness under `test/` with a first real test suite covering
  `routine-selfcheck`.
- Add `.github/workflows/ci.yml` with three jobs: `lint` (shellcheck),
  `test` on `[ubuntu-latest, macos-latest]` (bats), and `openspec-validate`
  (strict).
- Extend `CONTRIBUTING.md` with the development conventions and the loop,
  verbatim from the founding prompt, alongside the existing hard rules on
  sensitive data.
- Add a `README.md` stub opening with the thesis.

## Capabilities

### New Capabilities

- `selfcheck`: the harness integrity gate — what `routine-selfcheck` must
  verify (lint cleanliness and test-suite success), how it resolves its root,
  and its exit-code contract.

### Modified Capabilities

<!-- none — this is the first change; no existing specs -->

## Impact

- New files only; no existing behavior changes.
- `bin/`, `lib/`, `test/`, `.claude-plugin/`, `.github/workflows/`,
  `CONTRIBUTING.md`, `README.md`, `.gitignore`.
- Dev dependencies: bats-core and shellcheck (contributors + CI); OpenSpec
  stays a dev-only Node dependency, never in the plugin runtime.
