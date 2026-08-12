## MODIFIED Requirements

### Requirement: The developer is stateless and evidence-bound
`agents/developer.md` SHALL instruct: consume exactly one task from
`routine-next`; context is the task file, the caffeine docs named in that
task's own `## Caffeine` manifest, the ticket's `calibration/<type>.md`,
and block/unblock files when present — nothing else; work red → green per
acceptance scenario with the posture the calibration prescribes; return a
defective spec by calling `routine-defect <ticket-dir> <reason>` instead
of improvising; on blockage write `block.md` and call `routine-block`.

#### Scenario: Statelessness named in the prompt
- **WHEN** the agent file is read
- **THEN** it names the one-task rule, the closed context list including
  the calibration doc, the scripted defect return, and the block procedure
