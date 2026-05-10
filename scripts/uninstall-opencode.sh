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
