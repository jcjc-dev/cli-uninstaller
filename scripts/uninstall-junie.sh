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
