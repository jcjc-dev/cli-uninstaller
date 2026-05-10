#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

usage() {
  cat <<'EOF'
Uninstall OpenCode installed by https://opencode.ai/install.

Removes:
  ~/.opencode/bin/opencode

Optional purge targets:
  ~/.config/opencode
  ~/.local/share/opencode
  ~/.cache/opencode
  ~/.opencode

EOF
  usage_common
}

parse_common_args "$@"

if confirm "Remove OpenCode install artifacts?"; then
  remove_artifacts "$HOME/.opencode/bin/opencode"
else
  log "Skipped OpenCode install-artifact removal."
fi

remove_user_data \
  "${OPENCODE_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/opencode}" "This may include global provider configuration, auth, and user settings." \
  "${XDG_DATA_HOME:-$HOME/.local/share}/opencode" "This may include durable application data." \
  "${XDG_CACHE_HOME:-$HOME/.cache}/opencode" "This includes cache files." \
  "$HOME/.opencode" "This may remove the installer-owned bin directory plus any legacy OpenCode state stored under ~/.opencode."

log "Done. Package-manager installations should be removed with their package manager."
