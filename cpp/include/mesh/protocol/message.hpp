#ifndef MESH_PROTOCOL_MESSAGE_HPP
#define MESH_PROTOCOL_MESSAGE_HPP

#include <string>
#include <vector>
#include <chrono>
#include <cstdint>

namespace mesh::protocol {

enum class MessagePriority {
    Low,
    Normal,
    High
};

struct Message {
    std::string id;
    std::string from_id;
    std::string to_id;
    std::string content;
    std::chrono::system_clock::time_point timestamp;
    int32_t ttl = 10;
    std::vector<std::string> path;
    MessagePriority priority = MessagePriority::Normal;
    std::string type;
    
    Message() = default;
    Message(const std::string& to, const std::string& content, MessagePriority prio = MessagePriority::Normal);
    
    bool isExpired() const;
    void decrementTTL();
};

} // namespace mesh::protocol

#endif // MESH_PROTOCOL_MESSAGE_HPP

