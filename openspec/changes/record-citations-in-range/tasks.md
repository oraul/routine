## 1. A citation belongs to the release it is claimed for

- [x] 1.1 Red→green: `routine-record-lint` refuses a record citing a
      `#NNN` that is not a merge in its range, naming the entry and the
      number, and passes one whose every citation is in range — pinned
      by a fixture repository whose history makes the range real

- [ ] 1.2 Red→green: the rule skips rather than fails when its range
      cannot be established — no previous tag, a filename that names no
      tag, or no git history at all — so every existing fixture stays
      valid and a draft record can still be linted
