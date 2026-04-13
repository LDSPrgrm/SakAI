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

// RideEventPayload is the canonical payload shape for ride-scoped WebSocket events.
// It avoids serializing the full domain.Ride over the bus and ensures all consumers
// receive the same minimal set of fields.
type RideEventPayload struct {
	RideID       uuid.UUID  `json:"ride_id"`
	Status       string     `json:"status"`
	DriverID     *uuid.UUID `json:"driver_id,omitempty"`
	PassengerID  uuid.UUID  `json:"passenger_id"`
}

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
		// Deserialize into the canonical ride event payload.
		b, _ := json.Marshal(ge.Payload)
		var p RideEventPayload
		if err := json.Unmarshal(b, &p); err != nil {
			log.Printf("ws.RedisDispatcher: bad ride payload: %v", err)
			return
		}
		// Build a minimal Ride struct just for BroadcastToRide.
		ride := &struct {
			ID         uuid.UUID
			PassengerID uuid.UUID
			DriverID   *uuid.UUID
		}{
			ID:         p.RideID,
			PassengerID: p.PassengerID,
			DriverID:   p.DriverID,
		}
		d.hub.BroadcastToRideByIDs(ride.ID, ride.PassengerID, ride.DriverID, ge.Event, ge.Payload)
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
// The payload is normalized to a RideEventPayload for consistent serialization.
func (d *RedisDispatcher) PublishToRide(ctx context.Context, ride *domain.Ride, event EventType, payload any) error {
	// Merge incoming payload into a canonical RideEventPayload.
	// If the caller already passed a map, merge its keys; otherwise start fresh.
	base := RideEventPayload{
		RideID:      ride.ID,
		Status:      string(ride.Status),
		DriverID:    ride.DriverID,
		PassengerID: ride.PassengerID,
	}
	ge := globalEvent{
		RideID:  &ride.ID,
		Event:   event,
		Payload: base,
	}
	// Preserve any extra fields the caller attached to the original payload.
	if extra, ok := payload.(map[string]any); ok {
		m := map[string]any{
			"ride_id":      base.RideID,
			"status":       base.Status,
			"passenger_id": base.PassengerID,
		}
		if base.DriverID != nil {
			m["driver_id"] = *base.DriverID
		}
		for k, v := range extra {
			m[k] = v
		}
		ge.Payload = m
	}
	b, err := json.Marshal(ge)
	if err != nil {
		return err
	}
	return d.rdb.Publish(ctx, pubsubChannel, string(b)).Err()
}
