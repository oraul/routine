# Design — the-roads-are-declared-and-walked

## Ship the destination, don't invent it, don't warn about it

Three candidate fixes for the silent skip were weighed. A `mkdir -p` in
`telemetry_harness_emit` violates the no-invented-destination rule for
a real reason: the app key derives from the working directory, so a
gate run from an arbitrary cwd would mint junk `runs/<dirname>/` trees.
A loud skip (a stderr warning) keeps the silence out but records
nothing — the verdict is still lost. Shipping `runs/routine/` as
tracked repository content fixes the only case the repo owns — itself —
and leaves both existing rules untouched: emission still requires an
existing destination, and other apps still get theirs from
`routine-scaffold`.

## The gitignore re-include mechanics

Git cannot re-include a path whose parent directory is excluded, so
`runs/` (the current rule) must become `runs/*` before exceptions can
work. The shipped rules are:

    runs/*
    !runs/routine/
    runs/routine/*
    !runs/routine/README.md

Pinned by `git check-ignore` assertions: the marker is not ignored,
`runs/routine/telemetry.jsonl` and `runs/shopapp/…` are, and
`git ls-files runs/` names exactly the marker.

## The roads file grammar

One event per line; `#` comments and blanks ignored; the waiver form
`<event> — never walked: <why>` reuses the house em-dash grammar of
`- none — <why>`. The waiver rule is symmetric on purpose: a waivered
road that fires makes the waiver stale, and the check refuses it —
otherwise the file accumulates dead excuses exactly the way a record
accumulates stale counts. Seeded content is the 28 events measured from
call sites and runs evidence today plus `harness.roads`; the sole
waiver is `app.deps`, whose emitter (`bin/routine-deps`, the
/caffeinate discovery road) has never met a live run.

## The check counts itself

`routine-road-check` emits `harness.roads` through the same wrapper as
every other harness verdict, and the event is declared unwaivered. The
bootstrapping consequence is accepted and intended: the first live run
truthfully reports its own road as never walked (exit 1), that run
walks it, and the second run passes. Waivering it instead would go
stale on the first run and refuse on the second — the honest red is the
cheaper one.

## Extraction leans on the spec, not on luck

Observed events are read as field 8 of a `"`-split — legal only because
the fixed-key-order requirement guarantees `event` is the second key of
every line. The comparison itself is three `comm` calls over sorted
name sets (declared, waivered, observed): POSIX, deterministic output
order, no per-event process spawn. Usage errors (exit 2) emit no
telemetry, matching `routine-defect`; verdicts (0 and 1) emit.

## Scope boundary

`runs/` content stays untracked — the boundary drawn when the
run-evidence blind spot was closed stands: durable knowledge travels
through `evidence/` records and the specs, and this change ships a
marker, not data. The check is a session instrument; selfcheck tests
its behaviour on fixtures and never runs it against the live tree.
