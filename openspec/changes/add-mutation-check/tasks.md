## 1. The check

- [x] 1.1 Red→green: `bin/routine-mutation-check` gutts each `bin/`
      script in turn, runs the suite that script declares in its
      `routine-test:` frontmatter, requires that suite to fail, restores
      the script through a trap that survives interrupt, names every
      script whose suite stayed green, and exits non-zero when any did
