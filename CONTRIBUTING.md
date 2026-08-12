# Contribution Guidelines

## Hard Rules

### Never commit sensitive data

The following must **never** appear in any commit (code, commit messages, docs, configs, or history):

- Session URLs
- Tokens, API keys, or secrets of any kind
- Personal names
- Account identifiers (usernames, emails, account IDs)
- Passwords or credentials
- Any other sensitive or personally identifiable data

If sensitive data is committed by accident, do not just remove it in a follow-up commit — the history must be rewritten and any exposed credential rotated immediately.

## Conventions

- **Branch:** `change/<change-id>` — the OpenSpec ID verbatim, verb-led kebab.
  Escape hatch `chore/<slug>` for housekeeping touching no behavior.
- **Commits:** Conventional Commits. Types `spec|feat|fix|test|refactor|docs|ci|chore`;
  scope from `bin|lib|caffeine|skill|agents|openspec|ci`. Subject imperative
  ≤72 chars; body says why. Trailers: `Change: <id>` and `Task: <n.m>`.
  **One tasks.md checkbox = one commit** — failing test, implementation, and
  the checkbox tick together. `git log` mirrors `tasks.md` 1:1.
- **PR:** one change = one branch = one PR. Title
  `<type>: <change-id> — <outcome>`. Body headings exactly:
  `## Change` (archived folder path) · `## Why` · `## Spec delta` ·
  `## Evidence` (pasted bats/shellcheck/selfcheck summary lines) ·
  `## Tasks` (mirrored, all ticked) · `## Follow-ups`.
- **Merge:** merge commits, never squash — task commits are evidence.
  Auto-merge armed at PR creation; the CI ruleset is the merge decision.
  WIP = 1: no new branch while any PR is open.

## Releases

- **A tag is a guarantee.** `v<major>.<minor>.<patch>` on `main` asserts:
  every capability in `openspec/specs/` is implemented and green at that
  commit, and `.claude-plugin/plugin.json` declares exactly that version.
- **Bump by rule**, relative to the previous tag: **patch** = fixes and
  chores only (no capability added, removed, or modified); **minor** = any
  spec capability changed; **major** (1.0.0) is reserved until retro
  evidence from real-project runs proves the operational loop end to end.
- **Gate before tag, always**: `bin/routine-release-check vX.Y.Z` must exit
  0 (semver format, manifest match, clean worktree on main, green
  selfcheck). Tag annotated, from the commit the gate blessed; the GitHub
  Release description states the headline capabilities since the last tag.

## The loop

**P0 — Explore** *(on main; optional for pre-scoped changes)*
```
/opsx:explore <idea>
Read-only: no files, no change folder. End with recommended scope,
a verb-led change id, and what is explicitly out of scope.
```

**P1 — Propose** *(stops for human review)*
```
gh pr list --state open — must be empty. An open PR means fix it
forward before any new change.
git switch main && git pull
git switch -c change/<change-id>
/opsx:propose <change-id>
Artifact rules: scenarios are Given/When/Then and individually
testable; RFC 2119 keywords; design.md only if a real decision
exists; every tasks.md item is one red→green unit sized for a
single commit, ordered test-first.
Run: npx --yes @fission-ai/openspec@latest validate <change-id> --strict
— fix until clean.
Commit: spec(openspec): propose <change-id>  (trailer Change: <change-id>)
STOP. The human reviews the proposal before any implementation.
```

**P2 — Apply**
```
/opsx:apply <change-id>
Strict task order. Per task: failing bats test → show red →
implement to green → shellcheck → tick checkbox → one commit
(conventional subject + trailers Change: <change-id>, Task: <n.m>).
No edits outside task scope — a discovered gap becomes a new
committed task, never silent work.
Finish: bin/routine-selfcheck green. STOP before sync.
```

**P3 — Sync + Archive**
```
/opsx:sync <change-id>   → commit: spec(openspec): sync <change-id>
/opsx:archive <change-id> → commit: chore(openspec): archive <change-id>
Then: npx --yes @fission-ai/openspec@latest validate --all --strict
&& bin/routine-selfcheck — both green.
STOP before PR.
```

**P4 — PR**
```
Push branch. gh pr create:
Title: <type>: <change-id> — <outcome>
Body headings exactly: ## Change · ## Why · ## Spec delta ·
## Evidence · ## Tasks · ## Follow-ups.
gh pr merge --auto --merge
Session ends here. Green merges it; red leaves it open, which
blocks the next P1.
```
