#!/usr/bin/env bats

load test_helper

make_good_ticket() {
  ticket="$BATS_TEST_TMPDIR/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login"
  cat > "$ticket/requirement.md" <<'EOF'
# Requirement: Login
Type: feature
The system SHALL let users log in.
## Touchpoints
- app/models/user.rb
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
  cat > "$ticket/grounding.md" <<'GRD'
# Grounding: 0001
Grounded-at: 0123456789abcdef0123456789abcdef01234567

## Evidence
- app/models/user.rb — the touchpoint the feature extends

## Alternatives
- single-task shape rejected: form and session split cleanly

## Assumptions
- local auth only; no SSO in scope
GRD
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
  printf '%s\n' '# Task: endpoints' '## Scenario: endpoints respond' '- Given a' '- When b' '- Then c' '## Acceptance' '1. works' '## Caffeine' '- testing/tdd' > "$ticket/briefings/02-api/tasks/01-endpoints/task.md"
  printf '%s\n' '## Order' '1. auth first, api second' >> "$ticket/requirement.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -eq 0 ]
}

@test "typed contract topics are required per type" {
  make_good_ticket
  sed -i.bak '/^## Touchpoints/,$d' "$ticket/requirement.md" && rm -f "$ticket/requirement.md.bak"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *Touchpoints*) ;; *) false ;; esac
  sed -i.bak 's/^Type: feature/Type: greenfield/' "$ticket/requirement.md" && rm -f "$ticket/requirement.md.bak"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *Contracts*) ;; *) false ;; esac
}

@test "an epic requires its order of value" {
  make_good_ticket
  sed -i.bak 's/^Type: feature/Type: epic/' "$ticket/requirement.md" && rm -f "$ticket/requirement.md.bak"
  mkdir -p "$ticket/briefings/02-api/tasks/01-endpoints"
  printf '%s\n' '# Briefing: api' > "$ticket/briefings/02-api/briefing.md"
  printf '%s\n' '# Task: endpoints' '## Scenario: endpoints respond' '- Given a' '- When b' '- Then c' '## Acceptance' '1. works' '## Caffeine' '- testing/tdd' > "$ticket/briefings/02-api/tasks/01-endpoints/task.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *Order*) ;; *) false ;; esac
}

@test "malformed manifest bullets and unresolvable topics fail" {
  make_good_ticket
  printf '%s\n' '# Task: login form' '## Scenario: submit' '- Given a' '- When b' '- Then c' '## Acceptance' '1. works' '## Caffeine' '* ruby/rails' > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *"- <topic>"*) ;; *) false ;; esac
  printf '%s\n' '# Task: login form' '## Scenario: submit' '- Given a' '- When b' '- Then c' '## Acceptance' '1. works' '## Caffeine' '- ruby/nonexistent' > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *"ruby/nonexistent"*) ;; *) false ;; esac
  # Refusals teach: the failure lists the available vocabulary.
  case "$output" in *"available topics"*"ruby/rails"*) ;; *) false ;; esac
  printf '%s\n' '# Task: login form' '## Scenario: submit' '- Given a' '- When b' '- Then c' '## Acceptance' '1. works' '## Caffeine' '- ruby/rails' '- architecture/oop' > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -eq 0 ]
}

# A ticket whose sole manifest topic is the caller's choice — used to pin
# manifest resolution against a redirected ROUTINE_ROOT (Law 6: a
# hardcoded caffeine root can never be pointed at a fixture).
make_ticket_naming_topic() {
  ticket="$BATS_TEST_TMPDIR/0001"
  mkdir -p "$ticket/briefings/01-auth/tasks/01-login"
  cat > "$ticket/requirement.md" <<'EOF'
# Requirement: Login
Type: feature
The system SHALL let users log in.
## Touchpoints
- app/models/user.rb
EOF
  cat > "$ticket/briefings/01-auth/briefing.md" <<'EOF'
# Briefing: auth
Covers login.
EOF
  printf '%s\n' '# Task: login form' '## Scenario: submit' '- Given a' '- When b' '- Then c' \
    '## Acceptance' '1. works' '## Caffeine' "- $1" \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  cat > "$ticket/grounding.md" <<'GRD'
# Grounding: 0001
Grounded-at: 0123456789abcdef0123456789abcdef01234567

## Evidence
- app/models/user.rb — the touchpoint the feature extends

## Alternatives
- single-task shape rejected: form and session split cleanly

## Assumptions
- local auth only; no SSO in scope
GRD
}

# A fixture caffeine root holding exactly one topic, absent from the real
# corpus.
make_fixture_root() {
  froot="$BATS_TEST_TMPDIR/fixture-root"
  mkdir -p "$froot/caffeine/fixture"
  cat > "$froot/caffeine/fixture/only.md" <<'EOF'
# caffeine: fixture/only
Present only in this fixture tree, never in the real corpus.
EOF
}

@test "a topic present only in the fixture root resolves under ROUTINE_ROOT" {
  make_fixture_root
  make_ticket_naming_topic "fixture/only"
  run env ROUTINE_ROOT="$froot" "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -eq 0 ]
}

@test "a topic present only in the real corpus is refused under ROUTINE_ROOT" {
  make_fixture_root
  make_ticket_naming_topic "ruby/rails"
  run env ROUTINE_ROOT="$froot" "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *"ruby/rails"*"resolves to no"*) ;; *) false ;; esac
}

@test "a task without a scenario label fails" {
  make_good_ticket
  sed -i.bak '/^## Scenario: submit/d' "$ticket/briefings/01-auth/tasks/01-login/task.md"
  rm -f "$ticket/briefings/01-auth/tasks/01-login/task.md.bak"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *01-login/task.md*"## Scenario:"*) ;; *) false ;; esac
}

@test "a characterization heading satisfies the scenario requirement" {
  make_good_ticket
  printf '%s\n' '# Task: login form' '## Characterization: baseline pin' \
    '- Given the current behavior' '- When the pin runs' '- Then it captures baseline' \
    '## Acceptance' '1. the pin passes' '## Caffeine' '- ruby/rails' \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -eq 0 ]
}

@test "both a scenario and characterization heading together pass" {
  make_good_ticket
  printf '%s\n' '# Task: login form' '## Scenario: submit' '- Given a' '- When b' '- Then c' \
    '## Characterization: baseline pin' '- Given the current behavior' '- When the pin runs' \
    '- Then it captures baseline' '## Acceptance' '1. works' '## Caffeine' '- ruby/rails' \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -eq 0 ]
}

@test "a task with neither heading form fails naming the rule" {
  make_good_ticket
  printf '%s\n' '# Task: login form' '- Given a' '- When b' '- Then c' \
    '## Acceptance' '1. works' '## Caffeine' '- ruby/rails' \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *"## Scenario:"*"## Characterization:"*) ;; *) false ;; esac
}

@test "the given when then grammar is enforced under a characterization heading" {
  make_good_ticket
  printf '%s\n' '# Task: login form' '## Characterization: baseline pin' \
    '## Acceptance' '1. the pin passes' '## Caffeine' '- ruby/rails' \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *"Given/When/Then"*) ;; *) false ;; esac
}

@test "an empty manifest fails naming the floor" {
  make_good_ticket
  printf '%s\n' '# Task: login form' '## Scenario: submit' '- Given a' '- When b' '- Then c' \
    '## Acceptance' '1. works' '## Caffeine' \
    > "$ticket/briefings/01-auth/tasks/01-login/task.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *01-login/task.md*testing/tdd*) ;; *) false ;; esac
}

@test "defects persist on lint.log and a passing run clears it" {
  make_good_ticket
  sed -i.bak '/^## Scenario: submit/d' "$ticket/briefings/01-auth/tasks/01-login/task.md"
  rm -f "$ticket/briefings/01-auth/tasks/01-login/task.md.bak"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  [ -f "$ticket/lint.log" ]
  grep -q "## Scenario:" "$ticket/lint.log"
  make_good_ticket
  printf 'stale defect line\n' > "$ticket/lint.log"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -eq 0 ]
  [ ! -s "$ticket/lint.log" ]
}

@test "usage errors never touch a lint.log" {
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$BATS_TEST_TMPDIR/nope"
  [ "$status" -eq 2 ]
  [ ! -e "$BATS_TEST_TMPDIR/nope/lint.log" ]
}

# Grounding: the evidence behind the contract, ticket-level.
write_grounding() {
  cat > "$ticket/grounding.md" <<'GEOF'
# Grounding: 0001
Grounded-at: 0123456789abcdef0123456789abcdef01234567

## Evidence
- app/models/user.rb — the touchpoint the feature extends

## Alternatives
- single-task shape rejected: form and session split cleanly

## Assumptions
- local auth only; no SSO in scope
GEOF
}

@test "missing grounding.md fails the lint" {
  make_good_ticket
  rm -f "$ticket/grounding.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *grounding.md*) ;; *) false ;; esac
}

@test "empty evidence fails the lint" {
  make_good_ticket
  write_grounding
  python3 - "$ticket/grounding.md" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p).read().replace('- app/models/user.rb — the touchpoint the feature extends\n', '')
open(p, 'w').write(s)
PYEOF
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *Evidence*) ;; *) false ;; esac
}

@test "a missing or malformed vintage anchor fails" {
  make_good_ticket
  sed -i.bak '/^Grounded-at: /d' "$ticket/grounding.md" && rm -f "$ticket/grounding.md.bak"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *Grounded-at*) ;; *) false ;; esac
  make_good_ticket
  sed -i.bak 's/^Grounded-at: .*/Grounded-at: not-a-sha/' "$ticket/grounding.md" \
    && rm -f "$ticket/grounding.md.bak"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *Grounded-at*40*) ;; *) false ;; esac
}

@test "a claim-less evidence bullet fails even beside a well-formed one" {
  make_good_ticket
  python3 - "$ticket/grounding.md" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p).read().replace(
  '- app/models/user.rb — the touchpoint the feature extends',
  '- app/models/user.rb — has_secure_password lives here\n- app/models/session.rb')
open(p, 'w').write(s)
PYEOF
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *"app/models/session.rb"*"— <"*) ;; *) false ;; esac
}

@test "silent alternatives or assumptions fail naming the floor" {
  make_good_ticket
  python3 - "$ticket/grounding.md" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p).read().replace('- local auth only; no SSO in scope\n', '')
open(p, 'w').write(s)
PYEOF
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *Assumptions*"- none —"*) ;; *) false ;; esac
}

@test "a bare id inside prose does not reconcile" {
  make_good_ticket
  printf '## 2026-08-12T00:00:00Z\n\nscenario contradicts acceptance\n' \
    > "$ticket/briefings/01-auth/tasks/01-login/defect.md"
  printf '\n## Reconciliation\nreconciled per the defect on 01-01 as discussed\n' \
    >> "$ticket/grounding.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *01-01*) ;; *) false ;; esac
}

@test "a defect return demands reconciliation naming the task id" {
  make_good_ticket
  write_grounding
  printf '## 2026-08-12T00:00:00Z\n\nscenario contradicts acceptance\n' \
    > "$ticket/briefings/01-auth/tasks/01-login/defect.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -ne 0 ]
  case "$output" in *Reconciliation*01-01*|*01-01*Reconciliation*) ;; *) false ;; esac
  printf '\n## Reconciliation\n- 01-01 — scenario rewritten to match the acceptance list\n' \
    >> "$ticket/grounding.md"
  run "$ROUTINE_REPO_ROOT/bin/routine-spec-lint" "$ticket"
  [ "$status" -eq 0 ]
}
