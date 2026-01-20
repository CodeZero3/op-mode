# OP Mode Installer for Windows PowerShell

$ErrorActionPreference = "Stop"

Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  OP Mode - Orchestration Protocol Installer                   ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Determine script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Set target directory
$ClaudeDir = "$env:USERPROFILE\.claude"
$CommandsDir = "$ClaudeDir\commands"
$TargetDir = "$CommandsDir\op-mode"

# Create directories if they don't exist
Write-Host "[1/3] Creating directories..." -ForegroundColor Yellow
if (!(Test-Path $CommandsDir)) {
    New-Item -ItemType Directory -Force -Path $CommandsDir | Out-Null
}

# Check if op-mode already exists
if (Test-Path $TargetDir) {
    Write-Host "  Warning: Existing op-mode installation found." -ForegroundColor Yellow
    $confirm = Read-Host "  Overwrite? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "  Installation cancelled." -ForegroundColor Red
        exit 0
    }
    Remove-Item -Recurse -Force $TargetDir
}

# Copy files
Write-Host "[2/3] Installing OP Mode skill..." -ForegroundColor Yellow
Copy-Item -Recurse -Force "$ScriptDir\commands\op-mode" $TargetDir

# Verify installation
Write-Host "[3/3] Verifying installation..." -ForegroundColor Yellow
if (Test-Path "$TargetDir\SKILL.md") {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✓ OP Mode installed successfully!                           ║" -ForegroundColor Green
    Write-Host "╠══════════════════════════════════════════════════════════════╣" -ForegroundColor Green
    Write-Host "║  Location: ~/.claude/commands/op-mode/                       ║" -ForegroundColor Green
    Write-Host "║                                                              ║" -ForegroundColor Green
    Write-Host "║  Usage:                                                      ║" -ForegroundColor Green
    Write-Host "║    /op-mode <task description>                               ║" -ForegroundColor Green
    Write-Host "║                                                              ║" -ForegroundColor Green
    Write-Host "║  Example:                                                    ║" -ForegroundColor Green
    Write-Host "║    /op-mode Add user authentication with OAuth               ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
} else {
    Write-Host "  ❌ Installation failed. SKILL.md not found." -ForegroundColor Red
    exit 1
}

# Optional: Create .uop directory for memory
Write-Host ""
$createUop = Read-Host "Create .uop/ memory directory in current project? (y/N)"
if ($createUop -eq "y" -or $createUop -eq "Y") {
    New-Item -ItemType Directory -Force -Path ".uop\sessions" | Out-Null
    New-Item -ItemType Directory -Force -Path ".uop\history\decisions" | Out-Null
    New-Item -ItemType Directory -Force -Path ".uop\history\issues" | Out-Null
    New-Item -ItemType Directory -Force -Path ".uop\history\patterns" | Out-Null
    New-Item -ItemType Directory -Force -Path ".uop\summaries" | Out-Null
    "# OP Mode Index" | Out-File -FilePath ".uop\INDEX.md" -Encoding utf8
    Write-Host "  ✓ Created .uop/ directory structure" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done! Start using OP Mode with: /op-mode <your task>" -ForegroundColor Cyan
