## Purpose

The evidence trail: every script invocation reports exactly one machine-
parseable line, so retros can be computed from plain files with awk alone.

## ADDED Requirements

### Requirement: Telemetry lines use a fixed key order
`lib/telemetry.sh` SHALL provide a function that appends exactly one JSON
line per event to a named `telemetry.jsonl`, with keys in the fixed order
`ts,event,script,ticket,task,exit,ms`, ISO-8601 UTC timestamp, and
dot-notation event names.

#### Scenario: Line appended with fixed key order
- **WHEN** a script emits an event with exit code and duration
- **THEN** one line is appended whose keys appear exactly in the order
  `ts,event,script,ticket,task,exit,ms`

#### Scenario: Append never truncates
- **WHEN** the telemetry file already holds lines
- **THEN** emitting adds one line at the end and existing lines are unchanged

### Requirement: Telemetry is script-owned
Only scripts SHALL write telemetry. The emit function SHALL require an
explicit destination file; when a script runs outside any ticket context it
SHALL skip emission rather than invent a destination.

#### Scenario: No ticket context
- **WHEN** a gate runs with no ticket directory configured
- **THEN** no telemetry line is written and the gate's exit code is unaffected
