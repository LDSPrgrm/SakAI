package ws

import (
	"context"
	"encoding/json"
	"errors"
	"sync"
	"time"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
)

// ErrReplayOutOfWindow is returned by ReplayStore.Range when the caller's
// last_event_id is not present in the store (either out of the TTL window,
// stored in a different pod's history, or simply never seen). The handler
// MUST fall back to emitting `ride.state_sync` with a server snapshot.
var ErrReplayOutOfWindow = errors.New("ws: last_event_id outside replay window")

// ReplayStore persists outbound envelopes per user so that a reconnecting
// client can request events missed during the disconnect. The wire-level
// retention is bounded by [ReplayMaxLen] and [ReplayTTL]; anything older
// must be reconstructed from the durable ride DB via `ride.state_sync`.
type ReplayStore interface {
	Append(ctx context.Context, userID uuid.UUID, env Envelope) error
	Range(ctx context.Context, userID uuid.UUID, lastEventID string) ([]Envelope, error)
}

// ReplayMaxLen bounds the per-user stream size; XADD MAXLEN ~N trims
// approximately to keep XADD O(1). Sized for ~30 minutes of an active ride
// at peak event density.
const ReplayMaxLen int64 = 1000

// ReplayTTL is the wall-clock retention of per-user streams. After this,
// Redis evicts the key entirely and reconnecting clients fall through to
// `ride.state_sync` regardless of their last_event_id.
const ReplayTTL = 24 * time.Hour

const replayKeyPrefix = "sakai:ws:stream:"

// RedisReplayStore backs ReplayStore with Redis Streams (XADD/XRANGE).
type RedisReplayStore struct {
	rdb *redis.Client
	ttl time.Duration
}

// NewRedisReplayStore builds a ReplayStore using the given client and a
// custom TTL (use [ReplayTTL] in production).
func NewRedisReplayStore(rdb *redis.Client, ttl time.Duration) *RedisReplayStore {
	if ttl <= 0 {
		ttl = ReplayTTL
	}
	return &RedisReplayStore{rdb: rdb, ttl: ttl}
}

// Append writes the envelope to the user's stream and refreshes the key
// TTL. Errors are non-fatal at the dispatcher boundary — the caller should
// log + emit a metric and continue.
func (s *RedisReplayStore) Append(ctx context.Context, userID uuid.UUID, env Envelope) error {
	key := replayKeyPrefix + userID.String()
	b, err := json.Marshal(env)
	if err != nil {
		return err
	}
	pipe := s.rdb.Pipeline()
	pipe.XAdd(ctx, &redis.XAddArgs{
		Stream: key,
		MaxLen: ReplayMaxLen,
		Approx: true,
		Values: map[string]interface{}{
			"env":      string(b),
			"event_id": env.EventID.String(),
		},
	})
	pipe.Expire(ctx, key, s.ttl)
	_, err = pipe.Exec(ctx)
	return err
}

// Range returns every envelope written AFTER the entry whose stored
// event_id matches lastEventID. If lastEventID is empty, returns the entire
// retained stream. If lastEventID is not found, returns [ErrReplayOutOfWindow]
// so the handler can fall back to a snapshot.
func (s *RedisReplayStore) Range(ctx context.Context, userID uuid.UUID, lastEventID string) ([]Envelope, error) {
	key := replayKeyPrefix + userID.String()
	entries, err := s.rdb.XRange(ctx, key, "-", "+").Result()
	if err != nil {
		return nil, err
	}
	return collectAfter(entries, lastEventID)
}

func collectAfter(entries []redis.XMessage, lastEventID string) ([]Envelope, error) {
	result := make([]Envelope, 0, len(entries))
	past := lastEventID == ""
	for _, entry := range entries {
		envJSON, _ := entry.Values["env"].(string)
		eventID, _ := entry.Values["event_id"].(string)
		if !past {
			if eventID == lastEventID {
				past = true
			}
			continue
		}
		var env Envelope
		if err := json.Unmarshal([]byte(envJSON), &env); err != nil {
			continue
		}
		result = append(result, env)
	}
	if !past && lastEventID != "" {
		return nil, ErrReplayOutOfWindow
	}
	return result, nil
}

// MemReplayStore is a goroutine-safe in-memory ReplayStore for tests.
// Production code MUST use [RedisReplayStore] for cross-pod replay.
type MemReplayStore struct {
	mu      sync.Mutex
	streams map[uuid.UUID][]Envelope
	maxLen  int
}

// NewMemReplayStore returns an in-memory store bounded by maxLen entries
// per user. Use 0 for unbounded (tests only).
func NewMemReplayStore(maxLen int) *MemReplayStore {
	return &MemReplayStore{
		streams: map[uuid.UUID][]Envelope{},
		maxLen:  maxLen,
	}
}

func (s *MemReplayStore) Append(_ context.Context, userID uuid.UUID, env Envelope) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	entries := append(s.streams[userID], env)
	if s.maxLen > 0 && len(entries) > s.maxLen {
		entries = entries[len(entries)-s.maxLen:]
	}
	s.streams[userID] = entries
	return nil
}

func (s *MemReplayStore) Range(_ context.Context, userID uuid.UUID, lastEventID string) ([]Envelope, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	entries := s.streams[userID]
	if lastEventID == "" {
		out := make([]Envelope, len(entries))
		copy(out, entries)
		return out, nil
	}
	past := false
	result := make([]Envelope, 0, len(entries))
	for _, env := range entries {
		if !past {
			if env.EventID.String() == lastEventID {
				past = true
			}
			continue
		}
		result = append(result, env)
	}
	if !past {
		return nil, ErrReplayOutOfWindow
	}
	return result, nil
}
