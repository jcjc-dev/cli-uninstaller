#!/usr/bin/env bash

set -euo pipefail

BASE_URL="${CLI_UNINSTALLER_BASE_URL:-https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main}"

usage() {
  cat <<'EOF'
Usage:
  uninstall.sh <tool> [options]

Tools:
  junie
  copilot-cli
  claude-code
  opencode

Examples:
  curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- junie --dry-run
  curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- copilot-cli --purge

Set CLI_UNINSTALLER_BASE_URL to test a fork, branch, tag, or local raw host.
EOF
}

fetch() {
  local url="$1"
  local output="$2"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$output"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$output" "$url"
  else
    echo "curl or wget is required to fetch uninstall scripts." >&2
    exit 1
  fi
}

if [[ $# -lt 1 ]]; then
  usage >&2
  exit 2
fi

tool="$1"
shift

case "$tool" in
  junie) script="uninstall-junie.sh" ;;
  copilot-cli|copilot) script="uninstall-copilot-cli.sh" ;;
  claude-code|claude) script="uninstall-claude-code.sh" ;;
  opencode) script="uninstall-opencode.sh" ;;
  -h|--help|help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown tool: $tool" >&2
    usage >&2
    exit 2
    ;;
esac

tmp_script="$(mktemp "${TMPDIR:-/tmp}/cli-uninstaller.XXXXXX")"
trap 'rm -f "$tmp_script"' EXIT

fetch "$BASE_URL/scripts/$script" "$tmp_script"
bash "$tmp_script" "$@"
