#!/usr/bin/env bash
# Caffeine sidecar: mechanical Rails rules. Judges nothing a grep cannot
# see; judgment guidance lives in rails.md. TARGET = the app repo.
set -u

target="${TARGET:-$PWD}"
fails=0

# scan <ere> <scope-dir> — prints hits excluding vendored code.
scan() {
  grep -rnE --include='*.rb' "$1" "$2" 2>/dev/null \
    | grep -v -e '/vendor/' -e '/node_modules/'
}

check() {
  _rule="$1" _pattern="$2" _scope="$3"
  [ -d "$_scope" ] || return 0
  _hits="$(scan "$_pattern" "$_scope")" || true
  if [ -n "$_hits" ]; then
    printf '%s\n' "$_hits" | sed "s|^|caffeine/ruby/rails: $_rule: |" >&2
    fails=1
  fi
}

check "leftover debugger" 'binding\.(irb|pry)|(^|[^a-z_.])byebug|(^|[^a-z_.])debugger' "$target"
check "string-interpolated SQL" '(where|order|group|having|find_by_sql)\("[^"]*#\{' "$target"
check "puts in app code (use the logger)" '^[[:space:]]*puts([[:space:]]|\()' "$target/app"
check "rescue Exception (rescue StandardError instead)" 'rescue[[:space:]]+Exception' "$target"

exit "$fails"
