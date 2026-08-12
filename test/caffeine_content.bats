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
