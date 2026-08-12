#!/usr/bin/env bats

load test_helper

sidecar="caffeine/ruby/rails.sh"

make_clean_target() {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt/app/models"
  printf '%s\n' 'class User < ApplicationRecord' \
    '  def name_query(name)' \
    '    User.where(name: name)' \
    '  end' 'end' > "$tgt/app/models/user.rb"
}

@test "clean target passes" {
  make_clean_target
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "leftover debugger is caught" {
  make_clean_target
  printf '%s\n' 'def x' '  binding.irb' 'end' > "$tgt/app/models/debug.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *debugger*debug.rb*) ;; *) false ;; esac
}

@test "interpolated SQL is caught" {
  make_clean_target
  printf 'User.where("name = #{params[:n]}")\n' > "$tgt/app/models/sql.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *sql.rb*) ;; *) false ;; esac
}

@test "puts in app code is caught" {
  make_clean_target
  printf '%s\n' 'def y' '  puts "debugging"' 'end' > "$tgt/app/models/noisy.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *noisy.rb*) ;; *) false ;; esac
}

@test "puts outside app/ is not the sidecar's business" {
  make_clean_target
  mkdir -p "$tgt/script"
  printf 'puts "cli output"\n' > "$tgt/script/report.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "rescue Exception is caught" {
  make_clean_target
  printf '%s\n' 'begin' '  work' 'rescue Exception => e' 'end' > "$tgt/app/models/broad.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *broad.rb*) ;; *) false ;; esac
}

@test "vendor is excluded" {
  make_clean_target
  mkdir -p "$tgt/vendor/gems"
  printf 'binding.irb\n' > "$tgt/vendor/gems/dep.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "rescue ExceptionNotifier::Error is a near-miss that passes" {
  make_clean_target
  printf '%s\n' 'begin' '  x' 'rescue ExceptionNotifier::Error => e' '  log(e)' 'end' \
    > "$tgt/app/models/notify.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "rescue ::Exception is caught" {
  make_clean_target
  printf '%s\n' 'begin' '  x' 'rescue ::Exception => e' 'end' > "$tgt/app/models/bad.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
}

@test "modern binding.break is caught, debugger_output passes" {
  make_clean_target
  printf 'def x; binding.break; end\n' > "$tgt/app/models/brk.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  rm "$tgt/app/models/brk.rb"
  printf 'x = debugger_output.parse\n' > "$tgt/app/models/near.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "a debugger in an erb view is caught" {
  make_clean_target
  mkdir -p "$tgt/app/views/orders"
  printf '<%% binding.pry %%>\n' > "$tgt/app/views/orders/new.html.erb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
}

@test "mass-assignment escape hatch is caught" {
  make_clean_target
  printf 'def p; params.permit!; end\n' > "$tgt/app/models/c.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  rm "$tgt/app/models/c.rb"
  printf 'params.permit(:name)\n' > "$tgt/app/models/ok.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}
