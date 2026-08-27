# routine — Project Conventions

> An efficient routine is a daily routine being refined.
>
> Evidence tries to kill the claim; what survives is knowledge.

**routine** is a Claude Code plugin that runs a spec-first, two-agent
development loop (analyst, developer) against any target project with zero
setup in that project. Prompts define the work; deterministic bash scripts
enforce the rails.

## Laws — non-negotiable, apply to every change

1. **Determinism boundary.** Anything that matters — gates, state, sequencing,
   lifecycle — is a deterministic executable with exit-code semantics. An
   instruction to an LLM is never load-bearing.
2. **TDD from birth.** Every `bin/` script and every caffeine sidecar starts as
   a failing bats test: red → green → commit. Prompt files (skills, agents) are
   exempt from bats; their feedback loop is the retro.
3. **Script-owned state.** The LLM never read-modify-writes the index, never
   moves ticket directories, never appends telemetry. It calls scripts.
4. **Seam contract.** Every gate = routine baseline + optional app hook at
   `runs/<app>/hooks/<gate>.sh`. Exit 0 passes; non-zero aborts and surfaces
   the output. `developer.sh` is mandatory; missing optional hooks log one
   line and pass.
5. **Zero-setup core, scripted seams.** The operational core runs with zero
   setup in the target project beyond the Go toolchain that builds it. Today
   that core is bash 3.2 + BSD/GNU coreutils scripts — no associative
   arrays, no `mapfile`, no jq; its sanctioned destination is a single
   statically linked binary, built locally from the checkout so every user
   runs code they can read, carrying its own commit provenance. The seam
   stays scripts forever: app hooks at `runs/<app>/hooks/<gate>.sh` and
   caffeine sidecars are bash 3.2 + BSD/GNU coreutils, editable in place
   without a toolchain. No interpreter runtime (Node/Ruby/Python) enters the
   operational path on either side of the seam. OpenSpec (Node) is a dev
   dependency of this repo only and never enters the plugin runtime.
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

## Grounding pillars — the vocabulary of evidence

Every recorded claim is judged against seven pillars, named here so
records, retros, and reviews cite a pillar by name instead of
re-deriving the standard:

1. **Provenance** — every claim names its instrument and its anchor:
   what ran, against which commit.
2. **Refutation first** — validation is an attempt to break the claim;
   support-gathering is not validation.
3. **Independent instruments** — evidence comes from a meter the
   claimant does not control; a self-report is testimony, telemetry is
   evidence.
4. **Freshness** — evidence decays with its anchor; a moved anchor
   re-verifies exactly what moved.
5. **Symmetric recording** — what refuted you is recorded at the same
   fidelity as what confirmed you.
6. **Confound honesty** — a comparison claims only what its variables
   allow: name the confound or drop the cause.
7. **Exercised roads** — every road a contract opens is walked and
   harnessed; a path that has never run is a claim never tested.

A pillar is vocabulary, never a gate: the script that enforces one is
earned separately, from retro evidence, like every abstraction here.

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
