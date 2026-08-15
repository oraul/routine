## 1. A citation belongs to the release it is claimed for

- [x] 1.1 Red→green: `routine-record-lint` refuses a record citing a
      `#NNN` that is not a merge in its range, naming the entry and the
      number, and passes one whose every citation is in range — pinned
      by a fixture repository whose history makes the range real

- [x] 1.2 Characterization: the rule skips rather than fails when its
      range cannot be established — no previous tag, a filename that
      names no tag, or no git history at all — so every existing fixture
      stays valid and a draft record can still be linted

      Written as Red→green and corrected here, because a skip cannot be
      made red. Two independent mechanisms produce it — the git-dir
      guard and an empty `describe` — so removing either leaves the
      other, and removing the whole rule leaves nothing to skip. Green
      at birth by construction, which is characterization, not evidence.
