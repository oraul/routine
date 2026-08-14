## 1. The lint

- [x] 1.1 Red→green: `bin/routine-test-lint` refuses a mechanism-flavored
      opener, a name under three words, a name over 100 characters, and a
      name repeated within one suite — reporting every violation in one
      run with its file and rule, and passing the repository's own 336

## 2. The harness runs it

- [ ] 2.1 Red→green: `bin/routine-selfcheck` runs the naming lint before
      the suite, so a bad name stops CI the way a bad contract does
