#ifndef MESH_CORE_H
#define MESH_CORE_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// Core types
typedef struct mesh_context mesh_context_t;
typedef struct mesh_peer mesh_peer_t;
typedef struct mesh_message mesh_message_t;
typedef uint8_t mesh_node_id_t[32];
typedef uint8_t mesh_key_t[32];

// Error codes
typedef enum {
    MESH_SUCCESS = 0,
    MESH_ERROR_INVALID_PARAM = -1,
    MESH_ERROR_OUT_OF_MEMORY = -2,
    MESH_ERROR_NETWORK = -3,
    MESH_ERROR_CRYPTO = -4,
    MESH_ERROR_TIMEOUT = -5,
    MESH_ERROR_PEER_NOT_FOUND = -6,
    MESH_ERROR_PROTOCOL = -7,
} mesh_error_t;

// Message types
typedef enum {
    MESH_MSG_DATA = 0,
    MESH_MSG_CONTROL = 1,
    MESH_MSG_DISCOVERY = 2,
    MESH_MSG_ENCRYPTED = 3,
} mesh_message_type_t;

// Context management
mesh_context_t* mesh_create_context(const mesh_node_id_t node_id);
void mesh_destroy_context(mesh_context_t* ctx);
mesh_error_t mesh_start(mesh_context_t* ctx);
mesh_error_t mesh_stop(mesh_context_t* ctx);

// Peer management
mesh_peer_t* mesh_create_peer(const mesh_node_id_t peer_id, const char* address);
void mesh_destroy_peer(mesh_peer_t* peer);
mesh_error_t mesh_add_peer(mesh_context_t* ctx, mesh_peer_t* peer);
mesh_error_t mesh_remove_peer(mesh_context_t* ctx, const mesh_node_id_t peer_id);
size_t mesh_get_peer_count(mesh_context_t* ctx);

// Message handling
mesh_message_t* mesh_create_message(mesh_message_type_t type,
                                   const mesh_node_id_t from,
                                   const mesh_node_id_t to,
                                   const uint8_t* payload,
                                   size_t payload_size);
void mesh_destroy_message(mesh_message_t* msg);

mesh_error_t mesh_send_message(mesh_context_t* ctx, mesh_message_t* msg);
mesh_error_t mesh_broadcast_message(mesh_context_t* ctx, mesh_message_t* msg);

// Callback types
typedef void (*mesh_message_callback_t)(mesh_context_t* ctx,
                                       mesh_message_t* msg,
                                       void* user_data);

typedef void (*mesh_peer_callback_t)(mesh_context_t* ctx,
                                    mesh_peer_t* peer,
                                    bool connected,
                                    void* user_data);

// Callback registration
mesh_error_t mesh_set_message_callback(mesh_context_t* ctx,
                                      mesh_message_callback_t callback,
                                      void* user_data);

mesh_error_t mesh_set_peer_callback(mesh_context_t* ctx,
                                   mesh_peer_callback_t callback,
                                   void* user_data);

// Utility functions
const char* mesh_error_string(mesh_error_t error);
void mesh_get_version(int* major, int* minor, int* patch);

#ifdef __cplusplus
}
#endif

#endif // MESH_CORE_H
