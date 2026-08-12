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

@test "rails skeleton is complete, authorized, and copyable" {
  doc="$ROUTINE_REPO_ROOT/caffeine/ruby/rails.md"
  ! grep -qE '^[[:space:]]+\.\.\.$' "$doc"
  grep -q 'authorize' "$doc"
  grep -q 'Result' "$doc"
}

@test "rails and hexagonal arbitrate their conflict in both docs" {
  grep -q 'architecture/hexagonal' "$ROUTINE_REPO_ROOT/caffeine/ruby/rails.md"
  grep -q 'ruby/rails' "$ROUTINE_REPO_ROOT/caffeine/architecture/hexagonal.md"
}

@test "rspec guide carries the four missing tools" {
  doc="$ROUTINE_REPO_ROOT/caffeine/ruby/rspec.md"
  grep -q 'let!' "$doc"
  grep -q 'shared_examples' "$doc"
  grep -q 'it_behaves_like' "$doc"
  grep -q 'instance_double' "$doc"
  grep -q 'build_stubbed' "$doc"
}

@test "rspec guide aligns time travel with its own sidecar" {
  doc="$ROUTINE_REPO_ROOT/caffeine/ruby/rspec.md"
  grep -q 'travel_to' "$doc"
  ! grep -q 'Timecop' "$doc"
}

@test "oop teaches with worked material, not aphorisms alone" {
  doc="$ROUTINE_REPO_ROOT/caffeine/architecture/oop.md"
  grep -q '```' "$doc"
  grep -qi 'rule of three' "$doc"
  grep -qi 'when NOT' "$doc"
  grep -q 'eql?' "$doc"
  grep -qi 'actor' "$doc"
}

@test "hexagonal shows the structure it preaches" {
  doc="$ROUTINE_REPO_ROOT/caffeine/architecture/hexagonal.md"
  grep -q '```' "$doc"
  grep -q 'adapters/' "$doc"
  grep -qi 'primary' "$doc"
  grep -qi 'secondary' "$doc"
  grep -qi 'transaction' "$doc"
  grep -qi 'when NOT' "$doc"
}

@test "every guide carries the Judgment heading and the deference line" {
  for doc in "$ROUTINE_REPO_ROOT"/caffeine/*/*.md; do
    grep -q '^## Judgment' "$doc" || { echo "no Judgment heading: $doc"; false; }
    grep -qi 'outrank' "$doc" || { echo "no deference line: $doc"; false; }
  done
}

@test "the architecture docs have inbound edges and the analyst has the menu" {
  grep -q 'architecture/hexagonal' "$ROUTINE_REPO_ROOT/calibration/greenfield.md"
  grep -q 'architecture/oop' "$ROUTINE_REPO_ROOT/calibration/feature.md"
  grep -q 'routine-caffeine-list' "$ROUTINE_REPO_ROOT/agents/analyst.md"
}
