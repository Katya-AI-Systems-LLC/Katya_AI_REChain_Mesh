use katya_mesh::*;
use clap::{App, Arg, SubCommand};
use std::io::{self, Write};

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    init().await?;

    let matches = App::new("Katya Mesh CLI")
        .version(env!("CARGO_PKG_VERSION"))
        .author("Katya AI Team")
        .about("Command-line interface for Katya Mesh network")
        .subcommand(
            SubCommand::with_name("send")
                .about("Send a message")
                .arg(
                    Arg::with_name("to")
                        .short("t")
                        .long("to")
                        .value_name("NODE_ID")
                        .help("Recipient node ID (hex)")
                        .takes_value(true),
                )
                .arg(
                    Arg::with_name("message")
                        .short("m")
                        .long("message")
                        .value_name("MESSAGE")
                        .help("Message to send")
                        .takes_value(true)
                        .required(true),
                ),
        )
        .subcommand(
            SubCommand::with_name("broadcast")
                .about("Broadcast a message to all peers")
                .arg(
                    Arg::with_name("message")
                        .short("m")
                        .long("message")
                        .value_name("MESSAGE")
                        .help("Message to broadcast")
                        .takes_value(true)
                        .required(true),
                ),
        )
        .subcommand(
            SubCommand::with_name("peers")
                .about("List connected peers"),
        )
        .subcommand(
            SubCommand::with_name("stats")
                .about("Show network statistics"),
        )
        .subcommand(
            SubCommand::with_name("connect")
                .about("Connect to a peer")
                .arg(
                    Arg::with_name("address")
                        .short("a")
                        .long("address")
                        .value_name("ADDR")
                        .help("Peer address (IP:PORT)")
                        .takes_value(true)
                        .required(true),
                ),
        )
        .get_matches();

    match matches.subcommand() {
        ("send", Some(sub_matches)) => {
            let to_hex = sub_matches.value_of("to").unwrap_or("");
            let message_text = sub_matches.value_of("message").unwrap();

            if to_hex.is_empty() {
                eprintln!("Error: --to is required for send command");
                std::process::exit(1);
            }

            let to_node_id = NodeId::from_hex(to_hex)
                .map_err(|_| "Invalid node ID format")?;

            // Create a simple node for sending
            let config = NodeConfig::default();
            let node = create_node(config).await?;
            node.start().await?;

            let message = Message::unicast(node.node_id().clone(), to_node_id, message_text.as_bytes().to_vec());
            node.send_message(message).await?;

            println!("✅ Message sent successfully");
            node.stop().await?;
        }

        ("broadcast", Some(sub_matches)) => {
            let message_text = sub_matches.value_of("message").unwrap();

            // Create a simple node for broadcasting
            let config = NodeConfig::default();
            let node = create_node(config).await?;
            node.start().await?;

            let message = Message::broadcast(node.node_id().clone(), message_text.as_bytes().to_vec());
            node.send_message(message).await?;

            println!("📡 Message broadcasted successfully");
            node.stop().await?;
        }

        ("peers", Some(_)) => {
            // Create a simple node to check peers
            let config = NodeConfig::default();
            let node = create_node(config).await?;
            node.start().await?;

            // Give some time for peer discovery
            tokio::time::sleep(tokio::time::Duration::from_secs(2)).await;

            let peers = node.get_peers().await;
            if peers.is_empty() {
                println!("No peers connected");
            } else {
                println!("Connected peers:");
                for peer in peers {
                    println!("  {} - {} (last seen: {}s ago)",
                        peer.id,
                        peer.addresses.get(0).map(|a| a.to_string()).unwrap_or_else(|| "unknown".to_string()),
                        peer.last_seen
                    );
                }
            }

            node.stop().await?;
        }

        ("stats", Some(_)) => {
            // Create a simple node to get stats
            let config = NodeConfig::default();
            let node = create_node(config).await?;
            node.start().await?;

            let stats = node.get_stats().await;
            println!("📊 Network Statistics:");
            println!("  Messages sent: {}", stats.messages_sent);
            println!("  Messages received: {}", stats.messages_received);
            println!("  Bytes sent: {}", stats.bytes_sent);
            println!("  Bytes received: {}", stats.bytes_received);
            println!("  Connected peers: {}", stats.peers_connected);
            println!("  Discovered peers: {}", stats.peers_discovered);
            println!("  Uptime: {} seconds", stats.uptime_seconds);

            node.stop().await?;
        }

        ("connect", Some(sub_matches)) => {
            let address_str = sub_matches.value_of("address").unwrap();
            let address: std::net::SocketAddr = address_str.parse()
                .map_err(|_| "Invalid address format")?;

            // Create a simple node for connecting
            let config = NodeConfig::default();
            let node = create_node(config).await?;
            node.start().await?;

            let peer = Peer::new(NodeId::new(), address);
            match node.add_peer(peer).await {
                Ok(_) => println!("✅ Connected to peer at {}", address),
                Err(e) => eprintln!("❌ Failed to connect: {}", e),
            }

            node.stop().await?;
        }

        _ => {
            eprintln!("No subcommand provided. Use --help for usage information.");
            std::process::exit(1);
        }
    }

    Ok(())
}
