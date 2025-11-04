#!/bin/bash

# Katya AI REChain Mesh - Demo Launcher
# Quick setup for hackathon presentations

set -e  # Exit on any error

echo "🚀 Katya AI REChain Mesh - Demo Launcher"
echo "=========================================="

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found"
    echo "💡 Install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "⚠️  Docker not found - skipping container demo"
    SKIP_DOCKER=true
else
    echo "✅ Docker found"
    SKIP_DOCKER=false
fi

echo "✅ Flutter $(flutter --version | head -1 | cut -d' ' -f2) ready"

# Setup development environment
echo ""
echo "🔧 Setting up development environment..."
flutter pub get
flutter config --enable-web
flutter config --enable-linux-desktop

# Install quality gates
echo ""
echo "⚡ Installing quality gates..."
if [ -f "scripts/install-hooks.sh" ]; then
    bash scripts/install-hooks.sh
fi

# Run quick tests
echo ""
echo "🧪 Running quick tests..."
flutter analyze
flutter test --tags=smoke

# Build web version for demo
echo ""
echo "📦 Building web version for demo..."
flutter build web --release

# Setup demo environment
echo ""
echo "🎪 Setting up demo environment..."

# Create demo script
cat > demo.sh << 'EOF'
#!/bin/bash
echo "🎬 Katya AI REChain Mesh - Demo Mode"
echo "===================================="
echo ""
echo "📱 Demo Features Available:"
echo "   1. 🔗 Blockchain Module - Multi-wallet management"
echo "   2. 🎮 Gaming Module - Achievements and rewards"
echo "   3. 📡 IoT Module - Device management"
echo "   4. 👥 Social Module - Community features"
echo ""
echo "🚀 To start demo:"
echo "   flutter run -d chrome    # Web demo"
echo "   flutter run              # Mobile demo"
echo "   docker-compose up -d     # Full stack demo"
echo ""
echo "📊 Monitoring dashboards:"
echo "   http://localhost:9090    # Prometheus"
echo "   http://localhost:3000    # Grafana (admin/admin)"
echo "   http://localhost:5601    # Kibana"
echo ""
echo "🎯 Demo ready! Happy presenting! 🎉"
EOF

chmod +x demo.sh

# Start Docker environment if available
if [ "$SKIP_DOCKER" = false ]; then
    echo ""
    echo "🐳 Starting Docker environment..."
    docker-compose up -d

    echo ""
    echo "⏳ Waiting for services to start (2 minutes)..."
    sleep 120

    echo ""
    echo "🔍 Checking service health..."
    curl -f http://localhost:8080/health 2>/dev/null && echo "✅ Frontend ready" || echo "⚠️  Frontend not ready"
    curl -f http://localhost:8081/health 2>/dev/null && echo "✅ Backend ready" || echo "⚠️  Backend not ready"
    curl -f http://localhost:9090/-/healthy 2>/dev/null && echo "✅ Prometheus ready" || echo "⚠️  Prometheus not ready"
    curl -f http://localhost:3000/api/health 2>/dev/null && echo "✅ Grafana ready" || echo "⚠️  Grafana not ready"
fi

# Create demo shortcuts
echo ""
echo "🎯 Creating demo shortcuts..."

# Web demo shortcut
cat > web-demo.sh << 'EOF'
#!/bin/bash
echo "🌐 Starting web demo..."
flutter run -d chrome --web-port 3000
EOF
chmod +x web-demo.sh

# Mobile demo shortcut
cat > mobile-demo.sh << 'EOF'
#!/bin/bash
echo "📱 Starting mobile demo..."
echo "Choose device:"
flutter devices
echo ""
echo "Run: flutter run -d <device_id>"
EOF
chmod +x mobile-demo.sh

# Infrastructure demo shortcut
cat > infra-demo.sh << 'EOF'
#!/bin/bash
echo "🏗️  Infrastructure Demo"
echo "======================"
echo ""
echo "🐳 Docker services:"
docker-compose ps
echo ""
echo "📊 Monitoring access:"
echo "   Prometheus: http://localhost:9090"
echo "   Grafana: http://localhost:3000 (admin/admin)"
echo "   Kibana: http://localhost:5601"
echo ""
echo "🔍 Kubernetes (if deployed):"
echo "   kubectl get pods -n katya-rechain-mesh"
echo "   kubectl get services -n katya-rechain-mesh"
EOF
chmod +x infra-demo.sh

# Performance demo shortcut
cat > performance-demo.sh << 'EOF'
#!/bin/bash
echo "⚡ Performance Demo"
echo "=================="
echo ""
echo "🧪 Running performance tests..."
flutter test --tags=performance
echo ""
echo "📊 Code metrics:"
flutter pub global run dart-code-metrics analyze lib --reporter=console
echo ""
echo "🔍 Build analysis:"
flutter build apk --analyze-size
echo ""
echo "🚀 Performance demo complete!"
EOF
chmod +x performance-demo.sh

echo ""
echo "🎉 Demo environment ready!"
echo ""
echo "📋 Demo Options:"
echo "   1. 🌐 Web Demo: bash web-demo.sh"
echo "   2. 📱 Mobile Demo: bash mobile-demo.sh"
echo "   3. 🏗️  Infrastructure: bash infra-demo.sh"
echo "   4. ⚡ Performance: bash performance-demo.sh"
echo "   5. 🎬 Full Demo: bash demo.sh"
echo ""
echo "📚 Documentation:"
echo "   README.md - Project overview"
echo "   HACKATHON_DEMO.md - Presentation script"
echo "   PROJECT_HIGHLIGHTS.md - Competitive advantages"
echo "   READY_CHECKLIST.md - Pre-deployment checklist"
echo ""
echo "🎯 Quick commands:"
echo "   flutter run -d chrome    # Web demo"
echo "   flutter run              # Mobile demo"
echo "   docker-compose logs -f   # View logs"
echo "   kubectl get pods         # Kubernetes status"
echo ""
echo "🏆 Ready for hackathon presentation!"
echo "💡 Show the 4 main modules: Blockchain, Gaming, IoT, Social"
echo "📊 Demonstrate enterprise infrastructure and monitoring"
echo "🔒 Highlight security and compliance features"
echo ""
echo "🎊 Happy presenting! 🚀✨"
