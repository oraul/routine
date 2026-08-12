#!/usr/bin/env bats

load test_helper

sidecar="caffeine/js/vitest.sh"

make_clean_target() {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt/src"
  printf '%s\n' "import { describe, it, expect } from 'vitest'" \
    "describe('order total', () => {" \
    "  it('sums the line totals', () => {" \
    "    expect(total([100, 250])).toBe(350)" \
    "  })" \
    "})" > "$tgt/src/order.test.js"
}

@test "clean vitest suite passes" {
  make_clean_target
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "focused test is caught, prose 'only' passes" {
  make_clean_target
  printf "it.only('runs alone', () => {})\n" > "$tgt/src/f.test.js"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  rm "$tgt/src/f.test.js"
  printf "it('accepts only valid codes', () => {})\n" > "$tgt/src/ok.test.js"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "silently skipped test is caught" {
  make_clean_target
  printf "describe.skip('forgotten', () => {})\n" > "$tgt/src/s.test.js"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
}

@test "raw setTimeout in a test is caught" {
  make_clean_target
  printf "await new Promise(r => setTimeout(r, 500))\n" > "$tgt/src/t.test.js"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
}

@test "app code outside test globs is not scanned" {
  make_clean_target
  printf "setTimeout(poll, 1000)\nconsole.log('boot')\n" > "$tgt/src/app.js"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}
