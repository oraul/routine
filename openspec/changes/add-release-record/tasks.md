## 1. The record lint

- [x] 1.1 Red→green: `bin/routine-record-lint <file>` refuses a record
      missing either section, a section left silently empty, an entry
      with no `evidence:` line, and a Caffeine entry whose
      `topic: <ns>/<name>` resolves to no `caffeine/` pair; it reports
      every violation in one run and exits 0 clean, 1 on violations,
      2 on usage

## 2. The harness runs it

- [ ] 2.1 Red→green: `bin/routine-selfcheck` lints every record under
      `evidence/`, treating an absent directory as absent rather than as
      a failure
