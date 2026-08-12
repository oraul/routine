## 1. The lint

- [x] 1.1 Red→green: `bin/routine-script-lint` enforces the frontmatter
      grammar with the cross-agreement rules (name, verbatim usage,
      exit coverage with the dynamic convention, live test pointer,
      env iff referenced), fixture-tested under a `ROUTINE_ROOT`
      override

## 2. The corpus complies

- [x] 2.1 Red→green: every `bin/` script carries compliant frontmatter
      and `routine-selfcheck` runs the script lint after the caffeine
      lint — the repo-level lint run is the red

## 3. The computed manual

- [x] 3.1 Red→green: `bin/routine-manual` prints every script's
      contract assembled from frontmatter alone
