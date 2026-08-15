#!/usr/bin/env bats

load test_helper

# A fixture root whose corpus fully satisfies the topic contract: one
# paired topic and one declared doc-only topic.
make_corpus() {
  lroot="$BATS_TEST_TMPDIR/lroot"
  mkdir -p "$lroot/caffeine/ruby" "$lroot/caffeine/architecture" "$lroot/test"
  cat > "$lroot/caffeine/ruby/widget.md" <<'EOF'
# caffeine: ruby/widget
<!-- caffeine-topic: ruby/widget -->
<!-- caffeine-applies: widget >=1.0 -->
<!-- caffeine-source: https://example.invalid/widget-guide -->
<!-- caffeine-reviewed: 2026-08-12 -->

Loaded when your task's manifest names `ruby/widget`.

The sidecar mechanically rejects:
- leftover debugger
- puts in app code
- sleepy loops
EOF
  cat > "$lroot/caffeine/ruby/widget.sh" <<'EOF'
#!/usr/bin/env bash
# Caffeine sidecar: widget rules.
# caffeine-topic: ruby/widget
# caffeine-applies: widget >=1.0
# caffeine-reviewed: 2026-08-12
set -u
target="${TARGET:-$PWD}"
fails=0
check() { :; }
check W1 "leftover debugger" 'x'
check W2 "puts in app code" 'y'
check W3 "sleepy loops" 'z'
exit "$fails"
EOF
  cat > "$lroot/caffeine/architecture/shape.md" <<'EOF'
# caffeine: architecture/shape
<!-- caffeine-topic: architecture/shape -->
<!-- caffeine-applies: any -->
<!-- caffeine-source: https://example.invalid/shape-book -->
<!-- caffeine-reviewed: 2026-08-12 -->
<!-- caffeine-mode: doc-only -->

Judgment about shapes.
EOF
  printf '@test "the widget topic carries a placeholder test" { true; }\n' > "$lroot/test/caffeine_ruby_widget.bats"
}

lint() {
  run env ROUTINE_ROOT="$lroot" "$ROUTINE_REPO_ROOT/bin/routine-caffeine-lint"
}

@test "a compliant corpus passes" {
  make_corpus
  lint
  [ "$status" -eq 0 ]
}

@test "an empty corpus passes" {
  lroot="$BATS_TEST_TMPDIR/empty"
  mkdir -p "$lroot"
  lint
  [ "$status" -eq 0 ]
}

@test "a sidecar without its doc is malformed" {
  make_corpus
  rm "$lroot/caffeine/ruby/widget.md"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *"widget.md"*) ;; *) false ;; esac
}

@test "rule drift is caught and violations batch in one run" {
  make_corpus
  python3 - "$lroot/caffeine/ruby/widget.md" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p).read().replace('- sleepy loops\n', '')
s = s.replace('<!-- caffeine-source: https://example.invalid/widget-guide -->\n', '')
open(p, 'w').write(s)
PYEOF
  lint
  [ "$status" -ne 0 ]
  case "$output" in *"sleepy loops"*) ;; *) false ;; esac
  case "$output" in *caffeine-source*) ;; *) false ;; esac
}

@test "doc-only must be declared, never inferred" {
  make_corpus
  python3 - "$lroot/caffeine/architecture/shape.md" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p).read().replace('<!-- caffeine-mode: doc-only -->\n', '')
open(p, 'w').write(s)
PYEOF
  lint
  [ "$status" -ne 0 ]
  case "$output" in *doc-only*) ;; *) false ;; esac
}

@test "H1 must match the topic path" {
  make_corpus
  python3 - "$lroot/caffeine/ruby/widget.md" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p).read().replace('# caffeine: ruby/widget', '# caffeine: ruby/gadget')
open(p, 'w').write(s)
PYEOF
  lint
  [ "$status" -ne 0 ]
  case "$output" in *H1*|*"ruby/widget"*) ;; *) false ;; esac
}

@test "rule count outside 3-5 is a violation" {
  make_corpus
  printf 'check W4 "extra one" a\ncheck W5 "extra two" b\ncheck W6 "extra three" c\n' \
    >> "$lroot/caffeine/ruby/widget.sh"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *"6 rules"*|*"rule count"*) ;; *) false ;; esac
}

@test "a sidecar needs its derived fixture file" {
  make_corpus
  rm "$lroot/test/caffeine_ruby_widget.bats"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *caffeine_ruby_widget.bats*) ;; *) false ;; esac
}

@test "topics outside depth two are refused" {
  make_corpus
  mkdir -p "$lroot/caffeine/js/react"
  printf '# caffeine: js/react/hooks\n' > "$lroot/caffeine/js/react/hooks.md"
  lint
  [ "$status" -ne 0 ]
  case "$output" in *"depth"*) ;; *) false ;; esac
}

@test "missing sidecar header fields are named" {
  make_corpus
  python3 - "$lroot/caffeine/ruby/widget.sh" <<'PYEOF'
import sys
p = sys.argv[1]
s = open(p).read().replace('# caffeine-reviewed: 2026-08-12\n', '')
open(p, 'w').write(s)
PYEOF
  lint
  [ "$status" -ne 0 ]
  case "$output" in *caffeine-reviewed*) ;; *) false ;; esac
}
