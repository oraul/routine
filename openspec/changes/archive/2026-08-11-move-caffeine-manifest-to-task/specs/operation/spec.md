## MODIFIED Requirements

### Requirement: The analyst decomposes and never implements
`agents/analyst.md` SHALL instruct: decompose the requirement into briefings
and tasks in the spec grammar (requirement header, RFC 2119 keywords,
Given/When/Then scenarios, enumerated acceptance, and a caffeine manifest
per task), revise against the full spec-lint defect list, and never write
implementation code or touch script-owned state.

#### Scenario: Grammar named in the prompt
- **WHEN** the agent file is read
- **THEN** it names every grammar marker the linter enforces — including
  the per-task caffeine manifest — and the never-implements rule

### Requirement: The developer is stateless and evidence-bound
`agents/developer.md` SHALL instruct: consume exactly one task from
`routine-next`; context is the task file, the caffeine docs named in that
task's own `## Caffeine` manifest, and block/unblock files when present —
nothing else; work red → green per acceptance scenario; fail a defective
spec back to specify with a stated reason instead of improvising; on
blockage write `block.md` and call `routine-block`.

#### Scenario: Statelessness named in the prompt
- **WHEN** the agent file is read
- **THEN** it names the one-task rule, the closed context list scoped to
  the task's own manifest, the defective-spec refusal, and the block
  procedure
