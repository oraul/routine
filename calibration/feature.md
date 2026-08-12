# calibration: feature

New behavior inside existing code. The codebase's conventions outrank your
preferences; the seams you touch need protecting.

## Analyst

- The `## Touchpoints` section is the contract: name the modules, models,
  or endpoints the feature extends — the lint refuses a feature without
  it. Insight comes from reading that code first.
- Decompose along the existing structure — one briefing per touched
  subsystem — so tasks stay inside one convention set each.
- Early tasks pin current behavior at the seams you are about to change
  (characterization scenarios); later tasks add the new behavior.
- Scenarios must cover the interaction between old and new: the existing
  path still works, the new path works, and the boundary cases between.

## Developer

- Read before writing: the surrounding file's idioms — naming, error
  handling, test style — are the spec for *how*, as much as task.md is the
  spec for *what*. When a seam needs design judgment (a conditional edited
  twice, a boundary leaking), `architecture/oop` in the task's manifest
  carries the extraction playbook.
- Extend, don't rewrite. If the existing shape genuinely cannot host the
  feature, that is a defective-spec refusal with the reason stated, not a
  quiet refactor.
- Regression first: characterization tests pin the seam's current behavior
  and are green at birth **by design** — they run inside the app's own
  suite (the developer.sh facade), never through `routine-tdd`. Only the
  *new* behavior's scenarios go through `routine-tdd red` → `routine-tdd
  green`; a characterization test is not a red phase skipped, it is a
  different instrument.
- Match the target's tooling exactly; the developer.sh facade is the only
  definition of done.
