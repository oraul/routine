# routine

> An efficient routine is a daily routine being refined.

**routine** is a Claude Code plugin that runs a spec-first, two-agent
development loop — an analyst and a developer — against any target project
with zero setup in that project. Prompts define the work; deterministic bash
scripts enforce the rails: gates, state, sequencing, and lifecycle all live in
`bin/` scripts with exit-code semantics. The tool refines itself through
telemetry and retros, and earns every abstraction from evidence.

## Install

Not yet — the plugin is under construction, change by change, spec first.
Watch `openspec/specs/` grow; that is the durable record of what exists.

## Develop

See [CONTRIBUTING.md](CONTRIBUTING.md). Run the harness gate locally:

```sh
bin/routine-selfcheck
```

Requires `bats` and `shellcheck`.
