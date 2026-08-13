## 1. The anchor in the grammar

- [x] 1.1 Red→green: the lint requires a `Grounded-at: <40-hex sha>`
      line in grounding.md; fixtures comply

## 2. Re-entry trusts the anchor

- [x] 2.1 Red→green: `agents/analyst.md` states the mechanical-first
      re-entry rule (clean tree + same HEAD → trust; else re-verify
      only diff-named and untracked paths, then refresh the anchor) —
      pinned in `test/agents_content.bats`
