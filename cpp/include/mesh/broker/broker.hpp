#ifndef MESH_BROKER_BROKER_HPP
#define MESH_BROKER_BROKER_HPP

#include <string>
#include <vector>
#include <memory>
#include <thread>
#include <atomic>
#include <mutex>
#include <map>

#include "mesh/protocol/message.hpp"
#include "mesh/broker/peer.hpp"

namespace mesh::broker {

class Broker {
public:
    enum class AdapterType {
        Emulated,
        WiFiEmulated,
        AndroidBLE,
        iOSBLE
    };

    struct Stats {
        size_t total_peers = 0;
        size_t connected_peers = 0;
        size_t messages_in_queue = 0;
        size_t total_sent = 0;
        size_t total_delivered = 0;
        size_t total_failed = 0;
        double success_rate = 0.0;
    };

    Broker(const std::string& adapter_name);
    ~Broker();

    bool start();
    void stop();

    std::vector<std::shared_ptr<Peer>> getPeers() const;
    Stats getStats() const;

    bool sendMessage(const protocol::Message& message);
    void clearState();

private:
    void discoverPeers();
    void processMessageQueue();
    void updateStats();

    AdapterType adapter_type_;
    std::atomic<bool> is_running_{false};
    
    mutable std::mutex peers_mutex_;
    std::map<std::string, std::shared_ptr<Peer>> peers_;

    mutable std::mutex queue_mutex_;
    std::vector<protocol::Message> message_queue_;

    Stats stats_;
    mutable std::mutex stats_mutex_;

    std::thread discovery_thread_;
    std::thread queue_thread_;
    std::thread stats_thread_;
};

} // namespace mesh::broker

#endif // MESH_BROKER_BROKER_HPP

