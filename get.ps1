<#
.SYNOPSIS
  Bootstrap installer for athena-superpowers on Windows.
  You run this BEFORE having the repo — it asks where to clone, clones from
  GitHub, keeps it (git-pullable for updates), then runs the repo's install.ps1.

  For users who have never used a terminal: see the prompts. You just paste a
  folder path you created in File Explorer.

.NOTES
  PowerShell 5.1+ (ships with Windows 10/11). Re-run any time to update
  (git pull + reinstall).
#>

param(
  [string]$RepoURL = "https://github.com/Joe-zhouman/athena-guard-superpowers.git"
)

$ErrorActionPreference = "Stop"
function Info($m){ Write-Host "  $m" -ForegroundColor Cyan }
function Ok($m){ Write-Host "  [ok] $m" -ForegroundColor Green }
function Warn($m){ Write-Host "  [!]  $m" -ForegroundColor Yellow }
function Die($m){ Write-Host "  [x]  $m" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "=== athena-superpowers bootstrap ===" -ForegroundColor Cyan
Write-Host "  (clone from GitHub + install into Claude Code)"
Write-Host ""

# --- 0. git available? ---
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
  Die "git not found. Install Git for Windows (https://git-scm.com) and re-run this command."
}

# --- 1. ask the user where to clone (loop until valid) ---
Write-Host "Step 1 — pick a folder to keep the repo in." -ForegroundColor Cyan
Write-Host "  Do this in File Explorer (no need to type a path by hand if you don't want to):" -ForegroundColor DarkGray
Write-Host "    1. Open File Explorer, go somewhere you own (e.g. D:\ or Documents)." -ForegroundColor DarkGray
Write-Host "    2. Create a NEW folder, e.g. named 'athena'." -ForegroundColor DarkGray
Write-Host "    3. Click into it, then click the address bar and copy the path (Ctrl+C)." -ForegroundColor DarkGray
Write-Host "    4. Paste it below (Ctrl+V) and press Enter." -ForegroundColor DarkGray
Write-Host ""

$CloneRoot = $null
while ($true) {
  $raw = Read-Host "  Paste the folder path (then Enter)"
  # Read-Host returns $null on EOF (non-interactive stdin closed) or Ctrl+C.
  # In real interactive use this won't happen; treat it as "user cancelled".
  if ($null -eq $raw) {
    Write-Host ""
    Die "No input received (stdin closed / Ctrl+C). Re-run the command to try again."
  }
  $raw = $raw.Trim().Trim('"').Trim("'")   # tolerate quoted pastes

  if ([string]::IsNullOrWhiteSpace($raw)) {
    Warn "Empty input. Try again (paste a folder path)."
    continue
  }
  if (-not (Test-Path -LiteralPath $raw)) {
    Warn "That path does not exist: '$raw'"
    Write-Host "      Create the folder first (Step 1 above), then paste its path." -ForegroundColor DarkGray
    continue
  }
  $item = Get-Item -LiteralPath $raw -Force
  if (-not $item.PSIsContainer) {
    Warn "That's a file, not a folder: '$raw'"
    Write-Host "      Pick/create a folder, not a file." -ForegroundColor DarkGray
    continue
  }
  # writable check
  $testFile = Join-Path $raw ".athena-write-test-$PID"
  try {
    Set-Content -LiteralPath $testFile -Value "x" -ErrorAction Stop
    Remove-Item -LiteralPath $testFile -Force -ErrorAction SilentlyContinue
  } catch {
    Warn "Can't write to that folder: '$raw'"
    Write-Host "      Pick a folder you own (e.g. under your user directory or D:\)." -ForegroundColor DarkGray
    continue
  }
  $CloneRoot = $raw
  Ok "Using folder: $CloneRoot"
  break
}

# --- 2. clone (or update if already there) ---
$Target = Join-Path $CloneRoot "athena-superpowers"
Write-Host ""
Write-Host "Step 2 — get the repo from GitHub." -ForegroundColor Cyan

function Invoke-Git {
  param([Parameter(Mandatory=$true)][string[]]$GitArgs)
  $prev = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try { & git @GitArgs 2>$null | Out-Host } finally { $ErrorActionPreference = $prev }
  return $LASTEXITCODE
}

if (Test-Path -LiteralPath (Join-Path $Target ".git")) {
  Info "Found existing clone at $Target — updating (git pull)..."
  $rc = Invoke-Git @("-C", $Target, "pull", "--ff-only")
  if ($rc -ne 0) {
    Warn "git pull had conflicts (exit $rc). Left as-is."
    Write-Host "      Resolve them in $Target, or delete that folder and re-run to start fresh." -ForegroundColor DarkGray
  }
} else {
  Info "Cloning into $Target ..."
  $rc = Invoke-Git @("clone", $RepoURL, $Target)
  if ($rc -ne 0) {
    Die "git clone failed (exit $rc). Check your network / the path, then re-run this command."
  }
  Ok "Cloned"
}

# --- 3. run the repo's install.ps1 (symlink plugin + copy agents) ---
$InstallScript = Join-Path $Target "install.ps1"
if (-not (Test-Path -LiteralPath $InstallScript)) {
  Die "install.ps1 not found in $Target — the clone may be incomplete. Delete $Target and re-run."
}
Write-Host ""
Write-Host "Step 3 — install into Claude Code (symlink plugin + copy agents)." -ForegroundColor Cyan
& powershell -NoProfile -ExecutionPolicy Bypass -File $InstallScript
if ($LASTEXITCODE -ne 0) {
  Write-Host ""
  Die "install.ps1 failed (exit $LASTEXITCODE). Fix the issue above, then re-run this command — your clone at $Target is kept."
}

Write-Host ""
Ok "Done. The repo is kept at $Target — re-run this command any time to update (git pull + reinstall)."
Write-Host "  Start a NEW Claude Code session to load the hooks + skills + agents." -ForegroundColor DarkGray
Write-Host ""
Write-Host "  ⚠️ Before dispatching sagittarius: its router is tailored to Joe's MCP" -ForegroundColor Yellow
Write-Host "     setup. The main agent will walk you through rebuilding it. Structure is" -ForegroundColor DarkGray
Write-Host "     universal, tool names are not." -ForegroundColor DarkGray
Write-Host ""
