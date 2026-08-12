## MODIFIED Requirements

### Requirement: The analyst decomposes and never implements
`agents/analyst.md` SHALL instruct: read the requirement's declared work
type and its `calibration/<type>.md` before decomposing; ground first
and record it — `grounding.md`'s evidence, alternatives, and assumptions
are written before the artifacts they justify; decompose the
requirement into briefings and tasks in the spec grammar (requirement
header, `Type:` declaration, RFC 2119 keywords, Given/When/Then scenarios,
enumerated acceptance, and a caffeine manifest per task), shaped by the
type's calibration; revise against the full spec-lint defect list,
continuing the same conversation where it survives and re-grounding
from `grounding.md` where it does not; and never write implementation
code or touch script-owned state.

#### Scenario: Grammar named in the prompt
- **WHEN** the agent file is read
- **THEN** it names every grammar marker the linter enforces — including
  the type declaration, calibration loading, and the grounding record —
  and the never-implements rule
