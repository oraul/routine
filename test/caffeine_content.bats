#!/usr/bin/env bats

load test_helper

# Content truth pinned the mechanical way: load-bearing terms present,
# council-verified-wrong claims absent. These pin terms of art (API
# names), never sentences.

@test "sidekiq guide teaches strict_args and the string-key round trip" {
  doc="$ROUTINE_REPO_ROOT/caffeine/ruby/sidekiq.md"
  grep -q 'strict_args!' "$doc"
  grep -q 'string keys' "$doc"
  ! grep -qi 'corrupt silently' "$doc"
}

@test "sidekiq guide states OSS delivery semantics honestly" {
  doc="$ROUTINE_REPO_ROOT/caffeine/ruby/sidekiq.md"
  grep -q 'SIGKILL' "$doc"
  grep -q 'super_fetch' "$doc"
  ! grep -q 'guarantees at-least-once' "$doc"
}

@test "sidekiq guide enqueues in bulk and knows the retry numbers" {
  doc="$ROUTINE_REPO_ROOT/caffeine/ruby/sidekiq.md"
  grep -q 'perform_bulk' "$doc"
  ! grep -qE 'each \{ \|id\| [A-Za-z]+Job\.perform_async' "$doc"
  grep -q '25 retries' "$doc"
  grep -q 'sidekiq_retries_exhausted' "$doc"
  grep -qi 'dead set' "$doc"
}

@test "sidekiq guide covers the transaction/enqueue race" {
  doc="$ROUTINE_REPO_ROOT/caffeine/ruby/sidekiq.md"
  grep -q 'after_commit' "$doc"
  grep -q 'enqueue_after_transaction_commit' "$doc"
}

@test "active_record guide backs uniqueness with an index and names the errors" {
  doc="$ROUTINE_REPO_ROOT/caffeine/ruby/active_record.md"
  grep -q 'unique: true' "$doc"
  grep -q 'RecordNotUnique' "$doc"
  grep -q 'StaleObjectError' "$doc"
}

@test "active_record guide batches outside the transaction and knows find_each drops order" {
  doc="$ROUTINE_REPO_ROOT/caffeine/ruby/active_record.md"
  grep -q 'in_batches' "$doc"
  grep -qi 'ignores.*order' "$doc"
  ! grep -qE 'transaction do$[^`]*find_each' "$doc"
}

@test "active_record guide works the N+1 pair" {
  doc="$ROUTINE_REPO_ROOT/caffeine/ruby/active_record.md"
  grep -q 'includes' "$doc"
  grep -q 'preload' "$doc"
  grep -q 'eager_load' "$doc"
  grep -q 'strict_loading' "$doc"
}
