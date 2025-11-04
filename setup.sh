#!/bin/bash

# Katya AI REChain Mesh - Project Setup Script
# Sets up the complete development environment

set -e  # Exit on any error

echo "🚀 Katya AI REChain Mesh - Project Setup"
echo "=========================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed"
    echo "💡 Install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if Dart is installed
if ! command -v dart &> /dev/null; then
    echo "❌ Dart is not installed"
    echo "💡 Dart is included with Flutter"
    exit 1
fi

# Check Flutter version
FLUTTER_VERSION=$(flutter --version | grep -o "Flutter.*•" | cut -d' ' -f2)
REQUIRED_VERSION="3.24.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$FLUTTER_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "⚠️  Flutter version $FLUTTER_VERSION detected. Recommended: $REQUIRED_VERSION"
    echo "💡 Update Flutter: flutter upgrade"
fi

echo "✅ Flutter $FLUTTER_VERSION installed"

# Enable required platforms
echo "🔧 Configuring Flutter platforms..."
flutter config --enable-web
flutter config --enable-linux-desktop
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Verify setup
echo "🔍 Verifying setup..."
flutter doctor

# Check for common issues
echo "🔍 Checking for common issues..."

# Check if all dependencies are resolved
if [ ! -f "pubspec.lock" ]; then
    echo "❌ Dependencies not properly resolved"
    exit 1
fi

# Check if required files exist
REQUIRED_FILES=(
    "lib/main.dart"
    "pubspec.yaml"
    "README.md"
    ".gitignore"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Required file missing: $file"
        exit 1
    fi
done

# Generate necessary files if they don't exist
echo "🔨 Generating additional files..."

# Create analysis_options.yaml if it doesn't exist
if [ ! -f "analysis_options.yaml" ]; then
    echo "📝 Creating analysis_options.yaml..."
    cat > analysis_options.yaml << 'EOF'
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - avoid_print
    - prefer_const_constructors
    - prefer_final_fields
    - use_key_in_widget_constructors
    - prefer_collection_literals
    - avoid_unnecessary_containers
    - sized_box_for_whitespace
    - avoid_returning_null_for_void
    - prefer_is_not_empty
    - prefer_is_empty
    - unnecessary_null_in_if_null_operators
    - prefer_conditional_assignment
    - prefer_if_null_operators
    - prefer_spread_collections
    - unnecessary_this
    - unnecessary_new
    - unnecessary_const
    - avoid_init_to_null
    - prefer_const_literals_to_create_immutables
    - prefer_const_constructors_in_immutables
    - prefer_asserts_in_initializer_lists
    - prefer_foreach
    - prefer_function_declarations_over_variables
    - use_function_type_syntax_for_parameters
    - avoid_renaming_method_parameters
    - prefer_generic_function_type_aliases
    - avoid_bool_literals_in_conditional_expressions
    - prefer_adjacent_string_concatenation
    - prefer_interpolation_to_compose_strings
    - unnecessary_brace_in_string_interps
    - prefer_single_quotes
    - unnecessary_string_escapes
    - avoid_escaping_inner_quotes
    - prefer_const_declarations
    - avoid_unused_constructor_parameters
    - prefer_typing_uninitialized_variables
    - prefer_initializing_formals
    - avoid_setters_without_getters
    - avoid_getters_without_setters
    - prefer_final_in_for_each
    - join_return_with_assignment
    - prefer_for_elements_to_map_fromIterable
    - avoid_single_cascade_in_expression_statements
    - prefer_conditional_expressions
    - prefer_if_elements_to_conditional_expressions
    - prefer_contains
    - prefer_equal_for_default_values
    - avoid_catches_without_on_clauses
    - avoid_catching_errors
    - use_rethrow_when_possible
    - avoid_implementing_value_types
    - avoid_positional_boolean_parameters
    - avoid_classes_with_only_static_members
    - prefer_mixin
    - prefer_relative_imports
    - avoid_relative_lib_imports
    - avoid_returning_null_for_future
    - prefer_void_to_null
    - avoid_null_checks_in_equality_operators
    - avoid_double_and_int_checks
    - avoid_slow_async_io
    - avoid_types_as_parameter_names
    - avoid_web_libraries_in_flutter
    - implementation_imports
    - prefer_void_to_null
    - avoid_empty_else
    - unnecessary_statements
    - unrelated_type_equality_checks
    - valid_regexps
EOF
fi

# Create .vscode/launch.json for debugging
if [ ! -d ".vscode" ]; then
    mkdir -p .vscode
fi

if [ ! -f ".vscode/launch.json" ]; then
    echo "📝 Creating VS Code launch configuration..."
    cat > .vscode/launch.json << 'EOF'
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Flutter",
            "type": "dart",
            "request": "launch",
            "program": "lib/main.dart"
        },
        {
            "name": "Flutter (Profile Mode)",
            "type": "dart",
            "request": "launch",
            "program": "lib/main.dart",
            "flutterMode": "profile"
        },
        {
            "name": "Flutter (Release Mode)",
            "type": "dart",
            "request": "launch",
            "program": "lib/main.dart",
            "flutterMode": "release"
        }
    ]
}
EOF
fi

# Create .vscode/settings.json
if [ ! -f ".vscode/settings.json" ]; then
    echo "📝 Creating VS Code settings..."
    cat > .vscode/settings.json << 'EOF'
{
    "dart.flutterSdkPath": ".fvm/versions/stable",
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.codeActionsOnSave": {
        "source.fixAll": true
    },
    "dart.lineLength": 100,
    "files.exclude": {
        "**/.git": true,
        "**/.DS_Store": true,
        "**/node_modules": true,
        "**/.fvm": true,
        "**/build": true,
        "**/.dart_tool": true,
        "**/.flutter-plugins": true,
        "**/.pub-cache": true
    }
}
EOF
fi

# Run initial analysis
echo "🔍 Running initial analysis..."
flutter analyze

# Run tests if they exist
if [ -d "test" ] && [ "$(ls -A test)" ]; then
    echo "🧪 Running tests..."
    flutter test
fi

# Check build
echo "🔨 Testing build..."
flutter build apk --debug

# Create development environment file
if [ ! -f ".env.dev" ]; then
    echo "📝 Creating development environment file..."
    cat > .env.dev << 'EOF'
# Development Environment Variables
DEBUG=true
LOG_LEVEL=verbose
API_URL=http://localhost:8080

# Blockchain (Testnet)
BLOCKCHAIN_API_KEY=dev_api_key
BLOCKCHAIN_NETWORK=testnet

# AI Services
AI_API_KEY=dev_ai_key

# Mesh Network
MESH_NETWORK_ID=dev_network
MESH_API_KEY=dev_mesh_key

# Database (Development)
DATABASE_URL=sqlite:///dev.db

# Security (Development)
JWT_SECRET=dev_jwt_secret_key_not_for_production
EOF
fi

echo ""
echo "🎉 Setup completed successfully!"
echo ""
echo "📊 Project Status:"
echo "   ✅ Flutter: $(flutter --version | head -1)"
echo "   ✅ Dependencies: Installed"
echo "   ✅ Platforms: Configured"
echo "   ✅ Analysis: Clean"
echo "   ✅ Build: Working"
echo ""
echo "🚀 Next steps:"
echo "   1. Run 'flutter run' to start development"
echo "   2. Check README.md for detailed documentation"
echo "   3. Explore the 4 main modules: Blockchain, Gaming, IoT, Social"
echo "   4. Review CONTRIBUTING.md for development guidelines"
echo ""
echo "📚 Useful commands:"
echo "   flutter run              # Run on connected device"
echo "   flutter run -d web       # Run web version"
echo "   flutter test             # Run tests"
echo "   flutter analyze          # Code analysis"
echo "   dart format              # Format code"
echo "   make help               # Show Makefile commands"
echo ""
echo "💡 Happy coding with Katya AI REChain Mesh! 🎉"
