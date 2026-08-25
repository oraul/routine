# audit Specification (delta)

## ADDED Requirements

### Requirement: The concluded artifacts are the approved artifacts
When a ticket's `approve.md` exists and its last entry carries an
`Approved-at: <hash8>` fingerprint, `bin/routine-audit` SHALL recompute
the fingerprint over the ticket's `requirement.md`, `grounding.md`, and
every `briefings/*/briefing.md` — the same files, order, and cksum
derivation the approve records, through the one shared implementation —
and SHALL count a mismatch as a violation naming re-approval, because a
proceed that predates an amendment blesses artifacts the run did not
conclude with. A ticket with no `approve.md`, or none carrying a
fingerprint, SHALL skip this rule rather than fail it, so runs recorded
before the fingerprint existed stay auditable.

#### Scenario: An amended artifact after the last proceed is caught
- **WHEN** `requirement.md` changes after the last `Approved-at:` entry
  was recorded and the audit runs
- **THEN** the audit reports a violation naming the stale approval

#### Scenario: A matching fingerprint adds no violation
- **WHEN** the recomputed fingerprint equals the last recorded one
- **THEN** this rule stays silent

#### Scenario: Pre-fingerprint runs stay auditable
- **WHEN** a ticket carries no `approve.md` or no `Approved-at:` line
- **THEN** the rule is skipped and the remaining audit rules decide
