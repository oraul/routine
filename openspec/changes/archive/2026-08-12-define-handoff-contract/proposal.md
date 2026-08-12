## Why

The council audit found the analyst↔developer handoff owned by no
capability: its obligations are scattered across six files, manifest topics
are only validated mid-development (after human approve), the
defective-spec return path is a prose sentence steering the phase machine
(a Law 1 violation), and the 3-revise limit is counted by nobody. The seam
between the two agents is the product's core; it gets its own capability
and its own teeth.

## What Changes

- **New `contract` capability** owning the seam: what the analyst
  guarantees, what the developer guarantees, and the enforcement of each.
- **Typed contract topics**, checked by `routine-spec-lint` at the analyst
  gate: `bug` → `## Reproduction` (existing); `feature` → `## Touchpoints`
  naming the code the feature extends; `greenfield` → `## Contracts`
  (inputs/outputs/invariants); `epic` → `## Order` (order of value).
- **Manifest validity moves to the handoff**: every entry under a task's
  `## Caffeine` must be a `- <topic>` line resolving to
  `caffeine/<topic>.sh` or `.md`; malformed bullets and unresolvable
  topics fail lint — before approve, not mid-development.
- **`bin/routine-defect <ticket-dir> <reason>`**: the developer's
  defective-spec return as a script — writes the reason to the task's
  `defect.md`, resets the task to `pending`, emits `spec.defective`.
- **The revise limit becomes mechanical**: the analyst gate fails once the
  ticket's telemetry records more than 3 failed `spec.lint` runs.
- Prompts and calibration docs updated to teach the typed topics and the
  scripted defect return.

## Capabilities

### New Capabilities

- `contract`: the typed analyst↔developer handoff and its enforcement map.

### Modified Capabilities

- `spec-grammar`: typed topics; manifest form and resolvability rules.
- `tickets`: the defect return transition joins the lifecycle.
- `gates`: the analyst baseline gains the revise-limit check.
- `operation`: both agent contracts reference the typed topics and
  `routine-defect`.

## Impact

- New: `bin/routine-defect`, its bats suite, `openspec/specs/contract/`.
- Modified: `bin/routine-spec-lint`, `bin/routine-gate`,
  `agents/{analyst,developer}.md`, `calibration/*.md`, lint/gate tests.
