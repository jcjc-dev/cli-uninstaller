#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

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
