#!/usr/bin/env bats

load test_helper

sidecar="caffeine/ruby/rspec.sh"

make_clean_target() {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt/spec/models"
  printf '%s\n' 'RSpec.describe Order do' "  describe '#total' do" \
    "    it 'sums the line totals' do" \
    '      expect(order.total).to eq(350)' '    end' '  end' 'end' \
    > "$tgt/spec/models/order_spec.rb"
}

@test "clean spec passes" {
  make_clean_target
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "legacy should syntax is caught" {
  make_clean_target
  printf 'order.total.should eq(350)\n' > "$tgt/spec/models/old_spec.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *old_spec.rb*) ;; *) false ;; esac
}

@test "leftover focus marks are caught" {
  make_clean_target
  printf '%s\n' 'fdescribe Order do' 'end' > "$tgt/spec/models/foc_spec.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *foc_spec.rb*) ;; *) false ;; esac
}

@test "sleep in a spec is caught" {
  make_clean_target
  printf '%s\n' "it 'waits' do" '  sleep 2' 'end' > "$tgt/spec/models/slow_spec.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *slow_spec.rb*) ;; *) false ;; esac
}

@test "any_instance stubbing is caught" {
  make_clean_target
  printf 'allow_any_instance_of(Order).to receive(:total)\n' \
    > "$tgt/spec/models/stub_spec.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  case "$output" in *stub_spec.rb*) ;; *) false ;; esac
}

@test "sleep outside spec/ is not this sidecar's business" {
  make_clean_target
  mkdir -p "$tgt/app/models"
  printf 'sleep 1\n' > "$tgt/app/models/thing.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "prose containing the word fit passes" {
  make_clean_target
  printf "it 'should fit in the box' do\nend\n" > "$tgt/spec/models/fit_spec.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -eq 0 ]
}

@test "focus metadata and support files are caught" {
  make_clean_target
  printf "it 'x', :focus do\nend\n" > "$tgt/spec/models/f_spec.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
  rm "$tgt/spec/models/f_spec.rb"
  mkdir -p "$tgt/spec/support"
  printf 'config.filter_run focus: true\n' > "$tgt/spec/support/cfg.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
}

@test "legacy should_receive is caught" {
  make_clean_target
  printf 'order.should_receive(:total)\n' > "$tgt/spec/models/sr_spec.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
}

@test "silently disabled examples are caught" {
  make_clean_target
  printf "xit 'was disabled and forgotten' do\nend\n" > "$tgt/spec/models/x_spec.rb"
  run env TARGET="$tgt" bash "$ROUTINE_REPO_ROOT/$sidecar"
  [ "$status" -ne 0 ]
}
