# CLI Uninstaller

Conservative uninstall scripts for agentic coding CLIs installed by custom shell installers, especially `curl ... | bash` and `irm ... | iex` flows that bypass npm, pipx, Homebrew, Chocolatey, and WinGet.

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

Default uninstall removes install artifacts only. User data is kept unless `--purge` is provided, and interactive runs ask before deleting each user-data path.

Shared shell profile changes are not edited automatically. Installers commonly add `~/.local/bin` or another bin directory to PATH, but that path is often shared by many tools.

## Usage

### macOS and Linux

Run the top-level Bash dispatcher directly from GitHub:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- junie --dry-run
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- copilot-cli --dry-run
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- claude-code --dry-run
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- opencode --dry-run
```

Remove install artifacts:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- junie
```

Remove install artifacts and ask about user data:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- junie --purge
```

Non-interactive install-artifact removal:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- copilot-cli --yes
```

Non-interactive purge:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- copilot-cli --yes --purge
```

Use non-interactive purge only when the caller has already confirmed that deleting the tool's user state is intended.

You can also fetch a tool-specific script directly:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/scripts/uninstall-junie.sh | bash -s -- --dry-run
```

The tool-specific scripts fetch `lib/common.sh` from the default GitHub raw URL when they are not run from a local checkout. Set `CLI_UNINSTALLER_BASE_URL` to test a fork, branch, tag, or local raw host.

### Windows

Run the top-level PowerShell dispatcher directly from GitHub:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.ps1))) junie -DryRun
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.ps1))) claude-code -DryRun
```

Remove install artifacts:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.ps1))) junie
```

Remove install artifacts and ask about user data:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.ps1))) junie -Purge
```

Non-interactive install-artifact removal:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.ps1))) claude-code -Yes
```

Non-interactive purge:

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.ps1))) claude-code -Yes -Purge
```

## Local Development

Dry run from a checkout:

```sh
./scripts/uninstall-junie.sh --dry-run
./scripts/uninstall-copilot-cli.sh --dry-run
./scripts/uninstall-claude-code.sh --dry-run
./scripts/uninstall-opencode.sh --dry-run
```

PowerShell syntax check from a checkout:

```powershell
$null = [scriptblock]::Create((Get-Content .\uninstall.ps1 -Raw))
```

## Manifests

The `manifests/` directory records installer commands, install artifacts, user-data paths, and notes for each supported tool. Scripts should stay aligned with their corresponding manifest.

## Validation

Run:

```sh
bash -n uninstall.sh lib/common.sh scripts/*.sh
```

Optionally run dry-run checks for each script before publishing changes.
