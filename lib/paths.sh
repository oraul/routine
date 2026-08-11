# shellcheck shell=bash
# Root resolution (Law 6): ROUTINE_ROOT overrides everything,
# CLAUDE_PLUGIN_ROOT is the installed-plugin default, and the repository
# containing this file is the fallback. bash 3.2 compatible.

routine_root() {
  if [ -n "${ROUTINE_ROOT:-}" ]; then
    printf '%s\n' "$ROUTINE_ROOT"
  elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
    printf '%s\n' "$CLAUDE_PLUGIN_ROOT"
  else
    ( cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd )
  fi
}
