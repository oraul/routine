# Design — widen-developer-context

## Why the briefing and not grounding.md

`grounding.md` is the analyst's working evidence — every path it read,
including the ones it ruled out, plus alternatives and assumptions. It
is written for a re-entering analyst, not for an implementer, and
handing it over would widen the developer's world by an unbounded
amount for a bounded gain.

The briefing is already the right artifact: one coherent slice, written
after the grounding, summarising what a person implementing that slice
must know. It is the analyst's deliberate export. So the fix is not
"give the developer more" — it is "let the developer read the summary
the analyst already wrote for exactly this purpose".

The closed list stays closed. One briefing, its own, and no wider.

## Conventions in force become contract, not habit

Both proving runs produced a conventions section in the briefing
without being told to — the analyst reached for it because a slice
needs one. An uncontracted habit works until the run where it doesn't,
and its absence is invisible: nothing fails, the developer simply
re-derives.

Promoting it costs nothing today (both runs already comply) and makes
the interface dependable tomorrow. That is the same pin-it-while-it-is
-perfect move the test rules used.

## Precedence, stated so it cannot be improvised

The developer already resolves conflicts by a ladder: task text >
target conventions > calibration > caffeine. The briefing's conventions
describe the target, so they sit with the target's own conventions —
below the task's own text, above the calibration posture. Stated
explicitly because a new source with no declared rank is a source the
agent will rank by feel.

## Non-Goals, with what would earn each

- **Handing over `grounding.md`.** Unbounded context for bounded gain;
  earned if a run shows a developer needing evidence the briefing
  cannot carry.
- **Handing over the whole briefings tree.** Would break statelessness —
  the developer would see slices it is not implementing.
- **A script that checks the developer actually read the briefing.**
  Unobservable; the gate already judges the output.
- **Templating the delegation payload in the skill.** Real and related,
  but it is the driver's interface rather than the agent's; its own
  change so this one stays reviewable.
