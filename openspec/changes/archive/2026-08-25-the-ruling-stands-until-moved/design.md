# Design — the-ruling-stands-until-moved

## The marker grammar canonizes the record, not a preference

The detection pin is the fixed prefix `RULED at approve (approve.md A`
inside a non-floor bullet. Three forms were considered:

1. **A new dedicated marker** (e.g. `— ruled: <reading>`), shaped like
   the `— provisional:` grammar. Rejected: the only live occurrences
   on any record — four bullets across ticket 0008's later entries —
   already read `RULED at approve (approve.md A<n>...)`, and a new
   grammar would orphan the very record that motivated the change.
   Canonizing what exists keeps the archive readable by the same rule.
2. **A sidecar file** (ruled indices listed outside grounding.md).
   Rejected: the bullet is what the operator is shown at the
   checkpoint; a ruling recorded away from the question it settles is
   invisible exactly where it matters, and a second file is a second
   thing to drift.
3. **The chosen form.** The reconciliation appends
   ` RULED at approve (approve.md A<n>): <the standing reading>` to
   the bullet, keeping the original ` — provisional:` text in place —
   so the spec-lint's provisional-form rule keeps passing unchanged,
   and the bullet reads as its own history: what was proposed, what
   was ruled, where the ruling lives.

## Unanswered means stands; answered means moved

A ruled bullet left unanswered records
`A<n>: the ruling stands (RULED, not re-answered this proceed)` — the
entry stays a complete Q/A table, and a reader of `approve.md` alone
can tell a standing ruling from a typed answer. An `<n>: <answer>`
line given for a ruled bullet records verbatim, exactly as any answer
does: 0008's fourth entry moved a ruling precisely this way (the A2
amendment), so the amendment path needs no new verb — refusing
answers on ruled questions and inventing a separate amend command was
considered and rejected as machinery the record shows is not needed.

## Numbering never shifts

Answers are matched by position across all non-floor bullets, ruled
or not — only the refusal is lifted for ruled ones. The alternative
(numbering only unruled questions) makes an answer's index depend on
which siblings are ruled, so the same note means different things on
different days — the exact ambiguity the per-question form exists to
kill. Duplicate and unknown indices refuse exactly as today, ruled or
not.

## What the gate deliberately does not read

The gate trusts the marker's presence and never verifies that the
cited `A<n>` exists in `approve.md` or agrees with the standing
reading. That consistency check is a different seam (the 0008 A2
collision — a ruling and an artifact that disagreed with no detector)
with its own change queued; folding it in here would put two
behaviors behind one exit code and blur which rule refused.
