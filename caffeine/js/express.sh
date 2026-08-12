#!/usr/bin/env bash
# Caffeine sidecar: mechanical Express rules. Judges nothing a grep
# cannot see; judgment guidance lives in express.md. TARGET = the app.
# caffeine-topic: js/express
# caffeine-applies: express >=4
# caffeine-reviewed: 2026-08-12
set -u

# shellcheck source-path=SCRIPTDIR/../..
# shellcheck source=lib/sidecar.sh
. "$(cd "$(dirname "$0")/../.." && pwd)/lib/sidecar.sh"
sidecar_init js/express
sidecar_include="*.js *.mjs *.ts"

check E1 "synchronous fs call in request code (use the promise API)" \
  '(readFileSync|writeFileSync|existsSync|readdirSync)\(' "$target"
check E2 "console.log in app code (use a logger)" \
  '^[[:space:]]*console\.(log|debug)\(' "$target"
check E3 "leftover debugger statement" \
  '(^|[[:space:]])debugger(;|[[:space:]]|$)' "$target"
check E4 "wildcard CORS (scope the origin)" \
  'origin:[[:space:]]*['"'"'"]\*['"'"'"]|app\.use\(cors\(\)\)' "$target"

exit "$fails"
