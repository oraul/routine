# shellcheck shell=bash
# The one sidecar instrument: shared scan/check for every caffeine
# sidecar, so a bug fixed here is fixed everywhere. Vendored code is
# excluded by DIRECTORY, never by filtering hit lines — content that
# mentions /vendor/ must not hide a real hit. A scan that cannot run
# exits 2: a broken instrument is never a clean repo. bash 3.2.
#
# Usage in a sidecar:
#   . "$(cd "$(dirname "$0")/../.." && pwd)/lib/sidecar.sh"
#   sidecar_init <ns>/<topic>
#   check <id> "<rule>" '<pattern>' [scope]   # scope defaults to $target
#   exit "$fails"
#
# sidecar_include holds space-separated --include globs (default *.rb);
# a sidecar may override it between checks.

target="${TARGET:-$PWD}"
# Consumed by the sourcing sidecar's final `exit "$fails"`.
# shellcheck disable=SC2034
fails=0
sidecar_topic=""
sidecar_include="*.rb"

sidecar_init() { sidecar_topic="caffeine/$1"; }

check() {
  _c_id="$1" _c_rule="$2" _c_pattern="$3" _c_scope="${4:-$target}"
  [ -d "$_c_scope" ] || return 0
  _c_args=(-rnE)
  set -f
  for _c_glob in $sidecar_include; do
    _c_args[${#_c_args[@]}]="--include=$_c_glob"
  done
  set +f
  for _c_dir in vendor node_modules tmp coverage; do
    _c_args[${#_c_args[@]}]="--exclude-dir=$_c_dir"
  done
  _c_hits="$(grep "${_c_args[@]}" "$_c_pattern" "$_c_scope" 2>/dev/null)"
  _c_rc=$?
  if [ "$_c_rc" -gt 1 ]; then
    echo "${sidecar_topic}[${_c_id}]: scan failed (grep exit $_c_rc) — broken instrument" >&2
    exit 2
  fi
  if [ -n "$_c_hits" ]; then
    printf '%s\n' "$_c_hits" | sed "s|^|${sidecar_topic}[${_c_id}] $_c_rule: |" >&2
    # Consumed by the sourcing sidecar's final `exit "$fails"`.
    # shellcheck disable=SC2034
    fails=1
  fi
}
