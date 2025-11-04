package cache

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/go-redis/redis/v8"
	"github.com/rechain-network/katya-mesh-go/pkg/protocol"
)

// RedisCache provides Redis-based caching and pub/sub
type RedisCache struct {
	client  *redis.Client
	ctx     context.Context
	channel string
}

// NewRedisCache creates a new Redis cache instance
func NewRedisCache(addr, password string, db int, channel string) (*RedisCache, error) {
	client := redis.NewClient(&redis.Options{
		Addr:     addr,
		Password: password,
		DB:       db,
	})

	ctx := context.Background()

	// Test connection
	if err := client.Ping(ctx).Err(); err != nil {
		return nil, fmt.Errorf("failed to connect to Redis: %w", err)
	}

	return &RedisCache{
		client:  client,
		ctx:     ctx,
		channel: channel,
	}, nil
}

// SetMessage caches a message
func (r *RedisCache) SetMessage(msg *protocol.Message, ttl time.Duration) error {
	data, err := json.Marshal(msg)
	if err != nil {
		return err
	}

	key := fmt.Sprintf("message:%s", msg.ID)
	return r.client.Set(r.ctx, key, data, ttl).Err()
}

// GetMessage retrieves a cached message
func (r *RedisCache) GetMessage(id string) (*protocol.Message, error) {
	key := fmt.Sprintf("message:%s", id)
	data, err := r.client.Get(r.ctx, key).Bytes()
	if err == redis.Nil {
		return nil, fmt.Errorf("message not found: %s", id)
	}
	if err != nil {
		return nil, err
	}

	var msg protocol.Message
	if err := json.Unmarshal(data, &msg); err != nil {
		return nil, err
	}

	return &msg, nil
}

// PublishMessage publishes a message to Redis pub/sub
func (r *RedisCache) PublishMessage(msg *protocol.Message) error {
	data, err := json.Marshal(msg)
	if err != nil {
		return err
	}

	return r.client.Publish(r.ctx, r.channel, data).Err()
}

// SubscribeMessages subscribes to message updates
func (r *RedisCache) SubscribeMessages() (<-chan *protocol.Message, error) {
	pubsub := r.client.Subscribe(r.ctx, r.channel)
	ch := pubsub.Channel()

	msgChan := make(chan *protocol.Message, 100)

	go func() {
		defer close(msgChan)
		for redisMsg := range ch {
			var msg protocol.Message
			if err := json.Unmarshal([]byte(redisMsg.Payload), &msg); err == nil {
				msgChan <- &msg
			}
		}
	}()

	return msgChan, nil
}

// SetPoll caches a poll
func (r *RedisCache) SetPoll(poll *protocol.VotingPoll, ttl time.Duration) error {
	data, err := json.Marshal(poll)
	if err != nil {
		return err
	}

	key := fmt.Sprintf("poll:%s", poll.ID)
	return r.client.Set(r.ctx, key, data, ttl).Err()
}

// GetPoll retrieves a cached poll
func (r *RedisCache) GetPoll(id string) (*protocol.VotingPoll, error) {
	key := fmt.Sprintf("poll:%s", id)
	data, err := r.client.Get(r.ctx, key).Bytes()
	if err == redis.Nil {
		return nil, fmt.Errorf("poll not found: %s", id)
	}
	if err != nil {
		return nil, err
	}

	var poll protocol.VotingPoll
	if err := json.Unmarshal(data, &poll); err != nil {
		return nil, err
	}

	return &poll, nil
}

// PublishPoll publishes a poll update
func (r *RedisCache) PublishPoll(poll *protocol.VotingPoll) error {
	data, err := json.Marshal(poll)
	if err != nil {
		return err
	}

	return r.client.Publish(r.ctx, fmt.Sprintf("%s:polls", r.channel), data).Err()
}

// SetPeer caches peer information
func (r *RedisCache) SetPeer(peerID string, data map[string]interface{}, ttl time.Duration) error {
	key := fmt.Sprintf("peer:%s", peerID)
	jsonData, err := json.Marshal(data)
	if err != nil {
		return err
	}

	return r.client.Set(r.ctx, key, jsonData, ttl).Err()
}

// GetPeer retrieves cached peer information
func (r *RedisCache) GetPeer(peerID string) (map[string]interface{}, error) {
	key := fmt.Sprintf("peer:%s", peerID)
	data, err := r.client.Get(r.ctx, key).Bytes()
	if err == redis.Nil {
		return nil, fmt.Errorf("peer not found: %s", peerID)
	}
	if err != nil {
		return nil, err
	}

	var result map[string]interface{}
	if err := json.Unmarshal(data, &result); err != nil {
		return nil, err
	}

	return result, nil
}

// IncrementCounter increments a counter
func (r *RedisCache) IncrementCounter(key string) (int64, error) {
	return r.client.Incr(r.ctx, key).Result()
}

// GetCounter retrieves a counter value
func (r *RedisCache) GetCounter(key string) (int64, error) {
	val, err := r.client.Get(r.ctx, key).Int64()
	if err == redis.Nil {
		return 0, nil
	}
	return val, err
}

// Close closes the Redis connection
func (r *RedisCache) Close() error {
	return r.client.Close()
}

