param(
    [Parameter(Position = 0)]
    [ValidateSet("junie", "claude-code", "claude", "help")]
    [string]$Tool = "help",

    [switch]$DryRun,
    [switch]$Yes,
    [switch]$Purge,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

function Show-Usage {
    @"
Usage:
  uninstall.ps1 <tool> [-DryRun] [-Yes] [-Purge]

Tools:
  junie
  claude-code

Examples:
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.ps1))) junie -DryRun
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/jcjc-dev/cli-uninstaller/main/uninstall.ps1))) claude-code -Purge

Default behavior removes install artifacts only. User data is kept unless -Purge
is provided, and interactive runs ask before deleting each user-data path.

Package-manager installs are intentionally out of scope. If a tool was installed
with WinGet, Chocolatey, npm, pipx, Homebrew, or another package manager, remove
it with that same package manager.
"@
}

function Confirm-Action([string]$Prompt) {
    if ($DryRun -or $Yes) {
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

    if ($DryRun) {
        Write-Host "Would remove: $expanded"
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
            (Join-Path $junieBin "junie.cmd"),
            (Join-Path $junieBin "junie.exe"),
            $junieData
        )
    } else {
        Write-Host "Skipped Junie install-artifact removal."
    }

    Remove-UserData @(
        @{ Path = (Join-Path $HOME ".junie"); Note = "This may include allowlists, authentication state, settings, and recent session context." }
    )

    Write-Host "Done. User PATH entries were not modified because ~/.local/bin may be shared by other tools."
}

function Uninstall-ClaudeCode {
    if (Confirm-Action "Remove Claude Code native install artifacts?") {
        Remove-Artifacts @(
            (Join-Path $HOME ".local\bin\claude.exe"),
            (Join-Path $HOME ".local\bin\claude.cmd"),
            (Join-Path $HOME ".local\bin\claude"),
            (Join-Path $HOME ".local\share\claude"),
            (Join-Path $env:LOCALAPPDATA "Claude\claude.exe")
        )
    } else {
        Write-Host "Skipped Claude Code install-artifact removal."
    }

    Remove-UserData @(
        @{ Path = (Join-Path $HOME ".claude"); Note = "This may include auth state, settings, commands, memories, projects, transcripts, and session history." },
        @{ Path = (Join-Path $env:APPDATA "Claude"); Note = "This may include user configuration." },
        @{ Path = (Join-Path $env:LOCALAPPDATA "Claude"); Note = "This may include local app data and cache files." }
    )

    Write-Host "Done. Package-manager installations should be removed with their package manager."
}

if ($Help -or $Tool -eq "help") {
    Show-Usage
    exit 0
}

switch ($Tool) {
    "junie" { Uninstall-Junie }
    { $_ -in @("claude-code", "claude") } { Uninstall-ClaudeCode }
}
