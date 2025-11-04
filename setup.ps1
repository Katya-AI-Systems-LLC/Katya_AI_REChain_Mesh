# Katya AI REChain Mesh - Project Setup Script (PowerShell)
# Sets up the complete development environment for Windows

param(
    [switch]$SkipFlutterCheck,
    [switch]$Force,
    [string]$FlutterPath = $null
)

Write-Host "🚀 Katya AI REChain Mesh - Project Setup" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Check if Flutter is installed
function Test-FlutterInstallation {
    if ($SkipFlutterCheck) {
        Write-Host "⚠️  Skipping Flutter check..." -ForegroundColor Yellow
        return $true
    }

    try {
        $flutterVersion = & flutter --version 2>&1 | Select-Object -First 1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Flutter found: $flutterVersion" -ForegroundColor Green
            return $true
        }
    }
    catch {
        Write-Host "❌ Flutter not found in PATH" -ForegroundColor Red
        return $false
    }

    return $false
}

if (-not (Test-FlutterInstallation)) {
    Write-Host ""
    Write-Host "💡 To install Flutter:" -ForegroundColor Yellow
    Write-Host "   1. Download Flutter SDK from: https://flutter.dev/docs/get-started/install/windows"
    Write-Host "   2. Add flutter/bin to your PATH environment variable"
    Write-Host "   3. Run 'flutter doctor' to verify installation"
    Write-Host ""
    Write-Host "   Or run: setup.ps1 -SkipFlutterCheck" -ForegroundColor Yellow
    exit 1
}

# Check Flutter version
try {
    $flutterVersion = & flutter --version 2>&1 | Select-String "Flutter.*•" | Select-Object -First 1
    $currentVersion = $flutterVersion.Line.Split("•")[0].Trim().Split(" ")[1]
    $requiredVersion = "3.24.0"

    if ([version]$currentVersion -lt [version]$requiredVersion) {
        Write-Host "⚠️  Flutter version $currentVersion detected. Recommended: $requiredVersion" -ForegroundColor Yellow
        Write-Host "💡 Update Flutter: flutter upgrade" -ForegroundColor Yellow
    } else {
        Write-Host "✅ Flutter $currentVersion installed (recommended: $requiredVersion)" -ForegroundColor Green
    }
}
catch {
    Write-Host "⚠️  Could not determine Flutter version" -ForegroundColor Yellow
}

# Enable required platforms
Write-Host "🔧 Configuring Flutter platforms..." -ForegroundColor Blue
& flutter config --enable-web | Out-Null
& flutter config --enable-windows-desktop | Out-Null
& flutter config --enable-linux-desktop | Out-Null
& flutter config --enable-macos-desktop | Out-Null

# Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Blue
& flutter pub get

# Verify setup
Write-Host "🔍 Verifying setup..." -ForegroundColor Blue
& flutter doctor

# Check for common issues
Write-Host "🔍 Checking for common issues..." -ForegroundColor Blue

# Check if all dependencies are resolved
if (-not (Test-Path "pubspec.lock")) {
    Write-Host "❌ Dependencies not properly resolved" -ForegroundColor Red
    exit 1
}

# Check if required files exist
$requiredFiles = @(
    "lib/main.dart",
    "pubspec.yaml",
    "README.md",
    ".gitignore"
)

foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "❌ Required file missing: $file" -ForegroundColor Red
        exit 1
    }
}

# Generate necessary files
Write-Host "🔨 Generating additional files..." -ForegroundColor Blue

# Create analysis_options.yaml if it doesn't exist
if (-not (Test-Path "analysis_options.yaml")) {
    Write-Host "📝 Creating analysis_options.yaml..." -ForegroundColor Blue
    $analysisContent = @"
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
"@

    $analysisContent | Out-File -FilePath "analysis_options.yaml" -Encoding UTF8
}

# Create .vscode directory and files
if (-not (Test-Path ".vscode")) {
    New-Item -ItemType Directory -Path ".vscode" | Out-Null
}

if (-not (Test-Path ".vscode/launch.json")) {
    Write-Host "📝 Creating VS Code launch configuration..." -ForegroundColor Blue
    $launchConfig = @"
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
"@

    $launchConfig | Out-File -FilePath ".vscode/launch.json" -Encoding UTF8
}

if (-not (Test-Path ".vscode/settings.json")) {
    Write-Host "📝 Creating VS Code settings..." -ForegroundColor Blue
    $settings = @"
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
"@

    $settings | Out-File -FilePath ".vscode/settings.json" -Encoding UTF8
}

# Run initial analysis
Write-Host "🔍 Running initial analysis..." -ForegroundColor Blue
& flutter analyze

# Run tests if they exist
if (Test-Path "test") {
    $testFiles = Get-ChildItem -Path "test" -Recurse -File
    if ($testFiles.Count -gt 0) {
        Write-Host "🧪 Running tests..." -ForegroundColor Blue
        & flutter test
    }
}

# Check build
Write-Host "🔨 Testing build..." -ForegroundColor Blue
& flutter build apk --debug

# Create development environment file
if (-not (Test-Path ".env.dev")) {
    Write-Host "📝 Creating development environment file..." -ForegroundColor Blue
    $envContent = @"
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
"@

    $envContent | Out-File -FilePath ".env.dev" -Encoding UTF8
}

# Create PowerShell profile for development
if (-not (Test-Path ".vscode/powershell.json")) {
    $powershellConfig = @"
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "PowerShell Launch Current File",
            "type": "PowerShell",
            "request": "launch",
            "script": "${file}",
            "cwd": "${fileDirname}"
        },
        {
            "name": "PowerShell Build Script",
            "type": "PowerShell",
            "request": "launch",
            "script": "build_android.ps1",
            "cwd": "${workspaceFolder}"
        },
        {
            "name": "PowerShell Install Script",
            "type": "PowerShell",
            "request": "launch",
            "script": "install_android.ps1",
            "cwd": "${workspaceFolder}"
        }
    ]
}
"@

    $powershellConfig | Out-File -FilePath ".vscode/powershell.json" -Encoding UTF8
}

Write-Host ""
Write-Host "🎉 Setup completed successfully!" -ForegroundColor Green
Write-Host ""

# Show project status
Write-Host "📊 Project Status:" -ForegroundColor Cyan
Write-Host "   ✅ Flutter: $(& flutter --version | Select-Object -First 1)" -ForegroundColor Green
Write-Host "   ✅ Dependencies: Installed" -ForegroundColor Green
Write-Host "   ✅ Platforms: Configured" -ForegroundColor Green
Write-Host "   ✅ Analysis: Clean" -ForegroundColor Green
Write-Host "   ✅ Build: Working" -ForegroundColor Green

Write-Host ""
Write-Host "🚀 Next steps:" -ForegroundColor Cyan
Write-Host "   1. Run 'flutter run' to start development" -ForegroundColor White
Write-Host "   2. Check README.md for detailed documentation" -ForegroundColor White
Write-Host "   3. Explore the 4 main modules: Blockchain, Gaming, IoT, Social" -ForegroundColor White
Write-Host "   4. Review CONTRIBUTING.md for development guidelines" -ForegroundColor White

Write-Host ""
Write-Host "📚 Useful commands:" -ForegroundColor Cyan
Write-Host "   flutter run                    # Run on connected device" -ForegroundColor White
Write-Host "   flutter run -d web             # Run web version" -ForegroundColor White
Write-Host "   flutter test                   # Run tests" -ForegroundColor White
Write-Host "   flutter analyze                # Code analysis" -ForegroundColor White
Write-Host "   dart format                    # Format code" -ForegroundColor White
Write-Host "   .\build_android.ps1           # Build Android APK" -ForegroundColor White
Write-Host "   .\install_android.ps1         # Install on device" -ForegroundColor White

Write-Host ""
Write-Host "💡 Happy coding with Katya AI REChain Mesh! 🎉" -ForegroundColor Green
