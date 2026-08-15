# routine

> An efficient routine is a daily routine being refined.

**routine is a working model of a spec-first development loop.** It is
built, it is green, and you can run it — but the thing on offer is the
model, not the plugin. It answers one question: how do you build a loop
where an AI agent does real work and you can still tell, afterwards,
whether it actually did it?

The answer it proposes is a separation. Prompts describe; **scripts
decide**. Every gate, state change and lifecycle step is a bash script
with exit-code semantics, so no phase advances because something was
persuaded — it advances because a script exited 0. Evidence is written by
those scripts and outlives the session that produced it, which means the
run can be audited by someone who was not there.

Take the separations. Leave the bash.

## The concept pipeline

Five phases. What matters is not the dataflow — it is **who is answerable
at each step, and what stops the run there**.

```
preflight → specify → approve → develop → conclude
```

| phase | who decides | what stops the run |
|---|---|---|
| **preflight** | `routine-gate` | a dirty target, a red harness |
| **specify** | the analyst, graded by a lint | 3 failed lints in one episode → abort |
| **approve** | **the human, and only the human** | nothing proceeds without a recorded proceed |
| **develop** | a failing test, then a gate | a red gate, a defective spec, a blockage |
| **conclude** | `routine-audit`, replaying the record | a green with no red before it |

Three actors, and each runs at the tier its **grader** justifies. The
developer's work is graded by a test, a gate and an audit — mechanical,
so a cheaper model is bounded by verification. The analyst's
decomposition is graded by a lint and a human, so it is never pinned
below the session driving it. The scout only reads, and is graded by
whether its caller could then do its job.

The record is never delegated. Every TDD call, every refusal script, and
the judgment that a test is red belong to the actor that owns the task —
because evidence produced in a context nobody graded is not evidence.

## How a run flows

The **analyst** decomposes a requirement (typed `bug`, `feature`,
`greenfield`, or `epic` — each with its own calibration) into briefings and
tasks in a mechanically linted grammar. The human approves at a hard stop.
The **developer** then consumes one task at a time from a strictly ordered
line, red → green per scenario, with per-task caffeine (topic-specific
rules and guidance) checked by sidecar scripts at the developer gate. A
scripted conclude archives the ticket with its report; `routine-retro`
turns accumulated telemetry into the evidence future changes are earned
from.

Those two drive the phases. A third agent, the **scout**, drives none:
it is read-only, answers one mechanical question about the target — where
a symbol lives, which files reference it — and writes nothing. Either
phase agent may delegate reading to it where the host provides
delegation, and neither may delegate the record: the TDD calls, the
refusal scripts, and the judgment that a test is red stay with the agent
that owns the task. Each of the three declares its own `model` tier,
picked by who grades that role's output.

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
| `conventions` | commit/branch grammar and the sensitive-data harness |
| `contract` | typed analyst↔developer topics and the defect return |
| `tdd` | red and green as scripted, evidence-emitting phases |
| `audit` | replay of a ticket's telemetry against the protocol |

## What carries into your project, and what is an accident here

If you take this model somewhere else, these are the parts doing the
work:

- **Script-owned state.** `index.tsv` and `telemetry.jsonl` are written
  only by scripts. Nothing else may edit them — not the agent, not you.
  State an agent can edit is state you cannot trust.
- **Evidence that outlives the session.** Append-only, script-written,
  readable by someone who was not there. It is what makes an audit
  possible at all.
- **A gate whose exit code is the decision.** Not advice, not a
  checklist. Non-zero stops the run and its output is the reason.
- **A human checkpoint that cannot be automated away.** Exactly one, and
  its approval is recorded rather than remembered.
- **A record that is never delegated.** The boundary is writes: reading
  may be handed to a cheaper agent, the evidence rails may not.
- **Abstractions earned from retro evidence.** What was deliberately not
  built is recorded with the condition that would earn it, so a later
  reader inherits the reasoning and not just the decision.

These are accidents of this repository, not part of the model: bash and
bats, the `routine-*` script names, OpenSpec as the spec format,
Claude Code as the host. The same separations work with any language and
any test runner.

## Running it

The code works — 353 tests, green on Linux and macOS — so you can watch
the loop move:

```sh
claude plugin install oraul/routine
```

or clone and point Claude Code at the checkout. Operational state lives
under the plugin's own gitignored `runs/`; target projects never receive a
single file.

Honest scope: the loop is built and tested, not battle-tested. One
concluded run exists against one target project. Treat it as a model that
demonstrably runs, not as a tool proven in production.

## Develop

See [CONTRIBUTING.md](CONTRIBUTING.md) — spec first, never vibe. The gate:

```sh
bin/routine-selfcheck    # shellcheck + bats; requires bats and shellcheck
```

Releases follow the tag contract in CONTRIBUTING's Releases section:
`bin/routine-release-check vX.Y.Z` must bless the commit before any tag.
