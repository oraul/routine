# script-contract Specification

## Purpose

Every bin script's calling contract as machine-checkable frontmatter:
the grammar, the lint that binds it to the body, and the computed
manual that assembles the whole surface for one read.

## Requirements

### Requirement: Every bin script declares its contract as frontmatter
Every executable in `bin/` SHALL open, directly after the shebang, with
fixed-form comment lines in the flat grammar the caffeine headers
established: `# routine-script: <name>` matching the filename;
`# routine-description: <one line>`; one `# routine-exit: <code> —
<meaning>` per exit code; `# routine-test: <path>` naming the bats file
that is its acceptance; when the script prints a `usage:` string,
`# routine-usage: <usage>`; when the body references
`ROUTINE_TICKET_DIR` or `TARGET`, a `# routine-env: <var> — <meaning>`
line per variable. `# routine-param:`, `# routine-reads:`, and
`# routine-writes:` lines MAY elaborate; they carry no mechanical
weight. The head of a script SHALL therefore be its complete calling
contract — readable without the implementation.

#### Scenario: The head is the contract
- **WHEN** the first comment block of any `bin/` script is read
- **THEN** it names the script, what it does, its exit codes with
  meanings, and its acceptance test

#### Scenario: Name agreement
- **WHEN** a script's `routine-script:` line disagrees with its
  filename
- **THEN** the script lint exits non-zero naming the file and the rule

### Requirement: The script lint makes the contract exit codes
`bin/routine-script-lint` SHALL walk every executable in `bin/` and
verify mechanically: the frontmatter block is present with every
required key; `routine-script` equals the filename; `routine-usage`
agrees **verbatim** with the `usage:` string the body prints (required
exactly when the body prints one); the documented exit set equals the
body's literal `exit <n>` set, where a dynamic exit (`exit "$var"`)
covers exactly the codes 0 and 1 and code 0 is never phantom (falling
off the end is exit 0); the `routine-test` file exists and mentions
the script's name; `ROUTINE_TICKET_DIR` and `TARGET` are declared via
`routine-env` if and only if the body references them — the lint
itself exempt from the usage and env token rules, since the checker
must name what it hunts (the convention-check precedent). It
SHALL report every violation in one run naming file and rule, exit 0
only when the corpus is clean, and emit one harness telemetry line per
run.

#### Scenario: Undocumented exit code
- **WHEN** a script's body exits with a literal code its frontmatter
  does not document
- **THEN** the lint exits non-zero naming the script and the code

#### Scenario: Drifted usage
- **WHEN** a script's `routine-usage:` differs from the usage string
  the body prints
- **THEN** the lint exits non-zero naming the script and the rule

#### Scenario: Dead test pointer
- **WHEN** a script's `routine-test:` names a file that does not exist
  or never mentions the script
- **THEN** the lint exits non-zero naming the script and the pointer

#### Scenario: Clean corpus
- **WHEN** every `bin/` script satisfies the contract
- **THEN** the lint exits 0

### Requirement: The manual is computed, never curated
`bin/routine-manual` SHALL print the contract of every executable in
`bin/`, assembled at run time from the frontmatter lines alone — never
from a maintained document — and SHALL exit non-zero naming any script
whose frontmatter block is missing.

#### Scenario: The catalog covers the corpus
- **WHEN** `routine-manual` runs on a clean corpus
- **THEN** its output names every `bin/` script with its description,
  usage, and exit codes, and exits 0

#### Scenario: A contractless script cannot hide
- **WHEN** a `bin/` script lacks frontmatter
- **THEN** `routine-manual` exits non-zero naming it
