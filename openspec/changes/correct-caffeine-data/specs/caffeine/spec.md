## MODIFIED Requirements

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
