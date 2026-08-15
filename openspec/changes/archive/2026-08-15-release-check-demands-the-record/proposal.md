# Proposal — release-check-demands-the-record

## Why

The release record has a spec, a lint, and a place to live. What it does
not have is anything that makes a release carry one.

`bin/routine-record-lint` checks a record's form. `bin/routine-selfcheck`
runs it over every `evidence/*.md` that exists. Both are correct and both
are vacuous when the file is absent: a release with no record passes
every gate routine has, and the only thing asking for one is prose in
`CONTRIBUTING.md`.

That is the exact failure mode Law 1 names. A rule that lives only in a
document is not a rail — it holds while someone remembers it and fails
silently when nobody does. The record is meant to be the artifact a human
judges a release by; a release that can ship without one has an opinion
about records, not a gate.

## What changes

`bin/routine-release-check vX.Y.Z` gains one condition, alongside the
semver, manifest, worktree and selfcheck conditions it already enforces:
`evidence/<tag>.md` SHALL exist and SHALL pass `routine-record-lint`.

The tag names the file, so the record cannot be a stale copy of the last
release's — `v0.8.0` demands `evidence/v0.8.0.md` and nothing else
satisfies it.

Delegation, not reimplementation: release-check invokes
`routine-record-lint` and relays its verdict. A second implementation of
the record grammar could disagree with the first with nothing to catch
it, which is the argument the record lint itself already makes about
reusing the caffeine resolver.

## Impact

- `bin/routine-release-check` — one new condition, one new exit path
- `openspec/specs/release/spec.md` — the release-gate requirement gains
  the record condition
- `CONTRIBUTING.md` — the Releases section states where a record lives
  and that the gate demands it
- No existing release is retroactively invalidated: the condition binds
  the gate, and the gate runs before a tag, not over history.
