# Proposal — the-roads-are-declared-and-walked

## Why — the operator's rule, and a premise this change had to correct first

The operator's rule: **all paths that you open, you should harness
them** — an unexercised road is a claim never tested, and the harness
scripts should be more assertive about it. This is the exercised-roads
pillar (#98) getting its first rail.

Grounding the change refuted part of its own design-time premise, and
the correction is recorded here because the symmetric-recording pillar
demands it. The design artifact claimed three roads had never fired and
that three releases' gate verdicts left zero telemetry. Measured today
(the `find`/`cut` union over every `telemetry.jsonl` under `runs/`
ran): **27 of 28** declared events are observed, and
`runs/routine/telemetry.jsonl` holds 2 `harness.release` and 26
`harness.convention` lines — the earlier scan had missed `runs/routine`
entirely. Only `app.deps` has never fired.

What survives the refutation is worse than the refuted claim, not
better:

1. **Capture of the repo's own gate verdicts has depended on an
   accident.** `runs/routine/` exists in this container only because a
   *failed* `routine-scaffold` run created it on 2026-08-15 — its
   `app.scaffold` exit-1 line is the file's first line. Before that
   accident, `telemetry_harness_emit`'s `[ -d ] || return 0` guard
   dropped every repo-context verdict silently; without it, the guard
   still would.
2. **The evidence dies with the container.** `.gitignore` holds
   `runs/`, so the entire tree — all 370 lines of gate verdicts — is
   untracked. Every fresh clone (CI, a new session) is back to the
   silent skip until the accident repeats.
3. **Nothing measures road coverage.** The union above was counted by
   hand, twice, and one of the two counts was wrong. A count that
   exists only when someone remembers to run a pipeline is not a rail.

## What changes

- **The repository ships its own destination.** `runs/routine/` is
  carried by a tracked `README.md` marker with ignore rules re-including
  only that marker, so every clone's repo-context harness verdicts
  record from the first run. Session content stays untracked; the
  no-invented-destination rule stands untouched — nothing is invented
  when the destination is shipped.
- **The roads are declared.** `lib/roads.txt` lists every event the
  contracts can emit — today 28 plus the new check's own — with the
  single honest waiver: `app.deps — never walked: <why>`.
- **The check.** `bin/routine-road-check [runs-dir]` judges declared
  against walked in both directions and refuses stale waivers: an
  observed event missing from the list, a declared unwaivered event no
  line ever recorded, and a waiver whose road was in fact walked are
  each violations, all reported in one run, exit 1. Its own invocation
  is a declared road (`harness.roads`) recorded like any other harness
  verdict — so its first live run truthfully reports its own road
  unwalked, walks it by running, and passes from the second run on.
- `openspec/specs/telemetry/spec.md` gains both requirements as ADDED —
  no existing requirement changes.

## Not built, with what would earn it

- **`mkdir` in the emitter.** Refused, not deferred: the app key
  derives from the working directory, so an emitter that invents its
  destination scatters junk directories wherever a gate happens to run.
  Shipping the one destination the repo owns keeps the rule intact.
- **A call-site extractor feeding the declared list.** Dynamic event
  names (`tdd.$phase`) defeat grep — the hand-expanded count existing
  before this change was wrong once already. The check catches an
  undeclared event on its first firing; the residual blind spot is a
  call site that never fires *and* was never declared, and an extractor
  is earned the first time that is shown to have happened.
- **Wiring road-check into selfcheck or CI.** A fresh clone holds no
  run evidence, so a clone-time invocation could only fail or lie. The
  check is a session and release-record instrument; it earns a gate
  seat only if run evidence ever becomes durable.
- **Tracking run telemetry itself.** The boundary stands: durable
  knowledge travels through `evidence/` records and the specs; `runs/`
  is script-owned session state. This change ships a marker, not the
  data.
