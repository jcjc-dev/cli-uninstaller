#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

usage() {
  cat <<'EOF'
Uninstall Junie CLI installed by https://junie.jetbrains.com/install.sh.

Removes:
  ~/.local/bin/junie
  ${JUNIE_DATA:-~/.local/share/junie}

Optional purge targets:
  ~/.junie

EOF
  usage_common
}

parse_common_args "$@"

JUNIE_BIN="${JUNIE_BIN:-$HOME/.local/bin}"
JUNIE_DATA="${JUNIE_DATA:-$HOME/.local/share/junie}"

if confirm "Remove Junie CLI install artifacts?"; then
  remove_artifacts \
    "$JUNIE_BIN/junie" \
    "$JUNIE_DATA"
else
  log "Skipped Junie install-artifact removal."
fi

remove_user_data \
  "$HOME/.junie" "This may include allowlists, authentication state, settings, and recent session context."

log "Done. Shell profile PATH entries were not modified because ~/.local/bin may be shared by other tools."
