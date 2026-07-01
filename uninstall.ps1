# uninstall.ps1 — uninstall athena-superpowers (windows)
#
# What this does:
#   1. Removes the ~/.claude/skills/athena-superpowers/ symlink/junction/copy.
#   2. Removes the 9 athena agents from ~/.claude/agents/ (user-level globals).
#   3. Removes the athena refs from ~/.claude/agents/refs/.
#
# What this does NOT touch:
#   - Other agents or refs you've added to ~/.claude/agents/.
#   - The cloned repo itself (this script lives in it).
#   - Backed-up files (*.bak) — you delete those manually.
#
# Idempotent: safe to re-run. Already-removed files are silently skipped.
# Run from anywhere; resolves the repo root from this script's location.

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
    Write-Error "ERROR: this uninstall.ps1 is for Windows."
    exit 1
}

# --- confirmation ---
Write-Host "This will remove:"
Write-Host "  - plugin link/copy:  $PluginLink"
Write-Host "  - athena agents:     $AgentsDir\{aries,cancer,capricorn,libra,pisces,sagittarius,scorpio,taurus,virgo}.md"
Write-Host "  - athena refs:       $AgentsRefsDir\{aries-round[1-6]-*,pisces-*,sagittarius-*}.md"
Write-Host "  (other agents/refs in $AgentsDir are left untouched)"
Write-Host ""
$confirm = Read-Host "Proceed? [y/N]"
if ($confirm -notmatch '^[Yy]$') {
    Write-Host "Aborted."
    exit 0
}
Write-Host ""

# --- 1. remove plugin symlink/junction/copy ---
if (Test-Path $PluginLink) {
    $item = Get-Item $PluginLink -Force
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
        # it's a symlink or junction — remove directly
        Remove-Item $PluginLink -Force
        Write-Host "[plugin]  removed symlink/junction $PluginLink"
    } elseif ($item -is [System.IO.DirectoryInfo]) {
        # it's a directory copy — only remove if it looks like athena
        if (Test-Path "$PluginLink\.claude-plugin\plugin.json") {
            Remove-Item $PluginLink -Recurse -Force
            Write-Host "[plugin]  removed plugin directory copy $PluginLink"
        } else {
            Write-Warning "$PluginLink exists but doesn't look like athena — not removing."
        }
    } else {
        Write-Warning "$PluginLink exists but is a file (unexpected) — not removing."
    }
} else {
    Write-Host "[plugin]  already gone (nothing to do)"
}

# --- 2. remove agents (only the ones installed by install.ps1) ---
$agentCount = 0
$agentSkipped = 0
Get-ChildItem "$RepoRoot\user-agents\*.md" | ForEach-Object {
    $target = Join-Path $AgentsDir $_.Name
    if (Test-Path $target) {
        Remove-Item $target -Force
        $agentCount++
    } else {
        $agentSkipped++
    }
}
Write-Host "[agents]  removed $agentCount agent(s) from $AgentsDir ($agentSkipped already gone)"

# --- 3. remove refs (only the ones installed by install.ps1) ---
$refCount = 0
$refSkipped = 0
if (Test-Path "$RepoRoot\user-agents\refs") {
    Get-ChildItem "$RepoRoot\user-agents\refs\*.md" | ForEach-Object {
        $target = Join-Path $AgentsRefsDir $_.Name
        if (Test-Path $target) {
            Remove-Item $target -Force
            $refCount++
        } else {
            $refSkipped++
        }
    }
}
Write-Host "[refs]    removed $refCount ref(s) from $AgentsRefsDir ($refSkipped already gone)"

# --- 4. clean up empty refs dir if we emptied it ---
if ((Test-Path $AgentsRefsDir) -and (-not (Get-ChildItem $AgentsRefsDir -ErrorAction SilentlyContinue))) {
    Remove-Item $AgentsRefsDir -Force
    Write-Host "[refs]    removed empty directory $AgentsRefsDir"
}

Write-Host ""
Write-Host "Done. To complete:"
Write-Host "  1. Start a NEW Claude Code session (or /reload-plugins if available)."
Write-Host "  2. Verify: /plugin should no longer list athena-superpowers."
Write-Host "  3. The cloned repo at $RepoRoot is still on disk — delete it manually if you want."
Write-Host ""
Write-Host "To reinstall:  .\install.ps1"
