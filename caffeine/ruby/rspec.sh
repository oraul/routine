#!/usr/bin/env bash
# Caffeine sidecar: mechanical RSpec hygiene, scoped to spec/. Judges
# nothing a grep cannot see; structure lives in rspec.md. TARGET = the app.
# caffeine-topic: ruby/rspec
# caffeine-applies: rspec >=3.0
# caffeine-reviewed: 2026-08-12
set -u

target="${TARGET:-$PWD}"
specs="$target/spec"
fails=0

scan() {
  grep -rnE --include='*_spec.rb' --include='spec_helper.rb' \
    --include='rails_helper.rb' "$1" "$specs" 2>/dev/null \
    | grep -v -e '/vendor/' -e '/node_modules/'
}

check() {
  _rule="$1" _pattern="$2"
  [ -d "$specs" ] || return 0
  _hits="$(scan "$_pattern")" || true
  if [ -n "$_hits" ]; then
    printf '%s\n' "$_hits" | sed "s|^|caffeine/ruby/rspec: $_rule: |" >&2
    fails=1
  fi
}

check "legacy should syntax (use expect)" '\.should(_not)?([[:space:]]|\()'
check "leftover focus mark" '(^|[[:space:]])(fit|fdescribe|fcontext)([[:space:]]|\()|focus:[[:space:]]*true'
check "sleep in a spec (use test doubles or travel helpers)" '(^|[^a-z_.])sleep([[:space:]]|\()'
check "any_instance stubs objects the example never built" 'any_instance(_of)?\('

exit "$fails"
