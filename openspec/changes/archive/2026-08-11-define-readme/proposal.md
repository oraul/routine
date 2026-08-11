## Why

The README still reads like day one — a stub with an install section —
while the repository now carries eleven spec'd capabilities, three skills,
calibration, generated caffeine, and a release contract. The public face
deserves the same treatment as everything else: spec what it must present,
then write it.

## What Changes

- Extend the `guidance` capability with a README requirement: the thesis,
  what routine is and how the loop runs, the capability map, the three
  skills, install and develop instructions, and the release/versioning
  pointer.
- Rewrite `README.md` to that contract.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `guidance`: gains the README requirement alongside the CLAUDE.md session
  contract.

## Impact

- Modified: `README.md` only. Validation is `openspec validate --strict`
  plus a green selfcheck.
