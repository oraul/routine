## ADDED Requirements

### Requirement: The analyst's grounding survives the analyst
The analyst SHALL record the ground its contract stands on in the
ticket's `grounding.md` before the artifacts are gated, and on any
fresh invocation against an existing ticket (a defect return, a new
specify episode) SHALL re-ground from `grounding.md` and every
`defect.md` before re-deriving — and SHALL NOT rename or renumber
existing task directories on a re-specify (the index is append-only and
orphan rows are gate-fatal; restructuring means `routine-abort` and a
fresh ticket). Reconciliation after a defect return is enforced by the
lint, never by memory.

#### Scenario: Fresh invocation re-grounds first
- **WHEN** the analyst prompt is read
- **THEN** it instructs writing grounding.md before the gate and
  re-grounding from grounding.md and defect.md on re-entry, and forbids
  renaming existing task directories
