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
Uninstall Claude Code native installer artifacts.

Removes common native install artifacts:
  ~/.local/bin/claude
  ~/.local/share/claude
  ~/.cache/claude

Optional purge targets:
  ~/.claude
  ~/.config/claude

EOF
  usage_common
}

parse_common_args "$@"

if confirm "Remove Claude Code native install artifacts?"; then
  remove_artifacts \
    "$HOME/.local/bin/claude" \
    "$HOME/.local/share/claude" \
    "$HOME/.cache/claude"
else
  log "Skipped Claude Code install-artifact removal."
fi

remove_user_data \
  "$HOME/.claude" "This may include auth state, settings, commands, memories, projects, transcripts, and session history." \
  "${XDG_CONFIG_HOME:-$HOME/.config}/claude" "This may include user configuration."

log "Done. Homebrew, npm, and system package installations should be removed with their package manager."
