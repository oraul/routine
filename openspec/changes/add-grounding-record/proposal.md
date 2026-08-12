## Why

The analyst's grounding — which target files it read, which
decompositions it rejected, which assumptions the contract stands on —
lives only in the subagent's ephemeral context. Every revise is a fresh
analyst; the artifacts persist conclusions, never their evidence. The
council's sharpest finding: the revise loop's incentive gradient points
toward grammatically perfect, ungrounded specs, and after a defect
return the re-specifying analyst can silently contradict grounding
nobody recorded. `defect.md` — the one file that explains a rewind —
has one writer and zero readers.

## What Changes

- **A ticket-level `grounding.md`**, written by the analyst during
  specify and enforced by `routine-spec-lint`: `## Evidence` (at least
  one `- <path> — <why it matters>` line), `## Alternatives`
  (decompositions rejected, with reasons), `## Assumptions` (claims to
  re-verify). Uniform across work types — the typed topic already
  selected what to ground; a second typed matrix would double the drift
  surface for no mechanical gain.
- **Reconciliation is mechanical**: once any task carries a
  `defect.md`, the lint requires `## Reconciliation` in `grounding.md`
  naming each defective task id — derived from files the scripts
  already own, exactly like manifest-topic resolvability. Grounding can
  no longer outlive the evidence that invalidated it.
- **The prompts close the loop**: the analyst writes `grounding.md`
  first and, on a fresh invocation (defect return, new episode),
  re-grounds from it and from `defect.md` before re-deriving — and
  never renames existing task directories on a re-specify
  (restructuring means abort). The skill instructs revises to continue
  the same analyst conversation, with the grounding fallback stated as
  sufficient on its own — continuity is an optimization, never a
  mechanism.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `spec-grammar`: grounding.md joins the ticket grammar.
- `contract`: the analyst's grounding guarantee and the reconciliation
  obligation.
- `operation`: the analyst prompt requirement gains grounding and
  re-grounding.

## Impact

- Modified: `bin/routine-spec-lint`, `agents/analyst.md`,
  `skills/routine/SKILL.md`, `calibration/*.md` (one line each),
  `test/spec_lint.bats`, `test/gate.bats` (fixtures gain grounding.md).
