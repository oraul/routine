---
name: routine
description: Run the spec-first two-agent loop against the current target project, one gated phase at a time.
disable-model-invocation: true
---

# /routine — the phase protocol

You drive the phase machine. Scripts decide; you never do. Every transition
below calls a script — a non-zero exit **stops the run** and its output is
the reason. Never edit `index.tsv` or `telemetry.jsonl` directly; they are
script-owned.

The phases, in order: `preflight → specify → approve → develop → conclude`.

## 0. Resolve state

Run `routine-scaffold`. If it exits non-zero, relay its instruction (the app
needs `runs/<app>/hooks/developer.sh`) and stop — the human must create the
facade. Otherwise note the printed app state path. If no active ticket
exists, run `routine-ticket-new` and note the printed ticket path. Export
`ROUTINE_TICKET_DIR=<ticket path>` for every later script call.

## 1. preflight

Run `routine-gate preflight`. Non-zero: stop and surface the output.

## 2. specify

Delegate to the **analyst** agent (`agents/analyst.md`) with the human's
requirement. The analyst writes `requirement.md`, briefings, and tasks in
the ticket. Then run `routine-gate analyst`.

- Non-zero: hand the full defect list back to the analyst to revise.
- At most **3 revise attempts**; still failing → abort the ticket and tell
  the human why.

## 3. approve — hard stop

Show the human `requirement.md` and every `briefing.md`. **Stop and wait**
for the human to say proceed. This is the only human checkpoint in the
operational loop; never continue without it.

## 4. develop

Loop:

1. `routine-next "$ROUTINE_TICKET_DIR"` — exit 0 gives one task path;
   exit 3 means the line is blocked (tell the human to run `/unblock`);
   exit 4 means every task is done → go to conclude.
2. Delegate the task to the **developer** agent (`agents/developer.md`).
3. When the developer reports done, run `routine-gate developer`.
   Green → `routine-done "$ROUTINE_TICKET_DIR"`. Non-zero → the developer
   keeps working; it never improvises around a failing gate.
4. If the developer declares the spec defective, take its stated reason
   back to specify (phase 2). If it wrote `block.md` and called
   `routine-block`, the run halts here.

## 5. conclude

Run `routine-conclude "$ROUTINE_TICKET_DIR"`. It refuses unless every task
is done; on success the ticket is archived with its `report.md`. Relay the
report location. The run is over.
