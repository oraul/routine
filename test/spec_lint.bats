#!/usr/bin/env bats

load test_helper

make_good_ticket() {
  ticket="$BATS_TEST_TMPDIR/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login"
  cat > "$ticket/requirement.md" <<'EOF'
# Requirement: Login
The system SHALL let users log in.
EOF
  cat > "$ticket/briefings/01-auth/briefing.md" <<'EOF'
# Briefing: auth
## Caffeine
- ruby/rails
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
EOF
}

@test "well-formed ticket passes" {
  make_good_ticket
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -eq 0 ]
}

@test "headerless requirement fails naming file and rule" {
  make_good_ticket
  printf 'no header, no keywords\n' > "$ticket/requirement.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *requirement.md*Requirement*) ;; *) false ;; esac
}
