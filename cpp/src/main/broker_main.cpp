#include <iostream>
#include <csignal>
#include <memory>
#include "mesh/broker/broker.hpp"

std::unique_ptr<mesh::broker::Broker> g_broker;

void signalHandler(int signal) {
    std::cout << "\nReceived signal " << signal << ", shutting down...\n";
    if (g_broker) {
        g_broker->stop();
    }
    std::exit(0);
}

int main(int argc, char* argv[]) {
    std::string adapter = "emulated";
    int port = 8081;

    // Parse arguments (simplified)
    for (int i = 1; i < argc; ++i) {
        std::string arg = argv[i];
        if (arg == "--adapter" && i + 1 < argc) {
            adapter = argv[++i];
        } else if (arg == "--port" && i + 1 < argc) {
            port = std::stoi(argv[++i]);
        }
    }

    std::cout << "Katya Mesh C++ Broker\n";
    std::cout << "Adapter: " << adapter << "\n";
    std::cout << "Port: " << port << "\n";

    // Setup signal handlers
    std::signal(SIGINT, signalHandler);
    std::signal(SIGTERM, signalHandler);

    // Create and start broker
    g_broker = std::make_unique<mesh::broker::Broker>(adapter);
    if (!g_broker->start()) {
        std::cerr << "Failed to start broker\n";
        return 1;
    }

    std::cout << "Broker started successfully\n";
    std::cout << "Press Ctrl+C to stop\n";

    // Keep running
    while (true) {
        std::this_thread::sleep_for(std::chrono::seconds(1));
        
        // Print stats periodically
        auto stats = g_broker->getStats();
        if (stats.total_peers > 0 || stats.messages_in_queue > 0) {
            std::cout << "Stats - Peers: " << stats.total_peers 
                      << ", Queue: " << stats.messages_in_queue
                      << ", Success: " << stats.success_rate << "%\n";
        }
    }

    return 0;
}

