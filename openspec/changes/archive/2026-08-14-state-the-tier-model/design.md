# Design — state-the-tier-model

## The contract was spec'd but never pinned

`openspec/specs/guidance/spec.md` has required `CLAUDE.md`'s contents
since `define-claude-md`, and its scenarios read "WHEN CLAUDE.md is read
THEN it states…" — but no test reads it. A grep across `test/` for
`CLAUDE` finds only `CLAUDE_PLUGIN_ROOT` in `paths.bats`. The whole
guidance capability has been enforced by nothing but attention.

That is Law 1 unmet on the repository's own front door, so this change
adds `test/guidance_content.bats` on the `agents_content.bats` model:
load-bearing terms pinned mechanically, never sentences.

Two kinds of pin land in that file and they are not equal. The pins for
the tier model are TDD evidence — the text does not exist, red is shown,
then green. The pins for what `CLAUDE.md` already states are
**characterization**: they pass from birth, they belong in the ordinary
suite, and they are not routed through `routine-tdd red`. Recording that
distinction here is the point; a file where both kinds sit together
invites a later reader to mistake one for the other.

## What CLAUDE.md should say, and at what length

`CLAUDE.md` is deliberately short — pointers, not detail. The tier model
earns its place there for one reason: a session that reads only the
contract would otherwise not know a third agent exists, and would not
know that delegating the record is forbidden. That second half is the
load-bearing part; the tier names are context for it.

So the entry is a few lines and a pointer, not the essay. The reasoning
lives in the agent files and in the archived designs, which is where a
reader who wants it will already be.

## The honest limit goes in the contract, not just the design

Two archived designs record that no script here can observe which model
answered. That limit belongs in the contract too, because a session
reading "three tiers" without it will assume routine enforces something
it cannot. What routine checks is that a tier is declared and its value
recognised. The declaration is a record of intent, and it stays accurate
whether or not the host honours it.

## Non-Goals, with what would earn each

- **A `CLAUDE.md` section per agent.** The file is a pointer document;
  earned when a session demonstrably needs agent detail before opening
  the agent file, which the agent files themselves would show first.
- **Pinning prose sentences rather than terms.** Never earned — line
  wrapping breaks sentence greps, which this repository has already paid
  for twice.
- **A script that checks the host honoured a tier.** Not implementable
  from here; earned only if the host ever exposes the answering model to
  a script.
