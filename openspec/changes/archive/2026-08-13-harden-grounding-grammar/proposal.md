## Why

The council confirmed grounding.md is a contract in name only. Evidence
bullets record relevance ("the touchpoint the feature extends"), not
findings — so a re-entering analyst gets zero target facts and re-opens
every file, defeating "the analyst's grounding survives the analyst".
The lint accepts any bullet under Evidence, a bare substring satisfies
Reconciliation (a date can false-pass a task id), and empty
Alternatives/Assumptions pass silently — unconsidered, not
inapplicable, by the repo's own principle.

## What Changes

- **Evidence carries the claim**: every Evidence line must match
  `- <path> — <claim>` — the claim being what the file was found to
  contain or do, not why it was opened. Checked per line (the manifest
  loop pattern), so one good bullet cannot mask a malformed sibling.
  Ruled-out survey results get a blessed form:
  `- <path> — ruled out: <reason>` (in grounding.md only, never in a
  task manifest).
- **Reconciliation is a line contract**: each defective task id owns a
  line `- <tid> — <what the defect invalidated>`, matched
  metacharacter-proof (substring-anchored awk, not an interpolated
  regex).
- **Alternatives and Assumptions must be non-empty**: at least one
  `- ` bullet each, with the literal floor `- none — <why nothing
  qualifies>` as the considered opt-out — mirroring the manifest's
  testing/tdd floor.
- **The analyst prompt teaches the tightened forms**, including that
  the linter still never judges content — the `<claim>` text is
  judgment; only its shape is grammar.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `spec-grammar`: the grounding requirement's SHALLs state the line
  grammars.
- `operation`: the analyst requirement's grounding description carries
  the claim-bearing Evidence form.

## Impact

- Modified: `bin/routine-spec-lint`, `agents/analyst.md`,
  `test/spec_lint.bats` (+ fixtures in `test/gate.bats`),
  `test/agents_content.bats`.
