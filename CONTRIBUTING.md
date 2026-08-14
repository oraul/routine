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
  `<type>: <change-id> — <outcome>`. The body must carry, under whatever
  headings read best for the change:
  - **why** the change exists — the problem, not the diff;
  - **what changed**, in the reader's terms;
  - **what was deliberately not built**, with what would earn each — the
    non-goals are half the record, and a PR that omits them hands the
    next reader a decision with its reasoning stripped off;
  - **evidence**: the red you showed, then `bin/routine-selfcheck`,
    `openspec validate --specs --strict`, and
    `bin/routine-convention-check origin/main` with their verdicts;
  - the **archived change folder** and the requirements the sync touched.

  This is guidance, not a checked contract: no script reads a PR body, so
  a fixed heading list here would drift unnoticed — and did, for four
  consecutive PRs, before anyone compared the two.
- **Merge:** merge commits, never squash — task commits are evidence.
  Merge only on a full green board: arm auto-merge where the session has
  it, otherwise wait for every check and merge explicitly. Never merge
  past a red or still-running check.
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
- **Bump first, trigger second.** The release workflow always gates
  `main` — the `release/vX.Y.Z` branch is a message, not a source. So the
  manifest bump must be **merged to main before** the branch is pushed;
  push it first and the gate correctly refuses (`tag says X but
  plugin.json declares Y`) and the run is red for no reason. Order:

  ```
  chore branch bumps .claude-plugin/plugin.json → PR → merge to main
  bin/routine-release-check vX.Y.Z on main → must exit 0
  push release/vX.Y.Z (or dispatch the workflow with the tag)
  ```

  The workflow deletes its own trigger branch on success — a surviving
  `release/v*` branch means the publish did not happen.

## The loop

**P0 — Explore** *(on main; optional for pre-scoped changes)*
```
/opsx:explore <idea>
Read-only: no files, no change folder. End with recommended scope,
a verb-led change id, and what is explicitly out of scope.
```

**P1 — Propose** *(stops for human review)*
```
List open PRs — must be empty. An open PR means fix it forward
before any new change. (Use whichever GitHub surface the session
has: the `gh` CLI, the GitHub MCP tools, or the web UI. None is
assumed present — `command -v gh` fails in some sessions.)
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
bin/routine-convention-check origin/main — commit grammar and no
sensitive data. Fix a bad subject by amending, never by a
follow-up commit.
git push -u origin change/<change-id>
Open the PR: title <type>: <change-id> — <outcome>; body per the
PR convention above (why · what changed · what was deliberately
not built · evidence · the archived folder).
Scrub the PR body: some hosts append a session URL to the footer.
Read the body back after creating it and remove any session URL,
token, or account identifier — the hard rules bind artifacts, and
a PR body is an artifact.
Merge on a full green board — auto-merge where available, else
wait for every check. Red leaves it open, which blocks the next P1.
```
