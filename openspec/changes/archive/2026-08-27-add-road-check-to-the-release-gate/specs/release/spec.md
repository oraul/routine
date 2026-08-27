# release Specification (delta)

## ADDED Requirements

### Requirement: The release gate judges the road registry
`bin/routine-release-check` SHALL invoke `bin/routine-road-check` and
relay its verdict and output rather than restating the road rules, for
the same reason it relays `routine-record-lint` and
`routine-render-check`: two implementations of one rule can disagree
with nothing to catch the disagreement. A reported road violation SHALL
refuse the release. Where the releasing machine holds no corpus the
relayed check decides nothing and the release SHALL NOT be blocked by
it, so the guarantee binds a release cut on a machine holding the run
evidence — which is the machine where an undeclared road is walked in
the first place.

#### Scenario: A road violation blocks the release
- **WHEN** a telemetry line carries an event absent from `lib/roads.txt`
  and the release gate runs on that machine
- **THEN** the gate exits non-zero carrying the road check's own output

#### Scenario: A corpus-less release is not blocked by the road check
- **WHEN** the release gate runs where the runs directory holds no
  telemetry
- **THEN** the road check reports that it decided nothing and the gate
  is not refused on its account
