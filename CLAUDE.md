# CLAUDE.md — the session contract

**routine**: a Claude Code plugin running a spec-first, two-agent
development loop on deterministic bash rails. This file is what you must
know before touching anything; details live where the pointers point.

## Never vibe — spec first

Every behavior change starts as an OpenSpec change (`/opsx:propose`),
validated strict, **before** any implementation. One change = one branch
(`change/<id>`) = one PR; WIP = 1. Housekeeping touching no behavior may
use `chore/<slug>`. The full loop (P0–P4) is in [CONTRIBUTING.md](CONTRIBUTING.md).

## Hard rules — no exceptions, no follow-up-commit fixes

Never put in any commit, PR, or artifact: session URLs, tokens or secrets,
personal names, account identifiers, passwords, or any sensitive data.
Accidental leak = history rewrite + credential rotation, immediately.

## The rails

- The Laws live in [openspec/project.md](openspec/project.md). The two you
  will be tempted to break: anything that matters is a bash script with
  exit-code semantics (prompts are never load-bearing), and abstractions
  are earned from retro evidence, never speculated.
- TDD from birth: failing bats test → red shown → green → shellcheck →
  one tasks.md checkbox = one commit (trailers `Change:` and `Task:`).
- Script-owned state is untouchable: never edit `index.tsv` or
  `telemetry.jsonl` by hand — call the `bin/` scripts.

## Commands that decide

```sh
bin/routine-selfcheck                          # lint + full suite; green or stop
npx --yes @fission-ai/openspec@latest validate --all --strict
bin/routine-release-check vX.Y.Z               # must bless any tag
```

Merges use merge commits (never squash) titled
`Merge pull request #N: <type>: <change-id> — <outcome>` — no usernames in
commit messages.
