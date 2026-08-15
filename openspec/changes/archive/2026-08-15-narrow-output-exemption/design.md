# Design — narrow-output-exemption

## The exemption was reasoned, and reasoned wrongly

`pair-negative-assertions` did not exempt `$output` carelessly. It gave a
reason and wrote it into the spec: bats defines `$output` after `run`, so
there is no "subject missing" case to guard against.

The reasoning confused *defined* with *non-empty*. A crashed command
leaves `$output` defined and empty, and every negated grep over an empty
string succeeds. The exemption therefore reintroduced, for one subject,
exactly the failure the rule was built to remove.

Worth stating plainly because it is the more useful lesson: the rule was
correct and its exception was not. An exception is where a rule stops
being enforced, so it deserves at least the scrutiny the rule got.

## Why the sibling tests survive and this one does not

Three tests in `retro.bats` also run a command and examine `$output`
without asserting `$status`, and all three fail correctly on a crash:

```sh
case "$output" in *"red that passed"*) ;; *) false ;; esac   # no match → fails
deep_at="$(printf '%s\n' "$output" | grep -n 'x/deep' ...)"
[ -n "$deep_at" ]                                             # empty → fails
```

A **positive** assertion on empty output fails by itself. Only the
negation is satisfied by absence. That asymmetry is the whole subject of
`pair-negative-assertions`, and this change simply finishes applying it.

This is also why the rule is not "`run` implies asserting `$status`",
which was the shape this investigation started from. That broader rule
would flag all four tests, three of them wrongly. The defect is narrower
than the hypothesis, and the fix should be too.

## What `$status` proves that nothing else does

Asserting `$status` establishes that the command ran to a known
conclusion. Once that holds, an empty `$output` is a real observation
about a command that actually executed, and a negation over it means what
it says.

That makes `$status` the pairing partner for `$output`, exactly as
`[ -f "$doc" ]` is the pairing partner for a file subject. The rule stays
one rule; only the subject-specific evidence differs.

## Non-Goals, with what would earn each

- **Requiring `$status` after every `run`.** Measured and rejected: three
  of the four candidate tests are already protected by positive
  assertions, and forcing a status line into them would add noise without
  adding a guarantee. Earned if a positive-only test is ever shown to
  pass on a crash.
- **Requiring `$output` be non-empty before any use.** Overreach: plenty
  of tests legitimately assert on output that may be empty.
- **Re-auditing the other exemptions.** There are no others; `$output`
  was the only one.
