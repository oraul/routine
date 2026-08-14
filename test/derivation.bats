#!/usr/bin/env bats

load test_helper

# One number, one implementation. The retro owns the timestamp
# conversion and the caffeine failure ranking; a second script that
# recomputes either can disagree with it, and nothing would catch the
# drift. This guard exists because that already happened once.

@test "the timestamp conversion has exactly one implementation" {
  n="$(grep -l 'function epoch(' "$ROUTINE_REPO_ROOT"/bin/* | wc -l)"
  [ "$n" -eq 1 ]
  grep -q 'function epoch(' "$ROUTINE_REPO_ROOT/bin/routine-retro"
}

@test "the caffeine failure ranking has exactly one implementation" {
  # The ranking is the only place a script divides caffeine failures by
  # caffeine runs; a second one is a fork.
  n="$(grep -lE '\^caffeine\\?/' "$ROUTINE_REPO_ROOT"/bin/* | wc -l)"
  [ "$n" -eq 1 ]
  grep -qE '\^caffeine' "$ROUTINE_REPO_ROOT/bin/routine-retro"
}
