#!/usr/bin/env bats

load test_helper

sidecar="caffeine/ruby/active_record.sh"

make_clean_target() {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt/app/models"
  printf '%s\n' 'class User < ApplicationRecord' \
    '  def recent' \
    '    User.where(active: true).find_each { |u| u.touch }' \
    '  end' 'end' > "$tgt/app/models/user.rb"
}

@test "clean target passes" {
  make_clean_target
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "update_attribute is caught" {
  make_clean_target
  printf 'user.update_attribute(:name, n)\n' > "$tgt/app/models/skip.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *skip.rb*) ;; *) false ;; esac
}

@test "all.each is caught" {
  make_clean_target
  printf 'User.all.each { |u| u.touch }\n' > "$tgt/app/models/iter.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *iter.rb*) ;; *) false ;; esac
}

@test "save without validations is caught" {
  make_clean_target
  printf 'record.save(validate: false)\n' > "$tgt/app/models/nova.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *nova.rb*) ;; *) false ;; esac
}

@test "default_scope is caught" {
  make_clean_target
  printf '%s\n' 'class Post < ApplicationRecord' \
    '  default_scope { where(deleted: false) }' 'end' \
    > "$tgt/app/models/post.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *post.rb*) ;; *) false ;; esac
}
