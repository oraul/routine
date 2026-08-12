#!/usr/bin/env bash
# Caffeine sidecar: mechanical ActiveRecord rules. Judges nothing a grep
# cannot see; judgment guidance lives in active_record.md. TARGET = the app.
# caffeine-topic: ruby/active_record
# caffeine-applies: rails >=7.0
# caffeine-reviewed: 2026-08-12
set -u

target="${TARGET:-$PWD}"
fails=0

scan() {
  grep -rnE --include='*.rb' "$1" "$target" 2>/dev/null \
    | grep -v -e '/vendor/' -e '/node_modules/'
}

check() {
  _rule="$1" _pattern="$2"
  _hits="$(scan "$_pattern")" || true
  if [ -n "$_hits" ]; then
    printf '%s\n' "$_hits" | sed "s|^|caffeine/ruby/active_record: $_rule: |" >&2
    fails=1
  fi
}

check "update_attribute skips validations (use update!)" 'update_attribute\('
check "unbatched iteration (use find_each)" '\.all\.each'
check "save(validate: false) skips validations" 'save\(validate:[[:space:]]*false\)'
check "default_scope (prefer named scopes)" '(^|[[:space:]])default_scope'

exit "$fails"
