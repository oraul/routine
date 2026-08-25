# Tasks — the-ruling-stands-until-moved

## 1. The gate lets a standing ruling stand

- [x] 1.1 Red→green: `routine-approve` stops demanding an answer for a
      non-floor bullet carrying the ruled marker — unanswered records
      an `A<n>:` line saying the ruling stands, an answer records
      verbatim (moving the ruling), an unruled sibling still refuses
      by name, and indices never shift — `test/approve.bats`

## 2. The contracts teach the marker the gate reads

- [x] 2.1 Red→green: the analyst's reconciliation rule names the exact
      marker form appended to a ruled bullet, provisional text kept in
      place — `agents/analyst.md`, pinned in
      `test/agents_content.bats`
- [x] 2.2 Red→green: the skill's approve phase says a ruled question
      no longer demands its line and answering one moves its ruling —
      `skills/routine/SKILL.md`, pinned in `test/agents_content.bats`
