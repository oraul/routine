## Context

See proposal.md — Why. The grammar in the founding scope names the checks but
not the exact markers; this design fixes them so grep/awk can enforce them on
bash 3.2 + BSD tools.

## Goals / Non-Goals

- **Goals**: deterministic, line-oriented grammar markers; all defects
  reported in one run; the analyst gate wired to consume them.
- **Non-Goals**: semantic judgment of specs (the retro owns quality), the
  revise loop (the skill drives it, change 6), developer-gate baselines.

## Decisions

- **Concrete grammar markers** (the founding scope names the checks, not the
  markers): `# Requirement:` header line; RFC 2119 keywords as whole words
  (SHALL/MUST/SHOULD/MAY); scenarios as lines matching `Given`/`When`/`Then`
  prefixes (list items or bold variants both match via grep -E); acceptance
  as a `## Acceptance` heading followed by at least one `1.`-style or `- `
  enumerated line; caffeine manifest as a `## Caffeine` heading in
  briefing.md. ⚠ Review point — these markers become the analyst's contract.
- **Report-all, not fail-fast**: the analyst revises against the full defect
  list (at most 3 attempts per the phase machine), so one run must name every
  defect; the linter accumulates failures and exits once.
- **Coherence lives in the gate, not the linter**: spec-lint owns file
  grammar; the analyst baseline owns index/tree agreement, because the index
  is lifecycle state, not grammar.
- **Ticket addressing via `ROUTINE_TICKET_DIR`** — same channel telemetry
  already uses; no new argument surface on `routine-gate`.

## Risks / Trade-offs

- [Marker drift between linter and agent prompts] → change 6 writes the
  analyst prompt against these spec'd markers; the spec is the single
  source.
- [grep -c false positives inside code fences] → accepted: structural
  checks only, boring by design; retro evidence can earn a smarter parse.

## Migration Plan

New script plus an additive gate baseline; existing gates unchanged.
Rollback = revert the merge commit.
