package main

import (
	"flag"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/rechain-network/katya-mesh-go/internal/mesh"
	"github.com/rechain-network/katya-mesh-go/pkg/api"
)

func main() {
	var (
		adapter = flag.String("adapter", "emulated", "Mesh adapter type")
		port    = flag.Int("port", 8080, "Broker service port")
	)
	flag.Parse()

	log.Println("Starting Katya Mesh Broker...")
	log.Printf("Adapter: %s, Port: %d", *adapter, *port)

	broker := mesh.NewBroker(*adapter)
	if err := broker.Start(); err != nil {
		log.Fatalf("Failed to start broker: %v", err)
	}

	// Start REST API server
	apiServer := api.NewServer(broker, *port)
	go func() {
		if err := apiServer.Start(); err != nil {
			log.Printf("API server error: %v", err)
		}
	}()

	log.Printf("Broker started successfully")
	log.Printf("REST API available at http://localhost:%d", *port)
	log.Printf("Health check: http://localhost:%d/health", *port)
	log.Println("Press Ctrl+C to stop")

	// Wait for interrupt signal
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
	<-sigChan

	log.Println("Stopping broker...")
	apiServer.Stop()
	broker.Stop()
	log.Println("Broker stopped")
}

