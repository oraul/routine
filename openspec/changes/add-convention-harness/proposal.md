## Why

The repository's own rules — the hard rules on sensitive data and the
commit conventions — are enforced only by prose and discipline. Law 1 says
anything that matters is a script with exit-code semantics; nothing matters
more than the rule whose violation cannot be fixed by a follow-up commit.

## What Changes

- Add `bin/routine-convention-check <base-ref>`: over the commits since
  `<base-ref>` it SHALL fail on — sensitive patterns in the diff or any
  commit message (session URLs, common token shapes, private key blocks);
  non-conventional or over-length commit subjects; behavior-type commits
  (`spec|feat|fix|test|refactor`) missing their `Change:` trailer. The
  checker and its test fixtures are excluded from the diff scan (they must
  name the very patterns they hunt).
- Add a `conventions` CI job running the check against the PR base on every
  pull request.

## Capabilities

### New Capabilities

- `conventions`: the mechanical enforcement of the repository's hard rules
  and commit grammar.

### Modified Capabilities

<!-- none -->

## Impact

- New: `bin/routine-convention-check`, `test/convention_check.bats`; one CI
  job in `.github/workflows/ci.yml`.
- The ruleset can later require the `conventions` check once it has proven
  itself (a settings change on the GitHub side).
