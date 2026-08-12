## 1. Typed topics and manifest validity in lint

- [x] 1.1 Red→green: lint enforces per-type contract topics — feature
      `## Touchpoints`, greenfield `## Contracts`, epic `## Order`
- [x] 1.2 Red→green: lint enforces manifest form (`- <topic>` exactly) and
      topic resolvability against `caffeine/`

## 2. The defect return

- [x] 2.1 Red→green: `bin/routine-defect` — refuses without reason or
      in_progress task; writes `defect.md`; resets to pending; emits
      `spec.defective` with non-zero exit value
- [x] 2.2 Red→green: analyst gate fails after more than 3 failed spec.lint
      events, naming the revise limit

## 3. The seam documented where agents read

- [ ] 3.1 Update `agents/analyst.md`, `agents/developer.md`, and
      `calibration/*.md` with the typed topics and the scripted defect
      return; `skills/routine/SKILL.md` defect path calls the script
