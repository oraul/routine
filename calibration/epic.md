# calibration: epic

Too big to hold in one view. The decomposition is the work; everything else
is execution.

## Analyst

- The requirement states the destination and, critically, the **order of
  value**: which briefing ships something observable first.
- At least two briefings by rule; in practice, one briefing per coherent
  milestone, each leaving the system releasable — no briefing may end
  mid-broken.
- Sequence briefings so later ones can be cut: if the epic stops after
  briefing N, what shipped must still make sense.
- Keep every task's caffeine manifest tight; epics are where context bloat
  goes to hide.
- If a briefing's scope only becomes clear after an earlier one lands, say
  so in the requirement — an epic ticket may return to specify between
  briefings by design.

## Developer

- You still see exactly one task. Do not peek ahead; the strictly ordered
  line **is** the epic's plan, and improvising against it breaks sequencing
  the analyst reasoned about.
- Finish means finish: mid-epic pressure to leave loose ends "for a later
  task" is how epics decay — your task's acceptance list is complete or the
  task is not done.
- Blockages hurt more here (they stall the whole line): write `block.md`
  early and precisely rather than pushing through uncertainty.
