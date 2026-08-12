# caffeine Specification

## Purpose

Per-topic developer support: a teaching doc the developer loads only when
the briefing's manifest names it, and a sidecar that mechanically checks the
code against that topic's enforceable rules.

## Requirements

### Requirement: Sidecars are mechanical checkers with gate semantics
Each caffeine sidecar (`caffeine/<lang>/<topic>.sh`) SHALL check the code
under `TARGET` (default: current directory) against 3–5 mechanical,
grep-able rules declared through the shared library `lib/sidecar.sh` as
`check <id> "<rule>" '<pattern>' [scope]`. Every hit SHALL print as
`caffeine/<ns>/<topic>[<id>] <rule>: <file>:<line>:<content>` — the
bracketed id is the parse handle, the rule string the canonical name.
Scanning SHALL exclude vendored directories (`vendor`, `node_modules`,
`tmp`, `coverage`) by directory, never by filtering hit lines. The
sidecar SHALL exit 0 only when no rule matches, SHALL exit 2 when the
scan itself fails (a broken instrument is never a clean repo), and
SHALL judge nothing a grep cannot see — judgment guidance lives in the
paired `.md`.

#### Scenario: Clean target passes
- **WHEN** the target contains no rule violations
- **THEN** the sidecar exits 0

#### Scenario: Violation named
- **WHEN** a target file trips a rule
- **THEN** the sidecar exits non-zero printing its id, rule, file, and
  line

#### Scenario: Vendored content cannot hide a hit
- **WHEN** a violating line's content mentions `/vendor/` but the file
  lives under `app/`
- **THEN** the sidecar still reports it, and files under `vendor/` are
  skipped by directory

#### Scenario: A broken instrument is loud
- **WHEN** the scan itself errors (an invalid pattern or unreadable
  tree)
- **THEN** the sidecar exits 2, not 0


### Requirement: Dependency discovery is scripted
`bin/routine-deps` SHALL detect the target project's dependency manifests —
`Gemfile`, `package.json`, `requirements.txt` — under `TARGET` (default:
current directory), SHALL extract direct dependency names using grep/awk
only, and SHALL print one caffeine topic per line: `ruby/<gem>` from a
Gemfile, `js/<package>` from package.json dependencies and devDependencies,
`python/<package>` from requirements.txt. Extracted names SHALL be
canonicalized through `caffeine/aliases.tsv` (`<emitted>` TAB
`<topic> [<topic>…]`): a matching row replaces the emitted name with its
topics (one-to-many rows express implied topics); names without a row
pass through unchanged. When no known manifest exists it SHALL exit
non-zero naming the manifests it looked for. When `runs/<app>/` exists
for the target it SHALL emit one `app.deps` line with its exit code to
`runs/<app>/telemetry.jsonl`; without app state it SHALL emit nothing
rather than invent a destination.

#### Scenario: Gemfile topics
- **WHEN** the target's Gemfile declares `gem "rails"` and `gem 'pg'`
- **THEN** the output contains `ruby/rails` and `ruby/pg`

#### Scenario: package.json topics
- **WHEN** the target's package.json declares a dependency `"express"`
- **THEN** the output contains `js/express`

#### Scenario: No manifest
- **WHEN** the target has no known manifest
- **THEN** `routine-deps` exits non-zero naming Gemfile, package.json, and
  requirements.txt

#### Scenario: Discovery leaves app-level evidence
- **WHEN** `routine-deps` runs for a target whose `runs/<app>/` exists
- **THEN** `runs/<app>/telemetry.jsonl` gains one `app.deps` line

#### Scenario: Aliases land on real topics
- **WHEN** the Gemfile declares `gem "rspec-rails"`
- **THEN** the output contains `ruby/rspec` and not `ruby/rspec-rails`

#### Scenario: A topic can be implied
- **WHEN** the Gemfile declares `gem "rails"`
- **THEN** the output contains `ruby/active_record` alongside
  `ruby/rails`


### Requirement: Caffeine generation is gated, not trusted
`skills/caffeinate/SKILL.md` SHALL be human-invoked only and SHALL
instruct: discover topics via `routine-deps`; let the human select which to
generate; for each selected topic draft the `caffeine/<topic>.md` guidance
and a `caffeine/<topic>.sh` sidecar with 3–5 mechanical grep-able rules and
one bats fixture per rule, following the existing sidecar contract; and
treat generation as complete only when `routine-selfcheck` passes over the
result. Generated pairs SHALL reach the repository through the normal
change loop, never by direct commit to main.

#### Scenario: Generation protocol present in the skill
- **WHEN** the skill file is read
- **THEN** it names routine-deps discovery, human topic selection, the
  3–5-rule sidecar contract with per-rule fixtures, and the
  selfcheck-green completion condition

### Requirement: Doc-only topics carry judgment without a sidecar
A caffeine topic MAY ship only its `caffeine/<topic>.md` when its rules are
judgment rather than mechanics; such a topic SHALL be legal in any task
manifest. The `architecture/` namespace SHALL hold language-agnostic
doc-only topics, seeded with `architecture/oop.md` (object-oriented design)
and `architecture/hexagonal.md` (ports-and-adapters boundaries).

#### Scenario: Architecture seeds exist
- **WHEN** the repository is checked
- **THEN** `caffeine/architecture/oop.md` and
  `caffeine/architecture/hexagonal.md` exist and carry developer guidance

#### Scenario: Doc-only topic in a manifest
- **WHEN** a task manifest names `architecture/oop`
- **THEN** the developer loads its doc and the developer gate passes
  without running any sidecar for it

### Requirement: Guidance docs teach with annotated skeletons
Every caffeine guidance doc SHALL include at least one annotated
example — for `.sh`-paired topics a compact idiomatic code skeleton, for
doc-only topics an annotated structural example (a worked before/after
or a commented layout tree) — whose comments carry the judgment
insights, so the developer copies structure and absorbs reasoning in
the same read. Every guide SHALL state that the target's own
conventions outrank the guide where they conflict, and guides whose
advice can conflict with another loadable topic SHALL carry an explicit
arbitration note naming that topic.

#### Scenario: Skeleton present
- **WHEN** a ruby caffeine doc is read
- **THEN** it contains a fenced code skeleton with insight-bearing comments

#### Scenario: Doc-only topics carry worked material
- **WHEN** a doc-only guidance doc is read
- **THEN** it contains a fenced annotated example, not aphorisms alone

#### Scenario: Conflicting topics arbitrate
- **WHEN** `ruby/rails` and `architecture/hexagonal` are both loadable
- **THEN** each names the other and states which wins under what
  condition


### Requirement: Every topic satisfies the topic contract
Every caffeine topic SHALL live at depth two (`caffeine/<ns>/<topic>`)
and open with the H1 `# caffeine: <ns>/<topic>` matching its path. Every
`.md` SHALL carry, immediately after the H1, the metadata comment lines
`caffeine-topic` (matching the path), `caffeine-applies` (a non-empty
version constraint), `caffeine-source` (a non-empty upstream reference),
and `caffeine-reviewed` (an ISO date). Every `.sh` SHALL carry
`caffeine-topic`, `caffeine-applies`, and `caffeine-reviewed` header
comments, SHALL have a sibling `.md`, SHALL resolve `TARGET` with a
`$PWD` default, set `-u`, and end `exit "$fails"`, SHALL declare between
3 and 5 `check <id> "<rule>"` rules, and each rule string SHALL appear
verbatim in the sibling `.md`. A `.md` without a sidecar SHALL declare
`caffeine-mode: doc-only`. Every sidecar SHALL have a bats file at
`test/caffeine_<ns>_<topic>.bats`.

#### Scenario: A sidecar without its doc is malformed
- **WHEN** a `caffeine/<ns>/<topic>.sh` exists with no sibling `.md`
- **THEN** the caffeine lint exits non-zero naming the missing doc

#### Scenario: Rule drift is caught
- **WHEN** a sidecar's `check` rule string does not appear in the
  sibling doc
- **THEN** the lint exits non-zero naming the topic and rule

#### Scenario: Doc-only is declared, never inferred
- **WHEN** a `.md` has no sidecar and no `caffeine-mode: doc-only` line
- **THEN** the lint exits non-zero naming the missing declaration

#### Scenario: Missing provenance is a defect
- **WHEN** a topic doc lacks any of the four metadata fields
- **THEN** the lint exits non-zero naming the file and field


### Requirement: The caffeine lint is scripted
`bin/routine-caffeine-lint` SHALL walk every topic under the routine
root's `caffeine/` directory, check the topic contract, report every
violation in one run, and exit non-zero when any exists; an absent or
empty `caffeine/` SHALL pass. It SHALL emit one `harness.caffeine` line
per run under the harness-evidence rule.

#### Scenario: All violations in one run
- **WHEN** two topics each violate the contract
- **THEN** one lint run reports both and exits non-zero

#### Scenario: Empty corpus passes
- **WHEN** the routine root has no `caffeine/` topics
- **THEN** the lint exits 0

### Requirement: The catalog is computed, never stored
`bin/routine-caffeine-list` SHALL walk the routine root's `caffeine/`
topics and print one line per topic — the topic, its mode (`pair` or
`doc-only`), and the doc's first prose line — deriving everything from
the tree at run time. `bin/routine-spec-lint` SHALL, when a manifest
topic resolves to nothing, list the available topics in the failure
output.

#### Scenario: The vocabulary is browsable
- **WHEN** `routine-caffeine-list` runs
- **THEN** every topic under `caffeine/` appears with its mode and lede

#### Scenario: Refusals teach
- **WHEN** a manifest names an unresolvable topic
- **THEN** the lint failure names the topic and lists the available ones

### Requirement: The corpus spans concern and ecosystem namespaces
The caffeine corpus SHALL carry, beyond per-package topics, doc-only
concern topics (`testing/tdd`, `security/secrets`) loadable by any
ecosystem, and at least one application and one testing pair per
supported discovery ecosystem (`ruby/`, `js/`, `python/`). Sidecars
outside Ruby SHALL scan their ecosystem's file globs through the shared
library's `sidecar_include`.

#### Scenario: TDD judgment is loadable everywhere
- **WHEN** a task manifest in any ecosystem names `testing/tdd`
- **THEN** the doc loads and the developer gate passes it as doc-only
  evidence

#### Scenario: A js target has a real vocabulary
- **WHEN** `routine-caffeine-list` runs
- **THEN** it lists `js/express`, `js/vitest`, `python/django`, and
  `python/pytest` alongside the ruby topics
