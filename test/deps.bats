#!/usr/bin/env bats

load test_helper

@test "package.json dependencies become js/ topics" {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt"
  cat > "$tgt/package.json" <<'EOF'
{
  "name": "demo",
  "dependencies": {
    "express": "^4.19.0",
    "pg": "^8.11.0"
  },
  "devDependencies": {
    "vitest": "^1.0.0"
  }
}
EOF
  run env TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-deps"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -qx 'js/express'
  printf '%s\n' "$output" | grep -qx 'js/pg'
  printf '%s\n' "$output" | grep -qx 'js/vitest'
  ! printf '%s\n' "$output" | grep -qx 'js/demo'
}

@test "requirements.txt entries become python/ topics" {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt"
  printf '%s\n' '# comment' 'Django==5.0' 'requests>=2.31' 'uvicorn[standard]~=0.29' \
    > "$tgt/requirements.txt"
  run env TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-deps"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -qx 'python/django'
  printf '%s\n' "$output" | grep -qx 'python/requests'
  printf '%s\n' "$output" | grep -qx 'python/uvicorn'
}

@test "multiple manifests combine" {
  tgt="$BATS_TEST_TMPDIR/app"
  mkdir -p "$tgt"
  printf 'gem "rails"\n' > "$tgt/Gemfile"
  printf '%s\n' '{' '  "dependencies": {' '    "express": "^4.0.0"' '  }' '}' \
    > "$tgt/package.json"
  run env TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-deps"
  [ "$status" -eq 0 ]
  printf '%s\n' "$output" | grep -qx 'ruby/rails'
  printf '%s\n' "$output" | grep -qx 'js/express'
}

@test "no manifest exits non-zero naming the candidates" {
  tgt="$BATS_TEST_TMPDIR/empty"
  mkdir -p "$tgt"
  run env TARGET="$tgt" "$ROUTINE_REPO_ROOT/bin/routine-deps"
  [ "$status" -ne 0 ]
  case "$output" in *Gemfile*package.json*requirements.txt*) ;; *) false ;; esac
}

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
  # Canonicalized through the alias table: dead strings never print.
  printf '%s\n' "$output" | grep -qx 'ruby/rspec'
  ! printf '%s\n' "$output" | grep -qx 'ruby/rspec-rails'
  printf '%s\n' "$output" | grep -qx 'ruby/active_record'
}
