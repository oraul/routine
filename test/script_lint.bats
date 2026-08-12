#!/usr/bin/env bats

load test_helper

# A fixture root whose bin/ fully satisfies the script contract: one
# static-exit script with usage and env, one dynamic-exit verdict script.
make_corpus() {
  sroot="$BATS_TEST_TMPDIR/sroot"
  mkdir -p "$sroot/bin" "$sroot/test"
  cat > "$sroot/bin/routine-widget" <<'EOF'
#!/usr/bin/env bash
# routine-script: routine-widget
# routine-description: Does one widget thing for the fixture corpus
# routine-usage: routine-widget <dir> [note]
# routine-env: TARGET — the project under widgetization
# routine-exit: 0 — widget done
# routine-exit: 2 — usage
# routine-test: test/widget.bats
set -u
target="${TARGET:-$PWD}"
if [ -z "${1:-}" ]; then
  echo "usage: routine-widget <dir> [note]" >&2
  exit 2
fi
echo "widget in $target"
exit 0
EOF
  cat > "$sroot/bin/routine-verdict" <<'EOF'
#!/usr/bin/env bash
# routine-script: routine-verdict
# routine-description: A verdict script whose exit is the violation count
# routine-exit: 0 — clean
# routine-exit: 1 — violations found
# routine-test: test/verdict.bats
set -u
fails=0
exit "$fails"
EOF
  chmod +x "$sroot/bin/routine-widget" "$sroot/bin/routine-verdict"
  printf '@test "routine-widget runs" { true; }\n' > "$sroot/test/widget.bats"
  printf '@test "routine-verdict runs" { true; }\n' > "$sroot/test/verdict.bats"
}

lint() {
  run env ROUTINE_ROOT="$sroot" "$ROUTINE_REPO_ROOT/bin/routine-script-lint"
}

@test "a clean corpus passes" {
  make_corpus
  lint
  [ "$status" -eq 0 ]
}

@test "a script without frontmatter fails naming it" {
  make_corpus
  printf '%s\n' '#!/usr/bin/env bash' 'set -u' 'exit 0' \
    > "$sroot/bin/routine-widget"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *routine-widget*) ;; *) false ;; esac
}

@test "the declared name must match the filename" {
  make_corpus
  sed -i.bak 's/^# routine-script: routine-widget/# routine-script: routine-gadget/' \
    "$sroot/bin/routine-widget" && rm -f "$sroot/bin/routine-widget.bak"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *routine-widget*routine-gadget*) ;; *) false ;; esac
}

@test "an undocumented exit code fails naming script and code" {
  make_corpus
  printf 'exit 7\n' >> "$sroot/bin/routine-widget"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *routine-widget*7*) ;; *) false ;; esac
}

@test "a documented code the body never uses fails" {
  make_corpus
  sed -i.bak 's/^# routine-exit: 2 — usage/# routine-exit: 2 — usage\n# routine-exit: 5 — phantom/' \
    "$sroot/bin/routine-widget" && rm -f "$sroot/bin/routine-widget.bak"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *routine-widget*5*) ;; *) false ;; esac
}

@test "usage must agree verbatim with what the body prints" {
  make_corpus
  sed -i.bak 's/^# routine-usage: routine-widget <dir> \[note\]/# routine-usage: routine-widget <dir>/' \
    "$sroot/bin/routine-widget" && rm -f "$sroot/bin/routine-widget.bak"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *routine-widget*usage*) ;; *) false ;; esac
}

@test "a dead test pointer fails, a pointer that never names the script too" {
  make_corpus
  rm -f "$sroot/test/widget.bats"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *routine-widget*widget.bats*) ;; *) false ;; esac
  printf '@test "something else" { true; }\n' > "$sroot/test/widget.bats"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *routine-widget*widget.bats*) ;; *) false ;; esac
}

@test "a dynamic exit demands codes 0 and 1 documented" {
  make_corpus
  sed -i.bak '/^# routine-exit: 1 — violations found/d' \
    "$sroot/bin/routine-verdict" && rm -f "$sroot/bin/routine-verdict.bak"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *routine-verdict*1*) ;; *) false ;; esac
}

@test "context env vars are declared iff referenced" {
  make_corpus
  sed -i.bak '/^# routine-env: TARGET/d' "$sroot/bin/routine-widget" \
    && rm -f "$sroot/bin/routine-widget.bak"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *routine-widget*TARGET*) ;; *) false ;; esac
  make_corpus
  sed -i.bak 's/^# routine-exit: 0 — clean/# routine-env: ROUTINE_TICKET_DIR — never touched\n# routine-exit: 0 — clean/' \
    "$sroot/bin/routine-verdict" && rm -f "$sroot/bin/routine-verdict.bak"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *routine-verdict*ROUTINE_TICKET_DIR*) ;; *) false ;; esac
}

@test "all violations are reported in one run" {
  make_corpus
  printf 'exit 7\n' >> "$sroot/bin/routine-widget"
  rm -f "$sroot/test/verdict.bats"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *routine-widget*7*) ;; *) false ;; esac
  case "$output" in *routine-verdict*verdict.bats*) ;; *) false ;; esac
}
