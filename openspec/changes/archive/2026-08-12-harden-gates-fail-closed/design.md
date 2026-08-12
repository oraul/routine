## Context

Council findings: developer-gate silent greens, split root resolution,
hook/doc-only outcomes invisible in evidence, unblock's decorative task
argument.

## Goals / Non-Goals

- **Goals**: gates fail closed; one root; every gate stage outcome is an
  event; unblock honest about its signature.
- **Non-Goals**: ticket/task attribution on gate lines (C3); auditing the
  event set (C4).

## Decisions

- **Fail-closed matches the analyst gate's existing posture** — the
  asymmetry was the defect, not the strictness.
- **One root via `routine_root`** for spec-lint and caffeine; gate test
  fixtures symlink the repo's `lib/`, `caffeine/`, and
  `bin/routine-spec-lint` into the fixture root, keeping Law 6 testability
  without duplicating code into fixtures.
- **`gate.hook` / `gate.hook.absent` / `gate.developer.doc`** join the
  dot-notation family; the hook's path rides the `script` field exactly as
  sidecars do.

## Risks / Trade-offs

- [Fail-closed breaks callers that ran `routine-gate developer` before
  `routine-next`] → that call order was always a protocol violation; now
  it says so.

## Migration Plan

Behavior tightens only where silence was a bug. Rollback = revert the
merge commit.
