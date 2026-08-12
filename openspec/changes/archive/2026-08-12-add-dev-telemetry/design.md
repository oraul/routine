## Context

Council findings: empty attribution on gate lines, silent refusals,
untracked scaffold/deps, unrecorded TDD phases, cross-app blocked-seconds
collisions. C4's run audit needs all five fixed before it can replay a
ticket's telemetry against the protocol.

## Goals / Non-Goals

- **Goals**: every development-loop script invocation against real state
  leaves exactly one attributed line; TDD phases are enforced and
  recorded; retro respects the app dimension.
- **Non-Goals**: auditing the event set (C4); new telemetry keys — the
  fixed order `ts,event,script,ticket,task,exit,ms` stands.

## Decisions

- **Attribution is derived, never passed**: `telemetry_gate_emit` reads
  the ticket id from `basename ROUTINE_TICKET_DIR` and the task from the
  `in_progress` index row. Callers cannot lie; empty task means no task
  was in progress — itself evidence.
- **The scenario rides the `script` field** in tdd events, following the
  subject-of-evidence precedent set by `gate.developer.script` (sidecar
  path) and `gate.hook` (hook path).
- **Phase enforcement by exit code**: `routine-tdd red` exits non-zero
  when the command passed — a red that isn't red is a protocol violation,
  not a warning. The emitted line always records the command's actual
  exit, so evidence and enforcement stay separate.
- **Deps emission is conditional on existing app state**: scripts never
  invent a destination (telemetry law); scaffold creates the state, so it
  always emits.
- **Retro reads files via awk `FILENAME`** instead of `cat`, deriving the
  app from the path and keying blocked pairs by app+ticket+task.

## Risks / Trade-offs

- [Lifecycle events now appear with non-zero exits, shifting retro fail
  counts] → that is the point; the counts were undercounting reality.
- [routine-tdd requires the developer to route test runs through it] →
  the skill and agents already mandate showing red; the script makes the
  mandate checkable (C4).

## Migration Plan

Existing telemetry files remain parseable — no key changes. New events
extend the dot-notation family. Rollback = revert the merge commit.
