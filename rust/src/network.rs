use crate::error::{Error, Result};
use crate::types::{Message, NodeId, Peer, MeshStats};
use tokio::net::{TcpListener, TcpStream, UdpSocket};
use tokio::sync::{mpsc, RwLock};
use tokio_util::codec::{Framed, LengthDelimitedCodec};
use futures::{SinkExt, StreamExt};
use std::collections::HashMap;
use std::net::SocketAddr;
use std::sync::Arc;
use std::time::{Duration, Instant};

/// Network transport layer
pub struct NetworkTransport {
    node_id: NodeId,
    tcp_listener: Option<TcpListener>,
    udp_socket: Option<UdpSocket>,
    peers: Arc<RwLock<HashMap<NodeId, PeerConnection>>>,
    message_tx: mpsc::UnboundedSender<(Message, SocketAddr)>,
    message_rx: mpsc::UnboundedReceiver<(Message, SocketAddr)>,
    stats: Arc<RwLock<MeshStats>>,
}

#[derive(Clone)]
struct PeerConnection {
    peer: Peer,
    stream: Option<Arc<RwLock<Framed<TcpStream, LengthDelimitedCodec>>>>,
    last_seen: Instant,
}

impl NetworkTransport {
    pub async fn new(node_id: NodeId, listen_addr: SocketAddr) -> Result<Self> {
        let tcp_listener = TcpListener::bind(listen_addr).await
            .map_err(|e| Error::Network(format!("Failed to bind TCP listener: {}", e)))?;

        let udp_socket = UdpSocket::bind(listen_addr).await
            .map_err(|e| Error::Network(format!("Failed to bind UDP socket: {}", e)))?;

        let (message_tx, message_rx) = mpsc::unbounded_channel();

        Ok(NetworkTransport {
            node_id,
            tcp_listener: Some(tcp_listener),
            udp_socket: Some(udp_socket),
            peers: Arc::new(RwLock::new(HashMap::new())),
            message_tx,
            message_rx,
            stats: Arc::new(RwLock::new(MeshStats::default())),
        })
    }

    pub async fn start(&mut self) -> Result<()> {
        let tcp_listener = self.tcp_listener.take()
            .ok_or_else(|| Error::Network("TCP listener not available".to_string()))?;
        let udp_socket = self.udp_socket.take()
            .ok_or_else(|| Error::Network("UDP socket not available".to_string()))?;

        let peers = self.peers.clone();
        let message_tx = self.message_tx.clone();
        let stats = self.stats.clone();

        // TCP connection handler
        tokio::spawn(async move {
            loop {
                match tcp_listener.accept().await {
                    Ok((stream, addr)) => {
                        let framed = Framed::new(stream, LengthDelimitedCodec::new());
                        let framed = Arc::new(RwLock::new(framed));
                        let peers_clone = peers.clone();
                        let message_tx_clone = message_tx.clone();

                        tokio::spawn(async move {
                            if let Err(e) = handle_tcp_connection(framed, addr, peers_clone, message_tx_clone).await {
                                tracing::error!("TCP connection error: {}", e);
                            }
                        });
                    }
                    Err(e) => {
                        tracing::error!("TCP accept error: {}", e);
                        break;
                    }
                }
            }
        });

        // UDP message handler
        let message_tx_udp = self.message_tx.clone();
        tokio::spawn(async move {
            let mut buf = [0u8; 65536];
            loop {
                match udp_socket.recv_from(&mut buf).await {
                    Ok((len, addr)) => {
                        if let Ok(message) = bincode::deserialize::<Message>(&buf[..len]) {
                            let _ = message_tx_udp.send((message, addr));
                        }
                    }
                    Err(e) => {
                        tracing::error!("UDP recv error: {}", e);
                        break;
                    }
                }
            }
        });

        Ok(())
    }

    pub async fn connect_to_peer(&self, peer: Peer) -> Result<()> {
        if peer.addresses.is_empty() {
            return Err(Error::Network("Peer has no addresses".to_string()));
        }

        let addr = peer.addresses[0];
        let stream = TcpStream::connect(addr).await
            .map_err(|e| Error::Network(format!("Failed to connect to peer: {}", e)))?;

        let framed = Framed::new(stream, LengthDelimitedCodec::new());
        let framed = Arc::new(RwLock::new(framed));

        let connection = PeerConnection {
            peer: peer.clone(),
            stream: Some(framed),
            last_seen: Instant::now(),
        };

        let mut peers = self.peers.write().await;
        peers.insert(peer.id, connection);

        Ok(())
    }

    pub async fn send_message(&self, message: &Message, peer_id: &NodeId) -> Result<()> {
        let peers = self.peers.read().await;
        if let Some(connection) = peers.get(peer_id) {
            if let Some(stream) = &connection.stream {
                let framed = stream.write().await;
                let data = bincode::serialize(message)
                    .map_err(|e| Error::Serialization(e))?;

                framed.send(data.into()).await
                    .map_err(|e| Error::Network(format!("Failed to send message: {}", e)))?;

                let mut stats = self.stats.write().await;
                stats.messages_sent += 1;
                stats.bytes_sent += data.len() as u64;

                Ok(())
            } else {
                Err(Error::Network("No active connection to peer".to_string()))
            }
        } else {
            Err(Error::PeerNotFound(peer_id.to_string()))
        }
    }

    pub async fn broadcast_message(&self, message: &Message) -> Result<()> {
        let peers = self.peers.read().await;
        let mut errors = Vec::new();

        for (peer_id, connection) in peers.iter() {
            if let Err(e) = self.send_message(message, peer_id).await {
                errors.push(e);
            }
        }

        if errors.is_empty() {
            Ok(())
        } else {
            Err(Error::Network(format!("Broadcast failed with {} errors", errors.len())))
        }
    }

    pub async fn receive_message(&mut self) -> Option<(Message, SocketAddr)> {
        self.message_rx.recv().await
    }

    pub async fn get_stats(&self) -> MeshStats {
        self.stats.read().await.clone()
    }

    pub async fn get_peers(&self) -> Vec<Peer> {
        let peers = self.peers.read().await;
        peers.values().map(|conn| conn.peer.clone()).collect()
    }

    pub async fn disconnect_peer(&self, peer_id: &NodeId) -> Result<()> {
        let mut peers = self.peers.write().await;
        peers.remove(peer_id);
        Ok(())
    }
}

async fn handle_tcp_connection(
    framed: Arc<RwLock<Framed<TcpStream, LengthDelimitedCodec>>>,
    addr: SocketAddr,
    peers: Arc<RwLock<HashMap<NodeId, PeerConnection>>>,
    message_tx: mpsc::UnboundedSender<(Message, SocketAddr)>,
) -> Result<()> {
    loop {
        let framed_read = framed.read().await;
        match framed_read.next().await {
            Some(Ok(data)) => {
                if let Ok(message) = bincode::deserialize::<Message>(&data) {
                    let _ = message_tx.send((message, addr));
                }
            }
            Some(Err(e)) => {
                tracing::error!("Frame error: {}", e);
                break;
            }
            None => {
                tracing::info!("Connection closed by peer: {}", addr);
                break;
            }
        }
    }

    Ok(())
}

/// UDP discovery service for peer discovery
pub struct UdpDiscovery {
    socket: UdpSocket,
    node_id: NodeId,
    listen_addr: SocketAddr,
    discovered_peers: Arc<RwLock<HashMap<NodeId, Peer>>>,
}

impl UdpDiscovery {
    pub async fn new(node_id: NodeId, listen_addr: SocketAddr, multicast_addr: SocketAddr) -> Result<Self> {
        let socket = UdpSocket::bind(listen_addr).await
            .map_err(|e| Error::Network(format!("Failed to bind UDP discovery socket: {}", e)))?;

        // Join multicast group
        socket.join_multicast_v4(
            multicast_addr.ip().to_string().parse().unwrap(),
            listen_addr.ip(),
        ).map_err(|e| Error::Network(format!("Failed to join multicast group: {}", e)))?;

        Ok(UdpDiscovery {
            socket,
            node_id,
            listen_addr,
            discovered_peers: Arc::new(RwLock::new(HashMap::new())),
        })
    }

    pub async fn start(&self) -> Result<()> {
        let socket = self.socket.try_clone()
            .map_err(|e| Error::Network(format!("Failed to clone socket: {}", e)))?;
        let discovered_peers = self.discovered_peers.clone();
        let node_id = self.node_id;

        tokio::spawn(async move {
            let mut buf = [0u8; 1024];
            loop {
                match socket.recv_from(&mut buf).await {
                    Ok((len, addr)) => {
                        if let Ok(peer) = bincode::deserialize::<Peer>(&buf[..len]) {
                            if peer.id != node_id { // Don't add ourselves
                                let mut peers = discovered_peers.write().await;
                                peers.insert(peer.id, peer);
                                tracing::info!("Discovered peer: {} at {}", peer.id, addr);
                            }
                        }
                    }
                    Err(e) => {
                        tracing::error!("UDP discovery recv error: {}", e);
                        break;
                    }
                }
            }
        });

        // Broadcast our presence periodically
        let socket = self.socket.try_clone()
            .map_err(|e| Error::Network(format!("Failed to clone socket: {}", e)))?;
        let listen_addr = self.listen_addr;

        tokio::spawn(async move {
            let mut interval = tokio::time::interval(Duration::from_secs(30));
            loop {
                interval.tick().await;

                let peer = Peer::new(node_id, listen_addr);
                if let Ok(data) = bincode::serialize(&peer) {
                    let _ = socket.send_to(&data, "224.0.0.1:9999").await;
                }
            }
        });

        Ok(())
    }

    pub async fn get_discovered_peers(&self) -> Vec<Peer> {
        let peers = self.discovered_peers.read().await;
        peers.values().cloned().collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::net::{IpAddr, Ipv4Addr};

    #[tokio::test]
    async fn test_network_transport_creation() {
        let node_id = NodeId::new();
        let addr = SocketAddr::new(IpAddr::V4(Ipv4Addr::LOCALHOST), 0);

        let transport = NetworkTransport::new(node_id, addr).await;
        assert!(transport.is_ok());
    }

    #[tokio::test]
    async fn test_udp_discovery_creation() {
        let node_id = NodeId::new();
        let listen_addr = SocketAddr::new(IpAddr::V4(Ipv4Addr::LOCALHOST), 0);
        let multicast_addr = SocketAddr::new(IpAddr::V4(Ipv4Addr::new(224, 0, 0, 1)), 9999);

        let discovery = UdpDiscovery::new(node_id, listen_addr, multicast_addr).await;
        assert!(discovery.is_ok());
    }
}
