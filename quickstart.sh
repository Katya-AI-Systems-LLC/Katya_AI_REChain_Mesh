#!/bin/bash

# Katya AI REChain Mesh - Quick Start Script
# Gets you up and running in minutes

set -e  # Exit on any error

echo "🚀 Katya AI REChain Mesh - Quick Start"
echo "======================================"
echo ""

# Check requirements
echo "🔍 Checking requirements..."

if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found"
    echo "💡 Install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

if ! command -v dart &> /dev/null; then
    echo "❌ Dart not found"
    echo "💡 Dart is included with Flutter"
    exit 1
fi

echo "✅ Flutter $(flutter --version | head -1 | cut -d' ' -f2) found"

# Enable platforms
echo ""
echo "🔧 Configuring platforms..."
flutter config --enable-web
flutter config --enable-linux-desktop
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
flutter pub get

# Setup complete
echo ""
echo "🎉 Setup complete!"
echo ""
echo "📱 Your project is ready!"
echo ""
echo "🚀 Quick commands:"
echo "   flutter run              # Run on connected device"
echo "   flutter run -d web       # Run web version"
echo "   flutter test             # Run all tests"
echo "   flutter analyze          # Code analysis"
echo "   make help               # Show all available commands"
echo ""
echo "📚 Learn more:"
echo "   README.md               # Project documentation"
echo "   CONTRIBUTING.md         # How to contribute"
echo "   DEVELOPER_GUIDE.md      # Development guide"
echo ""
echo "💡 Pro tips:"
echo "   - Use 'flutter doctor' to verify your setup"
echo "   - Run 'make setup' for full development environment"
echo "   - Check out the 4 main modules: Blockchain, Gaming, IoT, Social"
echo ""
echo "Happy coding! 🎉"
