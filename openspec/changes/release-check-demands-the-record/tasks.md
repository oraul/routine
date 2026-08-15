## 1. The gate demands the record

- [x] 1.1 Red→green: `routine-release-check vX.Y.Z` refuses when
      `evidence/<tag>.md` is absent, and refuses when it exists but
      `routine-record-lint` rejects it — relaying the lint's own output
      rather than restating the rule, so the reason names the violated
      grammar

- [x] 1.2 Red→green: the record is bound to its tag — a well-formed
      record for the *previous* tag does not satisfy the current one,
      pinned by a fixture carrying `evidence/v0.1.0.md` while the gate
      is asked for `v0.2.0`

## 2. The convention says where it lives

- [ ] 2.1 `CONTRIBUTING.md`'s Releases section states the record's path
      (`evidence/<tag>.md`), that the gate refuses without it, and that
      the gate decides form and never truth
