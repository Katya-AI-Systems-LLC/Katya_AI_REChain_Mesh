use crate::error::{Error, Result};
use crate::types::{Message, NodeId, Peer, ProtocolType};
use async_trait::async_trait;
use dashmap::DashMap;
use std::collections::HashMap;
use std::sync::Arc;
use tokio::sync::RwLock;
use tokio::time::{Duration, Instant};

/// Trait for mesh protocols
#[async_trait]
pub trait MeshProtocol: Send + Sync {
    /// Handle an incoming message
    async fn handle_message(&self, message: &Message, from_peer: &NodeId) -> Result<Vec<Message>>;

    /// Get the protocol type
    fn protocol_type(&self) -> ProtocolType;

    /// Get protocol statistics
    fn stats(&self) -> ProtocolStats;
}

/// Statistics for protocol operations
#[derive(Clone, Debug, Default)]
pub struct ProtocolStats {
    pub messages_processed: u64,
    pub messages_sent: u64,
    pub bytes_processed: u64,
    pub errors: u64,
}

/// Flooding protocol implementation
pub struct FloodingProtocol {
    node_id: NodeId,
    seen_messages: Arc<DashMap<u64, Instant>>,
    max_ttl: u32,
    stats: Arc<RwLock<ProtocolStats>>,
}

impl FloodingProtocol {
    pub fn new(node_id: NodeId) -> Self {
        let seen_messages = Arc::new(DashMap::new());
        let stats = Arc::new(RwLock::new(ProtocolStats::default()));

        // Cleanup task for expired messages
        let seen_messages_clone = seen_messages.clone();
        tokio::spawn(async move {
            let mut interval = tokio::time::interval(Duration::from_secs(60));
            loop {
                interval.tick().await;
                let now = Instant::now();
                seen_messages_clone.retain(|_, timestamp| {
                    now.duration_since(*timestamp) < Duration::from_secs(300) // 5 minutes
                });
            }
        });

        FloodingProtocol {
            node_id,
            seen_messages,
            max_ttl: 64,
            stats,
        }
    }

    pub fn with_ttl(mut self, ttl: u32) -> Self {
        self.max_ttl = ttl;
        self
    }
}

#[async_trait]
impl MeshProtocol for FloodingProtocol {
    async fn handle_message(&self, message: &Message, from_peer: &NodeId) -> Result<Vec<Message>> {
        let mut stats = self.stats.write().await;
        stats.messages_processed += 1;
        stats.bytes_processed += message.payload.len() as u64;

        // Check if we've seen this message before
        if self.seen_messages.contains_key(&message.id) {
            return Ok(vec![]); // Already processed, don't flood again
        }

        // Mark message as seen
        self.seen_messages.insert(message.id, Instant::now());

        // Check TTL
        if message.hops >= message.ttl {
            return Ok(vec![]); // Message expired
        }

        // Create flooded message with incremented hop count
        let mut flooded_message = message.clone();
        flooded_message.hops += 1;
        flooded_message.protocol_type = ProtocolType::Flooding;

        stats.messages_sent += 1;

        Ok(vec![flooded_message])
    }

    fn protocol_type(&self) -> ProtocolType {
        ProtocolType::Flooding
    }

    fn stats(&self) -> ProtocolStats {
        futures::executor::block_on(async {
            self.stats.read().await.clone()
        })
    }
}

/// Gossip protocol implementation
pub struct GossipProtocol {
    node_id: NodeId,
    fanout: usize,
    rounds: usize,
    seen_messages: Arc<DashMap<u64, Instant>>,
    stats: Arc<RwLock<ProtocolStats>>,
}

impl GossipProtocol {
    pub fn new(node_id: NodeId) -> Self {
        let seen_messages = Arc::new(DashMap::new());
        let stats = Arc::new(RwLock::new(ProtocolStats::default()));

        // Cleanup task
        let seen_messages_clone = seen_messages.clone();
        tokio::spawn(async move {
            let mut interval = tokio::time::interval(Duration::from_secs(60));
            loop {
                interval.tick().await;
                let now = Instant::now();
                seen_messages_clone.retain(|_, timestamp| {
                    now.duration_since(*timestamp) < Duration::from_secs(300)
                });
            }
        });

        GossipProtocol {
            node_id,
            fanout: 3,
            rounds: 3,
            seen_messages,
            stats,
        }
    }

    pub fn with_fanout(mut self, fanout: usize) -> Self {
        self.fanout = fanout;
        self
    }

    pub fn with_rounds(mut self, rounds: usize) -> Self {
        self.rounds = rounds;
        self
    }
}

#[async_trait]
impl MeshProtocol for GossipProtocol {
    async fn handle_message(&self, message: &Message, from_peer: &NodeId) -> Result<Vec<Message>> {
        let mut stats = self.stats.write().await;
        stats.messages_processed += 1;
        stats.bytes_processed += message.payload.len() as u64;

        // Check if we've seen this message before
        if self.seen_messages.contains_key(&message.id) {
            return Ok(vec![]);
        }

        // Mark message as seen
        self.seen_messages.insert(message.id, Instant::now());

        // For gossip, we send to a subset of peers
        let mut gossiped_message = message.clone();
        gossiped_message.hops += 1;
        gossiped_message.protocol_type = ProtocolType::Gossip;

        stats.messages_sent += 1;

        Ok(vec![gossiped_message])
    }

    fn protocol_type(&self) -> ProtocolType {
        ProtocolType::Gossip
    }

    fn stats(&self) -> ProtocolStats {
        futures::executor::block_on(async {
            self.stats.read().await.clone()
        })
    }
}

/// Consensus protocol implementation
pub struct ConsensusProtocol {
    node_id: NodeId,
    peers: Arc<RwLock<HashMap<NodeId, Peer>>>,
    proposals: Arc<DashMap<u64, Proposal>>,
    stats: Arc<RwLock<ProtocolStats>>,
}

#[derive(Clone, Debug)]
struct Proposal {
    id: u64,
    proposer: NodeId,
    value: Vec<u8>,
    votes: HashMap<NodeId, bool>,
    start_time: Instant,
    timeout: Duration,
}

impl ConsensusProtocol {
    pub fn new(node_id: NodeId) -> Self {
        ConsensusProtocol {
            node_id,
            peers: Arc::new(RwLock::new(HashMap::new())),
            proposals: Arc::new(DashMap::new()),
            stats: Arc::new(RwLock::new(ProtocolStats::default())),
        }
    }

    pub async fn add_peer(&self, peer: Peer) {
        let mut peers = self.peers.write().await;
        peers.insert(peer.id, peer);
    }

    pub async fn remove_peer(&self, peer_id: &NodeId) {
        let mut peers = self.peers.write().await;
        peers.remove(peer_id);
    }

    pub async fn propose(&self, proposal_id: u64, value: Vec<u8>) -> Result<()> {
        let peers = self.peers.read().await;
        let quorum_size = (peers.len() / 2) + 1;

        let proposal = Proposal {
            id: proposal_id,
            proposer: self.node_id,
            value,
            votes: HashMap::new(),
            start_time: Instant::now(),
            timeout: Duration::from_secs(30),
        };

        self.proposals.insert(proposal_id, proposal);

        // Auto-vote for our own proposal
        self.vote(proposal_id, true).await?;

        Ok(())
    }

    pub async fn vote(&self, proposal_id: u64, approve: bool) -> Result<()> {
        let mut stats = self.stats.write().await;

        if let Some(mut proposal) = self.proposals.get_mut(&proposal_id) {
            proposal.votes.insert(self.node_id, approve);
            stats.messages_processed += 1;

            // Check if we have consensus
            let peers = self.peers.read().await;
            let total_peers = peers.len() + 1; // +1 for ourselves
            let approvals = proposal.votes.values().filter(|&&v| v).count();
            let quorum_size = (total_peers / 2) + 1;

            if approvals >= quorum_size {
                stats.messages_sent += 1;
                // Consensus reached!
                tracing::info!("Consensus reached for proposal {}", proposal_id);
            }
        }

        Ok(())
    }

    pub async fn check_consensus(&self, proposal_id: u64) -> Result<Option<bool>> {
        if let Some(proposal) = self.proposals.get(&proposal_id) {
            let peers = self.peers.read().await;
            let total_peers = peers.len() + 1;
            let approvals = proposal.votes.values().filter(|&&v| v).count();
            let quorum_size = (total_peers / 2) + 1;

            if approvals >= quorum_size {
                return Ok(Some(true));
            }

            let rejections = proposal.votes.len() - approvals;
            if rejections > total_peers - quorum_size {
                return Ok(Some(false));
            }

            // Check timeout
            if proposal.start_time.elapsed() > proposal.timeout {
                return Ok(Some(false)); // Timeout = rejection
            }
        }

        Ok(None) // No consensus yet
    }
}

#[async_trait]
impl MeshProtocol for ConsensusProtocol {
    async fn handle_message(&self, message: &Message, from_peer: &NodeId) -> Result<Vec<Message>> {
        let mut stats = self.stats.write().await;
        stats.messages_processed += 1;
        stats.bytes_processed += message.payload.len() as u64;

        // Handle consensus messages
        // This is a simplified implementation
        let response = Message::unicast(self.node_id, *from_peer, b"ACK".to_vec());
        stats.messages_sent += 1;

        Ok(vec![response])
    }

    fn protocol_type(&self) -> ProtocolType {
        ProtocolType::Consensus
    }

    fn stats(&self) -> ProtocolStats {
        futures::executor::block_on(async {
            self.stats.read().await.clone()
        })
    }
}

/// Protocol registry for managing multiple protocols
pub struct ProtocolRegistry {
    protocols: HashMap<ProtocolType, Box<dyn MeshProtocol>>,
}

impl ProtocolRegistry {
    pub fn new() -> Self {
        ProtocolRegistry {
            protocols: HashMap::new(),
        }
    }

    pub fn register<P: MeshProtocol + 'static>(&mut self, protocol: P) {
        self.protocols.insert(protocol.protocol_type(), Box::new(protocol));
    }

    pub async fn handle_message(&self, message: &Message, from_peer: &NodeId) -> Result<Vec<Message>> {
        if let Some(protocol) = self.protocols.get(&message.protocol_type) {
            protocol.handle_message(message, from_peer).await
        } else {
            Err(Error::Protocol(format!("Unknown protocol: {:?}", message.protocol_type)))
        }
    }

    pub fn get_protocol(&self, protocol_type: &ProtocolType) -> Option<&dyn MeshProtocol> {
        self.protocols.get(protocol_type).map(|p| p.as_ref())
    }

    pub fn get_stats(&self, protocol_type: &ProtocolType) -> Option<ProtocolStats> {
        self.protocols.get(protocol_type).map(|p| p.stats())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_flooding_protocol() {
        let node_id = NodeId::new();
        let protocol = FloodingProtocol::new(node_id);
        let message = Message::broadcast(node_id, b"Hello".to_vec());

        let responses = protocol.handle_message(&message, &NodeId::new()).await.unwrap();
        assert_eq!(responses.len(), 1);

        // Second time should return empty (already seen)
        let responses2 = protocol.handle_message(&message, &NodeId::new()).await.unwrap();
        assert_eq!(responses2.len(), 0);
    }

    #[tokio::test]
    async fn test_gossip_protocol() {
        let node_id = NodeId::new();
        let protocol = GossipProtocol::new(node_id);
        let message = Message::broadcast(node_id, b"Hello".to_vec());

        let responses = protocol.handle_message(&message, &NodeId::new()).await.unwrap();
        assert_eq!(responses.len(), 1);
    }

    #[tokio::test]
    async fn test_consensus_protocol() {
        let node_id = NodeId::new();
        let protocol = ConsensusProtocol::new(node_id);

        protocol.propose(1, b"Test proposal".to_vec()).await.unwrap();

        let consensus = protocol.check_consensus(1).await.unwrap();
        assert_eq!(consensus, Some(true)); // Single node consensus
    }
}
