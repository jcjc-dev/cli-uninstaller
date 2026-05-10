# CLI Uninstaller

Conservative uninstall scripts for agentic coding CLIs installed by custom shell installers, especially `curl ... | bash` flows that bypass npm, Homebrew, Chocolatey, and WinGet.

## Scope

This repo captures uninstall behavior by reversing installer scripts and vendor documentation. The first verified tools are:

- JetBrains Junie CLI
- GitHub Copilot CLI
- Claude Code native installer
- OpenCode script installer

## Safety Model

Each script separates:

- install artifacts: binaries, shims, version directories, update payloads
- user data: auth state, settings, conversations, transcripts, permissions, logs, skills, hooks, allowlists, and caches

Default uninstall removes install artifacts only. User data is kept unless `--purge` is provided, and interactive runs ask before deleting each user-data path.

Shared shell profile changes are not edited automatically. Installers commonly add `~/.local/bin` or another bin directory to PATH, but that path is often shared by many tools.

## Usage

Dry run:

```sh
./scripts/uninstall-junie.sh --dry-run
./scripts/uninstall-copilot-cli.sh --dry-run
./scripts/uninstall-claude-code.sh --dry-run
./scripts/uninstall-opencode.sh --dry-run
```

Remove install artifacts:

```sh
./scripts/uninstall-junie.sh
./scripts/uninstall-copilot-cli.sh
./scripts/uninstall-claude-code.sh
./scripts/uninstall-opencode.sh
```

Remove install artifacts and ask about user data:

```sh
./scripts/uninstall-junie.sh --purge
```

Non-interactive install-artifact removal:

```sh
./scripts/uninstall-copilot-cli.sh --yes
```

Non-interactive purge:

```sh
./scripts/uninstall-copilot-cli.sh --yes --purge
```

Use non-interactive purge only when the caller has already confirmed that deleting the tool's user state is intended.

## Manifests

The `manifests/` directory records installer commands, install artifacts, user-data paths, and notes for each supported tool. Scripts should stay aligned with their corresponding manifest.

## Validation

Run:

```sh
bash -n lib/common.sh scripts/*.sh
```

Optionally run dry-run checks for each script before publishing changes.
