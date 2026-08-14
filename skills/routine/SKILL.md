---
name: routine
description: Run the spec-first two-agent loop against the current target project, one gated phase at a time.
disable-model-invocation: true
---

# /routine — the phase protocol

> **Script paths**: every `routine-*` script lives in this plugin's `bin/`.
> In an installed plugin session invoke them as
> `"$CLAUDE_PLUGIN_ROOT/bin/<script>"`; in this repository, `bin/<script>`.
> The names below are shorthand for that resolved path.

You drive the phase machine. Scripts decide; you never do. Every transition
below calls a script — a non-zero exit **stops the run** and its output is
the reason. Never edit `index.tsv` or `telemetry.jsonl` directly; they are
script-owned.

## Who does what

You are the judgment tier: you hold the human's requirement, build each
delegation payload, and decide what happens between phases. Routine
declares no model for you — a skill has no such field, and this session
is the human's own, so nothing here can enforce or verify it. The agents
you delegate to declare their own tier in their frontmatter, chosen by
who grades their output: the developer's work is graded by tests, gates
and the audit; the analyst's decomposition is graded by a lint and a
human, so it inherits yours rather than being pinned below it.

Delegation costs a context and a round trip. It earns that when the work
is large enough to deserve its own attention — a survey across many
files, an independent judgment, a task taken from red to green — and not
when it is a single tool call you could make yourself.

**When an agent seems stalled**: a delegation returns or it errors —
there is no offline state to poll, and while you wait you are not running
code that could time anything out, so a slow agent is never a timeout and
never an assumption. Read the record instead: `routine-health
"$ROUTINE_TICKET_DIR"` reports the phase, what is in flight and the exact
next command, and `routine-next` re-serves an interrupted task with its
evidence intact.

The phases, in order: `preflight → specify → approve → develop → conclude`.

## 0. Resolve state

Every script's head is its authoritative contract — usage, env, exit
codes — and `routine-manual` prints the whole surface in one call.
Consult it whenever a contract is in doubt; never work from a recalled
one. (The branching below is protocol: what to *do* with each exit.)

Run `routine-scaffold`. If it exits non-zero, relay its instruction (the app
needs `runs/<app>/hooks/developer.sh`) and stop — the human must create the
facade. Otherwise note the printed app state path.

Then run `routine-health` with no argument and branch on its
**exit code** — never judge for yourself whether a run is live or
where it stopped:

- **exit 0, "no active ticket"** — run `routine-ticket-new` and note the
  printed ticket path. This is a fresh run.
- **exit 0 with a ticket path** — a previous session left this run in
  flight (its own token limit, a closed terminal, a stopped agent).
  Adopt the printed ticket, and resume at the phase health derived: its
  `next:` line is the command to run. Do **not** restart at phase 1, and
  do **not** open a second ticket.
- **exit 1** — a human must act first (a blocked line, a pending
  approve, an exhausted revise budget, or more than one active ticket).
  Relay health's output and stop.

Export both handles every later call needs: `ROUTINE_TICKET_DIR=<ticket
path>` and `TARGET=<target project root>` (the project the work lands
in; default is the current directory). `routine-health "$ROUTINE_TICKET_DIR"`
is also the honest answer at any later moment to "where are we?" — it
reads state and never spends a counted gate run to learn it.

## 1. preflight

Run `routine-gate preflight`. Non-zero: stop and surface the output.

A resumed run does not pass through here at all — phase 0 sends it
straight to the phase health derived. If you find yourself running
preflight against a dirty target while a task is in_progress, you took
the wrong road: that is an interrupted develop, handled in phase 4.

## 2. specify

Delegate to the **analyst** agent (`agents/analyst.md`) with the human's
requirement, the ticket directory, and `TARGET` — a stateless agent's
payload is its whole world; never assume it inherits your environment.
The analyst writes `requirement.md`, briefings, and tasks in the ticket.
Then run `routine-gate analyst`.

- Non-zero: hand the full defect list back to the analyst to revise —
  continuing the **same analyst conversation** where it survives, so the
  grounding context is not re-derived. When that context is gone (a
  fresh session, a defect return), hand the analyst the surviving
  record instead: the ticket's `grounding.md`, its `lint.log` (the
  last run's defect list, script-owned), and every task's `defect.md`.
  Recovery reads those files — never a re-run of the gate, which would
  spend a counted revise on information recovery.
- At most **3 revise attempts** per episode (the gate counts them); still
  failing → run `routine-abort "$ROUTINE_TICKET_DIR" "<why>"` and tell
  the human — never an abort in prose.

## 3. approve — hard stop

Show the human `requirement.md` and every `briefing.md`. **Stop and wait**
for the human to say proceed. This is the only human checkpoint in the
operational loop; never continue without it. When the human proceeds,
record it: `routine-approve "$ROUTINE_TICKET_DIR" "<their remarks, if
any>"` — the audit refuses a run whose approval left no evidence, and
the remarks become ticket evidence instead of transcript exhaust.

## 4. develop

**Resuming after an interrupted develop**: health may report
`uncommitted:` — the dead developer's partial work, still in the
target. That is context, not damage. Two roads: work forward from it
(the usual choice — pass the diff to the re-served developer so it
builds on its predecessor instead of duplicating it), or reset the
target and resume from the recorded red. Never leave it unmentioned in
the delegation payload; a stateless developer cannot see what it was
not told.

`routine-next` re-serves the same task — it returns the first row that is not done, in_progress
included, and re-flips nothing — so a task whose developer died is
handed straight back. If `routine-health` reported a passing developer
gate for that task, the work is finished and unrecorded: run
`routine-done` and move on. Otherwise re-delegate the task; the
developer re-records its evidence under the identical label and
command, which the audit pairs against the red already on record. Never
restart the run and never open a second ticket — the allocator refuses
that anyway.

Loop:

1. `routine-next "$ROUTINE_TICKET_DIR"` — exit 0 gives one task path;
   exit 2 is a caller bug (the ticket dir is wrong — fix the path, do
   NOT treat it as a blocked line); exit 3 means the line is blocked
   (tell the human to run `/unblock`); exit 4 means every task is
   done → go to conclude.
2. Delegate the task to the **developer** agent (`agents/developer.md`)
   with the task path, the ticket directory, and `TARGET` in the payload.
3. When the developer reports done, run `routine-gate developer`.
   Green → `routine-done "$ROUTINE_TICKET_DIR"`. Non-zero → the developer
   keeps working; it never improvises around a failing gate.
4. If the developer declares the spec defective, it runs
   `routine-defect "$ROUTINE_TICKET_DIR" "<reason>"`; take the recorded
   reason back to specify (phase 2), and re-run approve for the revised
   artifacts — re-specified work is new work. If it wrote `block.md` and called
   `routine-block`, the run halts here.

## 5. conclude

Run `routine-conclude "$ROUTINE_TICKET_DIR"`. It refuses unless every task
is done **and** `routine-audit` confirms the recorded run matches the
protocol — a skipped stage or a green without its red surfaces here, with
the violations named. Be honest about what a violation means: telemetry
is script-owned and append-only, so evidence missing from a task already
marked done cannot be re-created — the road is
`routine-abort "$ROUTINE_TICKET_DIR" "<the violations>"` and then a
fresh ticket, not a retrofit. Only a violation on run-level or still-in-flight
work (an unreleased block, an unfinished task) can be cured on the rails.
On success the ticket is archived with its `report.md`; relay the printed
archive path. The run is over.
