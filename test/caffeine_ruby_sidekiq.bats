#!/usr/bin/env bats

load test_helper

sidecar="caffeine/ruby/sidekiq.sh"

make_clean_target() {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt/app/jobs"
  printf '%s\n' 'class HardJob' '  include Sidekiq::Job' \
    '  def perform(user_id)' '    User.find(user_id).work' '  end' 'end' \
    > "$tgt/app/jobs/hard_job.rb"
}

@test "clean job code passes" {
  make_clean_target
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "legacy Sidekiq::Worker include is caught" {
  make_clean_target
  printf '%s\n' 'class OldJob' '  include Sidekiq::Worker' 'end' \
    > "$tgt/app/jobs/old_job.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *old_job.rb*) ;; *) false ;; esac
}

@test "keyword arguments to perform_async are caught" {
  make_clean_target
  printf 'HardJob.perform_async(user_id: 1)\n' > "$tgt/app/jobs/enqueue.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *enqueue.rb*) ;; *) false ;; esac
}

@test "sleep inside a job is caught" {
  make_clean_target
  printf '%s\n' 'class SlowJob' '  include Sidekiq::Job' \
    '  def perform' '    sleep 5' '  end' 'end' \
    > "$tgt/app/jobs/slow_job.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *slow_job.rb*) ;; *) false ;; esac
}

@test "retry false is caught" {
  make_clean_target
  printf '%s\n' 'class RiskyJob' '  include Sidekiq::Job' \
    '  sidekiq_options retry: false' 'end' \
    > "$tgt/app/jobs/risky_job.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *risky_job.rb*) ;; *) false ;; esac
}
