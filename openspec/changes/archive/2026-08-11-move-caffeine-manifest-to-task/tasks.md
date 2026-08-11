## 1. Grammar

- [x] 1.1 Red→green: `routine-spec-lint` requires `## Caffeine` on every
      `task.md` and no longer on `briefing.md`; fixtures updated

## 2. Developer gate

- [x] 2.1 Red→green: the developer baseline reads the in-progress task's
      `## Caffeine` manifest; gate fixtures move their manifests into
      task.md

## 3. Prompts

- [x] 3.1 Update `agents/analyst.md` (manifest per task) and
      `agents/developer.md` (context scoped to the task's own manifest)
