## Context

See proposal.md — Why. The checker must run identically on a laptop, in CI,
and against fixture repositories (Law 6 via `TARGET`).

## Goals / Non-Goals

- **Goals**: the hard rules and commit grammar as exit codes; zero new
  dependencies (git + grep).
- **Non-Goals**: full secret entropy scanning (GitHub's own secret
  scanning already runs); rewriting history on detection (that is the
  human's runbook); enforcing task-per-commit granularity (not mechanically
  decidable).

## Decisions

- **`TARGET` parameterizes the repo under check**, defaulting to the
  current directory — same convention as the sidecars, so bats fixtures are
  ordinary temp repositories.
- **Pattern list is small and named**: session URLs, `ghp_`/`github_pat_`
  tokens, `sk-` API keys, `AKIA` AWS ids, `BEGIN ... PRIVATE KEY`. Breadth
  is GitHub secret scanning's job; this list encodes this repository's own
  history of near-misses.
- **Self-exclusion by pathspec** (`:(exclude)` for the checker and its
  tests): the alternative — encoding patterns obliquely — makes the checker
  unreadable, and message scanning still covers those two files' commits.
- **Merge commits exempt from grammar**, matching the convention that merge
  subjects follow the owner-free `Merge pull request #N:` format instead.

## Risks / Trade-offs

- [False positives on token-shaped test data] → name fixtures obviously
  (`not-a-real-token`) or place them in the excluded test file.
- [`sk-` prefix is broad] → accepted: a false positive costs a minute; a
  false negative costs a rotation.

## Migration Plan

Additive. The `conventions` CI job reports on PRs immediately; adding it to
the required-checks ruleset is a later GitHub settings change.
Rollback = revert the merge commit.
