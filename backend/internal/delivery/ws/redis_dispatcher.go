package ws

import (
	"context"
	"encoding/json"
	"log"

	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
	"github.com/sakai/backend/internal/domain"
)

// The global channel name for broadcasting events across all API instances.
const pubsubChannel = "sakai:ws:events"

// globalEvent wraps an envelope with target routing information.
type globalEvent struct {
	TargetUserID *uuid.UUID `json:"target_user_id,omitempty"`
	RideID       *uuid.UUID `json:"ride_id,omitempty"` // If set, send to both passenger & driver
	Event        EventType  `json:"event"`
	Payload      any        `json:"payload"`
}

// RedisDispatcher acts as a scalable event bus across multiple backend instances.
// It publishes events to Redis and subscribes to Redis to forward them to the local Hub.
type RedisDispatcher struct {
	rdb *redis.Client
	hub *Hub
}

// NewRedisDispatcher creates a new pub/sub dispatcher.
func NewRedisDispatcher(rdb *redis.Client, hub *Hub) *RedisDispatcher {
	return &RedisDispatcher{
		rdb: rdb,
		hub: hub,
	}
}

// Run starts the Redis subscription loop. It blocks until ctx is canceled.
func (d *RedisDispatcher) Run(ctx context.Context) {
	sub := d.rdb.Subscribe(ctx, pubsubChannel)
	defer sub.Close()

	ch := sub.Channel()
	for {
		select {
		case <-ctx.Done():
			return
		case msg := <-ch:
			var ge globalEvent
			if err := json.Unmarshal([]byte(msg.Payload), &ge); err != nil {
				log.Printf("ws.RedisDispatcher: bad payload: %v", err)
				continue
			}
			d.routeLocally(&ge)
		}
	}
}

// routeLocally delivers an event from Redis to connections on *this* specific node.
func (d *RedisDispatcher) routeLocally(ge *globalEvent) {
	if ge.TargetUserID != nil {
		d.hub.SendToUser(*ge.TargetUserID, ge.Event, ge.Payload)
	} else if ge.RideID != nil {
		// If it's a ride-wide broadcast, we expect the payload to contain the Ride object (or at least IDs).
		// We'll peek into the payload to find passenger/driver IDs if available.
		// A cleaner approach used here: just let the local Hub try to send to both.
		b, _ := json.Marshal(ge.Payload)
		var ride domain.Ride
		if err := json.Unmarshal(b, &ride); err == nil {
			d.hub.BroadcastToRide(&ride, ge.Event, ge.Payload)
		}
	}
}

// PublishToUser sends an event to a specific user across the cluster.
func (d *RedisDispatcher) PublishToUser(ctx context.Context, userID uuid.UUID, event EventType, payload any) error {
	ge := globalEvent{
		TargetUserID: &userID,
		Event:        event,
		Payload:      payload,
	}
	b, err := json.Marshal(ge)
	if err != nil {
		return err
	}
	return d.rdb.Publish(ctx, pubsubChannel, string(b)).Err()
}

// PublishToRide sends an event to all participants of a ride across the cluster.
func (d *RedisDispatcher) PublishToRide(ctx context.Context, ride *domain.Ride, event EventType, payload any) error {
	ge := globalEvent{
		RideID:  &ride.ID,
		Event:   event,
		Payload: payload, // Usually the ride itself or a subset of it
	}
	b, err := json.Marshal(ge)
	if err != nil {
		return err
	}
	return d.rdb.Publish(ctx, pubsubChannel, string(b)).Err()
}
