## 1. The expectation rule

- [x] 1.1 Red→green: `routine-test-lint` refuses a test body carrying no
      visible expectation, accepts every token form the corpus uses
      (`[`, `[[`, `status`, `output`, `grep`, `diff`, `assert`, `refute`,
      `-eq`, `-ne`, a leading `!`), names the body rule distinctly from
      the naming rule, and passes the repository's own 350 unchanged
