#!/usr/bin/env bats

load test_helper

sidecar="caffeine/python/pytest.sh"

make_clean_target() {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt/tests"
  printf '%s\n' 'def test_total_sums_line_totals():' \
    '    assert total([100, 250]) == 350' > "$tgt/tests/test_order.py"
}

@test "clean pytest suite passes" {
  make_clean_target
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "reasonless skip is caught, reasoned skip passes" {
  make_clean_target
  printf '%s\n' 'import pytest' '@pytest.mark.skip()' \
    'def test_later():' '    pass' > "$tgt/tests/test_s.py"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  printf '%s\n' 'import pytest' '@pytest.mark.skip(reason="flaky upstream, #42")' \
    'def test_later():' '    pass' > "$tgt/tests/test_s.py"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "time.sleep in a test is caught" {
  make_clean_target
  printf '%s\n' 'import time' 'def test_eventually():' \
    '    time.sleep(2)' > "$tgt/tests/test_t.py"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
}

@test "placeholder assert True is caught" {
  make_clean_target
  printf '%s\n' 'def test_todo():' '    assert True' > "$tgt/tests/test_a.py"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
}

@test "app code outside tests/ is not scanned" {
  make_clean_target
  mkdir -p "$tgt/shop"
  printf '%s\n' 'import time' 'time.sleep(1)' 'assert True' > "$tgt/shop/poll.py"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}
