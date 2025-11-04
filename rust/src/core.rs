use crate::error::{Error, Result};
use crate::types::{Message, NodeId, Peer, NodeConfig, MeshStats, ProtocolType};
use crate::protocol::{MeshProtocol, ProtocolRegistry, FloodingProtocol, GossipProtocol, ConsensusProtocol};
use crate::network::{NetworkTransport, UdpDiscovery};
use crate::crypto::{AesGcmCrypto, Ed25519Signer};
use async_trait::async_trait;
use tokio::sync::{mpsc, RwLock};
use std::collections::HashMap;
use std::sync::Arc;
use std::time::Duration;

/// Main mesh node implementation
pub struct Node {
    config: NodeConfig,
    transport: Arc<RwLock<NetworkTransport>>,
    discovery: Option<UdpDiscovery>,
    protocols: Arc<RwLock<ProtocolRegistry>>,
    crypto: Option<AesGcmCrypto>,
    signer: Ed25519Signer,
    peers: Arc<RwLock<HashMap<NodeId, Peer>>>,
    message_handlers: Arc<RwLock<Vec<Box<dyn MessageHandler>>>>,
    stats: Arc<RwLock<MeshStats>>,
    running: Arc<RwLock<bool>>,
}

#[async_trait]
impl MessageHandler for Node {
    async fn handle_message(&self, message: &Message, from_peer: &NodeId) -> Result<()> {
        // Process message through protocols
        let protocols = self.protocols.read().await;
        if let Ok(responses) = protocols.handle_message(message, from_peer).await {
            // Send responses back through transport
            let transport = self.transport.read().await;
            for response in responses {
                if let Some(to_peer) = response.to {
                    let _ = transport.send_message(&response, &to_peer).await;
                } else {
                    let _ = transport.broadcast_message(&response).await;
                }
            }
        }

        // Call registered message handlers
        let handlers = self.message_handlers.read().await;
        for handler in handlers.iter() {
            if let Err(e) = handler.handle_message(message, from_peer).await {
                tracing::error!("Message handler error: {}", e);
            }
        }

        Ok(())
    }
}

#[async_trait]
pub trait MessageHandler: Send + Sync {
    async fn handle_message(&self, message: &Message, from_peer: &NodeId) -> Result<()>;
}

impl Node {
    pub async fn new(config: NodeConfig) -> Result<Self> {
        let transport = NetworkTransport::new(config.node_id, config.listen_addr).await?;
        let transport = Arc::new(RwLock::new(transport));

        let discovery = if config.listen_addr.ip().is_multicast() {
            Some(UdpDiscovery::new(config.node_id, config.listen_addr, config.listen_addr).await?)
        } else {
            None
        };

        let mut protocols = ProtocolRegistry::new();

        // Register default protocols
        match config.protocol {
            ProtocolType::Flooding => {
                protocols.register(FloodingProtocol::new(config.node_id));
            }
            ProtocolType::Gossip => {
                protocols.register(GossipProtocol::new(config.node_id));
            }
            ProtocolType::Consensus => {
                protocols.register(ConsensusProtocol::new(config.node_id));
            }
            _ => {
                // Register all protocols
                protocols.register(FloodingProtocol::new(config.node_id));
                protocols.register(GossipProtocol::new(config.node_id));
                protocols.register(ConsensusProtocol::new(config.node_id));
            }
        }

        let crypto = if config.enable_encryption {
            Some(AesGcmCrypto::new(&[0u8; 32])) // TODO: Use proper key derivation
        } else {
            None
        };

        let signer = Ed25519Signer::new();

        Ok(Node {
            config,
            transport,
            discovery,
            protocols: Arc::new(RwLock::new(protocols)),
            crypto,
            signer,
            peers: Arc::new(RwLock::new(HashMap::new())),
            message_handlers: Arc::new(RwLock::new(Vec::new())),
            stats: Arc::new(RwLock::new(MeshStats::default())),
            running: Arc::new(RwLock::new(false)),
        })
    }

    pub async fn start(&self) -> Result<()> {
        let mut running = self.running.write().await;
        if *running {
            return Err(Error::InvalidParameter("Node already running".to_string()));
        }
        *running = true;
        drop(running);

        // Start transport
        let mut transport = self.transport.write().await;
        transport.start().await?;
        drop(transport);

        // Start discovery if available
        if let Some(discovery) = &self.discovery {
            discovery.start().await?;
        }

        // Start message processing loop
        let transport = self.transport.clone();
        let running = self.running.clone();
        let node = Arc::new(self.clone());

        tokio::spawn(async move {
            while *running.read().await {
                let mut transport = transport.write().await;
                if let Some((message, addr)) = transport.receive_message().await {
                    drop(transport);

                    // Find peer by address
                    let peers = node.peers.read().await;
                    let from_peer = peers.values()
                        .find(|p| p.addresses.contains(&addr))
                        .map(|p| p.id)
                        .unwrap_or_else(|| NodeId::new()); // Fallback

                    if let Err(e) = node.handle_message(&message, &from_peer).await {
                        tracing::error!("Failed to handle message: {}", e);
                    }

                    // Update stats
                    let mut stats = node.stats.write().await;
                    stats.messages_received += 1;
                    stats.bytes_received += message.payload.len() as u64;
                }
            }
        });

        tracing::info!("Node {} started on {}", self.config.node_id, self.config.listen_addr);
        Ok(())
    }

    pub async fn stop(&self) -> Result<()> {
        let mut running = self.running.write().await;
        *running = false;
        Ok(())
    }

    pub async fn send_message(&self, message: Message) -> Result<()> {
        let transport = self.transport.read().await;

        if let Some(to) = message.to {
            transport.send_message(&message, &to).await?;
        } else {
            transport.broadcast_message(&message).await?;
        }

        Ok(())
    }

    pub async fn add_peer(&self, peer: Peer) -> Result<()> {
        // Connect via transport
        let transport = self.transport.read().await;
        transport.connect_to_peer(peer.clone()).await?;

        // Add to peer list
        let mut peers = self.peers.write().await;
        peers.insert(peer.id, peer);

        Ok(())
    }

    pub async fn remove_peer(&self, peer_id: &NodeId) -> Result<()> {
        let transport = self.transport.read().await;
        transport.disconnect_peer(peer_id).await?;

        let mut peers = self.peers.write().await;
        peers.remove(peer_id);

        Ok(())
    }

    pub async fn get_peers(&self) -> Vec<Peer> {
        let peers = self.peers.read().await;
        peers.values().cloned().collect()
    }

    pub async fn register_message_handler<H: MessageHandler + 'static>(&self, handler: H) {
        let mut handlers = self.message_handlers.write().await;
        handlers.push(Box::new(handler));
    }

    pub async fn get_stats(&self) -> MeshStats {
        let mut stats = self.stats.read().await.clone();

        // Add transport stats
        let transport = self.transport.read().await;
        let transport_stats = transport.get_stats().await;
        stats.messages_sent += transport_stats.messages_sent;
        stats.messages_received += transport_stats.messages_received;
        stats.bytes_sent += transport_stats.bytes_sent;
        stats.bytes_received += transport_stats.bytes_received;

        stats
    }

    pub fn node_id(&self) -> &NodeId {
        &self.config.node_id
    }

    pub fn config(&self) -> &NodeConfig {
        &self.config
    }
}

impl Clone for Node {
    fn clone(&self) -> Self {
        // This is a simplified clone - in practice you'd want proper reference counting
        Node {
            config: self.config.clone(),
            transport: self.transport.clone(),
            discovery: None, // Discovery not cloned
            protocols: self.protocols.clone(),
            crypto: self.crypto.clone(),
            signer: Ed25519Signer::new(), // New signer for clone
            peers: self.peers.clone(),
            message_handlers: self.message_handlers.clone(),
            stats: self.stats.clone(),
            running: self.running.clone(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::net::{IpAddr, Ipv4Addr, SocketAddr};

    #[tokio::test]
    async fn test_node_creation() {
        let config = NodeConfig {
            node_id: NodeId::new(),
            listen_addr: SocketAddr::new(IpAddr::V4(Ipv4Addr::LOCALHOST), 0),
            max_peers: 10,
            heartbeat_interval: 30,
            protocol: ProtocolType::Flooding,
            enable_encryption: false,
            enable_compression: false,
        };

        let node = Node::new(config).await;
        assert!(node.is_ok());
    }

    #[tokio::test]
    async fn test_node_start_stop() {
        let config = NodeConfig {
            node_id: NodeId::new(),
            listen_addr: SocketAddr::new(IpAddr::V4(Ipv4Addr::LOCALHOST), 0),
            max_peers: 10,
            heartbeat_interval: 30,
            protocol: ProtocolType::Flooding,
            enable_encryption: false,
            enable_compression: false,
        };

        let node = Node::new(config).await.unwrap();
        assert!(node.start().await.is_ok());
        assert!(node.stop().await.is_ok());
    }
}
