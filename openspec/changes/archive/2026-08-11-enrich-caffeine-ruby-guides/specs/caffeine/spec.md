## ADDED Requirements

### Requirement: Guidance docs teach with annotated skeletons
Every `caffeine/ruby/<topic>.md` SHALL include at least one annotated code
skeleton — a compact idiomatic template whose comments carry the judgment
insights — so the developer copies structure and absorbs reasoning in the
same read.

#### Scenario: Skeleton present
- **WHEN** a ruby caffeine doc is read
- **THEN** it contains a fenced code skeleton with insight-bearing comments

### Requirement: The ruby/rspec pair covers spec structure and hygiene
`caffeine/ruby/rspec.md` SHALL present the Better Specs file skeleton
(method-named describes, `subject`/`let` over shared state, sentence-style
contexts, one behavior per example). `caffeine/ruby/rspec.sh` SHALL flag
legacy `.should` syntax, leftover focus marks (`fit`, `fdescribe`,
`fcontext`, `focus:`), `sleep` inside specs, and `any_instance` stubbing —
each rule with its own fixture.

#### Scenario: Leftover focus caught
- **WHEN** a spec file contains `fdescribe`
- **THEN** `rspec.sh` exits non-zero naming that line

#### Scenario: Clean spec passes
- **WHEN** specs use `expect`, unfocused examples, and no sleeps
- **THEN** `rspec.sh` exits 0
