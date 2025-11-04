use crate::error::Error;
use crate::types::{NodeId, Message, NodeConfig, ProtocolType, MessageType};
use crate::core::Node;
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_void};
use std::ptr;
use std::sync::Arc;
use tokio::runtime::Runtime;

/// Opaque handle to a mesh node
#[repr(C)]
pub struct mesh_node {
    _private: [u8; 0],
}

/// Opaque handle to a message
#[repr(C)]
pub struct mesh_message {
    _private: [u8; 0],
}

/// Opaque handle to a node configuration
#[repr(C)]
pub struct mesh_config {
    _private: [u8; 0],
}

/// Callback function types
pub type mesh_message_callback = extern "C" fn(
    node: *mut mesh_node,
    message: *const mesh_message,
    user_data: *mut c_void,
);

pub type mesh_peer_callback = extern "C" fn(
    node: *mut mesh_node,
    peer_id: *const c_char,
    connected: c_int,
    user_data: *mut c_void,
);

/// Error codes for FFI
#[repr(C)]
pub enum mesh_error {
    MESH_SUCCESS = 0,
    MESH_ERROR_INVALID_PARAM = -1,
    MESH_ERROR_OUT_OF_MEMORY = -2,
    MESH_ERROR_NETWORK = -3,
    MESH_ERROR_CRYPTO = -4,
    MESH_ERROR_TIMEOUT = -5,
    MESH_ERROR_PEER_NOT_FOUND = -6,
    MESH_ERROR_PROTOCOL = -7,
    MESH_ERROR_INTERNAL = -8,
}

/// Protocol types for FFI
#[repr(C)]
pub enum mesh_protocol_type {
    MESH_PROTOCOL_FLOODING = 0,
    MESH_PROTOCOL_GOSSIP = 1,
    MESH_PROTOCOL_CONSENSUS = 2,
    MESH_PROTOCOL_DIRECT = 3,
}

/// Message types for FFI
#[repr(C)]
pub enum mesh_message_type {
    MESH_MSG_DATA = 0,
    MESH_MSG_CONTROL = 1,
    MESH_MSG_DISCOVERY = 2,
    MESH_MSG_ENCRYPTED = 3,
}

/// Global Tokio runtime for FFI calls
static mut RUNTIME: Option<Runtime> = None;

/// Initialize the FFI runtime
#[no_mangle]
pub extern "C" fn mesh_init() -> mesh_error {
    unsafe {
        if RUNTIME.is_none() {
            match Runtime::new() {
                Ok(rt) => {
                    RUNTIME = Some(rt);
                    mesh_error::MESH_SUCCESS
                }
                Err(_) => mesh_error::MESH_ERROR_INTERNAL,
            }
        } else {
            mesh_error::MESH_SUCCESS
        }
    }
}

/// Shutdown the FFI runtime
#[no_mangle]
pub extern "C" fn mesh_shutdown() {
    unsafe {
        if let Some(rt) = RUNTIME.take() {
            rt.shutdown_background();
        }
    }
}

/// Create a new node configuration
#[no_mangle]
pub extern "C" fn mesh_config_new() -> *mut mesh_config {
    let config = NodeConfig::default();
    let boxed = Box::new(config);
    Box::into_raw(boxed) as *mut mesh_config
}

/// Set the listen address for a configuration
#[no_mangle]
pub extern "C" fn mesh_config_set_listen_addr(
    config: *mut mesh_config,
    addr: *const c_char,
) -> mesh_error {
    if config.is_null() || addr.is_null() {
        return mesh_error::MESH_ERROR_INVALID_PARAM;
    }

    let config = unsafe { &mut *(config as *mut NodeConfig) };
    let addr_str = match unsafe { CStr::from_ptr(addr) }.to_str() {
        Ok(s) => s,
        Err(_) => return mesh_error::MESH_ERROR_INVALID_PARAM,
    };

    match addr_str.parse() {
        Ok(socket_addr) => {
            config.listen_addr = socket_addr;
            mesh_error::MESH_SUCCESS
        }
        Err(_) => mesh_error::MESH_ERROR_INVALID_PARAM,
    }
}

/// Set the protocol type for a configuration
#[no_mangle]
pub extern "C" fn mesh_config_set_protocol(
    config: *mut mesh_config,
    protocol: mesh_protocol_type,
) -> mesh_error {
    if config.is_null() {
        return mesh_error::MESH_ERROR_INVALID_PARAM;
    }

    let config = unsafe { &mut *(config as *mut NodeConfig) };
    config.protocol = match protocol {
        mesh_protocol_type::MESH_PROTOCOL_FLOODING => ProtocolType::Flooding,
        mesh_protocol_type::MESH_PROTOCOL_GOSSIP => ProtocolType::Gossip,
        mesh_protocol_type::MESH_PROTOCOL_CONSENSUS => ProtocolType::Consensus,
        mesh_protocol_type::MESH_PROTOCOL_DIRECT => ProtocolType::Direct,
    };

    mesh_error::MESH_SUCCESS
}

/// Set encryption for a configuration
#[no_mangle]
pub extern "C" fn mesh_config_set_encryption(
    config: *mut mesh_config,
    enabled: c_int,
) -> mesh_error {
    if config.is_null() {
        return mesh_error::MESH_ERROR_INVALID_PARAM;
    }

    let config = unsafe { &mut *(config as *mut NodeConfig) };
    config.enable_encryption = enabled != 0;
    mesh_error::MESH_SUCCESS
}

/// Free a configuration
#[no_mangle]
pub extern "C" fn mesh_config_free(config: *mut mesh_config) {
    if !config.is_null() {
        unsafe {
            let _ = Box::from_raw(config as *mut NodeConfig);
        }
    }
}

/// Create a new mesh node
#[no_mangle]
pub extern "C" fn mesh_node_new(config: *const mesh_config) -> *mut mesh_node {
    if config.is_null() {
        return ptr::null_mut();
    }

    let config = unsafe { &*(config as *const NodeConfig) };
    let rt = unsafe { RUNTIME.as_ref() };

    if let Some(rt) = rt {
        match rt.block_on(async {
            Node::new(config.clone()).await
        }) {
            Ok(node) => {
                let boxed = Box::new(node);
                Box::into_raw(boxed) as *mut mesh_node
            }
            Err(_) => ptr::null_mut(),
        }
    } else {
        ptr::null_mut()
    }
}

/// Start a mesh node
#[no_mangle]
pub extern "C" fn mesh_node_start(node: *mut mesh_node) -> mesh_error {
    if node.is_null() {
        return mesh_error::MESH_ERROR_INVALID_PARAM;
    }

    let node = unsafe { &*(node as *mut Node) };
    let rt = unsafe { RUNTIME.as_ref() };

    if let Some(rt) = rt {
        match rt.block_on(async {
            node.start().await
        }) {
            Ok(_) => mesh_error::MESH_SUCCESS,
            Err(_) => mesh_error::MESH_ERROR_INTERNAL,
        }
    } else {
        mesh_error::MESH_ERROR_INTERNAL
    }
}

/// Stop a mesh node
#[no_mangle]
pub extern "C" fn mesh_node_stop(node: *mut mesh_node) -> mesh_error {
    if node.is_null() {
        return mesh_error::MESH_ERROR_INVALID_PARAM;
    }

    let node = unsafe { &*(node as *mut Node) };
    let rt = unsafe { RUNTIME.as_ref() };

    if let Some(rt) = rt {
        match rt.block_on(async {
            node.stop().await
        }) {
            Ok(_) => mesh_error::MESH_SUCCESS,
            Err(_) => mesh_error::MESH_ERROR_INTERNAL,
        }
    } else {
        mesh_error::MESH_ERROR_INTERNAL
    }
}

/// Create a new message
#[no_mangle]
pub extern "C" fn mesh_message_new(
    msg_type: mesh_message_type,
    payload: *const u8,
    payload_len: usize,
) -> *mut mesh_message {
    if payload.is_null() && payload_len > 0 {
        return ptr::null_mut();
    }

    let message_type = match msg_type {
        mesh_message_type::MESH_MSG_DATA => MessageType::Data,
        mesh_message_type::MESH_MSG_CONTROL => MessageType::Control,
        mesh_message_type::MESH_MSG_DISCOVERY => MessageType::Discovery,
        mesh_message_type::MESH_MSG_ENCRYPTED => MessageType::Encrypted,
    };

    let payload_vec = if payload_len > 0 {
        unsafe { std::slice::from_raw_parts(payload, payload_len).to_vec() }
    } else {
        Vec::new()
    };

    let message = Message::new(NodeId::new(), payload_vec);
    let mut boxed_message = Box::new(message);
    boxed_message.message_type = message_type;

    Box::into_raw(boxed_message) as *mut mesh_message
}

/// Send a message through a node
#[no_mangle]
pub extern "C" fn mesh_node_send_message(
    node: *mut mesh_node,
    message: *mut mesh_message,
) -> mesh_error {
    if node.is_null() || message.is_null() {
        return mesh_error::MESH_ERROR_INVALID_PARAM;
    }

    let node = unsafe { &*(node as *mut Node) };
    let message = unsafe { Box::from_raw(message as *mut Message) };
    let message_clone = message.clone();
    let _ = Box::into_raw(message); // Don't drop the original

    let rt = unsafe { RUNTIME.as_ref() };

    if let Some(rt) = rt {
        match rt.block_on(async {
            node.send_message(message_clone).await
        }) {
            Ok(_) => mesh_error::MESH_SUCCESS,
            Err(_) => mesh_error::MESH_ERROR_NETWORK,
        }
    } else {
        mesh_error::MESH_ERROR_INTERNAL
    }
}

/// Free a message
#[no_mangle]
pub extern "C" fn mesh_message_free(message: *mut mesh_message) {
    if !message.is_null() {
        unsafe {
            let _ = Box::from_raw(message as *mut Message);
        }
    }
}

/// Free a node
#[no_mangle]
pub extern "C" fn mesh_node_free(node: *mut mesh_node) {
    if !node.is_null() {
        unsafe {
            let _ = Box::from_raw(node as *mut Node);
        }
    }
}

/// Get the last error message (simplified)
#[no_mangle]
pub extern "C" fn mesh_error_string(error: mesh_error) -> *const c_char {
    let error_str = match error {
        mesh_error::MESH_SUCCESS => "Success",
        mesh_error::MESH_ERROR_INVALID_PARAM => "Invalid parameter",
        mesh_error::MESH_ERROR_OUT_OF_MEMORY => "Out of memory",
        mesh_error::MESH_ERROR_NETWORK => "Network error",
        mesh_error::MESH_ERROR_CRYPTO => "Cryptography error",
        mesh_error::MESH_ERROR_TIMEOUT => "Timeout",
        mesh_error::MESH_ERROR_PEER_NOT_FOUND => "Peer not found",
        mesh_error::MESH_ERROR_PROTOCOL => "Protocol error",
        mesh_error::MESH_ERROR_INTERNAL => "Internal error",
    };

    // This is unsafe - in a real implementation, you'd need proper string management
    unsafe { CStr::from_bytes_with_nul_unchecked(error_str.as_bytes()).as_ptr() }
}
