#!/usr/bin/env bash
# Caffeine sidecar: mechanical Sidekiq rules. Judges nothing a grep cannot
# see; judgment guidance lives in sidekiq.md. TARGET = the app repo.
set -u

target="${TARGET:-$PWD}"
fails=0

scan() {
  grep -rnE --include='*.rb' "$1" "$2" 2>/dev/null \
    | grep -v -e '/vendor/' -e '/node_modules/'
}

check() {
  _rule="$1" _pattern="$2" _scope="$3"
  [ -d "$_scope" ] || return 0
  _hits="$(scan "$_pattern" "$_scope")" || true
  if [ -n "$_hits" ]; then
    printf '%s\n' "$_hits" | sed "s|^|caffeine/ruby/sidekiq: $_rule: |" >&2
    fails=1
  fi
}

check "legacy include Sidekiq::Worker (use Sidekiq::Job)" \
  'include[[:space:]]+Sidekiq::Worker' "$target"
check "keyword args to perform_* (arguments must be JSON-native)" \
  'perform_(async|in|at)\([^)]*[a-z_]+:' "$target"
for jobs_dir in "$target/app/workers" "$target/app/jobs" "$target/app/sidekiq"; do
  check "sleep inside a job pins a Sidekiq thread" \
    '(^|[^a-z_.])sleep([[:space:]]|\()' "$jobs_dir"
done
check "retry: false silently drops failures (state the dead-set plan)" \
  'sidekiq_options[^#]*retry:[[:space:]]*false' "$target"

exit "$fails"
