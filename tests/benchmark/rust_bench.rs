#[cfg(test)]
mod benchmarks {
    use katya_mesh::*;
    use std::time::{Duration, Instant};
    use tokio::runtime::Runtime;

    fn rt() -> Runtime {
        Runtime::new().unwrap()
    }

    #[bench]
    fn bench_rust_node_creation(b: &mut test::Bencher) {
        let rt = rt();

        b.iter(|| {
            let config = NodeConfig {
                node_id: "bench-rust-node".to_string(),
                listen_addr: "127.0.0.1:9015".to_string(),
                max_peers: 10,
                heartbeat_interval: Duration::from_secs(5),
                enable_encryption: true,
            };

            rt.block_on(async {
                let node = Node::new(config).await.expect("Failed to create node");
                node.close().await;
            });
        });
    }

    #[bench]
    fn bench_rust_message_send(b: &mut test::Bencher) {
        let rt = rt();

        let config = NodeConfig {
            node_id: "bench-rust-send-node".to_string(),
            listen_addr: "127.0.0.1:9016".to_string(),
            max_peers: 100,
            heartbeat_interval: Duration::from_secs(5),
            enable_encryption: false,
        };

        let node = rt.block_on(Node::new(config)).expect("Failed to create node");

        let message = b"Benchmark message";

        b.iter(|| {
            rt.block_on(async {
                node.broadcast_message(message).await.expect("Failed to send message");
            });
        });

        rt.block_on(node.close());
    }

    #[bench]
    fn bench_rust_crypto_encrypt(b: &mut test::Bencher) {
        let keypair = generate_keypair().expect("Failed to generate keypair");
        let plaintext = b"Benchmark crypto message";

        b.iter(|| {
            encrypt(&keypair.public_key, plaintext).expect("Failed to encrypt");
        });
    }

    #[bench]
    fn bench_rust_crypto_decrypt(b: &mut test::Bencher) {
        let keypair = generate_keypair().expect("Failed to generate keypair");
        let plaintext = b"Benchmark crypto message";
        let ciphertext = encrypt(&keypair.public_key, plaintext).expect("Failed to encrypt");

        b.iter(|| {
            decrypt(&keypair.private_key, &ciphertext).expect("Failed to decrypt");
        });
    }

    #[bench]
    fn bench_rust_flooding_protocol(b: &mut test::Bencher) {
        let rt = rt();

        let config = NodeConfig {
            node_id: "bench-rust-flood-node".to_string(),
            listen_addr: "127.0.0.1:9017".to_string(),
            max_peers: 50,
            heartbeat_interval: Duration::from_secs(5),
            enable_encryption: false,
        };

        let node = rt.block_on(Node::new(config)).expect("Failed to create node");
        let message = b"Flood benchmark message";

        b.iter(|| {
            rt.block_on(async {
                node.send_flood_message(message).await.expect("Failed to send flood message");
            });
        });

        rt.block_on(node.close());
    }

    #[bench]
    fn bench_rust_gossip_protocol(b: &mut test::Bencher) {
        let rt = rt();

        let config = NodeConfig {
            node_id: "bench-rust-gossip-node".to_string(),
            listen_addr: "127.0.0.1:9018".to_string(),
            max_peers: 50,
            heartbeat_interval: Duration::from_secs(5),
            enable_encryption: false,
        };

        let node = rt.block_on(Node::new(config)).expect("Failed to create node");
        let message = b"Gossip benchmark message";

        b.iter(|| {
            rt.block_on(async {
                node.send_gossip_message(message).await.expect("Failed to send gossip message");
            });
        });

        rt.block_on(node.close());
    }

    #[bench]
    fn bench_rust_consensus_protocol(b: &mut test::Bencher) {
        let rt = rt();

        let config = NodeConfig {
            node_id: "bench-rust-consensus-node".to_string(),
            listen_addr: "127.0.0.1:9019".to_string(),
            max_peers: 20,
            heartbeat_interval: Duration::from_secs(5),
            enable_encryption: false,
        };

        let node = rt.block_on(Node::new(config)).expect("Failed to create node");

        b.iter(|| {
            rt.block_on(async {
                node.start_consensus_round("bench-round").await.expect("Failed to start consensus");
            });
        });

        rt.block_on(node.close());
    }

    #[bench]
    fn bench_rust_full_mesh_simulation(b: &mut test::Bencher) {
        let rt = rt();

        b.iter(|| {
            rt.block_on(async {
                // Create multiple nodes
                let mut nodes = Vec::new();
                for i in 0..5 {
                    let config = NodeConfig {
                        node_id: format!("bench-node-{}", i),
                        listen_addr: format!("127.0.0.1:{}", 9020 + i),
                        max_peers: 10,
                        heartbeat_interval: Duration::from_secs(5),
                        enable_encryption: false,
                    };

                    let node = Node::new(config).await.expect("Failed to create node");
                    nodes.push(node);
                }

                // Connect nodes in a mesh
                for i in 0..nodes.len() {
                    for j in 0..nodes.len() {
                        if i != j {
                            let addr = format!("127.0.0.1:{}", 9020 + j);
                            let _ = nodes[i].connect_to_peer(addr).await;
                        }
                    }
                }

                // Send messages through the mesh
                let message = b"Mesh simulation message";
                for node in &nodes {
                    let _ = node.broadcast_message(message).await;
                }

                // Cleanup
                for node in nodes {
                    node.close().await;
                }
            });
        });
    }
}
