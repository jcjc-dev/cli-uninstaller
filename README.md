# Get Started

Conservative uninstall scripts for agentic coding CLIs installed by custom shell installers, especially `curl ... | bash` and `irm ... | iex` flows that bypass npm, pipx, Homebrew, Chocolatey, and WinGet.

## Uninstall

Choose your tool and platform, then copy one command.

### Junie CLI

macOS / Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- junie
```

Windows:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.ps1))) junie
```

### GitHub Copilot CLI

macOS / Linux custom installer:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- copilot-cli
```

Windows:

Native Windows installs are managed by WinGet and are intentionally out of scope for this repo.

### Claude Code

macOS / Linux native installer:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- claude-code
```

Windows:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.ps1))) claude-code
```

### OpenCode

macOS / Linux custom installer:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- opencode
```

Windows:

No verified custom Windows installer is currently covered.

## Options

By default, scripts remove install artifacts only. User data is kept.

To also remove user data, add `--purge` on macOS/Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- junie --purge
```

Or add `-Purge` on Windows:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.ps1))) junie -Purge
```

Use `--yes` or `-Yes` only when the caller has already confirmed that deleting install artifacts without prompts is intended.

## Scope

This repo captures uninstall behavior by reversing installer scripts and vendor documentation. The first verified tools are:

- JetBrains Junie CLI
- GitHub Copilot CLI
- Claude Code native installer
- OpenCode script installer

Out of scope:

- npm, npx, pnpm, Yarn, pipx, Homebrew, Chocolatey, WinGet, apt, dnf, pacman, or other package-manager installs
- wrappers that simply call a package manager
- IDE extensions and marketplace installs

Platform support:

- macOS and Linux: Bash scripts under `scripts/` plus the `uninstall.sh` dispatcher.
- Windows: native PowerShell support through `uninstall.ps1` for verified custom Windows installers only.
- Windows Git Bash, MSYS2, and WSL are not the primary Windows path. Use `uninstall.ps1` for native Windows installs.

## Safety Model

Each script separates:

- install artifacts: binaries, shims, version directories, update payloads
- user data: auth state, settings, conversations, transcripts, permissions, logs, skills, hooks, allowlists, and caches

Default uninstall removes install artifacts only. User data is kept unless `--purge` or `-Purge` is provided, and interactive runs ask before deleting each user-data path.

Shared shell profile changes are not edited automatically. Installers commonly add `~/.local/bin` or another bin directory to PATH, but that path is often shared by many tools.

## Manifests

The `manifests/` directory records installer commands, install artifacts, user-data paths, and notes for each supported tool. Scripts should stay aligned with their corresponding manifest.
