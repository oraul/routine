## Context

`gh release create --generate-notes` delegates the body to GitHub,
which attributes PRs to accounts. The repo's merge-title grammar
(`Merge pull request #N: <type>: <change-id> — <outcome>`) is owner-free
and convention-checked, so the notes can be computed from history alone.

## Goals / Non-Goals

- **Goals**: owner-free notes from script-owned grammar; the published
  v0.1.0 repairable by re-requesting the same tag.
- **Non-Goals**: changelog curation or categorization — the merge
  subjects are the record.

## Decisions

- **Notes are a script with exit-code semantics**
  (`bin/routine-release-notes`), not workflow inline shell — testable
  with bats, reusable locally.
- **Range = previous tag → the tag** (or HEAD while the tag doesn't
  exist yet; all history when there is no previous tag), first-parent
  merges only — one line per PR, the `Merge pull request #N: ` prefix
  stripped to a bullet.
- **The workflow edits when the release exists**: `gh release view`
  decides create vs edit; the tag never moves, only title and notes are
  replaced. Notes are written to `$RUNNER_TEMP`, keeping the gate's
  clean-worktree guarantee intact.
- **`fetch-depth: 0`** on checkout: notes need history and tags.

## Risks / Trade-offs

- [Anyone with push access can rewrite release notes by re-pushing the
  branch] → same trust boundary as publishing; the gate still re-runs,
  and notes derive from history, not from the request.

## Migration Plan

Additive script plus workflow edit; re-pushing `release/v0.1.0` repairs
the live notes. Rollback = revert the merge commit.
