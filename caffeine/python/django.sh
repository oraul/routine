#!/usr/bin/env bash
# Caffeine sidecar: mechanical Django rules. Judges nothing a grep
# cannot see; judgment guidance lives in django.md. TARGET = the app.
# caffeine-topic: python/django
# caffeine-applies: django >=4.2
# caffeine-reviewed: 2026-08-12
set -u

# shellcheck source-path=SCRIPTDIR/../..
# shellcheck source=lib/sidecar.sh
. "$(cd "$(dirname "$0")/../.." && pwd)/lib/sidecar.sh"
sidecar_init python/django
sidecar_include="*.py"

check D1 "committed DEBUG = True (never in settings)" \
  '^DEBUG[[:space:]]*=[[:space:]]*True' "$target"
check D2 "bare except swallows everything (name the exception)" \
  '^[[:space:]]*except[[:space:]]*:' "$target"
check D3 "f-string SQL (use query parameters)" \
  '\.(execute|raw)\(f['"'"'"]' "$target"
check D4 "print in app code (use logging)" \
  '^[[:space:]]*print\(' "$target"

exit "$fails"
