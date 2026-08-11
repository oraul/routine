# calibration: bug

The work is restoring a promise the system already made. Everything bends
toward reproduction and root cause; new surface area is scope creep.

## Analyst

- The `## Reproduction` section is the contract: exact steps, expected vs
  actual. If you cannot write it, the requirement is not ready — say so.
- State the suspected root cause as a claim to verify, not a certainty.
- Decompose small: usually one briefing; the first task is always
  "reproduce as a failing test", verbatim from the Reproduction section.
  Follow-up tasks fix and then harden (the neighboring cases the same root
  cause would break).
- Scenarios describe today's broken behavior and the restored behavior —
  never new features smuggled in as "while we're here".

## Developer

- The failing test **is** the reproduction. If you cannot make it fail the
  way the Reproduction section says, stop and fail the task — a bug you
  cannot reproduce is a defective spec, not a coding problem.
- Fix the root cause, not the symptom: the test that reproduces plus at
  least one sibling case that would have caught it.
- Touch the minimum. A bug ticket that refactors is two tickets wearing one
  id.
- Leave the regression test named after the behavior, not the incident.
