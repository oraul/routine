#!/usr/bin/env bash
# Caffeine sidecar: mechanical Sidekiq rules. Judges nothing a grep cannot
# see; judgment guidance lives in sidekiq.md. TARGET = the app repo.
# caffeine-topic: ruby/sidekiq
# caffeine-applies: sidekiq >=6.3
# caffeine-reviewed: 2026-08-12
set -u

# shellcheck source-path=SCRIPTDIR/../..
# shellcheck source=lib/sidecar.sh
. "$(cd "$(dirname "$0")/../.." && pwd)/lib/sidecar.sh"
sidecar_init ruby/sidekiq

check K1 "legacy include Sidekiq::Worker (use Sidekiq::Job)" \
  'include[[:space:]]+Sidekiq::Worker' "$target"
check K2 "keyword args to perform_* (arguments must be JSON-native)" \
  'perform_(async|in|at)\(([^)]*,)?[[:space:]]*[a-z_]+:[[:space:]]' "$target"
for _jobs in "$target/app/workers" "$target/app/jobs" "$target/app/sidekiq"; do
  check K3 "sleep inside a job pins a Sidekiq thread" \
    '(^|[^a-z_.])sleep([[:space:]]|\()' "$_jobs"
done
check K4 "retry: false silently drops failures (state the dead-set plan)" \
  'sidekiq_options[^#]*retry:[[:space:]]*false' "$target"
check K5 "Sidekiq delayed extensions were removed (use a job class)" \
  '\.delay(_for\(|_until\(|\.)' "$target"

exit "$fails"
