## Context

See proposal.md — Why. The manifest's location is a contract shared by the
linter, the developer gate, and both agent prompts; all four move together
or the drift is immediate.

## Goals / Non-Goals

- **Goals**: one manifest location — the task; the developer loads exactly
  its task's topics; lint enforces presence per task.
- **Non-Goals**: briefing-level manifest inheritance or merging (a task's
  list is complete on its own); migrating old tickets (none exist beyond
  local demo state).

## Decisions

- **The heading stays mandatory, the list may be empty**: an absent section
  is indistinguishable from a forgotten one, so every task declares its
  manifest even when that declaration is "nothing".
- **No briefing fallback**: reading briefing.md when the task list is empty
  would reintroduce two sources of truth; empty means empty.
- **Requirement renamed** (`briefing's` → `task's` manifest sidecars) so the
  spec never says one thing while meaning another.

## Risks / Trade-offs

- [Repetition across sibling tasks naming the same topic] → accepted:
  explicitness over inheritance; the analyst writes two short lines.

## Migration Plan

Grammar-breaking for tickets authored under the old rule; none exist in
any repository. Rollback = revert the merge commit.
