# Proposal — frame-readme-as-model

## Why

The README opens: *"a Claude Code plugin that runs a spec-first,
two-agent development loop against any target project with zero setup"*,
and carries an `## Install` section with `claude plugin install`. A
reader concludes this is a tool to install and use.

That is not what it is. Stated twice by its author: *"for now it's a
concept art the routine project"* and *"it's a mental model, the routine
that serves as inspiration for another project"*. The value on offer is
the model — how a spec-first loop can be built so that judgment and
mechanism are separable — not a plugin someone should adopt.

A reader who installs it and looks for a product will conclude it is an
unfinished one. A reader who is handed the model can take the parts
worth taking into a project written in any language.

## What Changes

- The README opens with what routine **is** — a working model of a
  spec-first loop — before it says what it does.
- A **concept pipeline** shows the loop as a model: what each phase
  decides, who decides it, and which of the three actors is answerable
  at each step. It is the pipeline as a *diagram of authority*, not an
  install-and-run diagram.
- The install instructions stay, demoted to a "run it if you want to see
  it move" position rather than the call to action.
- A section names **what is worth stealing** and what is specific to this
  repository, so the model transfers without the reader having to reverse
  it out of the implementation.
- The guidance spec requires the framing and the pipeline, so the README
  cannot drift back into product copy.

## Impact

- Affected specs: `guidance`
- Affected code: `README.md`, `test/guidance_content.bats`
- No behavior change: no script, agent, or skill is touched.
