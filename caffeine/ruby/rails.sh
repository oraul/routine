#!/usr/bin/env bash
# Caffeine sidecar: mechanical Rails rules. Judges nothing a grep cannot
# see; judgment guidance lives in rails.md. TARGET = the app repo.
# caffeine-topic: ruby/rails
# caffeine-applies: rails >=7.0
# caffeine-reviewed: 2026-08-12
set -u

# shellcheck source-path=SCRIPTDIR/../..
# shellcheck source=lib/sidecar.sh
. "$(cd "$(dirname "$0")/../.." && pwd)/lib/sidecar.sh"
sidecar_init ruby/rails

check R1 "leftover debugger" 'binding\.(irb|pry)|(^|[^a-z_.])byebug|(^|[^a-z_.])debugger' "$target"
check R2 "string-interpolated SQL" '(where|order|group|having|find_by_sql)\("[^"]*#\{' "$target"
check R3 "puts in app code (use the logger)" '^[[:space:]]*puts([[:space:]]|\()' "$target/app"
check R4 "rescue Exception (rescue StandardError instead)" 'rescue[[:space:]]+Exception' "$target"

exit "$fails"
