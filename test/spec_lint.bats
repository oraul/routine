#!/usr/bin/env bats

load test_helper

make_good_ticket() {
  ticket="$BATS_TEST_TMPDIR/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login"
  cat > "$ticket/requirement.md" <<'EOF'
# Requirement: Login
Type: feature
The system SHALL let users log in.
EOF
  cat > "$ticket/briefings/01-auth/briefing.md" <<'EOF'
# Briefing: auth
Covers login.
EOF
  cat > "$ticket/briefings/01-auth/tasks/01-login/task.md" <<'EOF'
# Task: login form
## Scenario: submit
- Given a visitor with valid credentials
- When they submit the login form
- Then they are logged in
## Acceptance
1. the form renders
2. invalid credentials show an error
## Caffeine
- ruby/rails
EOF
}

@test "well-formed ticket passes" {
  make_good_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -eq 0 ]
}

@test "all defects are reported in one run" {
  make_good_ticket
  sed -i.bak 's/SHALL/will/' "$ticket/requirement.md" && rm -f "$ticket/requirement.md.bak"
  sed -i.bak '/Given/d' "$ticket/briefings/01-auth/tasks/01-login/task.md" && rm -f "$ticket"/briefings/01-auth/tasks/01-login/task.md.bak
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *"RFC 2119"*) ;; *) false ;; esac
  case "$output" in *"Given/When/Then"*) ;; *) false ;; esac
}

@test "empty acceptance list fails" {
  make_good_ticket
  printf '%s\n' '# Task: t' '- Given a' '- When b' '- Then c' '## Acceptance' \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *acceptance*) ;; *) false ;; esac
}

@test "task without caffeine section and taskless briefing fail; lint emits telemetry" {
  make_good_ticket
  printf '# Briefing: auth\n' > "$ticket/briefings/01-auth/briefing.md"
  sed -i.bak '/## Caffeine/,$d' "$ticket/briefings/01-auth/tasks/01-login/task.md"
  rm -f "$ticket/briefings/01-auth/tasks/01-login/task.md.bak"
  mkdir -p "$ticket/briefings/02-api"
  printf '%s\n' '# Briefing: api' > "$ticket/briefings/02-api/briefing.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *Caffeine*) ;; *) false ;; esac
  case "$output" in *"no tasks"*) ;; *) false ;; esac
  [ "$(grep -c '"event":"spec.lint"' "$ticket/telemetry.jsonl")" -eq 1 ]
  grep -q '"exit":1' "$ticket/telemetry.jsonl"
}

@test "headerless requirement fails naming file and rule" {
  make_good_ticket
  printf 'no header, no keywords\n' > "$ticket/requirement.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *requirement.md*Requirement*) ;; *) false ;; esac
}

@test "missing or unknown type is rejected naming the valid set" {
  make_good_ticket
  sed -i.bak '/^Type:/d' "$ticket/requirement.md" && rm -f "$ticket/requirement.md.bak"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *bug*feature*greenfield*epic*) ;; *) false ;; esac
  make_good_ticket
  sed -i.bak 's/^Type: feature/Type: refactor/' "$ticket/requirement.md" && rm -f "$ticket/requirement.md.bak"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *bug*feature*greenfield*epic*) ;; *) false ;; esac
}

@test "a bug requires a reproduction section" {
  make_good_ticket
  sed -i.bak 's/^Type: feature/Type: bug/' "$ticket/requirement.md" && rm -f "$ticket/requirement.md.bak"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *Reproduction*) ;; *) false ;; esac
  printf '%s\n' '## Reproduction' '1. visit /login with expired session' >> "$ticket/requirement.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -eq 0 ]
}

@test "an epic requires at least two briefings" {
  make_good_ticket
  sed -i.bak 's/^Type: feature/Type: epic/' "$ticket/requirement.md" && rm -f "$ticket/requirement.md.bak"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *"two briefings"*) ;; *) false ;; esac
  mkdir -p "$ticket/briefings/02-api/tasks/01-endpoints"
  printf '%s\n' '# Briefing: api' > "$ticket/briefings/02-api/briefing.md"
  printf '%s\n' '# Task: endpoints' '- Given a' '- When b' '- Then c' '## Acceptance' '1. works' '## Caffeine' > "$ticket/briefings/02-api/tasks/01-endpoints/task.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -eq 0 ]
}
