#[cfg(test)]
mod tests {
    use katya_mesh::*;
    use std::time::Duration;
    use tokio::time::sleep;

    #[tokio::test]
    async fn test_rust_node_creation() {
        let config = NodeConfig {
            node_id: "rust-test-node".to_string(),
            listen_addr: "127.0.0.1:8091".to_string(),
            max_peers: 10,
            heartbeat_interval: Duration::from_secs(5),
            enable_encryption: true,
        };

        let node = Node::new(config).await.expect("Failed to create node");
        assert_eq!(node.id(), "rust-test-node");
        assert!(node.is_running().await);

        node.close().await;
    }

    #[tokio::test]
    async fn test_rust_message_exchange() {
        // Create two Rust nodes
        let config1 = NodeConfig {
            node_id: "rust-node-1".to_string(),
            listen_addr: "127.0.0.1:8092".to_string(),
            max_peers: 5,
            heartbeat_interval: Duration::from_secs(5),
            enable_encryption: false, // Disable for simpler testing
        };

        let config2 = NodeConfig {
            node_id: "rust-node-2".to_string(),
            listen_addr: "127.0.0.1:8093".to_string(),
            max_peers: 5,
            heartbeat_interval: Duration::from_secs(5),
            enable_encryption: false,
        };

        let node1 = Node::new(config1).await.expect("Failed to create node1");
        let node2 = Node::new(config2).await.expect("Failed to create node2");

        // Connect nodes
        node1.connect_to_peer("127.0.0.1:8093".to_string()).await
            .expect("Failed to connect nodes");

        // Wait for connection
        sleep(Duration::from_secs(2)).await;

        let peers = node1.get_peers().await;
        assert!(peers.contains(&"rust-node-2".to_string()));

        // Send message
        let test_message = b"Hello from Rust node 1!";
        node1.send_message("rust-node-2", test_message).await
            .expect("Failed to send message");

        // Wait for message delivery
        sleep(Duration::from_secs(1)).await;

        let messages = node2.get_messages().await;
        assert_eq!(messages.len(), 1);
        assert_eq!(messages[0].data, test_message);
        assert_eq!(messages[0].from, "rust-node-1");

        node1.close().await;
        node2.close().await;
    }

    #[tokio::test]
    async fn test_rust_crypto_operations() {
        // Test key generation
        let keypair = generate_keypair().expect("Failed to generate keypair");

        // Test encryption/decryption
        let plaintext = b"Secret message from Rust";
        let ciphertext = encrypt(&keypair.public_key, plaintext)
            .expect("Failed to encrypt");
        assert_ne!(plaintext, ciphertext.as_slice());

        let decrypted = decrypt(&keypair.private_key, &ciphertext)
            .expect("Failed to decrypt");
        assert_eq!(plaintext, decrypted.as_slice());

        // Test signing/verification
        let message = b"Message to sign";
        let signature = sign(&keypair.private_key, message)
            .expect("Failed to sign");

        let valid = verify(&keypair.public_key, message, &signature)
            .expect("Failed to verify");
        assert!(valid);
    }

    #[tokio::test]
    async fn test_rust_performance_benchmark() {
        let config = NodeConfig {
            node_id: "rust-bench-node".to_string(),
            listen_addr: "127.0.0.1:8094".to_string(),
            max_peers: 100,
            heartbeat_interval: Duration::from_secs(5),
            enable_encryption: false,
        };

        let node = Node::new(config).await.expect("Failed to create node");

        // Benchmark message processing
        let start = std::time::Instant::now();

        let num_messages = 1000;
        for i in 0..num_messages {
            let msg = format!("Benchmark message {}", i);
            node.broadcast_message(msg.as_bytes()).await
                .expect("Failed to broadcast message");
        }

        let duration = start.elapsed();
        let msg_per_sec = num_messages as f64 / duration.as_secs_f64();

        println!("Processed {} messages in {:.2}ms ({:.2} msg/sec)",
                num_messages, duration.as_millis(), msg_per_sec);

        node.close().await;
    }

    #[tokio::test]
    async fn test_rust_protocol_operations() {
        let config = NodeConfig {
            node_id: "rust-protocol-node".to_string(),
            listen_addr: "127.0.0.1:8095".to_string(),
            max_peers: 10,
            heartbeat_interval: Duration::from_secs(5),
            enable_encryption: true,
        };

        let node = Node::new(config).await.expect("Failed to create node");

        // Test flooding protocol
        let flood_msg = Message {
            id: "test-flood".to_string(),
            message_type: MessageType::Flood,
            data: b"Flood test message".to_vec(),
            from: "rust-protocol-node".to_string(),
            timestamp: std::time::SystemTime::now(),
        };

        node.send_flood_message(flood_msg).await
            .expect("Failed to send flood message");

        // Test gossip protocol
        let gossip_msg = Message {
            id: "test-gossip".to_string(),
            message_type: MessageType::Gossip,
            data: b"Gossip test message".to_vec(),
            from: "rust-protocol-node".to_string(),
            timestamp: std::time::SystemTime::now(),
        };

        node.send_gossip_message(gossip_msg).await
            .expect("Failed to send gossip message");

        node.close().await;
    }
}
