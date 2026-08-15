# Proposal — add-release-record

## Why

A release is a number until it can be compared to the one before it.
`routine-release-notes` composes what merged; nothing says whether the
release was better, and nothing forces the question to be answered
honestly.

The record that answers it has two sections, named for routine's only
two mechanisms — knowledge that gets inherited, and decisions made by
exit code:

- **Caffeine** — what improved: the lesson, the evidence it is real, and
  where it now lives.
- **Gate** — what the rails do not catch, including what got worse: the
  claim, the evidence, and the script that would decide it.

Something getting worse with nothing stopping it *is* a missing gate, so
it is recorded as a finding rather than a lament.

The judgment in that record is the human's. What a script can own is its
**form** — and one clause of its truth.

## What Changes

- `bin/routine-record-lint <file>`: both sections present, no section
  silently empty, every entry carries an `evidence:` line, and a
  Caffeine entry naming `topic: <ns>/<name>` **resolves to a real
  `caffeine/` pair** — the one check that catches a false claim rather
  than a malformed one.
- `bin/routine-selfcheck` runs it over any record in `evidence/`.

## Impact

- Affected specs: `release`
- Affected code: `bin/routine-record-lint` (new),
  `bin/routine-selfcheck`, `test/record_lint.bats` (new)
- The lint decides form, never truth: it cannot know whether a lesson is
  real or a section is honest — the same ceiling `grounding.md`'s lint
  states about its own claims.
