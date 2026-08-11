#!/usr/bin/env bats

load test_helper

@test "Gemfile gems become ruby/ topics" {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt"
  printf '%s\n' 'source "https://rubygems.org"' '' \
    'gem "rails", "~> 7.1"' "gem 'pg'" 'gem "puma", require: false' \
    'group :test do' '  gem "rspec-rails"' 'end' > "$tgt/Gemfile"
  run env TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-deps"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -qx 'ruby/rails'
  printf '%s\n' "$output" | grep -qx 'ruby/pg'
  printf '%s\n' "$output" | grep -qx 'ruby/puma'
  printf '%s\n' "$output" | grep -qx 'ruby/rspec-rails'
}
