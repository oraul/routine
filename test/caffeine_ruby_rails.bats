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
