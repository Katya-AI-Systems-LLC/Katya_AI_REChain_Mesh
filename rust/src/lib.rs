pub mod core;
pub mod crypto;
pub mod protocol;
pub mod network;
pub mod error;
pub mod types;
pub mod ffi;

pub use core::*;
pub use crypto::*;
pub use error::*;
pub use types::*;

// Re-export commonly used types
pub use types::{NodeId, Message, Peer, MessageType, ProtocolType};

/// Initialize the Katya Mesh library with default settings
pub async fn init() -> Result<(), Error> {
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::EnvFilter::from_default_env())
        .init();

    tracing::info!("Katya Mesh v{} initialized", env!("CARGO_PKG_VERSION"));
    Ok(())
}

/// Create a new mesh node with the given configuration
pub async fn create_node(config: NodeConfig) -> Result<Node, Error> {
    Node::new(config).await
}

/// Get library version information
pub fn version() -> &'static str {
    env!("CARGO_PKG_VERSION")
}
