## MODIFIED Requirements

### Requirement: The routine skill encodes the gated phase machine
`skills/routine/SKILL.md` SHALL be human-invoked only
(`disable-model-invocation: true`) and SHALL instruct the protocol
`preflight → specify → approve → develop → conclude`, where every phase
transition calls its gate or lifecycle script and a non-zero exit stops
the run. It SHALL forbid direct writes to `index.tsv` and
`telemetry.jsonl`, SHALL make approve a hard stop for the human whose
proceed is recorded by `routine-approve` (with any remarks the human
made), SHALL limit specify to 3 revise attempts per episode with the
exhausted branch calling `routine-abort` (never an abort in prose), and
SHALL distinguish `routine-next`'s exits: 0 a task, 2 a caller bug (bad
ticket dir), 3 a blocked line, 4 all done.

#### Scenario: Protocol present in the skill
- **WHEN** the skill file is read
- **THEN** it names the five phases in order, the gate call per transition,
  the stop-on-non-zero rule, the approve hard stop recorded by
  `routine-approve`, and the 3-revise limit
  with the `routine-abort` exhausted branch and every `routine-next` exit
  code explained
