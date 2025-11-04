use thiserror::Error;

#[derive(Error, Debug)]
pub enum Error {
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),

    #[error("Serialization error: {0}")]
    Serialization(#[from] bincode::Error),

    #[error("JSON error: {0}")]
    Json(#[from] serde_json::Error),

    #[error("Crypto error: {0}")]
    Crypto(String),

    #[error("Network error: {0}")]
    Network(String),

    #[error("Protocol error: {0}")]
    Protocol(String),

    #[error("Invalid parameter: {0}")]
    InvalidParameter(String),

    #[error("Peer not found: {0}")]
    PeerNotFound(String),

    #[error("Timeout error")]
    Timeout,

    #[error("Authentication failed")]
    AuthenticationFailed,

    #[error("Connection closed")]
    ConnectionClosed,

    #[error("Resource exhausted")]
    ResourceExhausted,

    #[error("Internal error: {0}")]
    Internal(String),
}

pub type Result<T> = std::result::Result<T, Error>;
