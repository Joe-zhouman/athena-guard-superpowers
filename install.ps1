# install.ps1 — install athena-superpowers (windows)
#
# What this does:
#   1. Plugins the repo at ~/.claude/skills/athena-superpowers/ via symlink,
#      so CC's @skills-dir mechanism auto-loads the plugin's HOOKS and SKILLS.
#   2. COPIES the agents (+ refs/) into ~/.claude/agents/, as USER-LEVEL
#      global agents — not plugin agents.
#
# Why copy (not symlink) for agents: file names are stable, so re-running
# this script just overwrites — that IS the update. Copy avoids broken
# symlinks if the user moves or deletes the cloned repo.
#
# Why symlink for the plugin: hooks + skills have no field restrictions,
# and symlink means editing the repo updates the plugin immediately.
#
# Idempotent: safe to re-run. Overwrites agents, refreshes symlink.
# Run from anywhere; resolves the repo root from this script's location.
#
# Requires: PowerShell 5.1+ (Windows 10+).
# Symlink creation may need admin or Developer Mode enabled.
# If symlink is not possible, falls back to copying the plugin directory.

param()

$ErrorActionPreference = "Stop"

# --- locate repo root (this script lives at repo root) ---
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = $ScriptDir

# --- sanity: must be the athena repo ---
if (-not (Test-Path "$RepoRoot\.claude-plugin\plugin.json") -or -not (Test-Path "$RepoRoot\user-agents")) {
    Write-Error "ERROR: $RepoRoot does not look like the athena-superpowers repo"
    Write-Error "       (expected .claude-plugin/plugin.json and user-agents/)"
    exit 1
}

$ClaudeHome = "$env:USERPROFILE\.claude"
$SkillsDir = "$ClaudeHome\skills"
$PluginLink = "$SkillsDir\athena-superpowers"
$AgentsDir = "$ClaudeHome\agents"
$AgentsRefsDir = "$AgentsDir\refs"

# --- platform guard ---
if (-not ($IsWindows -or [System.Environment]::OSVersion.Platform -eq "Win32NT")) {
    Write-Error "ERROR: this install.ps1 is for Windows (got $([System.Environment]::OSVersion))"
    Write-Error "       Linux: use install.sh. macOS: not yet supported."
    exit 1
}

Write-Host "Installing athena-superpowers from: $RepoRoot"
Write-Host ""

# --- 1. plugin (hooks + skills) via @skills-dir symlink ---
New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null

if (Test-Path $PluginLink) {
    $item = Get-Item $PluginLink -Force
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        # existing symlink/junction — remove and replace
        Remove-Item $PluginLink -Force
    } else {
        Write-Warning "$PluginLink exists and is not a symlink."
        Write-Warning "         Backing it up to $PluginLink.bak and replacing."
        Move-Item $PluginLink "$PluginLink.bak" -Force
    }
}

# try symlink first, fall back to copy
$symlinked = $false
try {
    New-Item -ItemType SymbolicLink -Path $PluginLink -Target $RepoRoot -Force -ErrorAction Stop | Out-Null
    $symlinked = $true
    Write-Host "[plugin]  symlinked $PluginLink -> $RepoRoot"
} catch {
    # on Windows, symlinks need admin or Developer Mode. Try junction as fallback.
    try {
        New-Item -ItemType Junction -Path $PluginLink -Target $RepoRoot -Force -ErrorAction Stop | Out-Null
        $symlinked = $true
        Write-Host "[plugin]  junctioned $PluginLink -> $RepoRoot"
    } catch {
        Write-Warning "         Symlink/junction failed. Falling back to directory copy."
        Copy-Item -Recurse -Force -Path $RepoRoot\* -Destination $PluginLink
    }
}
if ($symlinked) {
    Write-Host "          hooks + skills auto-load next session (@skills-dir)"
} else {
    Write-Host "[plugin]  copied $RepoRoot -> $PluginLink (not auto-updating — re-run to update)"
}

# --- 2. agents (user-level global, full capabilities) ---
New-Item -ItemType Directory -Force -Path $AgentsDir | Out-Null
New-Item -ItemType Directory -Force -Path $AgentsRefsDir | Out-Null

$agentCount = 0
Get-ChildItem "$RepoRoot\user-agents\*.md" | ForEach-Object {
    Copy-Item $_.FullName $AgentsDir -Force
    $agentCount++
}

$refCount = 0
if (Test-Path "$RepoRoot\user-agents\refs") {
    Get-ChildItem "$RepoRoot\user-agents\refs\*.md" | ForEach-Object {
        Copy-Item $_.FullName $AgentsRefsDir -Force
        $refCount++
    }
}

Write-Host "[agents]  copied $agentCount agents -> $AgentsDir"
Write-Host "[refs]    copied $refCount refs -> $AgentsRefsDir"
Write-Host "          (user-level: global, no field restrictions)"

Write-Host ""
Write-Host "Done. To activate:"
Write-Host "  1. Start a NEW Claude Code session (hooks/skills load at session start)."
Write-Host "  2. Verify plugin:    /plugin   (should list athena-superpowers@skills-dir)"
Write-Host "  3. Verify an agent:  dispatch @capricorn or check the agent list."
Write-Host ""
Write-Host "Update later: git pull && .\install.ps1   (re-running overwrites agents)"
