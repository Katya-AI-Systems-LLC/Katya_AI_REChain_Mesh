# Pre-commit hook for Windows (PowerShell)
# Install with: Copy-Item scripts\pre-commit.ps1 .git\hooks\pre-commit

Write-Host "🔍 Running pre-commit checks..." -ForegroundColor Cyan

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

# Run Flutter format
Write-Host "📝 Formatting code..." -ForegroundColor Blue
try {
    $formatResult = dart format --set-exit-if-changed . 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Code formatting failed" -ForegroundColor Red
        Write-Host "💡 Run 'dart format .' to fix formatting issues" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "❌ Code formatting failed: $_" -ForegroundColor Red
    exit 1
}

# Check for uncommitted changes from formatting
$hasChanges = $false
try {
    $changes = git diff --quiet 2>$null
    $hasChanges = $LASTEXITCODE -ne 0
} catch {
    $hasChanges = $false
}

if ($hasChanges) {
    Write-Host "📝 Code formatted. Adding changes..." -ForegroundColor Blue
    git add . 2>$null
}

# Run analyzer
Write-Host "🔍 Running analyzer..." -ForegroundColor Blue
try {
    $analyzeResult = flutter analyze 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Code analysis failed" -ForegroundColor Red
        Write-Host "💡 Fix the issues above before committing" -ForegroundColor Yellow
        Write-Host $analyzeResult -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Code analysis failed: $_" -ForegroundColor Red
    exit 1
}

# Run tests
Write-Host "🧪 Running tests..." -ForegroundColor Blue
try {
    $testResult = flutter test 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Tests failed" -ForegroundColor Red
        Write-Host "💡 Fix failing tests before committing" -ForegroundColor Yellow
        Write-Host $testResult -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Tests failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host "✅ All checks passed! Ready to commit." -ForegroundColor Green
exit 0
