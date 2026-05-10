#!/usr/bin/env bash

set -euo pipefail

DRY_RUN=false
ASSUME_YES=false
PURGE=false

usage_common() {
  cat <<'EOF'
Common options:
  -n, --dry-run   Show what would be removed without deleting anything.
  -y, --yes       Do not prompt for standard install-artifact removal.
  --purge         Also remove user state directories after explicit selection.
  -h, --help      Show help.

Default behavior removes install artifacts only. User data, sessions, auth,
permissions, logs, and customizations are removed only in purge mode.
EOF
}

parse_common_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--dry-run)
        DRY_RUN=true
        shift
        ;;
      -y|--yes)
        ASSUME_YES=true
        shift
        ;;
      --purge)
        PURGE=true
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage >&2
        exit 2
        ;;
    esac
  done
}

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'Warning: %s\n' "$*" >&2
}

confirm() {
  local prompt="$1"

  if [[ "$DRY_RUN" == true ]]; then
    return 0
  fi

  if [[ "$ASSUME_YES" == true ]]; then
    return 0
  fi

  if [[ ! -t 0 ]]; then
    return 1
  fi

  local reply
  printf '%s [y/N] ' "$prompt"
  read -r reply
  case "$reply" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

confirm_purge_path() {
  local path="$1"
  local note="$2"

  if [[ "$PURGE" != true ]]; then
    return 1
  fi

  if [[ "$ASSUME_YES" == true ]]; then
    log "Purge selected for $path ($note)"
    return 0
  fi

  confirm "Remove user data at $path? $note"
}

remove_path() {
  local path="$1"

  if [[ ! -e "$path" && ! -L "$path" ]]; then
    log "Not found: $path"
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log "Would remove: $path"
    return 0
  fi

  rm -rf -- "$path"
  log "Removed: $path"
}

remove_artifacts() {
  local artifact
  for artifact in "$@"; do
    remove_path "$artifact"
  done
}

remove_user_data() {
  local path note

  while [[ $# -gt 0 ]]; do
    path="$1"
    note="$2"
    shift 2

    if confirm_purge_path "$path" "$note"; then
      remove_path "$path"
    else
      log "Kept user data: $path"
    fi
  done
}
