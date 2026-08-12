## Why

v0.1.0 published with GitHub's auto-generated notes, which attribute
every PR to an account (`by @<owner>`). The hard rule bans account
identifiers in artifacts we author, and a release body is an artifact —
the notes must come from the repo's own owner-free grammar, and the
existing release must be repairable through the rails, not the UI.

## What Changes

- **`bin/routine-release-notes <tag> [repo-dir]`**: prints owner-free
  release notes composed from first-parent merge subjects since the
  previous tag (all history for the first release). The output SHALL
  contain no `@` mentions — the merge-title grammar is already
  owner-free by convention.
- **The release workflow uses the script and becomes idempotent**:
  notes come from `routine-release-notes`; when the release already
  exists, `gh release edit` replaces title and notes in place instead
  of failing — re-requesting a published tag repairs its notes without
  moving the tag.

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `release`: notes are scripted and owner-free; re-publication edits in
  place.

## Impact

- Added: `bin/routine-release-notes`, `test/release_notes.bats`.
- Modified: `.github/workflows/release.yml`,
  `test/release_workflow.bats`.
