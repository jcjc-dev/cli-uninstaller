# 🧹 CLI Uninstaller

You can finally clean up coding agents you downloaded without using a package manager.

## 🚀 Get Started

CLI Uninstaller removes coding-agent CLIs installed on macOS and Linux by custom shell scripts like `curl ... | bash`. It intentionally skips tools installed through npm, pipx, Homebrew, or other package managers.

## 🧽 Uninstall

Choose your tool and platform, then copy one command.

### 🤖 Junie CLI

macOS / Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- junie
```

### 🤖 GitHub Copilot CLI

macOS / Linux custom installer:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- copilot-cli
```

### 🤖 Claude Code

macOS / Linux native installer:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- claude-code
```

### 🤖 OpenCode

macOS / Linux custom installer:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- opencode
```

## ⚙️ Options

By default, scripts remove install artifacts only. User data is kept.

To also remove user data, add `--purge` on macOS/Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.sh | bash -s -- junie --purge
```

Use `--yes` only when the caller has already confirmed that deleting install artifacts without prompts is intended.

## 🎯 What This Covers

Verified tools:

- JetBrains Junie CLI
- GitHub Copilot CLI
- Claude Code native installer
- OpenCode script installer

Not covered:

- Windows
- npm, npx, pnpm, Yarn, pipx, Homebrew, apt, dnf, pacman, or other package-manager installs
- wrappers that simply call a package manager
- IDE extensions and marketplace installs

Platforms:

- macOS and Linux: Bash scripts under `scripts/` plus the `uninstall.sh` dispatcher.

## 🛡️ Safety Model

Each script separates:

- install artifacts: binaries, shims, version directories, update payloads
- user data: auth state, settings, conversations, transcripts, permissions, logs, skills, hooks, allowlists, and caches

Default uninstall removes install artifacts only. User data is kept unless `--purge` is provided, and interactive runs ask before deleting each user-data path.

Shared shell profile changes are not edited automatically. Installers commonly add `~/.local/bin` or another bin directory to PATH, but that path is often shared by many tools.

## 📦 Manifests

The `manifests/` directory records installer commands, install artifacts, user-data paths, and notes for each supported tool. Scripts should stay aligned with their corresponding manifest.
