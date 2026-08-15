# selfcheck Specification (delta)

## ADDED Requirements

### Requirement: A suite must notice when its script is gutted
`bin/routine-mutation-check` SHALL, for each script in `bin/`, replace that script's body with a stub that exits 0 silently, run the suite the script declares in its `routine-test:` frontmatter, and require that suite to fail. A suite that still passes against a gutted script is not constraining that script's behaviour, and the check SHALL name the script and the suite together without guessing which is at fault. The original script SHALL be restored through a trap on `EXIT`, `INT` and `TERM`, so an interrupted run never leaves a gutted script on disk — a check that reports correctly and leaves the repository broken is worse than no check. The check SHALL print how many scripts were mutated and how many suites noticed, and SHALL exit 0 when every suite noticed, 1 when any suite stayed green, and 2 on usage. It SHALL NOT run inside `routine-selfcheck`: it invokes one suite per script and would make the ordinary gate too slow to run, and a gate people avoid running decides nothing.

#### Scenario: A suite that notices its gutted script passes the check
- **WHEN** a script is replaced by a stub and its declared suite fails
- **THEN** the check counts that script as covered

#### Scenario: A suite that stays green is named
- **WHEN** a script is replaced by a stub and its declared suite still passes
- **THEN** the check names that script and its suite and exits non-zero

#### Scenario: The script is restored even when interrupted
- **WHEN** the check is interrupted mid-run
- **THEN** every mutated script is restored to its original content

#### Scenario: The summary counts both sides
- **WHEN** the check finishes
- **THEN** it prints how many scripts were mutated and how many suites noticed
