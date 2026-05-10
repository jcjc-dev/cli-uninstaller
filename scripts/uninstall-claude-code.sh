#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"

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

log "Done. Homebrew, npm, WinGet, and system package installations should be removed with their package manager."
