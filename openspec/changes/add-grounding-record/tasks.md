## 1. The grounding artifact

- [x] 1.1 Red→green: `routine-spec-lint` requires `grounding.md` with
      `## Evidence` (≥1 bullet), `## Alternatives`, `## Assumptions`;
      fixtures comply

## 2. Reconciliation is mechanical

- [x] 2.1 Red→green: once any `defect.md` exists, the lint requires
      `## Reconciliation` naming each defective task id

## 3. The prompts close the loop

- [x] 3.1 Red→green: analyst writes grounding first and re-grounds from
      grounding.md + defect.md on fresh invocations, never renaming
      existing task dirs; the skill states revise continuity with the
      grounding fallback; calibrations name their evidence
