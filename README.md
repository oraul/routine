# routine

> An efficient routine is a daily routine being refined.

**routine** is a Claude Code plugin that runs a spec-first, two-agent
development loop against any target project with zero setup in that
project. Prompts define the work; deterministic bash scripts enforce the
rails: every gate, state change, and lifecycle step is a script with
exit-code semantics. The tool refines itself through telemetry and retros,
and earns every abstraction from evidence — this repository is built under
the same laws it enforces.

## How a run flows

```
preflight → specify → approve → develop → conclude
```

The **analyst** decomposes a requirement (typed `bug`, `feature`,
`greenfield`, or `epic` — each with its own calibration) into briefings and
tasks in a mechanically linted grammar. The human approves at a hard stop.
The **developer** then consumes one task at a time from a strictly ordered
line, red → green per scenario, with per-task caffeine (topic-specific
rules and guidance) checked by sidecar scripts at the developer gate. A
scripted conclude archives the ticket with its report; `routine-retro`
turns accumulated telemetry into the evidence future changes are earned
from.

## Skills

- **`/routine`** — drive the phase protocol against the current target.
- **`/unblock <ticket> <task>`** — capture human context that releases a
  blocked task line.
- **`/caffeinate`** — read the target's dependency manifests and grow new
  caffeine pairs, gated by the harness.

## Capabilities

The durable record is [`openspec/specs/`](openspec/specs/) — every
capability below was built spec-first, change by change:

| capability | one line |
|---|---|
| `selfcheck` | the harness integrity gate: lint clean, suite green |
| `gates` | selfcheck → baseline → app hook composition per phase |
| `telemetry` | fixed-key-order JSONL evidence, script-owned |
| `tickets` | scaffold, allocation, the ordered blockable task line |
| `spec-grammar` | the ticket grammar the lint enforces |
| `retro` | compute-don't-store aggregation of all telemetry |
| `operation` | the phase protocol and both agent contracts |
| `caffeine` | per-topic teaching docs + mechanical sidecars |
| `calibration` | per-work-type decomposition and developer posture |
| `release` | what a tag asserts and the scripted gate that blesses it |
| `guidance` | the session contract (CLAUDE.md) and this README |

## Install

```sh
claude plugin install oraul/routine
```

or clone and point Claude Code at the checkout. Operational state lives
under the plugin's own gitignored `runs/`; target projects never receive a
single file.

## Develop

See [CONTRIBUTING.md](CONTRIBUTING.md) — spec first, never vibe. The gate:

```sh
bin/routine-selfcheck    # shellcheck + bats; requires bats and shellcheck
```

Releases follow the tag contract in CONTRIBUTING's Releases section:
`bin/routine-release-check vX.Y.Z` must bless the commit before any tag.
