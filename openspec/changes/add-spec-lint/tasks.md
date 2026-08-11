## 1. The linter

- [x] 1.1 Red→green: `bin/routine-spec-lint` passes a well-formed fixture
      ticket and fails a missing/headerless `requirement.md`, naming file and
      rule
- [ ] 1.2 Red→green: RFC 2119, scenario (Given/When/Then), and enumerated
      acceptance checks — all defects reported in one run
- [ ] 1.3 Red→green: briefing checks (`briefing.md` with `## Caffeine`, at
      least one task) and the `spec.lint` telemetry line

## 2. The analyst gate

- [ ] 2.1 Red→green: analyst baseline requires `ROUTINE_TICKET_DIR`, runs
      spec-lint, and surfaces its output on failure
- [ ] 2.2 Red→green: index/tree coherence — rows without directories and task
      directories without rows each fail naming the offender
