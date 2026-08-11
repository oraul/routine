# shellcheck shell=bash
# Root resolution (Law 6): ROUTINE_ROOT overrides everything,
# CLAUDE_PLUGIN_ROOT is the installed-plugin default, and the repository
# containing this file is the fallback. bash 3.2 compatible.

# App key derivation (Law 7): the target repository's directory name.
# $1 = target path (a git worktree, or any directory as fallback).
routine_app_key() {
  _p_top="$(git -C "$1" rev-parse --show-toplevel 2>/dev/null)" || _p_top="$1"
  basename "$_p_top"
}

routine_root() {
  if [ -n "${ROUTINE_ROOT:-}" ]; then
    printf '%s\n' "$ROUTINE_ROOT"
  elif [ -n "${CLAUDE_PLUGIN_ROOT:-}" ]; then
    printf '%s\n' "$CLAUDE_PLUGIN_ROOT"
  else
    ( cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd )
  fi
}
