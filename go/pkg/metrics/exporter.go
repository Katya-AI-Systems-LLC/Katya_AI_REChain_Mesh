package metrics

import (
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/rechain-network/katya-mesh-go/internal/mesh"
)

var (
	// Peer metrics
	peersTotal = promauto.NewGauge(prometheus.GaugeOpts{
		Name: "mesh_peers_total",
		Help: "Total number of discovered peers",
	})

	peersConnected = promauto.NewGauge(prometheus.GaugeOpts{
		Name: "mesh_peers_connected",
		Help: "Number of connected peers",
	})

	// Message metrics
	messagesInQueue = promauto.NewGauge(prometheus.GaugeOpts{
		Name: "mesh_messages_queue_size",
		Help: "Number of messages in queue",
	})

	messagesSentTotal = promauto.NewCounter(prometheus.CounterOpts{
		Name: "mesh_messages_sent_total",
		Help: "Total number of messages sent",
	})

	messagesDeliveredTotal = promauto.NewCounter(prometheus.CounterOpts{
		Name: "mesh_messages_delivered_total",
		Help: "Total number of messages delivered",
	})

	messagesFailedTotal = promauto.NewCounter(prometheus.CounterOpts{
		Name: "mesh_messages_failed_total",
		Help: "Total number of failed messages",
	})

	// Success rate
	successRate = promauto.NewGauge(prometheus.GaugeOpts{
		Name: "mesh_success_rate",
		Help: "Message delivery success rate",
	})

	// HTTP metrics
	httpRequestsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "mesh_http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"method", "endpoint", "status"},
	)

	httpRequestDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "mesh_http_request_duration_seconds",
			Help:    "HTTP request duration in seconds",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"method", "endpoint"},
	)
)

// UpdateStats updates Prometheus metrics from broker stats
func UpdateStats(stats *mesh.Stats) {
	peersTotal.Set(float64(stats.TotalPeers))
	peersConnected.Set(float64(stats.ConnectedPeers))
	messagesInQueue.Set(float64(stats.MessagesInQueue))
	successRate.Set(stats.SuccessRate)
}

// IncMessagesSent increments messages sent counter
func IncMessagesSent() {
	messagesSentTotal.Inc()
}

// IncMessagesDelivered increments messages delivered counter
func IncMessagesDelivered() {
	messagesDeliveredTotal.Inc()
}

// IncMessagesFailed increments messages failed counter
func IncMessagesFailed() {
	messagesFailedTotal.Inc()
}

// RecordHTTPRequest records HTTP request metrics
func RecordHTTPRequest(method, endpoint, status string, duration float64) {
	httpRequestsTotal.WithLabelValues(method, endpoint, status).Inc()
	httpRequestDuration.WithLabelValues(method, endpoint).Observe(duration)
}

