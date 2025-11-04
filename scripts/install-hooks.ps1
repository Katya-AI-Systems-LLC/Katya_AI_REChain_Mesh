# Install Git Hooks for Katya AI REChain Mesh (PowerShell)

param(
    [switch]$Force
)

Write-Host "🔧 Installing Git Hooks..." -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan

# Check if we're in a git repository
try {
    $gitDir = git rev-parse --git-dir 2>$null
    if (-not $gitDir) {
        throw "Not in a git repository"
    }
} catch {
    Write-Host "❌ Not in a git repository" -ForegroundColor Red
    exit 1
}

# Create hooks directory if it doesn't exist
if (-not (Test-Path ".git\hooks")) {
    New-Item -ItemType Directory -Path ".git\hooks" | Out-Null
}

# Install pre-commit hook
Write-Host "📝 Installing pre-commit hook..." -ForegroundColor Blue
if (Test-Path "scripts\pre-commit.ps1") {
    Copy-Item "scripts\pre-commit.ps1" ".git\hooks\pre-commit" -Force:$Force
    Write-Host "✅ Pre-commit hook installed" -ForegroundColor Green
} else {
    Write-Host "❌ Pre-commit script not found" -ForegroundColor Red
    exit 1
}

# Install pre-push hook (optional)
if (Test-Path "scripts\pre-push.ps1") {
    Write-Host "📤 Installing pre-push hook..." -ForegroundColor Blue
    Copy-Item "scripts\pre-push.ps1" ".git\hooks\pre-push" -Force:$Force
    Write-Host "✅ Pre-push hook installed" -ForegroundColor Green
}

# Set git configuration
Write-Host "⚙️  Configuring Git..." -ForegroundColor Blue
try {
    git config core.hooksPath .git/hooks 2>$null
    Write-Host "✅ Git hooks configured" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to configure Git hooks: $_" -ForegroundColor Red
    exit 1
}

# Make scripts executable (for Unix-like environments)
if (Get-Command chmod -ErrorAction SilentlyContinue) {
    Get-ChildItem -Path "scripts" -Filter "*.sh" | ForEach-Object {
        chmod +x $_.FullName
    }
}

Write-Host ""
Write-Host "🎉 Git hooks installed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Installed hooks:" -ForegroundColor Cyan
Write-Host "   - pre-commit: Runs formatting, analysis, and tests before commits" -ForegroundColor White
Write-Host "   - pre-push: Additional checks before pushing (if configured)" -ForegroundColor White
Write-Host ""
Write-Host "💡 To enable:" -ForegroundColor Cyan
Write-Host "   git config core.hooksPath .git/hooks" -ForegroundColor White
Write-Host ""
Write-Host "🔄 To update hooks:" -ForegroundColor Cyan
Write-Host "   .\scripts\install-hooks.ps1" -ForegroundColor White
Write-Host ""
Write-Host "❌ To disable hooks:" -ForegroundColor Cyan
Write-Host "   git config core.hooksPath ''" -ForegroundColor White
