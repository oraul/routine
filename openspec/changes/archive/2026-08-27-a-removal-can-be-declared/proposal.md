## Why

`routine-change-check` refused its first live delta — `add-go-core`'s
guidance amendment — naming `cross-compiled per release, ...` as a
lost line. The refusal was correct by the rule and wrong for the
case: the removal was deliberate, stated in the proposal, and the
entire point of the task. The rule knows only the silent-loss class
and has no grammar for an intended removal, so the driver overrode
it by hand and recorded the override in the change's design.

That override is the defect. The migration ahead reworks laws and
specs continually, so this gate will keep refusing deliberate
rewordings — and a gate overridden by habit is worse than no gate,
because the next refusal is read as noise before it is read.

## What Changes

- A delta file may carry a `## Removed Lines` section: one
  `- <text>` bullet per live line the change deliberately drops.
- `routine-change-check` exempts exactly the declared lines and
  refuses every undeclared loss in the same run — the reviewer reads
  the declaration, the check only decides whether one exists.

## What is deliberately not built

- No judgment of whether a removal is wise: that is the reviewer's,
  and a script claiming otherwise would be lying about what it
  checked.
- No retroactive declaration in the archived `add-go-core` delta: its
  override is history, recorded where it happened.
