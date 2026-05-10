param(
    [Parameter(Position = 0)]
    [ValidateSet("junie", "claude-code", "claude", "help")]
    [string]$Tool = "help",

    [switch]$Yes,
    [switch]$Purge,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

function Show-Usage {
    @"
Usage:
  uninstall.ps1 <tool> [-Yes] [-Purge]

Tools:
  junie
  claude-code

Package-manager installs are intentionally out of scope. If a tool was installed
with WinGet, npm, pipx, Homebrew, or another package manager, remove it with
that same package manager.
"@
}

function Confirm-Action([string]$Prompt) {
    if ($Yes) {
        return $true
    }

    $reply = Read-Host "$Prompt [y/N]"
    return $reply -in @("y", "Y", "yes", "YES")
}

function Remove-PathSafe([string]$Path) {
    if (-not $Path) {
        return
    }

    $expanded = [Environment]::ExpandEnvironmentVariables($Path)
    if (-not (Test-Path -LiteralPath $expanded)) {
        Write-Host "Not found: $expanded"
        return
    }

    Remove-Item -LiteralPath $expanded -Recurse -Force
    Write-Host "Removed: $expanded"
}

function Remove-Artifacts([string[]]$Paths) {
    foreach ($path in $Paths) {
        Remove-PathSafe $path
    }
}

function Remove-UserData([object[]]$Items) {
    foreach ($item in $Items) {
        $path = $item.Path
        $note = $item.Note

        if (-not $Purge) {
            Write-Host "Kept user data: $path"
            continue
        }

        if ($Yes -or (Confirm-Action "Remove user data at $path? $note")) {
            Remove-PathSafe $path
        } else {
            Write-Host "Kept user data: $path"
        }
    }
}

function Uninstall-Junie {
    $junieBin = if ($env:JUNIE_BIN) { $env:JUNIE_BIN } else { Join-Path $HOME ".local\bin" }
    $junieData = if ($env:JUNIE_DATA) { $env:JUNIE_DATA } else { Join-Path $HOME ".local\share\junie" }

    if (Confirm-Action "Remove Junie CLI install artifacts?") {
        Remove-Artifacts @(
            (Join-Path $junieBin "junie.bat"),
            $junieData
        )
    } else {
        Write-Host "Skipped Junie install-artifact removal."
    }

    Remove-UserData @(
        @{ Path = (Join-Path $HOME ".junie"); Note = "This may include allowlists, authentication state, settings, and recent session context." }
    )
}

function Uninstall-ClaudeCode {
    if (Confirm-Action "Remove Claude Code native install artifacts?") {
        Remove-Artifacts @(
            (Join-Path $HOME ".local\bin\claude"),
            (Join-Path $HOME ".local\bin\claude.exe"),
            (Join-Path $HOME ".local\bin\claude.cmd"),
            (Join-Path $HOME ".local\share\claude"),
            (Join-Path $HOME ".cache\claude")
        )
    } else {
        Write-Host "Skipped Claude Code install-artifact removal."
    }

    Remove-UserData @(
        @{ Path = (Join-Path $HOME ".claude"); Note = "This may include auth state, settings, commands, memories, projects, transcripts, and session history." },
        @{ Path = (Join-Path $HOME ".config\claude"); Note = "This may include user configuration." }
    )
}

if ($Help -or $Tool -eq "help") {
    Show-Usage
    exit 0
}

switch ($Tool) {
    "junie" { Uninstall-Junie }
    { $_ -in @("claude-code", "claude") } { Uninstall-ClaudeCode }
}
