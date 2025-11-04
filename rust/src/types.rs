use serde::{Deserialize, Serialize};
use std::fmt;
use std::net::SocketAddr;
use uuid::Uuid;

/// Unique identifier for a mesh node
#[derive(Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
pub struct NodeId([u8; 32]);

impl NodeId {
    /// Generate a new random NodeId
    pub fn new() -> Self {
        let uuid = Uuid::new_v4();
        let mut bytes = [0u8; 32];
        bytes[..16].copy_from_slice(uuid.as_bytes());
        // Fill the rest with random data
        use rand::Rng;
        rand::thread_rng().fill(&mut bytes[16..]);
        NodeId(bytes)
    }

    /// Create NodeId from bytes
    pub fn from_bytes(bytes: [u8; 32]) -> Self {
        NodeId(bytes)
    }

    /// Get the bytes representation
    pub fn as_bytes(&self) -> &[u8; 32] {
        &self.0
    }

    /// Convert to hex string
    pub fn to_hex(&self) -> String {
        hex::encode(self.0)
    }

    /// Parse from hex string
    pub fn from_hex(s: &str) -> Result<Self, hex::FromHexError> {
        let bytes = hex::decode(s)?;
        if bytes.len() != 32 {
            return Err(hex::FromHexError::InvalidStringLength);
        }
        let mut arr = [0u8; 32];
        arr.copy_from_slice(&bytes);
        Ok(NodeId(arr))
    }
}

impl fmt::Display for NodeId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}", &self.to_hex()[..16])
    }
}

impl fmt::Debug for NodeId {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "NodeId({})", &self.to_hex()[..16])
    }
}

impl Default for NodeId {
    fn default() -> Self {
        Self::new()
    }
}

/// Message types for mesh communication
#[derive(Clone, Debug, Serialize, Deserialize)]
pub enum MessageType {
    Data,
    Control,
    Discovery,
    Encrypted,
    Broadcast,
    Unicast,
    Multicast,
}

/// Protocol types supported by the mesh
#[derive(Clone, Debug, Serialize, Deserialize)]
pub enum ProtocolType {
    Flooding,
    Gossip,
    Consensus,
    Direct,
}

/// A message in the mesh network
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Message {
    pub id: u64,
    pub message_type: MessageType,
    pub protocol_type: ProtocolType,
    pub from: NodeId,
    pub to: Option<NodeId>,
    pub payload: Vec<u8>,
    pub timestamp: u64,
    pub ttl: u32,
    pub hops: u32,
    pub signature: Option<Vec<u8>>,
}

impl Message {
    pub fn new(from: NodeId, payload: Vec<u8>) -> Self {
        use std::time::{SystemTime, UNIX_EPOCH};
        let timestamp = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_secs();

        Message {
            id: rand::random(),
            message_type: MessageType::Data,
            protocol_type: ProtocolType::Direct,
            from,
            to: None,
            payload,
            timestamp,
            ttl: 64,
            hops: 0,
            signature: None,
        }
    }

    pub fn broadcast(from: NodeId, payload: Vec<u8>) -> Self {
        let mut msg = Self::new(from, payload);
        msg.message_type = MessageType::Broadcast;
        msg
    }

    pub fn unicast(from: NodeId, to: NodeId, payload: Vec<u8>) -> Self {
        let mut msg = Self::new(from, payload);
        msg.message_type = MessageType::Unicast;
        msg.to = Some(to);
        msg
    }

    pub fn is_expired(&self) -> bool {
        self.hops >= self.ttl
    }

    pub fn increment_hops(&mut self) {
        self.hops += 1;
    }
}

/// Information about a peer in the mesh
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Peer {
    pub id: NodeId,
    pub addresses: Vec<SocketAddr>,
    pub last_seen: u64,
    pub connected: bool,
    pub metadata: std::collections::HashMap<String, String>,
}

impl Peer {
    pub fn new(id: NodeId, address: SocketAddr) -> Self {
        use std::time::{SystemTime, UNIX_EPOCH};
        let last_seen = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_secs();

        Peer {
            id,
            addresses: vec![address],
            last_seen,
            connected: false,
            metadata: std::collections::HashMap::new(),
        }
    }

    pub fn update_last_seen(&mut self) {
        use std::time::{SystemTime, UNIX_EPOCH};
        self.last_seen = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_secs();
    }

    pub fn is_alive(&self) -> bool {
        use std::time::{SystemTime, UNIX_EPOCH};
        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_secs();
        now.saturating_sub(self.last_seen) < 300 // 5 minutes timeout
    }
}

/// Configuration for a mesh node
#[derive(Clone, Debug)]
pub struct NodeConfig {
    pub node_id: NodeId,
    pub listen_addr: SocketAddr,
    pub max_peers: usize,
    pub heartbeat_interval: u64,
    pub protocol: ProtocolType,
    pub enable_encryption: bool,
    pub enable_compression: bool,
}

impl Default for NodeConfig {
    fn default() -> Self {
        NodeConfig {
            node_id: NodeId::new(),
            listen_addr: "127.0.0.1:0".parse().unwrap(),
            max_peers: 100,
            heartbeat_interval: 30,
            protocol: ProtocolType::Gossip,
            enable_encryption: true,
            enable_compression: false,
        }
    }
}

/// Statistics for mesh operations
#[derive(Clone, Debug, Default, Serialize, Deserialize)]
pub struct MeshStats {
    pub messages_sent: u64,
    pub messages_received: u64,
    pub bytes_sent: u64,
    pub bytes_received: u64,
    pub peers_connected: usize,
    pub peers_discovered: usize,
    pub uptime_seconds: u64,
}
