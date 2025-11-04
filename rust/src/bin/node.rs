use katya_mesh::*;
use std::net::{IpAddr, Ipv4Addr, SocketAddr};
use clap::{App, Arg};
use tokio::signal;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize logging
    init().await?;

    // Parse command line arguments
    let matches = App::new("Katya Mesh Node")
        .version(env!("CARGO_PKG_VERSION"))
        .author("Katya AI Team")
        .about("High-performance mesh networking node")
        .arg(
            Arg::with_name("listen-addr")
                .short("l")
                .long("listen-addr")
                .value_name("ADDR")
                .help("Listen address (default: 0.0.0.0:0)")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("protocol")
                .short("p")
                .long("protocol")
                .value_name("PROTOCOL")
                .help("Protocol to use: flooding, gossip, consensus (default: gossip)")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("max-peers")
                .long("max-peers")
                .value_name("NUM")
                .help("Maximum number of peers (default: 100)")
                .takes_value(true),
        )
        .arg(
            Arg::with_name("enable-encryption")
                .long("enable-encryption")
                .help("Enable message encryption"),
        )
        .arg(
            Arg::with_name("node-id")
                .long("node-id")
                .value_name("ID")
                .help("Node ID (hex string, auto-generated if not provided)")
                .takes_value(true),
        )
        .get_matches();

    // Parse listen address
    let listen_addr_str = matches.value_of("listen-addr").unwrap_or("0.0.0.0:0");
    let listen_addr: SocketAddr = listen_addr_str.parse()?;

    // Parse protocol
    let protocol_str = matches.value_of("protocol").unwrap_or("gossip");
    let protocol = match protocol_str {
        "flooding" => ProtocolType::Flooding,
        "gossip" => ProtocolType::Gossip,
        "consensus" => ProtocolType::Consensus,
        _ => {
            eprintln!("Invalid protocol: {}", protocol_str);
            std::process::exit(1);
        }
    };

    // Parse max peers
    let max_peers = matches
        .value_of("max-peers")
        .unwrap_or("100")
        .parse::<usize>()?;

    // Parse node ID
    let node_id = if let Some(id_str) = matches.value_of("node-id") {
        NodeId::from_hex(id_str).map_err(|_| "Invalid node ID format")?
    } else {
        NodeId::new()
    };

    // Parse encryption
    let enable_encryption = matches.is_present("enable-encryption");

    // Create node configuration
    let config = NodeConfig {
        node_id,
        listen_addr,
        max_peers,
        heartbeat_interval: 30,
        protocol,
        enable_encryption,
        enable_compression: false,
    };

    // Create and start node
    let node = create_node(config).await?;
    node.start().await?;

    println!("🚀 Katya Mesh Node started!");
    println!("   Node ID: {}", node.node_id());
    println!("   Listen Address: {}", node.config().listen_addr);
    println!("   Protocol: {:?}", node.config().protocol);
    println!("   Encryption: {}", if node.config().enable_encryption { "enabled" } else { "disabled" });
    println!();
    println!("Press Ctrl+C to stop...");

    // Wait for shutdown signal
    signal::ctrl_c().await?;
    println!("\n🛑 Shutting down...");

    node.stop().await?;

    // Print final stats
    let stats = node.get_stats().await;
    println!("📊 Final Statistics:");
    println!("   Messages sent: {}", stats.messages_sent);
    println!("   Messages received: {}", stats.messages_received);
    println!("   Bytes sent: {}", stats.bytes_sent);
    println!("   Bytes received: {}", stats.bytes_received);
    println!("   Connected peers: {}", stats.peers_connected);
    println!("   Uptime: {} seconds", stats.uptime_seconds);

    Ok(())
}
