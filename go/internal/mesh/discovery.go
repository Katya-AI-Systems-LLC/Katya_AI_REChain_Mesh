package mesh

import (
	"fmt"
	"log"
	"net"
	"time"
)

// UDPDiscovery implements UDP multicast peer discovery
type UDPDiscovery struct {
	multicastAddr *net.UDPAddr
	conn          *net.UDPConn
	localID       string
	isRunning     bool
	peers         map[string]*UDPPeer
	onPeerFound   func(*UDPPeer)
}

// UDPPeer represents a peer discovered via UDP
type UDPPeer struct {
	ID        string
	Address   string
	Port      int
	LastSeen  time.Time
}

// NewUDPDiscovery creates a new UDP discovery instance
func NewUDPDiscovery(localID string) (*UDPDiscovery, error) {
	addr, err := net.ResolveUDPAddr("udp4", "224.0.0.251:5353")
	if err != nil {
		return nil, fmt.Errorf("failed to resolve multicast address: %w", err)
	}

	return &UDPDiscovery{
		multicastAddr: addr,
		localID:       localID,
		peers:         make(map[string]*UDPPeer),
	}, nil
}

// Start starts UDP discovery
func (d *UDPDiscovery) Start() error {
	if d.isRunning {
		return fmt.Errorf("discovery already running")
	}

	conn, err := net.ListenMulticastUDP("udp4", nil, d.multicastAddr)
	if err != nil {
		return fmt.Errorf("failed to listen multicast: %w", err)
	}

	d.conn = conn
	d.isRunning = true

	// Start listening for peers
	go d.listen()
	// Start advertising
	go d.advertise()

	log.Println("UDP discovery started")
	return nil
}

// Stop stops UDP discovery
func (d *UDPDiscovery) Stop() {
	if !d.isRunning {
		return
	}

	d.isRunning = false
	if d.conn != nil {
		d.conn.Close()
	}

	log.Println("UDP discovery stopped")
}

// SetOnPeerFound sets callback for peer discovery
func (d *UDPDiscovery) SetOnPeerFound(callback func(*UDPPeer)) {
	d.onPeerFound = callback
}

// GetPeers returns discovered peers
func (d *UDPDiscovery) GetPeers() []*UDPPeer {
	peers := make([]*UDPPeer, 0, len(d.peers))
	for _, peer := range d.peers {
		peers = append(peers, peer)
	}
	return peers
}

// listen listens for peer announcements
func (d *UDPDiscovery) listen() {
	buffer := make([]byte, 1024)

	for d.isRunning {
		n, src, err := d.conn.ReadFromUDP(buffer)
		if err != nil {
			if d.isRunning {
				log.Printf("UDP read error: %v", err)
			}
			continue
		}

		// Parse peer announcement
		data := string(buffer[:n])
		if len(data) > 0 && data != d.localID {
			peer := &UDPPeer{
				ID:       data,
				Address:  src.IP.String(),
				Port:     src.Port,
				LastSeen: time.Now(),
			}

			if _, exists := d.peers[peer.ID]; !exists {
				d.peers[peer.ID] = peer
				log.Printf("Discovered UDP peer: %s at %s:%d", peer.ID, peer.Address, peer.Port)
				if d.onPeerFound != nil {
					d.onPeerFound(peer)
				}
			} else {
				d.peers[peer.ID].LastSeen = time.Now()
			}
		}
	}
}

// advertise announces this peer periodically
func (d *UDPDiscovery) advertise() {
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()

	for range ticker.C {
		if !d.isRunning {
			return
		}

		// Send announcement
		_, err := d.conn.WriteToUDP([]byte(d.localID), d.multicastAddr)
		if err != nil {
			log.Printf("UDP write error: %v", err)
		}
	}
}

