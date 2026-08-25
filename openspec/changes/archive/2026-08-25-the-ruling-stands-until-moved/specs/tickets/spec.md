# tickets Specification (delta)

## MODIFIED Requirements

### Requirement: Approval is recorded evidence
`bin/routine-approve <ticket-dir> [note]` SHALL refuse unless the
ticket's telemetry holds a passing `gate.analyst` line (approval of
ungated artifacts is meaningless), and SHALL emit one `ticket.approve`
telemetry line on every recorded proceed. When the ticket's
`grounding.md` carries non-floor `## Questions` bullets, the proceed
SHALL be earned per question: the note's lines of the form
`<n>: <answer>` are matched by position to the section's non-floor
bullets, and the gate SHALL refuse — recording nothing — while any
index lacks an answer, naming each open question, or while an answer
names an index no question holds; lines in no `<n>:` form remain free
remarks and bind to nothing. A non-floor bullet carrying the ruled
marker — the fixed text `RULED at approve (approve.md A` followed by
its answer index, the form the analyst's reconciliation appends when
it bakes a recorded ruling into the bullet — SHALL NOT demand a fresh
answer: left unanswered it no longer blocks, and the recorded entry's
`A<n>:` line SHALL say the ruling stands, because a standing ruling
binds until the operator moves it and a demanded re-answer teaches
the operator to type filler that carries no judgment. An answer given
to a ruled question SHALL record verbatim exactly as any answer
does — answering a ruled question is how the operator moves its
ruling. Ruled bullets SHALL keep their positions in the numbering, so
an answer's index never depends on which siblings are ruled. A single
free-text note SHALL NOT
dissolve the section, because one word could previously pass every
question at once and only an exit code makes a question answered —
while whether an answer is good, whether a question is real, and
whether the human read before typing remain judgments no script here
makes. A `## Questions` section at its `- none — <why>` floor SHALL
NOT block a proceed, so asking stays a deliberate act rather than a
tax on every ticket. Every recorded proceed SHALL append an
`approve.md` entry under a timestamped heading — the
question-and-answer pairs verbatim as `Q<n>`/`A<n>` lines, any free
remarks, and an `Approved-at: <hash8>` fingerprint of the artifacts
the operator blessed (`requirement.md`, `grounding.md`, and every
`briefings/*/briefing.md`, hashed in sorted path order through the
same cksum derivation `routine-tdd` records) — a bare proceed
included, so a later reader can always tell what was approved and
whether it is still what concluded. Repeated approvals (after a
defect return) SHALL keep the full history, append-only. The
fingerprint SHALL have one implementation, shared with the audit.

#### Scenario: Approval leaves a line
- **WHEN** `routine-approve <ticket> "ship without the CSV export"`
  runs after a passing analyst gate
- **THEN** the telemetry gains one `ticket.approve` line and
  `approve.md` carries the remark and an `Approved-at:` fingerprint
  under a timestamp

#### Scenario: Ungated artifacts cannot be approved
- **WHEN** `routine-approve` runs with no passing `gate.analyst` on
  record
- **THEN** it exits non-zero naming the missing gate

#### Scenario: An unanswered operator question blocks the proceed
- **WHEN** `grounding.md` carries a non-floor `## Questions` section and
  `routine-approve` is called with no note
- **THEN** it exits non-zero naming the unanswered questions, and no
  `ticket.approve` line is recorded

#### Scenario: Nothing to ask never blocks
- **WHEN** `## Questions` is at its `- none — <why>` floor
- **THEN** `routine-approve` records the proceed exactly as it does today

#### Scenario: A free-text note no longer answers open questions
- **WHEN** two non-floor questions are open and the note carries prose
  with no `<n>:` lines
- **THEN** the gate exits non-zero naming both open questions, and no
  `ticket.approve` line is recorded

#### Scenario: Each answer pairs with its question in the record
- **WHEN** the note answers `1:` and `2:` for two open questions
- **THEN** `approve.md` gains one entry holding each question and its
  answer as `Q<n>`/`A<n>` lines

#### Scenario: An answer naming no question is refused
- **WHEN** one question is open and the note carries `2: <answer>`
- **THEN** the gate exits non-zero saying index 2 names no open
  question

#### Scenario: A bare proceed still writes its entry
- **WHEN** `routine-approve` records a proceed with no questions and no
  note
- **THEN** `approve.md` gains a timestamped entry carrying the
  `Approved-at:` fingerprint

#### Scenario: A standing ruling stops demanding a re-answer
- **WHEN** the only non-floor question's bullet carries
  `RULED at approve (approve.md A1): <the standing reading>` and
  `routine-approve` runs with no `1:` line
- **THEN** the proceed records, and the entry's `A1:` line says the
  ruling stands

#### Scenario: Answering a ruled question moves its ruling
- **WHEN** a ruled bullet's index is answered as `1: <new ruling>`
- **THEN** the answer records verbatim in the entry's `A1:` line

#### Scenario: An unruled sibling still blocks
- **WHEN** question 1 is ruled, question 2 is not, and the note
  answers neither
- **THEN** the gate refuses naming only question 2, and nothing is
  recorded
