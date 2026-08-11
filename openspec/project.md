# routine — Project Conventions

> An efficient routine is a daily routine being refined.

**routine** is a Claude Code plugin that runs a spec-first, two-agent
development loop (analyst, developer) against any target project with zero
setup in that project. Prompts define the work; deterministic bash scripts
enforce the rails.

## Laws — non-negotiable, apply to every change

1. **Determinism boundary.** Anything that matters — gates, state, sequencing,
   lifecycle — is a bash script with exit-code semantics. An instruction to an
   LLM is never load-bearing.
2. **TDD from birth.** Every `bin/` script and every caffeine sidecar starts as
   a failing bats test: red → green → commit. Prompt files (skills, agents) are
   exempt from bats; their feedback loop is the retro.
3. **Script-owned state.** The LLM never read-modify-writes the index, never
   moves ticket directories, never appends telemetry. It calls scripts.
4. **Seam contract.** Every gate = routine baseline + optional app hook at
   `runs/<app>/hooks/<gate>.sh`. Exit 0 passes; non-zero aborts and surfaces
   the output. `developer.sh` is mandatory; missing optional hooks log one
   line and pass.
5. **Bash-only runtime.** Operational scripts target bash 3.2 + BSD/GNU
   coreutils: no associative arrays, no `mapfile`, no jq, no Node/Ruby/Python
   in the operational path. OpenSpec (Node) is a dev dependency of this repo
   only and never enters the plugin runtime.
6. **`ROUTINE_ROOT` everywhere.** Every script resolves its state root from
   `ROUTINE_ROOT` (default: `$CLAUDE_PLUGIN_ROOT`, fallback: this repo's
   root). A hardcoded state path is a bug. This is what makes scripts testable
   against fixture directories.
7. **Naming is derivation, not decision.** Branch from change ID, commit from
   task, PR from proposal, app key from directory name. You never invent a name
   where a rule can derive one.
8. **WIP = 1 at every layer.** One open PR maximum in this repo. One strictly
   ordered task line per ticket in operation; a blocked task blocks the line.
9. **Earn abstractions.** The founding scope lists what not to build. Do not
   build it, however natural it feels mid-implementation.
10. **Boring by design.** Plain names, plain bash, no cleverness, no lore.

## Stack

- **Runtime:** bash 3.2-compatible scripts + BSD/GNU coreutils only.
- **Tests:** bats-core; every `bin/` script and sidecar is born from a failing
  bats test.
- **Lint:** shellcheck, clean over `bin/`, `lib/`, and caffeine sidecars.
- **Meta tooling (dev-only):** OpenSpec (Node) governs specs and changes in
  this repo; it never enters the plugin runtime.

## Process

Development conventions — branching, commits, PRs, the loop — live in
[CONTRIBUTING.md](../CONTRIBUTING.md) and are binding from change 1.
