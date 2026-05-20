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
	RideID      uuid.UUID  `json:"ride_id"`
	Status      string     `json:"status"`
	DriverID    *uuid.UUID `json:"driver_id,omitempty"`
	PassengerID uuid.UUID  `json:"passenger_id"`
}

// globalEvent wraps an Envelope with target routing information.
//
// The Envelope is stamped once by the publishing node (timestamp +
// UUIDv7 event_id) and forwarded verbatim by every subscribing node —
// clients can dedupe by event_id without coordination.
//
// During the v1.2 → v1.3 rolling deploy, old nodes publish the legacy
// flat shape `{event, payload, target_user_id?, ride_id?}` with no
// nested envelope. [UnmarshalJSON] reconstructs an Envelope from the
// legacy fields so subscribing new nodes don't drop those messages.
// Drop the legacy branch after the cluster is fully on v1.3+.
type globalEvent struct {
	TargetUserID *uuid.UUID `json:"target_user_id,omitempty"`
	RideID       *uuid.UUID `json:"ride_id,omitempty"`
	Envelope     Envelope   `json:"envelope"`
}

// UnmarshalJSON accepts both the v1.3 nested shape AND the v1.2 flat
// shape. Required for backward-compat during rolling deploys.
func (g *globalEvent) UnmarshalJSON(b []byte) error {
	type alias globalEvent
	var a alias
	if err := json.Unmarshal(b, &a); err != nil {
		return err
	}

	// If the nested envelope is empty (legacy shape), reconstruct it from
	// the top-level legacy fields.
	if a.Envelope.Event == "" {
		var legacy struct {
			Event   EventType `json:"event"`
			Payload any       `json:"payload"`
		}
		if err := json.Unmarshal(b, &legacy); err != nil {
			return err
		}
		a.Envelope = Envelope{
			Event:   legacy.Event,
			Payload: legacy.Payload,
			// Timestamp / EventID stay zero — legacy publishers didn't set them.
		}
	}

	*g = globalEvent(a)
	return nil
}

// RedisDispatcher acts as a scalable event bus across multiple backend instances.
// It publishes events to Redis and subscribes to Redis to forward them to the local Hub.
//
// When a ReplayStore is attached (via [RedisDispatcher.WithReplayStore]), every
// publish is mirrored to a per-recipient durable stream so that a reconnecting
// client can request the events it missed during the disconnect.
//
// When an AuditWriter is attached (via [RedisDispatcher.WithAuditWriter]),
// every publish appends a PII-safe row to the long-term audit store.
type RedisDispatcher struct {
	rdb         *redis.Client
	hub         *Hub
	replayStore ReplayStore
	auditWriter AuditWriter
}

// NewRedisDispatcher creates a new pub/sub dispatcher.
func NewRedisDispatcher(rdb *redis.Client, hub *Hub) *RedisDispatcher {
	return &RedisDispatcher{
		rdb: rdb,
		hub: hub,
	}
}

// WithReplayStore attaches a ReplayStore so PublishTo* also durably records
// envelopes for replay. nil disables replay (default).
func (d *RedisDispatcher) WithReplayStore(store ReplayStore) *RedisDispatcher {
	d.replayStore = store
	return d
}

// ReplayStore returns the attached store (nil if none).
func (d *RedisDispatcher) ReplayStore() ReplayStore { return d.replayStore }

// appendReplay best-effort writes the envelope to the recipient's stream.
// Errors are logged but never propagated — replay failures must not break
// real-time delivery.
func (d *RedisDispatcher) appendReplay(ctx context.Context, userID uuid.UUID, env Envelope) {
	if d.replayStore == nil {
		return
	}
	if err := d.replayStore.Append(ctx, userID, env); err != nil {
		log.Printf("ws: replay append failed for user %s: %v", userID, err)
	}
}

// WithAuditWriter attaches an [AuditWriter]. Each PublishTo* writes one
// audit row per envelope (the envelope itself, not per-recipient).
func (d *RedisDispatcher) WithAuditWriter(w AuditWriter) *RedisDispatcher {
	d.auditWriter = w
	return d
}

// writeAudit best-effort persists an AuditEvent. Logged + non-fatal.
func (d *RedisDispatcher) writeAudit(ctx context.Context, ev AuditEvent) {
	if d.auditWriter == nil {
		return
	}
	if err := d.auditWriter.Write(ctx, ev); err != nil {
		log.Printf("ws: audit write failed event=%s id=%s: %v", ev.EventType, ev.EventID, err)
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
// The Envelope inside the globalEvent is forwarded as-is so timestamp + event_id
// stay stable across the cluster.
func (d *RedisDispatcher) routeLocally(ge *globalEvent) {
	switch {
	case ge.TargetUserID != nil:
		d.hub.sendEnvelope(*ge.TargetUserID, ge.Envelope)

	case ge.RideID != nil:
		// Extract passenger/driver IDs from the canonical ride payload so we
		// can fan out to both recipients without consulting the database.
		passengerID, driverID, ok := extractRideRecipients(ge.Envelope.Payload)
		if !ok {
			log.Printf("ws.RedisDispatcher: ride payload missing routing fields: %+v", ge.Envelope.Payload)
			metrics.IncInvalid(ge.Envelope.Event, "missing_routing_fields")
			return
		}
		d.hub.sendEnvelope(passengerID, ge.Envelope)
		if driverID != nil {
			d.hub.sendEnvelope(*driverID, ge.Envelope)
		}
	}
}

// extractRideRecipients pulls passenger_id and driver_id (optional) from a
// ride-scoped payload. Tolerates both RideEventPayload structs and the
// `map[string]any` form callers historically used.
func extractRideRecipients(payload any) (passengerID uuid.UUID, driverID *uuid.UUID, ok bool) {
	b, err := json.Marshal(payload)
	if err != nil {
		return uuid.Nil, nil, false
	}
	var p RideEventPayload
	if err := json.Unmarshal(b, &p); err != nil {
		return uuid.Nil, nil, false
	}
	if p.PassengerID == uuid.Nil {
		return uuid.Nil, nil, false
	}
	return p.PassengerID, p.DriverID, true
}

// PublishToUser sends an event to a specific user across the cluster.
func (d *RedisDispatcher) PublishToUser(ctx context.Context, userID uuid.UUID, event EventType, payload any) error {
	env := NewEnvelope(event, payload)
	d.appendReplay(ctx, userID, env)
	d.writeAudit(ctx, EnvelopeAuditEvent(env, &userID, nil))
	ge := globalEvent{
		TargetUserID: &userID,
		Envelope:     env,
	}
	b, err := json.Marshal(ge)
	if err != nil {
		return err
	}
	if pubErr := d.rdb.Publish(ctx, pubsubChannel, string(b)).Err(); pubErr != nil {
		RedisPublishError()
		return pubErr
	}
	return nil
}

// PublishToRide sends an event to all participants of a ride across the cluster.
// The payload is normalized to a RideEventPayload for consistent serialization;
// extra fields from `gin.H` callers are preserved as map keys.
func (d *RedisDispatcher) PublishToRide(ctx context.Context, ride *domain.Ride, event EventType, payload any) error {
	base := RideEventPayload{
		RideID:      ride.ID,
		Status:      string(ride.Status),
		DriverID:    ride.DriverID,
		PassengerID: ride.PassengerID,
	}
	var canonical any = base
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
		canonical = m
	}
	env := NewEnvelope(event, canonical)
	d.appendReplay(ctx, ride.PassengerID, env)
	if ride.DriverID != nil {
		d.appendReplay(ctx, *ride.DriverID, env)
	}
	d.writeAudit(ctx, EnvelopeAuditEvent(env, nil, &ride.ID))
	ge := globalEvent{
		RideID:   &ride.ID,
		Envelope: env,
	}
	b, err := json.Marshal(ge)
	if err != nil {
		return err
	}
	if pubErr := d.rdb.Publish(ctx, pubsubChannel, string(b)).Err(); pubErr != nil {
		RedisPublishError()
		return pubErr
	}
	return nil
}
