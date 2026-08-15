# Proposal — pair-negative-assertions

## Why

`! grep -q X "$doc"` passes when `$doc` does not exist. So does
`! grep -rq X "$dir"/*/FILE.md` when the glob matches nothing. The
assertion cannot distinguish "the forbidden thing is absent" from "there
was nothing to look at", and both answers are green.

This is not hypothetical here. `test/agents_content.bats` holds:

```sh
@test "no skill declares a model for the driving session" {
  ! grep -rq '^model:' "$ROUTINE_REPO_ROOT"/skills/*/SKILL.md
}
```

Demonstrated: it passes with `skills/` deleted, and passes with `skills/`
present but empty. It was written on 2026-08-14, has been green ever
since, and has never once proved the claim its name makes.

The rules shipped so far catch tests that are obviously empty — no claim
in the name, no assertion in the body. This catches a test that is
convincingly empty, which is the more dangerous kind, because nothing
about it looks wrong.

## What Changes

- The violating test gains a positive assertion that its subject exists
  and is non-empty, so the negative means something.
- `bin/routine-test-lint` gains a third rule family: a `!` assertion must
  be accompanied by a positive assertion naming the **same subject** —
  the same file variable, path, or glob. A positive assertion about
  something else does not protect it.
- `$output` is exempt: it is always defined after `run`, so a negative
  against it cannot be vacuous for this reason.

## Impact

- Affected specs: `selfcheck`
- Affected code: `bin/routine-test-lint`, `test/test_lint.bats`,
  `test/agents_content.bats`
- 20 of 21 existing negative assertions already pair on their own
  subject and are untouched. The 21st is the defect above.
