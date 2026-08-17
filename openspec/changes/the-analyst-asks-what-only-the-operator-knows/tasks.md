## 1. The interface check, red against main before anything is fixed

- [x] 1.1 Red→green: `test/agents_content.bats` asserts the two agent
      contracts agree about the TDD phases and what evidence each
      records. Its red is `main` as it stands — run it before touching
      `agents/analyst.md`, capture the failure, and only then fix the
      contradiction, because correcting the contracts first destroys the
      only unforced red this change can get

- [x] 1.2 Red→green: `agents/analyst.md` and
      `openspec/specs/spec-grammar/spec.md` describe the characterization
      phase as PR #91 built it — proven with `routine-tdd characterize`,
      recording a `tdd.characterize` line and no red/green pair, rather
      than "no TDD evidence"

## 2. A question is not an assumption

- [ ] 2.1 Red→green: `agents/analyst.md` separates a derivation (citable
      to a path and a line in the target) from a question only the
      operator can answer (product intent the code has no opinion on),
      and records the questions under their own heading with the
      `- none — <why nothing qualifies>` floor

- [ ] 2.2 Red→green: each question carries the provisional reading the
      decomposition was built on, so the loop never stalls waiting for an
      answer and the override stays cheap

- [ ] 2.3 Red→green: `routine-spec-lint` enforces the new section's
      presence and floor the way it already enforces `## Alternatives`
      and `## Assumptions`

## 3. The questions reach the operator, and the proceed is earned

- [ ] 3.1 Red→green: `skills/routine/SKILL.md`'s approve step shows the
      questions alongside `requirement.md` and the briefings

- [ ] 3.2 Red→green: `routine-approve` refuses a proceed that leaves
      non-floor questions unanswered, and still records a proceed when
      the section is at its floor — a ticket with nothing to ask must not
      be blocked

- [ ] 3.3 Red→green: the specify payload template gains a context field
      naming what the app is and what the operator cares about
