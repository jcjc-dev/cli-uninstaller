#!/usr/bin/env bash

set -euo pipefail

load_common() {
  local source_path="${BASH_SOURCE[0]:-}"
  local local_common=""

  if [[ "$source_path" == */* ]]; then
    local_common="$(cd -- "$(dirname -- "$source_path")" && pwd)/../lib/common.sh"
  fi

  if [[ -n "$local_common" && -r "$local_common" ]]; then
    # shellcheck source=../lib/common.sh
    source "$local_common"
    return
  fi

  local base_url="${CLI_UNINSTALLER_BASE_URL:-https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main}"
  CLI_UNINSTALLER_COMMON_TMP="$(mktemp "${TMPDIR:-/tmp}/cli-uninstaller-common.XXXXXX")"
  trap 'rm -f "$CLI_UNINSTALLER_COMMON_TMP"' EXIT

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$base_url/lib/common.sh" -o "$CLI_UNINSTALLER_COMMON_TMP"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$CLI_UNINSTALLER_COMMON_TMP" "$base_url/lib/common.sh"
  else
    echo "curl or wget is required to fetch cli-uninstaller helpers." >&2
    exit 1
  fi

  # shellcheck source=../lib/common.sh
  source "$CLI_UNINSTALLER_COMMON_TMP"
}

load_common

usage() {
  cat <<'EOF'
Uninstall GitHub Copilot CLI installed by https://gh.io/copilot-install.

Removes:
  ${PREFIX:-~/.local}/bin/copilot
  /usr/local/bin/copilot when writable or when run with sufficient privileges

Optional purge targets:
  ${COPILOT_HOME:-~/.copilot}
  ${COPILOT_CACHE_HOME:-platform cache directory}

EOF
  usage_common
}

parse_common_args "$@"

if [[ "$(id -u 2>/dev/null || echo 1)" -eq 0 ]]; then
  DEFAULT_PREFIX="/usr/local"
else
  DEFAULT_PREFIX="$HOME/.local"
fi

PREFIX="${PREFIX:-$DEFAULT_PREFIX}"
COPILOT_HOME="${COPILOT_HOME:-$HOME/.copilot}"

case "$(uname -s || echo unknown)" in
  Darwin*) DEFAULT_CACHE="$HOME/Library/Caches/copilot" ;;
  Linux*) DEFAULT_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/copilot" ;;
  *) DEFAULT_CACHE="$HOME/.cache/copilot" ;;
esac
COPILOT_CACHE_HOME="${COPILOT_CACHE_HOME:-$DEFAULT_CACHE}"

ARTIFACTS=("$PREFIX/bin/copilot")
if [[ "$PREFIX" != "/usr/local" ]]; then
  ARTIFACTS+=("/usr/local/bin/copilot")
fi

if confirm "Remove GitHub Copilot CLI install artifacts?"; then
  remove_artifacts "${ARTIFACTS[@]}"
else
  log "Skipped GitHub Copilot CLI install-artifact removal."
fi

remove_user_data \
  "$COPILOT_HOME" "This includes auth state, settings, agents, skills, hooks, permissions, logs, and session history." \
  "$COPILOT_CACHE_HOME" "This includes caches, marketplace data, and auto-update packages."

log "Done. Shell profile PATH entries were not modified because PATH directories may be shared."
