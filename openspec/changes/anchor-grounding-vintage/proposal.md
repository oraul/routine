## Why

Grounding cannot say *when* it was true. Without a vintage anchor, the
re-entering analyst can never mechanically decide whether the Evidence
claims still hold, so the safe move is always re-searching the target —
the exact cost this council set out to remove. One header line makes
staleness decidable: same commit and a clean tree means every claim is
current by construction; anything else names exactly which paths to
re-verify.

## What Changes

- **`Grounded-at: <sha>` joins the grounding grammar**: a column-0
  header line under the `# Grounding:` title, the target's HEAD at
  grounding time (`git -C "$TARGET" rev-parse HEAD` — reading the
  target, never writing it). The lint enforces presence and 40-hex
  form; truth stays the analyst's.
- **Re-entry becomes mechanical-first** in `agents/analyst.md`:
  Evidence bullets are current only when `Grounded-at` equals the
  target's current HEAD AND `git -C "$TARGET" status --porcelain` is
  empty; otherwise re-verify only bullets whose paths appear in
  `git -C "$TARGET" diff --name-only <sha>` (sha against the worktree,
  so committed and uncommitted changes both count) plus untracked
  paths — then refresh the anchor. Never a full re-search.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `spec-grammar`: the grounding requirement gains the anchor line.
- `operation`: the analyst's re-entry rule becomes anchor-first.

## Impact

- Modified: `bin/routine-spec-lint`, `agents/analyst.md`,
  `test/spec_lint.bats` + grounding fixtures (`test/gate.bats`),
  `test/agents_content.bats`.
