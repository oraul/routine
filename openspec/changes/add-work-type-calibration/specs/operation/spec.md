## MODIFIED Requirements

### Requirement: The analyst decomposes and never implements
`agents/analyst.md` SHALL instruct: read the requirement's declared work
type and its `calibration/<type>.md` before decomposing; decompose the
requirement into briefings and tasks in the spec grammar (requirement
header, `Type:` declaration, RFC 2119 keywords, Given/When/Then scenarios,
enumerated acceptance, and a caffeine manifest per task), shaped by the
type's calibration; revise against the full spec-lint defect list; and
never write implementation code or touch script-owned state.

#### Scenario: Grammar named in the prompt
- **WHEN** the agent file is read
- **THEN** it names every grammar marker the linter enforces — including
  the type declaration and calibration loading — and the never-implements
  rule

### Requirement: The developer is stateless and evidence-bound
`agents/developer.md` SHALL instruct: consume exactly one task from
`routine-next`; context is the task file, the caffeine docs named in that
task's own `## Caffeine` manifest, the ticket's `calibration/<type>.md`,
and block/unblock files when present — nothing else; work red → green per
acceptance scenario with the posture the calibration prescribes; fail a
defective spec back to specify with a stated reason instead of
improvising; on blockage write `block.md` and call `routine-block`.

#### Scenario: Statelessness named in the prompt
- **WHEN** the agent file is read
- **THEN** it names the one-task rule, the closed context list including
  the calibration doc, the defective-spec refusal, and the block procedure
