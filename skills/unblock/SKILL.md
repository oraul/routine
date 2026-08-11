---
name: unblock
description: Capture human context for a blocked task and release the line.
disable-model-invocation: true
---

# /unblock <ticket> <task> — release a blocked task

> **Script paths**: every `routine-*` script lives in this plugin's `bin/`.
> In an installed plugin session invoke them as
> `"$CLAUDE_PLUGIN_ROOT/bin/<script>"`; in this repository, `bin/<script>`.
> The names below are shorthand for that resolved path.

A blocked task blocks the whole line. Only human context releases it, and
that context must be written down before anything moves.

1. Read the task's `block.md` — the developer's stated blockage.
2. Converse with the human until you can state, concretely, what unblocks
   the task: a decision, a credential's location (never its value), a
   clarified requirement, a dependency landing.
3. Write that context to the task directory's `unblock.md`.
4. Run `routine-unblock <ticket-dir>`. It refuses while `unblock.md` is
   missing — write the file first, always.
5. Never edit `index.tsv` yourself; the script owns the status flip.

The next `/routine` develop loop will pick the task up again with your
`unblock.md` in the developer's context.
