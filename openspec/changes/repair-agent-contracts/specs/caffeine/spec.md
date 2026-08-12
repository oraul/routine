# caffeine Specification (delta)

## MODIFIED Requirements

### Requirement: Caffeine generation is gated, not trusted
`skills/caffeinate/SKILL.md` SHALL be human-invoked only and SHALL
instruct: discover topics via `routine-deps`; let the human select which
to generate; for each selected topic draft the pair the lint enforces —
a `caffeine/<ns>/<topic>.md` opening with the exact H1
`# caffeine: <ns>/<topic>` and the metadata comment headers
(`caffeine-topic`, `caffeine-applies`, `caffeine-source`,
`caffeine-reviewed`; `caffeine-mode: doc-only` when no sidecar ships),
and a `caffeine/<ns>/<topic>.sh` sidecar sourcing `lib/sidecar.sh` with
3–5 mechanical `check <id> "<rule>"` calls whose rule strings appear
verbatim in the doc, plus one bats fixture per topic at
`test/caffeine_<ns>_<topic>.bats` demonstrating a real catch and a
clean pass. Generation SHALL be complete only when
`routine-caffeine-lint` and `routine-selfcheck` pass over the result.
Generated pairs SHALL reach the repository through the normal change
loop, never by direct commit to main.

#### Scenario: Generation protocol present in the skill
- **WHEN** the skill file is read
- **THEN** it names routine-deps discovery, human topic selection, the
  metadata headers, the `lib/sidecar.sh` check-call contract with the
  per-topic fixture, verbatim doc/sidecar rule agreement, and the
  lint-and-selfcheck completion condition
