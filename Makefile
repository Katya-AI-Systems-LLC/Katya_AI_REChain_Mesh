.PHONY: help setup clean analyze test build install format lint deps update-deps doctor

# Default target
help:
	@echo "Katya AI REChain Mesh - Development Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  setup       - Initial project setup"
	@echo "  clean       - Clean build artifacts"
	@echo "  analyze     - Run Dart analyzer"
	@echo "  test        - Run tests with coverage"
	@echo "  build       - Build for all platforms"
	@echo "  install     - Install on connected devices"
	@echo "  format      - Format code"
	@echo "  lint        - Run linter"
	@echo "  deps        - Get dependencies"
	@echo "  update-deps - Update dependencies"
	@echo "  doctor      - Run Flutter doctor"
	@echo "  serve       - Serve web app locally"
	@echo "  docker      - Build Docker images"
	@echo "  deploy      - Deploy to production"

# Setup project
setup:
	@echo "Setting up project..."
	flutter pub get
	flutter config --enable-web
	flutter config --enable-linux-desktop
	flutter config --enable-windows-desktop
	flutter config --enable-macos-desktop
	dart run build_runner build --delete-conflicting-outputs
	@echo "Setup complete!"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	flutter clean
	flutter pub cache repair
	rm -rf build/
	rm -rf .dart_tool/
	rm -rf coverage/
	find . -name "*.log" -delete
	@echo "Clean complete!"

# Analyze code
analyze:
	@echo "Running analyzer..."
	flutter analyze

# Run tests
test:
	@echo "Running tests..."
	flutter test --coverage

# Run tests with specific tags
test-unit:
	flutter test --tags=unit

test-integration:
	flutter test --tags=integration

test-widget:
	flutter test --tags=widget

# Build for all platforms
build: build-android build-ios build-web build-linux build-windows build-macos

build-android:
	@echo "Building Android..."
	flutter build apk --release
	flutter build appbundle --release

build-ios:
	@echo "Building iOS..."
	flutter build ios --release --no-codesign

build-web:
	@echo "Building Web..."
	flutter build web --release

build-linux:
	@echo "Building Linux..."
	flutter config --enable-linux-desktop
	sudo apt-get update
	sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
	flutter build linux --release

build-windows:
	@echo "Building Windows..."
	flutter config --enable-windows-desktop
	flutter build windows --release

build-macos:
	@echo "Building macOS..."
	flutter config --enable-macos-desktop
	flutter build macos --release

# Install on connected devices
install: install-android install-ios install-web

install-android:
	@echo "Installing on Android device..."
	flutter install

install-ios:
	@echo "Installing on iOS device..."
	flutter install

install-web:
	@echo "Serving web locally..."
	flutter run -d chrome

# Code formatting
format:
	@echo "Formatting code..."
	dart format .

# Linting
lint:
	@echo "Running linter..."
	flutter analyze
	dart analyze

# Dependencies
deps:
	@echo "Getting dependencies..."
	flutter pub get

update-deps:
	@echo "Updating dependencies..."
	flutter pub upgrade
	flutter pub outdated

# Flutter doctor
doctor:
	@echo "Running Flutter doctor..."
	flutter doctor

# Serve web locally
serve:
	@echo "Serving web application..."
	flutter run -d chrome

# Docker operations
docker-build:
	@echo "Building Docker images..."
	docker build -t katya-ai-rechain-mesh .
	docker build -t katya-ai-rechain-mesh-backend backend/

docker-up:
	@echo "Starting Docker containers..."
	docker-compose up -d

docker-down:
	@echo "Stopping Docker containers..."
	docker-compose down

# Deployment
deploy-web:
	@echo "Deploying web to Firebase..."
	firebase deploy

deploy-android:
	@echo "Deploying Android to Google Play..."
	fastlane android deploy

deploy-ios:
	@echo "Deploying iOS to App Store..."
	fastlane ios deploy

# Development helpers
logs:
	@echo "Showing Flutter logs..."
	flutter logs

devices:
	@echo "Listing connected devices..."
	flutter devices

emulators:
	@echo "Listing emulators..."
	flutter emulators

# CI/CD helpers
ci-test:
	flutter test --coverage --machine > coverage.json

ci-analyze:
	flutter analyze --format=json > analysis.json

# Security
security-scan:
	@echo "Running security scan..."
	flutter pub audit

# Performance
performance-test:
	@echo "Running performance tests..."
	flutter test --tags=performance

# Documentation
docs:
	@echo "Generating documentation..."
	dart doc .

# Release management
version-patch:
	@echo "Bumping patch version..."
	dart run version_bumper --patch

version-minor:
	@echo "Bumping minor version..."
	dart run version_bumper --minor

version-major:
	@echo "Bumping major version..."
	dart run version_bumper --major

# Backup and restore
backup:
	@echo "Creating backup..."
	tar czf backup_$(shell date +%Y%m%d_%H%M%S).tar.gz lib/ assets/ pubspec.yaml pubspec.lock

restore:
	@echo "Usage: make restore BACKUP_FILE=backup_YYYYMMDD_HHMMSS.tar.gz"
	tar xzf $(BACKUP_FILE)

# Environment specific
dev:
	@echo "Setting up development environment..."
	cp config/env.dev .env

staging:
	@echo "Setting up staging environment..."
	cp config/env.staging .env

prod:
	@echo "Setting up production environment..."
	cp config/env.prod .env
