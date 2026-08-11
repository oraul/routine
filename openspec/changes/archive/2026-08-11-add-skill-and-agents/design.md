## Context

See proposal.md — Why. Prompts are the one non-deterministic layer; the
design constraint is that nothing load-bearing lives in them (Law 1): they
narrate the protocol, the scripts enforce it.

## Goals / Non-Goals

- **Goals**: prompt files that only ever delegate decisions to script exit
  codes; agent contracts that mirror the spec'd grammar and lifecycle
  exactly.
- **Non-Goals**: dogfooding `/routine` on this repo (§10), bats for prompts
  (Law 2 exempts them; the retro is their feedback loop), any new script.

## Decisions

- **Skill frontmatter carries `disable-model-invocation: true`** — both
  skills are human entry points; the model must never self-invoke a phase.
- **The skill names scripts, not behaviors**: each phase step is a literal
  command (`routine-gate preflight`, `routine-next`, …) so drift between
  prompt and rail is grep-visible.
- **Agent prompts restate the grammar markers verbatim from the
  spec-grammar spec** rather than describing them loosely — the linter and
  the analyst must share one source of truth.
- **Developer context is a closed list** (task.md, manifest docs,
  block/unblock files): statelessness is enforced by instruction plus the
  fact that scripts hand it exactly one task path.

## Risks / Trade-offs

- [Prompt drift as scripts evolve] → the operation spec pins the required
  content; `openspec validate --strict` plus retro evidence catch drift.
- [LLM ignores an instruction] → every guarantee it could break is
  double-held by a script (gates, evidence-gated transitions, script-owned
  state).

## Migration Plan

New prompt files only. Rollback = revert the merge commit.
