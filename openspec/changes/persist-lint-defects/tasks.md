## 1. The list survives the run

- [x] 1.1 Red→green: `routine-spec-lint` mirrors every defect line to
      `<ticket>/lint.log`, truncated per run, untouched on usage errors

## 2. The prompts read the survivor

- [ ] 2.1 Red→green: the skill's fresh-context branch and the analyst's
      re-entry list hand over `lint.log` — pinned in
      `test/agents_content.bats`
