# routine

> An efficient routine is a daily routine being refined.

**routine** is a Claude Code plugin that runs a spec-first, two-agent
development loop — an analyst and a developer — against any target project
with zero setup in that project. Prompts define the work; deterministic bash
scripts enforce the rails: gates, state, sequencing, and lifecycle all live in
`bin/` scripts with exit-code semantics. The tool refines itself through
telemetry and retros, and earns every abstraction from evidence.

## Install

Add the repository as a Claude Code plugin:

```sh
claude plugin install oraul/routine
```

or clone it and point Claude Code at the checkout. The plugin ships two
human-invoked skills — `/routine` (the phase protocol) and `/unblock` — plus
`/caffeinate` for growing caffeine pairs from a target's dependencies.
Operational state lives under the plugin's own `runs/` (gitignored); target
projects never receive a single file.

The durable record of what exists is `openspec/specs/` — nine capabilities,
each built change by change.

## Develop

See [CONTRIBUTING.md](CONTRIBUTING.md). Run the harness gate locally:

```sh
bin/routine-selfcheck
```

Requires `bats` and `shellcheck`.
