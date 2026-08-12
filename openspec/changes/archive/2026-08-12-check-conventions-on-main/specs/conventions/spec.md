# conventions Specification (delta)

## MODIFIED Requirements

### Requirement: The check runs on every pull request
CI SHALL run `routine-convention-check` as its own job on every pull
request and on every push to main. The diff base SHALL be the pull
request's base on pull-request events and the pre-push tip
(`github.event.before`) on pushes — falling back to the tip's parent
when the pre-push tip is the zero hash or unreachable — so pushed
history (the merge commit included) is scanned exactly once and old
history is never rescanned.

#### Scenario: PR with a violation
- **WHEN** a pull request contains a commit violating any rule above
- **THEN** the `conventions` job fails

#### Scenario: The merge commit is scanned on main
- **WHEN** a pull request merges to main
- **THEN** the push-triggered `conventions` job checks the pushed
  commits — the merge commit's message included — instead of skipping
