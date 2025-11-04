#include "mesh/core.h"
#include <cstring>
#include <memory>
#include <vector>
#include <unordered_map>
#include <mutex>
#include <atomic>
#include <iostream>

// Internal structures
struct mesh_context {
    mesh_node_id_t node_id;
    std::unordered_map<std::string, std::unique_ptr<mesh_peer_t>> peers;
    std::mutex peers_mutex;
    std::atomic<bool> running{false};

    mesh_message_callback_t message_callback{nullptr};
    void* message_user_data{nullptr};

    mesh_peer_callback_t peer_callback{nullptr};
    void* peer_user_data{nullptr};
};

struct mesh_peer {
    mesh_node_id_t peer_id;
    std::string address;
    std::atomic<bool> connected{false};
    std::atomic<uint32_t> connection_count{0};
};

struct mesh_message {
    mesh_message_type_t type;
    mesh_node_id_t from;
    mesh_node_id_t to;
    std::vector<uint8_t> payload;
    uint64_t timestamp;
    uint32_t ttl{64};
    uint32_t hops{0};
};

// C API implementation
extern "C" {

mesh_context_t* mesh_create_context(const mesh_node_id_t node_id) {
    try {
        auto ctx = new mesh_context_t();
        std::memcpy(ctx->node_id, node_id, sizeof(mesh_node_id_t));
        return ctx;
    } catch (const std::exception& e) {
        std::cerr << "Failed to create mesh context: " << e.what() << std::endl;
        return nullptr;
    }
}

void mesh_destroy_context(mesh_context_t* ctx) {
    if (ctx) {
        delete ctx;
    }
}

mesh_error_t mesh_start(mesh_context_t* ctx) {
    if (!ctx) {
        return MESH_ERROR_INVALID_PARAM;
    }

    ctx->running = true;
    // TODO: Start network threads, discovery, etc.
    return MESH_SUCCESS;
}

mesh_error_t mesh_stop(mesh_context_t* ctx) {
    if (!ctx) {
        return MESH_ERROR_INVALID_PARAM;
    }

    ctx->running = false;
    // TODO: Stop network threads, cleanup connections
    return MESH_SUCCESS;
}

mesh_peer_t* mesh_create_peer(const mesh_node_id_t peer_id, const char* address) {
    if (!address) {
        return nullptr;
    }

    try {
        auto peer = new mesh_peer_t();
        std::memcpy(peer->peer_id, peer_id, sizeof(mesh_node_id_t));
        peer->address = address;
        return peer;
    } catch (const std::exception& e) {
        std::cerr << "Failed to create peer: " << e.what() << std::endl;
        return nullptr;
    }
}

void mesh_destroy_peer(mesh_peer_t* peer) {
    if (peer) {
        delete peer;
    }
}

mesh_error_t mesh_add_peer(mesh_context_t* ctx, mesh_peer_t* peer) {
    if (!ctx || !peer) {
        return MESH_ERROR_INVALID_PARAM;
    }

    std::string peer_id_str(reinterpret_cast<const char*>(peer->peer_id),
                           sizeof(mesh_node_id_t));

    std::lock_guard<std::mutex> lock(ctx->peers_mutex);
    if (ctx->peers.find(peer_id_str) != ctx->peers.end()) {
        return MESH_ERROR_INVALID_PARAM; // Peer already exists
    }

    ctx->peers[peer_id_str] = std::unique_ptr<mesh_peer_t>(peer);

    // Notify peer callback
    if (ctx->peer_callback) {
        ctx->peer_callback(ctx, peer, true, ctx->peer_user_data);
    }

    return MESH_SUCCESS;
}

mesh_error_t mesh_remove_peer(mesh_context_t* ctx, const mesh_node_id_t peer_id) {
    if (!ctx) {
        return MESH_ERROR_INVALID_PARAM;
    }

    std::string peer_id_str(reinterpret_cast<const char*>(peer_id),
                           sizeof(mesh_node_id_t));

    std::lock_guard<std::mutex> lock(ctx->peers_mutex);
    auto it = ctx->peers.find(peer_id_str);
    if (it == ctx->peers.end()) {
        return MESH_ERROR_PEER_NOT_FOUND;
    }

    auto peer = it->second.get();

    // Notify peer callback
    if (ctx->peer_callback) {
        ctx->peer_callback(ctx, peer, false, ctx->peer_user_data);
    }

    ctx->peers.erase(it);
    return MESH_SUCCESS;
}

size_t mesh_get_peer_count(mesh_context_t* ctx) {
    if (!ctx) {
        return 0;
    }

    std::lock_guard<std::mutex> lock(ctx->peers_mutex);
    return ctx->peers.size();
}

mesh_message_t* mesh_create_message(mesh_message_type_t type,
                                   const mesh_node_id_t from,
                                   const mesh_node_id_t to,
                                   const uint8_t* payload,
                                   size_t payload_size) {
    try {
        auto msg = new mesh_message_t();
        msg->type = type;
        std::memcpy(msg->from, from, sizeof(mesh_node_id_t));
        std::memcpy(msg->to, to, sizeof(mesh_node_id_t));

        if (payload && payload_size > 0) {
            msg->payload.assign(payload, payload + payload_size);
        }

        msg->timestamp = static_cast<uint64_t>(std::time(nullptr));
        return msg;
    } catch (const std::exception& e) {
        std::cerr << "Failed to create message: " << e.what() << std::endl;
        return nullptr;
    }
}

void mesh_destroy_message(mesh_message_t* msg) {
    if (msg) {
        delete msg;
    }
}

mesh_error_t mesh_send_message(mesh_context_t* ctx, mesh_message_t* msg) {
    if (!ctx || !msg) {
        return MESH_ERROR_INVALID_PARAM;
    }

    if (!ctx->running) {
        return MESH_ERROR_NETWORK;
    }

    // TODO: Implement actual message sending
    // For now, just notify the message callback as if received
    if (ctx->message_callback) {
        ctx->message_callback(ctx, msg, ctx->message_user_data);
    }

    return MESH_SUCCESS;
}

mesh_error_t mesh_broadcast_message(mesh_context_t* ctx, mesh_message_t* msg) {
    if (!ctx || !msg) {
        return MESH_ERROR_INVALID_PARAM;
    }

    if (!ctx->running) {
        return MESH_ERROR_NETWORK;
    }

    // TODO: Implement actual broadcast
    // For now, notify callback for each peer
    std::lock_guard<std::mutex> lock(ctx->peers_mutex);
    for (const auto& peer_pair : ctx->peers) {
        if (ctx->message_callback) {
            ctx->message_callback(ctx, msg, ctx->message_user_data);
        }
    }

    return MESH_SUCCESS;
}

mesh_error_t mesh_set_message_callback(mesh_context_t* ctx,
                                      mesh_message_callback_t callback,
                                      void* user_data) {
    if (!ctx) {
        return MESH_ERROR_INVALID_PARAM;
    }

    ctx->message_callback = callback;
    ctx->message_user_data = user_data;
    return MESH_SUCCESS;
}

mesh_error_t mesh_set_peer_callback(mesh_context_t* ctx,
                                   mesh_peer_callback_t callback,
                                   void* user_data) {
    if (!ctx) {
        return MESH_ERROR_INVALID_PARAM;
    }

    ctx->peer_callback = callback;
    ctx->peer_user_data = user_data;
    return MESH_SUCCESS;
}

const char* mesh_error_string(mesh_error_t error) {
    switch (error) {
        case MESH_SUCCESS:
            return "Success";
        case MESH_ERROR_INVALID_PARAM:
            return "Invalid parameter";
        case MESH_ERROR_OUT_OF_MEMORY:
            return "Out of memory";
        case MESH_ERROR_NETWORK:
            return "Network error";
        case MESH_ERROR_CRYPTO:
            return "Cryptography error";
        case MESH_ERROR_TIMEOUT:
            return "Timeout";
        case MESH_ERROR_PEER_NOT_FOUND:
            return "Peer not found";
        case MESH_ERROR_PROTOCOL:
            return "Protocol error";
        default:
            return "Unknown error";
    }
}

void mesh_get_version(int* major, int* minor, int* patch) {
    if (major) *major = 1;
    if (minor) *minor = 0;
    if (patch) *patch = 0;
}

} // extern "C"
