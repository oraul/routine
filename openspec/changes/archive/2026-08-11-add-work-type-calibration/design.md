## Context

See proposal.md — Why. Calibration must follow the caffeine pattern: the
deterministic layer knows only markers and file existence; all judgment
lives in loadable docs.

## Goals / Non-Goals

- **Goals**: one declared type per ticket; two cheap structural teeth (bug
  reproduction, epic decomposition); four docs that actually change how the
  agents work.
- **Non-Goals**: per-briefing or per-task types (one shape per ticket; an
  epic's variety lives in its briefings); auto-detection of type (declaring
  is the human/analyst's judgment); more types before retro evidence asks
  for them.

## Decisions

- **`Type:` is a plain line, not a heading** — greppable with one anchor
  (`^Type: `), and it reads as metadata, which it is.
- **Only two type-conditional rules** — reproduction-for-bugs and
  two-briefings-for-epics are the only shape facts a grep can honestly
  check; everything else (root-cause statements, seam tests, structure
  tasks) is calibration-doc guidance with the retro as its feedback loop.
- **Docs live in `calibration/`**, a sibling of `caffeine/` — same pattern:
  mechanical trigger (the Type line), judgment payload (the .md), loaded
  only when relevant.
- **The developer loads calibration from the ticket, not per task** — the
  type is ticket-scoped, so its posture applies to every task in it.

## Risks / Trade-offs

- [Wrong type declared] → the approve hard stop shows the human the
  requirement, type included; misdeclaration is visible before any work.
- [Calibration docs drift from reality] → retro evidence (blocked time,
  gate retries per type) is the designed corrective.

## Migration Plan

Grammar-breaking for old tickets; none exist in any repository. Rollback =
revert the merge commit.
