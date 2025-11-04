#!/bin/bash

# Install Git Hooks for Katya AI REChain Mesh

echo "🔧 Installing Git Hooks..."
echo "=========================="

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Not in a git repository"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Install pre-commit hook
echo "📝 Installing pre-commit hook..."
if [ -f "scripts/pre-commit" ]; then
    chmod +x scripts/pre-commit
    ln -sf ../../scripts/pre-commit .git/hooks/pre-commit
    echo "✅ Pre-commit hook installed"
else
    echo "❌ Pre-commit script not found"
    exit 1
fi

# Install pre-push hook (optional)
if [ -f "scripts/pre-push" ]; then
    echo "📤 Installing pre-push hook..."
    chmod +x scripts/pre-push
    ln -sf ../../scripts/pre-push .git/hooks/pre-push
    echo "✅ Pre-push hook installed"
fi

# Set git configuration
echo "⚙️  Configuring Git..."
git config core.hooksPath .git/hooks

# Make scripts executable
find scripts/ -type f -name "*.sh" -exec chmod +x {} \;

echo ""
echo "🎉 Git hooks installed successfully!"
echo ""
echo "📋 Installed hooks:"
echo "   - pre-commit: Runs formatting, analysis, and tests before commits"
echo "   - pre-push: Additional checks before pushing (if configured)"
echo ""
echo "💡 To enable:"
echo "   git config core.hooksPath .git/hooks"
echo ""
echo "🔄 To update hooks:"
echo "   bash scripts/install-hooks.sh"
echo ""
echo "❌ To disable hooks:"
echo "   git config core.hooksPath ''"
