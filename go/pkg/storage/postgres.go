package storage

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"time"

	_ "github.com/lib/pq"
	"github.com/rechain-network/katya-mesh-go/pkg/protocol"
)

// PostgreSQLStorage provides PostgreSQL-based storage
type PostgreSQLStorage struct {
	db *sql.DB
}

// NewPostgreSQLStorage creates a new PostgreSQL storage instance
func NewPostgreSQLStorage(dsn string) (*PostgreSQLStorage, error) {
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, fmt.Errorf("failed to open database: %w", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := db.PingContext(ctx); err != nil {
		return nil, fmt.Errorf("failed to ping database: %w", err)
	}

	storage := &PostgreSQLStorage{db: db}

	// Initialize schema
	if err := storage.initSchema(ctx); err != nil {
		return nil, fmt.Errorf("failed to init schema: %w", err)
	}

	return storage, nil
}

// initSchema creates database tables
func (s *PostgreSQLStorage) initSchema(ctx context.Context) error {
	schema := `
	CREATE TABLE IF NOT EXISTS messages (
		id TEXT PRIMARY KEY,
		from_id TEXT NOT NULL,
		to_id TEXT NOT NULL,
		content TEXT NOT NULL,
		timestamp TIMESTAMP NOT NULL,
		ttl INTEGER DEFAULT 10,
		path TEXT[],
		priority TEXT DEFAULT 'normal',
		type TEXT,
		metadata JSONB
	);

	CREATE TABLE IF NOT EXISTS polls (
		id TEXT PRIMARY KEY,
		title TEXT NOT NULL,
		description TEXT,
		options TEXT[] NOT NULL,
		votes JSONB NOT NULL,
		creator_id TEXT NOT NULL,
		created_at TIMESTAMP NOT NULL,
		is_active BOOLEAN DEFAULT true,
		metadata JSONB
	);

	CREATE TABLE IF NOT EXISTS votes (
		id TEXT PRIMARY KEY,
		poll_id TEXT NOT NULL REFERENCES polls(id),
		user_id TEXT NOT NULL,
		option TEXT NOT NULL,
		timestamp TIMESTAMP NOT NULL,
		signature TEXT,
		public_key TEXT
	);

	CREATE INDEX IF NOT EXISTS idx_messages_from_id ON messages(from_id);
	CREATE INDEX IF NOT EXISTS idx_messages_to_id ON messages(to_id);
	CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp);
	CREATE INDEX IF NOT EXISTS idx_votes_poll_id ON votes(poll_id);
	CREATE INDEX IF NOT EXISTS idx_votes_user_id ON votes(user_id);
	`

	_, err := s.db.ExecContext(ctx, schema)
	return err
}

// SaveMessage saves a message
func (s *PostgreSQLStorage) SaveMessage(msg *protocol.Message) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	pathJSON, _ := json.Marshal(msg.Path)
	metadataJSON, _ := json.Marshal(msg.Metadata)

	query := `
	INSERT INTO messages (id, from_id, to_id, content, timestamp, ttl, path, priority, type, metadata)
	VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
	ON CONFLICT (id) DO UPDATE SET
		content = EXCLUDED.content,
		timestamp = EXCLUDED.timestamp,
		metadata = EXCLUDED.metadata
	`

	_, err := s.db.ExecContext(ctx, query,
		msg.ID, msg.FromID, msg.ToID, msg.Content,
		msg.Timestamp, msg.TTL, string(pathJSON),
		string(msg.Priority), msg.Type, string(metadataJSON))
	return err
}

// GetMessages returns all messages
func (s *PostgreSQLStorage) GetMessages(limit int) ([]protocol.Message, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if limit <= 0 {
		limit = 100
	}

	query := `
	SELECT id, from_id, to_id, content, timestamp, ttl, path, priority, type, metadata
	FROM messages
	ORDER BY timestamp DESC
	LIMIT $1
	`

	rows, err := s.db.QueryContext(ctx, query, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var messages []protocol.Message
	for rows.Next() {
		var msg protocol.Message
		var pathJSON, metadataJSON string
		var priorityStr string

		if err := rows.Scan(&msg.ID, &msg.FromID, &msg.ToID, &msg.Content,
			&msg.Timestamp, &msg.TTL, &pathJSON, &priorityStr,
			&msg.Type, &metadataJSON); err != nil {
			return nil, err
		}

		json.Unmarshal([]byte(pathJSON), &msg.Path)
		json.Unmarshal([]byte(metadataJSON), &msg.Metadata)
		msg.Priority = protocol.MessagePriority(priorityStr)

		messages = append(messages, msg)
	}

	return messages, rows.Err()
}

// SavePoll saves a poll
func (s *PostgreSQLStorage) SavePoll(poll *protocol.VotingPoll) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	optionsJSON, _ := json.Marshal(poll.Options)
	votesJSON, _ := json.Marshal(poll.Votes)
	metadataJSON, _ := json.Marshal(poll.Metadata)

	query := `
	INSERT INTO polls (id, title, description, options, votes, creator_id, created_at, is_active, metadata)
	VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
	ON CONFLICT (id) DO UPDATE SET
		title = EXCLUDED.title,
		description = EXCLUDED.description,
		options = EXCLUDED.options,
		votes = EXCLUDED.votes,
		is_active = EXCLUDED.is_active,
		metadata = EXCLUDED.metadata
	`

	_, err := s.db.ExecContext(ctx, query,
		poll.ID, poll.Title, poll.Description,
		string(optionsJSON), string(votesJSON),
		poll.CreatorID, poll.CreatedAt, poll.IsActive,
		string(metadataJSON))
	return err
}

// GetPoll retrieves a poll by ID
func (s *PostgreSQLStorage) GetPoll(pollID string) (*protocol.VotingPoll, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
	SELECT id, title, description, options, votes, creator_id, created_at, is_active, metadata
	FROM polls
	WHERE id = $1
	`

	var poll protocol.VotingPoll
	var optionsJSON, votesJSON, metadataJSON string

	err := s.db.QueryRowContext(ctx, query, pollID).Scan(
		&poll.ID, &poll.Title, &poll.Description,
		&optionsJSON, &votesJSON,
		&poll.CreatorID, &poll.CreatedAt, &poll.IsActive,
		&metadataJSON)

	if err == sql.ErrNoRows {
		return nil, fmt.Errorf("poll not found: %s", pollID)
	}
	if err != nil {
		return nil, err
	}

	json.Unmarshal([]byte(optionsJSON), &poll.Options)
	json.Unmarshal([]byte(votesJSON), &poll.Votes)
	json.Unmarshal([]byte(metadataJSON), &poll.Metadata)

	return &poll, nil
}

// GetAllPolls returns all polls
func (s *PostgreSQLStorage) GetAllPolls(activeOnly bool) ([]*protocol.VotingPoll, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
	SELECT id, title, description, options, votes, creator_id, created_at, is_active, metadata
	FROM polls
	`
	if activeOnly {
		query += "WHERE is_active = true"
	}
	query += " ORDER BY created_at DESC"

	rows, err := s.db.QueryContext(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var polls []*protocol.VotingPoll
	for rows.Next() {
		var poll protocol.VotingPoll
		var optionsJSON, votesJSON, metadataJSON string

		if err := rows.Scan(&poll.ID, &poll.Title, &poll.Description,
			&optionsJSON, &votesJSON,
			&poll.CreatorID, &poll.CreatedAt, &poll.IsActive,
			&metadataJSON); err != nil {
			return nil, err
		}

		json.Unmarshal([]byte(optionsJSON), &poll.Options)
		json.Unmarshal([]byte(votesJSON), &poll.Votes)
		json.Unmarshal([]byte(metadataJSON), &poll.Metadata)

		polls = append(polls, &poll)
	}

	return polls, rows.Err()
}

// SaveVote saves a vote
func (s *PostgreSQLStorage) SaveVote(vote *protocol.Vote) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
	INSERT INTO votes (id, poll_id, user_id, option, timestamp, signature, public_key)
	VALUES ($1, $2, $3, $4, $5, $6, $7)
	ON CONFLICT (id) DO NOTHING
	`

	_, err := s.db.ExecContext(ctx, query,
		vote.ID, vote.PollID, vote.UserID, vote.Option,
		vote.Timestamp, vote.Signature, vote.PublicKey)

	if err == nil {
		// Update poll vote count
		updateQuery := `
		UPDATE polls
		SET votes = jsonb_set(
			COALESCE(votes, '{}'::jsonb),
			ARRAY[$2],
			to_jsonb(COALESCE((votes->>$2)::int, 0) + 1)
		)
		WHERE id = $1
		`
		s.db.ExecContext(ctx, updateQuery, vote.PollID, vote.Option)
	}

	return err
}

// GetVotes returns votes for a poll
func (s *PostgreSQLStorage) GetVotes(pollID string) ([]*protocol.Vote, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	query := `
	SELECT id, poll_id, user_id, option, timestamp, signature, public_key
	FROM votes
	WHERE poll_id = $1
	ORDER BY timestamp DESC
	`

	rows, err := s.db.QueryContext(ctx, query, pollID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var votes []*protocol.Vote
	for rows.Next() {
		var vote protocol.Vote
		if err := rows.Scan(&vote.ID, &vote.PollID, &vote.UserID,
			&vote.Option, &vote.Timestamp, &vote.Signature, &vote.PublicKey); err != nil {
			return nil, err
		}
		votes = append(votes, &vote)
	}

	return votes, rows.Err()
}

// Close closes the database connection
func (s *PostgreSQLStorage) Close() error {
	return s.db.Close()
}

