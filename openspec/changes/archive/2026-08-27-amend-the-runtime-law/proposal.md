## Why

Laws 1 and 5 bind the determinism boundary to bash the implementation
language, not to the invariant the laws exist to protect: a
deterministic executable with exit-code semantics, zero setup in the
target project, and a seam any user can edit in place. A compiled core
(Go) is under evaluation for the operational scripts; under the current
wording, even proposing that migration violates the laws it would be
validated against. The laws also leave the real boundary unstated — the
seam between the core and the user-editable surface — which is the part
that must survive any migration.

## What Changes

- Amend Law 1: the determinism boundary binds "a deterministic
  executable with exit-code semantics" — one phrase, no other movement.
- Replace Law 5 ("Bash-only runtime") with "Zero-setup core, scripted
  seams": the core runs with zero setup (today: bash 3.2 + BSD/GNU
  coreutils; sanctioned destination: a single statically linked binary,
  cross-compiled per release, carrying its own commit provenance); the
  seam — app hooks and caffeine sidecars — stays bash 3.2 forever; no
  interpreter runtime enters the operational path on either side.
- Add a `guidance` requirement pinning the amended boundary and seam,
  enforced by grep pins in `test/guidance_content.bats` like the rest of
  the capability.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `guidance`: gains a requirement that the conventions state the runtime
  boundary as invariant plus seam, pinned by tests.

## Impact

- `openspec/project.md`: Laws 1 and 5 amended; every other law, the
  motto, and the pillars untouched.
- `test/guidance_content.bats`: two new pins, red on the un-amended
  file.
- No script, hook, or sidecar changes: the runtime today remains bash
  and every existing law-consumer stays true. The migration itself, if
  it proceeds, is its own sequence of changes validated against the
  amended laws.
