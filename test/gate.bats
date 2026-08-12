#!/usr/bin/env bats

load test_helper

# Fixture state root: a fake selfcheck (green by default) and a runs/ dir,
# reached through ROUTINE_ROOT (Law 6). routine-gate sources its libs from
# the real repo but resolves state, selfcheck, and hooks from this root.
make_gate_root() {
  groot="$BATS_TEST_TMPDIR/groot"
  mkdir -p "$groot/bin" "$groot/runs"
  printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$groot/bin/routine-selfcheck"
  chmod +x "$groot/bin/routine-selfcheck"
  # One-root resolution: the fixture root must carry every stage the gate
  # resolves — lint, caffeine, libs — so it borrows the repo's via symlink.
  ln -s "$ROUTINE_REPO_ROOT/lib" "$groot/lib"
  ln -s "$ROUTINE_REPO_ROOT/caffeine" "$groot/caffeine"
  ln -s "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$groot/bin/routine-spec-lint"
}

# A bare ticket dir: enough context for preflight evidence.
make_tdir() {
  tdir="$BATS_TEST_TMPDIR/ticket"
  mkdir -p "$tdir"
}

# Fixture target project: a git repo with one commit, clean, on a branch.
make_target() {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt"
  git -C "$tgt" -c init.defaultBranch=main init -q
  git -C "$tgt" -c user.name=test -c user.email=test@example.invalid \
    commit -q --allow-empty -m "root"
}

@test "hook exit code is relayed verbatim" {
  make_gate_root
  make_target
  make_good_ticket
  mkdir -p "$groot/runs/app/hooks"
  printf '%s\n' '#!/usr/bin/env bash' 'exit 7' > "$groot/runs/app/hooks/developer.sh"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$ticket" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" developer
  [ "$status" -eq 7 ]
  grep '"event":"gate.hook"' "$ticket/telemetry.jsonl" | grep -q '"exit":7'
}

@test "failing selfcheck stops preflight before the hook" {
  make_gate_root
  make_target
  make_tdir
  printf '%s\n' '#!/usr/bin/env bash' 'echo harness red' 'exit 1' > "$groot/bin/routine-selfcheck"
  mkdir -p "$groot/runs/app/hooks"
  printf '#!/usr/bin/env bash\ntouch "%s/hook-ran"\n' "$groot" > "$groot/runs/app/hooks/preflight.sh"
  run env ROUTINE_TICKET_DIR="$tdir" ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-gate" preflight
  [ "$status" -ne 0 ]
  case "$output" in *"harness red"*) ;; *) false ;; esac
  [ ! -f "$groot/hook-ran" ]
}

# A grammar-clean ticket whose index agrees with its tree.
make_good_ticket() {
  ticket="$BATS_TEST_TMPDIR/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login"
  printf '%s\n' '# Requirement: Login' 'Type: feature' \
    'The system SHALL let users log in.' '## Touchpoints' \
    '- app/models/user.rb' > "$ticket/requirement.md"
  printf '%s\n' '# Briefing: auth' 'Covers login.' \
    > "$ticket/briefings/01-auth/briefing.md"
  printf '%s\n' '# Task: login' '- Given a' '- When b' '- Then c' \
    '## Acceptance' '1. works' '## Caffeine' \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  : > "$ticket/index.tsv"
  "$ROUTINE_REPO_ROOT/bin/routine-next" "$ticket" > /dev/null
}

@test "missing optional hook logs one line and passes" {
  make_gate_root
  make_target
  make_good_ticket
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$ticket" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" analyst
  [ "$status" -eq 0 ]
  [ "$(printf '%s\n' "$output" | grep -c 'no analyst hook')" -eq 1 ]
  [ "$(grep -c '"event":"gate.hook.absent"' "$ticket/telemetry.jsonl")" -eq 1 ]
}

@test "analyst gate passes a fresh ticket by syncing the index" {
  make_gate_root
  make_target
  make_good_ticket
  : > "$ticket/index.tsv"
  rm -f "$ticket/telemetry.jsonl"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$ticket" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" analyst
  [ "$status" -eq 0 ]
  grep -q "^01-01" "$ticket/index.tsv"
}

@test "analyst gate requires a ticket context" {
  make_gate_root
  make_target
  run env -u ROUTINE_TICKET_DIR ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-gate" analyst
  [ "$status" -ne 0 ]
  case "$output" in *ROUTINE_TICKET_DIR*) ;; *) false ;; esac
}

@test "analyst gate aborts once the revise limit is exhausted" {
  make_gate_root
  make_target
  make_good_ticket
  for i in 1 2 3 4; do
    printf '{"ts":"2026-01-01T00:0%s:00Z","event":"spec.lint","script":"bin/routine-spec-lint","ticket":"0001","task":"","exit":1,"ms":5}\n' "$i" \
      >> "$ticket/telemetry.jsonl"
  done
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$ticket" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" analyst
  [ "$status" -ne 0 ]
  case "$output" in *"revise limit"*) ;; *) false ;; esac
}

@test "a defect return opens a fresh revise budget" {
  make_gate_root
  make_target
  make_good_ticket
  for i in 1 2 3 4; do
    printf '{"ts":"2026-01-01T00:0%s:00Z","event":"spec.lint","script":"bin/routine-spec-lint","ticket":"0001","task":"","exit":1,"ms":5}\n' "$i" \
      >> "$ticket/telemetry.jsonl"
  done
  printf '{"ts":"2026-01-01T00:05:00Z","event":"spec.defective","script":"bin/routine-defect","ticket":"0001","task":"01-01","exit":1,"ms":3}\n' \
    >> "$ticket/telemetry.jsonl"
  printf '{"ts":"2026-01-01T00:06:00Z","event":"spec.lint","script":"bin/routine-spec-lint","ticket":"0001","task":"","exit":1,"ms":5}\n' \
    >> "$ticket/telemetry.jsonl"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$ticket" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" analyst
  [ "$status" -eq 0 ]
}

@test "analyst gate surfaces spec-lint failures" {
  make_gate_root
  make_target
  make_good_ticket
  printf 'broken\n' > "$ticket/requirement.md"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$ticket" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" analyst
  [ "$status" -ne 0 ]
  case "$output" in *spec-lint*requirement.md*) ;; *) false ;; esac
}

@test "analyst gate fails on an index row without a directory" {
  make_gate_root
  make_target
  make_good_ticket
  printf '09-09\t09-x\t09-y\tpending\t2026-01-01T00:00:00Z\n' >> "$ticket/index.tsv"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$ticket" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" analyst
  [ "$status" -ne 0 ]
  case "$output" in *09-09*) ;; *) false ;; esac
}


@test "missing developer hook aborts naming the file and an example" {
  make_gate_root
  make_target
  make_good_ticket
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$ticket" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" developer
  [ "$status" -ne 0 ]
  case "$output" in *"runs/app/hooks/developer.sh"*) ;; *) false ;; esac
  case "$output" in *'cd "$TARGET"'*) ;; *) false ;; esac
}

@test "developer gate fails closed without ticket context or in_progress" {
  make_gate_root
  make_target
  run env -u ROUTINE_TICKET_DIR ROUTINE_ROOT="$groot" TARGET="$tgt" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" developer
  [ "$status" -ne 0 ]
  case "$output" in *ROUTINE_TICKET_DIR*) ;; *) false ;; esac
  make_good_ticket
  "$ROUTINE_REPO_ROOT/bin/routine-done" "$ticket" > /dev/null
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$ticket" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" developer
  [ "$status" -ne 0 ]
  case "$output" in *in_progress*) ;; *) false ;; esac
}

@test "red harness aborts preflight before any target check" {
  make_gate_root
  make_tdir
  printf '%s\n' '#!/usr/bin/env bash' 'echo harness red' 'exit 1' > "$groot/bin/routine-selfcheck"
  run env ROUTINE_TICKET_DIR="$tdir" ROUTINE_ROOT="$groot" TARGET="$BATS_TEST_TMPDIR/nonexistent" "$ROUTINE_REPO_ROOT/bin/routine-gate" preflight
  [ "$status" -ne 0 ]
  case "$output" in *"harness red"*) ;; *) false ;; esac
  case "$output" in *worktree*|*branch*) false ;; *) ;; esac
}

@test "preflight passes on a clean target on a branch" {
  make_gate_root
  make_target
  make_tdir
  run env ROUTINE_TICKET_DIR="$tdir" ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-gate" preflight
  [ "$status" -eq 0 ]
}

@test "preflight fails on a dirty target worktree" {
  make_gate_root
  make_target
  make_tdir
  touch "$tgt/untracked-file"
  run env ROUTINE_TICKET_DIR="$tdir" ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-gate" preflight
  [ "$status" -ne 0 ]
  case "$output" in *worktree*) ;; *) false ;; esac
}

@test "preflight fails on a detached HEAD" {
  make_gate_root
  make_target
  make_tdir
  git -C "$tgt" checkout -q --detach HEAD
  run env ROUTINE_TICKET_DIR="$tdir" ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-gate" preflight
  [ "$status" -ne 0 ]
  case "$output" in *branch*) ;; *) false ;; esac
}

@test "gate emits one telemetry line when ticket context is set" {
  make_gate_root
  make_target
  tdir="$BATS_TEST_TMPDIR/ticket"
  mkdir -p "$tdir"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$tdir" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" preflight
  [ "$status" -eq 0 ]
  [ "$(wc -l < "$tdir/telemetry.jsonl")" -eq 2 ]
  grep -q '"event":"gate.hook.absent"' "$tdir/telemetry.jsonl"
  grep -q '"event":"gate.preflight"' "$tdir/telemetry.jsonl"
  grep '"event":"gate.preflight"' "$tdir/telemetry.jsonl" \
    | grep '"ticket":"ticket"' | grep -q '"task":""'
}

@test "preflight fails closed without ticket context" {
  make_gate_root
  make_target
  run env -u ROUTINE_TICKET_DIR ROUTINE_ROOT="$groot" TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-gate" preflight
  [ "$status" -ne 0 ]
  case "$output" in *ROUTINE_TICKET_DIR*) ;; *) false ;; esac
  [ -z "$(find "$BATS_TEST_TMPDIR" -name telemetry.jsonl)" ]
}

# Ticket whose in-progress task manifests ruby/rails.
make_manifest_ticket() {
  make_good_ticket
  printf '%s\n' '# Task: login' '- Given a' '- When b' '- Then c' \
    '## Acceptance' '1. works' '## Caffeine' '- ruby/rails' \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
}

@test "developer baseline runs manifest sidecars and records telemetry" {
  make_gate_root
  make_target
  make_manifest_ticket
  mkdir -p "$groot/runs/app/hooks"
  printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$groot/runs/app/hooks/developer.sh"
  printf 'binding.irb\n' > "$tgt/bad.rb"
  git -C "$tgt" add . 2>/dev/null; git -C "$tgt" -c user.name=t -c user.email=t@example.invalid commit -qm wip
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$ticket" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" developer
  [ "$status" -ne 0 ]
  case "$output" in *"leftover debugger"*) ;; *) false ;; esac
  grep -q '"event":"gate.developer.script"' "$ticket/telemetry.jsonl"
  grep '"event":"gate.developer.script"' "$ticket/telemetry.jsonl" | grep -q '"exit":1'
  grep '"event":"gate.developer.script"' "$ticket/telemetry.jsonl" \
    | grep '"ticket":"0001"' | grep -q '"task":"01-01"'
}

@test "doc-only manifest topic logs and passes" {
  make_gate_root
  make_target
  make_good_ticket
  printf '%s\n' '# Task: login' '- Given a' '- When b' '- Then c' \
    '## Acceptance' '1. works' '## Caffeine' '- architecture/oop' \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  mkdir -p "$groot/runs/app/hooks"
  printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$groot/runs/app/hooks/developer.sh"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$ticket" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" developer
  [ "$status" -eq 0 ]
  case "$output" in *doc-only*) ;; *) false ;; esac
  grep '"event":"gate.developer.doc"' "$ticket/telemetry.jsonl" \
    | grep -q '"script":"caffeine/architecture/oop.md"'
}

@test "fixture root redirects the whole gate including sidecars" {
  make_gate_root
  make_target
  make_good_ticket
  rm "$groot/caffeine"
  mkdir -p "$groot/caffeine/fixture"
  printf '%s\n' '#!/usr/bin/env bash' 'echo fixture sidecar ran' 'exit 0' \
    > "$groot/caffeine/fixture/probe.sh"
  printf '%s\n' '# Task: login' '- Given a' '- When b' '- Then c' \
    '## Acceptance' '1. works' '## Caffeine' '- fixture/probe' \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  mkdir -p "$groot/runs/app/hooks"
  printf '%s\n' '#!/usr/bin/env bash' 'exit 0' > "$groot/runs/app/hooks/developer.sh"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$ticket" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" developer
  [ "$status" -eq 0 ]
  case "$output" in *"fixture sidecar ran"*) ;; *) false ;; esac
}

@test "developer baseline fails on an unknown manifest topic" {
  make_gate_root
  make_target
  make_manifest_ticket
  printf '%s\n' '# Task: login' '- Given a' '- When b' '- Then c' \
    '## Acceptance' '1. works' '## Caffeine' '- ruby/nonexistent' \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  run env ROUTINE_ROOT="$groot" TARGET="$tgt" ROUTINE_TICKET_DIR="$ticket" \
    "$ROUTINE_REPO_ROOT/bin/routine-gate" developer
  [ "$status" -ne 0 ]
  case "$output" in *"ruby/nonexistent"*) ;; *) false ;; esac
}



@test "missing gate name exits non-zero naming the gates" {
  run "$ROUTINE_REPO_ROOT/bin/routine-gate"
  [ "$status" -ne 0 ]
  case "$output" in *preflight*analyst*developer*) ;; *) false ;; esac
}

@test "unknown gate name exits non-zero naming the gates" {
  run "$ROUTINE_REPO_ROOT/bin/routine-gate" retro
  [ "$status" -ne 0 ]
  case "$output" in *preflight*analyst*developer*) ;; *) false ;; esac
}
