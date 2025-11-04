#include "mesh/core.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

// Internal structures
struct mesh_context {
    mesh_node_id_t node_id;
    mesh_peer_t** peers;
    size_t peer_count;
    size_t peer_capacity;
    bool running;

    mesh_message_callback_t message_callback;
    void* message_user_data;

    mesh_peer_callback_t peer_callback;
    void* peer_user_data;
};

struct mesh_peer {
    mesh_node_id_t peer_id;
    char* address;
    bool connected;
    uint32_t connection_count;
};

struct mesh_message {
    mesh_message_type_t type;
    mesh_node_id_t from;
    mesh_node_id_t to;
    uint8_t* payload;
    size_t payload_size;
    uint64_t timestamp;
    uint32_t ttl;
    uint32_t hops;
};

// Context management
mesh_context_t* mesh_create_context(const mesh_node_id_t node_id) {
    mesh_context_t* ctx = calloc(1, sizeof(mesh_context_t));
    if (!ctx) {
        return NULL;
    }

    memcpy(ctx->node_id, node_id, sizeof(mesh_node_id_t));
    ctx->peers = NULL;
    ctx->peer_count = 0;
    ctx->peer_capacity = 0;
    ctx->running = false;

    return ctx;
}

void mesh_destroy_context(mesh_context_t* ctx) {
    if (!ctx) {
        return;
    }

    // Clean up peers
    for (size_t i = 0; i < ctx->peer_count; i++) {
        mesh_destroy_peer(ctx->peers[i]);
    }
    free(ctx->peers);

    free(ctx);
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

// Peer management
mesh_peer_t* mesh_create_peer(const mesh_node_id_t peer_id, const char* address) {
    if (!address) {
        return NULL;
    }

    mesh_peer_t* peer = calloc(1, sizeof(mesh_peer_t));
    if (!peer) {
        return NULL;
    }

    memcpy(peer->peer_id, peer_id, sizeof(mesh_node_id_t));
    peer->address = strdup(address);
    if (!peer->address) {
        free(peer);
        return NULL;
    }

    peer->connected = false;
    peer->connection_count = 0;

    return peer;
}

void mesh_destroy_peer(mesh_peer_t* peer) {
    if (!peer) {
        return;
    }

    free(peer->address);
    free(peer);
}

static int peer_id_compare(const mesh_node_id_t a, const mesh_node_id_t b) {
    return memcmp(a, b, sizeof(mesh_node_id_t));
}

mesh_error_t mesh_add_peer(mesh_context_t* ctx, mesh_peer_t* peer) {
    if (!ctx || !peer) {
        return MESH_ERROR_INVALID_PARAM;
    }

    // Check if peer already exists
    for (size_t i = 0; i < ctx->peer_count; i++) {
        if (peer_id_compare(ctx->peers[i]->peer_id, peer->peer_id) == 0) {
            return MESH_ERROR_INVALID_PARAM;
        }
    }

    // Expand capacity if needed
    if (ctx->peer_count >= ctx->peer_capacity) {
        size_t new_capacity = ctx->peer_capacity == 0 ? 8 : ctx->peer_capacity * 2;
        mesh_peer_t** new_peers = realloc(ctx->peers, new_capacity * sizeof(mesh_peer_t*));
        if (!new_peers) {
            return MESH_ERROR_OUT_OF_MEMORY;
        }
        ctx->peers = new_peers;
        ctx->peer_capacity = new_capacity;
    }

    ctx->peers[ctx->peer_count++] = peer;

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

    for (size_t i = 0; i < ctx->peer_count; i++) {
        if (peer_id_compare(ctx->peers[i]->peer_id, peer_id) == 0) {
            mesh_peer_t* peer = ctx->peers[i];

            // Notify peer callback
            if (ctx->peer_callback) {
                ctx->peer_callback(ctx, peer, false, ctx->peer_user_data);
            }

            // Remove peer from array
            memmove(&ctx->peers[i], &ctx->peers[i + 1],
                   (ctx->peer_count - i - 1) * sizeof(mesh_peer_t*));
            ctx->peer_count--;

            mesh_destroy_peer(peer);
            return MESH_SUCCESS;
        }
    }

    return MESH_ERROR_PEER_NOT_FOUND;
}

size_t mesh_get_peer_count(mesh_context_t* ctx) {
    return ctx ? ctx->peer_count : 0;
}

// Message handling
mesh_message_t* mesh_create_message(mesh_message_type_t type,
                                   const mesh_node_id_t from,
                                   const mesh_node_id_t to,
                                   const uint8_t* payload,
                                   size_t payload_size) {
    mesh_message_t* msg = calloc(1, sizeof(mesh_message_t));
    if (!msg) {
        return NULL;
    }

    msg->type = type;
    memcpy(msg->from, from, sizeof(mesh_node_id_t));
    memcpy(msg->to, to, sizeof(mesh_node_id_t));

    if (payload && payload_size > 0) {
        msg->payload = malloc(payload_size);
        if (!msg->payload) {
            free(msg);
            return NULL;
        }
        memcpy(msg->payload, payload, payload_size);
        msg->payload_size = payload_size;
    }

    msg->timestamp = (uint64_t)time(NULL);
    msg->ttl = 64;
    msg->hops = 0;

    return msg;
}

void mesh_destroy_message(mesh_message_t* msg) {
    if (!msg) {
        return;
    }

    free(msg->payload);
    free(msg);
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
    for (size_t i = 0; i < ctx->peer_count; i++) {
        if (ctx->message_callback) {
            ctx->message_callback(ctx, msg, ctx->message_user_data);
        }
    }

    return MESH_SUCCESS;
}

// Callback registration
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

// Utility functions
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
