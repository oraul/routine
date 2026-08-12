#!/usr/bin/env bats

load test_helper

sidecar="caffeine/python/django.sh"

make_clean_target() {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt/shop"
  printf '%s\n' 'import logging' 'logger = logging.getLogger(__name__)' \
    'def close_order(order):' '    order.closed = True' \
    "    order.save(update_fields=['closed'])" > "$tgt/shop/services.py"
  printf '%s\n' 'DEBUG = False' 'ALLOWED_HOSTS = ["shop.example"]' \
    > "$tgt/shop/settings.py"
}

@test "clean django code passes" {
  make_clean_target
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "committed DEBUG = True is caught" {
  make_clean_target
  printf 'DEBUG = True\n' > "$tgt/shop/settings.py"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
}

@test "bare except is caught, named except passes" {
  make_clean_target
  printf '%s\n' 'try:' '    x()' 'except:' '    pass' > "$tgt/shop/b.py"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  printf '%s\n' 'try:' '    x()' 'except ValueError:' '    raise' > "$tgt/shop/b.py"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "f-string SQL is caught" {
  make_clean_target
  printf 'cursor.execute(f"SELECT * FROM orders WHERE id = {oid}")\n' > "$tgt/shop/q.py"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
}

@test "print in app code is caught" {
  make_clean_target
  printf 'print(order)\n' > "$tgt/shop/p.py"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
}
