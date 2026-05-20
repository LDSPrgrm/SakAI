package ws

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
	"github.com/redis/go-redis/v9"
)

// pod models a single backend instance: its own Hub + an httptest server
// that registers WS connections against that Hub. All pods share a Redis
// instance via NewRedisDispatcher and subscribe to the same pubsub channel.
type pod struct {
	hub        *Hub
	dispatcher *RedisDispatcher
	server     *httptest.Server
	stop       context.CancelFunc
	wsURL      string
}

// newPod stands up a backend instance wired to rdb. The dispatcher's
// Run loop receives every published envelope so the local hub fans it
// out to whichever user is connected here (or no-ops if not).
func newPod(t *testing.T, rdb *redis.Client) *pod {
	t.Helper()
	hub := NewHub(30 * time.Second)
	store := NewRedisReplayStore(rdb, time.Minute)
	dispatcher := NewRedisDispatcher(rdb, hub).WithReplayStore(store)
	handler := NewHandler(hub).WithReplayStore(store)

	ctx, cancel := context.WithCancel(context.Background())
	go dispatcher.Run(ctx)

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		userIDStr := r.Header.Get("X-User-ID")
		userID, err := uuid.Parse(userIDStr)
		if err != nil {
			http.Error(w, "bad user", http.StatusBadRequest)
			return
		}
		conn, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			return
		}
		hub.Register(userID, conn, conn.Subprotocol())
		go func() {
			defer hub.Unregister(userID)
			for {
				msgType, raw, err := conn.ReadMessage()
				if err != nil {
					return
				}
				if msgType != websocket.TextMessage {
					continue
				}
				handler.handleInbound(userID, raw)
			}
		}()
	}))

	u, _ := url.Parse(srv.URL)
	wsURL := strings.Replace(u.String(), "http", "ws", 1)
	return &pod{
		hub:        hub,
		dispatcher: dispatcher,
		server:     srv,
		stop:       cancel,
		wsURL:      wsURL,
	}
}

func (p *pod) close() {
	p.stop()
	p.server.Close()
}

func dialPod(t *testing.T, p *pod, userID uuid.UUID) *websocket.Conn {
	t.Helper()
	dialer := *websocket.DefaultDialer
	dialer.Subprotocols = []string{SubprotocolV2}
	header := http.Header{"X-User-ID": []string{userID.String()}}
	c, _, err := dialer.Dial(p.wsURL, header)
	if err != nil {
		t.Fatalf("dial: %v", err)
	}
	time.Sleep(40 * time.Millisecond)
	return c
}

func readEnvFrom(t *testing.T, c *websocket.Conn, d time.Duration) Envelope {
	t.Helper()
	c.SetReadDeadline(time.Now().Add(d))
	_, raw, err := c.ReadMessage()
	if err != nil {
		t.Fatalf("read: %v", err)
	}
	var env Envelope
	if err := json.Unmarshal(raw, &env); err != nil {
		t.Fatalf("unmarshal: %v", err)
	}
	return env
}

// TestMultiPodChaos_KillOnePodFanoutSurvives stands up three pods sharing a
// Redis bus. A client connected to pod[2] receives events published from
// pod[0]. We then kill pod[2] (the one the user is on) and reconnect to
// pod[1]; the user must recover the events published during the cutover
// via replay.request.
func TestMultiPodChaos_KillOnePodFanoutSurvives(t *testing.T) {
	_, rdb := newMiniRedis(t)

	pods := []*pod{newPod(t, rdb), newPod(t, rdb), newPod(t, rdb)}
	defer func() {
		for _, p := range pods {
			p.close()
		}
	}()

	userID := uuid.New()
	conn := dialPod(t, pods[2], userID)

	// Cross-pod publish: client lives on pods[2], publisher is pods[0].
	// Redis pubsub fans to all three; pods[2] writes to the wire, the other
	// two no-op because the user isn't registered locally.
	env1 := NewEnvelope(EventRideStatusChanged, map[string]any{"step": 1})
	if err := pods[0].dispatcher.PublishToUser(context.Background(), userID, env1.Event, env1.Payload); err != nil {
		t.Fatalf("publish 1: %v", err)
	}
	got1 := readEnvFrom(t, conn, 2*time.Second)
	cursor := got1.EventID.String()

	// Kill pods[2] — the one the user is on. Server close terminates the
	// connection; the client now needs to reconnect somewhere else.
	_ = conn.Close()
	pods[2].close()
	pods = pods[:2]

	// During the cutover, pods[0] publishes another event. With the user
	// disconnected, nothing reaches the wire — the event survives only in
	// the replay store.
	env2 := NewEnvelope(EventRideStatusChanged, map[string]any{"step": 2})
	if err := pods[0].dispatcher.PublishToUser(context.Background(), userID, env2.Event, env2.Payload); err != nil {
		t.Fatalf("publish 2: %v", err)
	}

	// Reconnect to pods[1]. Replay.request with the cursor must drain the
	// envelope that was published while disconnected.
	conn2 := dialPod(t, pods[1], userID)
	defer conn2.Close()
	sendInbound(t, conn2, map[string]any{
		"type":          "replay.request",
		"last_event_id": cursor,
	})
	got2 := readEnvFrom(t, conn2, 2*time.Second)
	if got2.Event != EventRideStatusChanged {
		t.Fatalf("post-cutover event = %q, want %q", got2.Event, EventRideStatusChanged)
	}
}

// TestMultiPodChaos_PublishFromAnyPodReachesUser sanity-checks that publish
// is location-independent: regardless of which pod issues PublishToUser,
// the envelope reaches the user on whichever pod they happen to be on.
func TestMultiPodChaos_PublishFromAnyPodReachesUser(t *testing.T) {
	_, rdb := newMiniRedis(t)
	pods := []*pod{newPod(t, rdb), newPod(t, rdb), newPod(t, rdb)}
	defer func() {
		for _, p := range pods {
			p.close()
		}
	}()

	userID := uuid.New()
	conn := dialPod(t, pods[0], userID)
	defer conn.Close()

	for i, publisher := range pods {
		if err := publisher.dispatcher.PublishToUser(
			context.Background(),
			userID,
			EventRideStatusChanged,
			map[string]any{"from_pod": i},
		); err != nil {
			t.Fatalf("publish from pod[%d]: %v", i, err)
		}
		env := readEnvFrom(t, conn, 2*time.Second)
		payload, _ := env.Payload.(map[string]any)
		got, _ := payload["from_pod"].(float64)
		if int(got) != i {
			t.Errorf("pod[%d] publish landed as from_pod=%v", i, got)
		}
	}
}
