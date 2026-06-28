// ws-replay is an operator tool that streams a user's historical WebSocket
// envelopes out of Redis Streams to stdout or — when --ws is given — into a
// live WebSocket endpoint. Per RFC §16.6 it exists so an oncall engineer
// can rehydrate a stuck client without producing new app traffic.
//
// Typical use:
//
//	ws-replay --user 9f… --since 0
//	ws-replay --user 9f… --ws ws://localhost:8080/ws --token "$JWT"
//
// The tool is read-only against Redis and additive against the WS endpoint;
// it never deletes the source stream nor publishes back to the pubsub bus.
package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/google/uuid"
	"github.com/gorilla/websocket"
	"github.com/joho/godotenv"
	"github.com/redis/go-redis/v9"

	"github.com/sakai/backend/configs"
	"github.com/sakai/backend/internal/delivery/ws"
)

func main() {
	userFlag := flag.String("user", "", "Recipient user UUID whose stream to replay (required)")
	sinceFlag := flag.String("since", "", "Skip envelopes up to and including this event_id (default: replay everything in window)")
	wsFlag := flag.String("ws", "", "Optional ws:// or wss:// endpoint to forward envelopes into (one TextMessage per envelope)")
	tokenFlag := flag.String("token", "", "Bearer token to send on the WS upgrade request (Authorization header)")
	dryRunFlag := flag.Bool("dry-run", false, "Print envelopes to stdout even when --ws is set; do NOT dial the endpoint")
	paceFlag := flag.Duration("pace", 0, "Sleep between envelopes; useful when replaying into a live client to avoid burst delivery")

	flag.Parse()

	if *userFlag == "" {
		fmt.Fprintln(os.Stderr, "ws-replay: --user is required")
		flag.Usage()
		os.Exit(2)
	}
	uid, err := uuid.Parse(*userFlag)
	if err != nil {
		log.Fatalf("ws-replay: --user: %v", err)
	}

	_ = godotenv.Load("../../.env")
	_ = godotenv.Load()
	cfg := configs.Load()

	opts, err := redis.ParseURL(cfg.RedisURL)
	if err != nil {
		log.Fatalf("ws-replay: parse REDIS_URL: %v", err)
	}
	rdb := redis.NewClient(opts)
	defer rdb.Close()

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	store := ws.NewRedisReplayStore(rdb, ws.ReplayTTL)
	envs, err := store.Range(ctx, uid, *sinceFlag)
	if err != nil {
		log.Fatalf("ws-replay: load stream: %v", err)
	}
	if len(envs) == 0 {
		fmt.Fprintln(os.Stderr, "ws-replay: no envelopes after cursor — nothing to replay")
		return
	}

	if *wsFlag == "" || *dryRunFlag {
		writeStdout(envs)
		if *wsFlag != "" && *dryRunFlag {
			fmt.Fprintln(os.Stderr, "ws-replay: --dry-run set, not forwarding to", *wsFlag)
		}
		return
	}

	if err := forwardToWS(*wsFlag, *tokenFlag, envs, *paceFlag); err != nil {
		log.Fatalf("ws-replay: forward to ws: %v", err)
	}
	fmt.Fprintf(os.Stderr, "ws-replay: forwarded %d envelopes to %s\n", len(envs), *wsFlag)
}

func writeStdout(envs []ws.Envelope) {
	enc := json.NewEncoder(os.Stdout)
	for _, env := range envs {
		_ = enc.Encode(env)
	}
}

// forwardToWS dials the target endpoint with the v2 subprotocol and the
// caller-provided bearer token, then pushes each envelope verbatim. The
// optional `pace` lets the operator throttle delivery so client-side UIs
// don't burst-animate every transition in one frame.
func forwardToWS(endpoint, token string, envs []ws.Envelope, pace time.Duration) error {
	dialer := *websocket.DefaultDialer
	dialer.Subprotocols = []string{ws.SubprotocolV2}
	header := http.Header{}
	if token != "" {
		header.Set("Authorization", "Bearer "+token)
	}
	conn, _, err := dialer.Dial(endpoint, header)
	if err != nil {
		return fmt.Errorf("dial: %w", err)
	}
	defer conn.Close()
	for _, env := range envs {
		b, err := json.Marshal(env)
		if err != nil {
			return fmt.Errorf("marshal: %w", err)
		}
		if err := conn.WriteMessage(websocket.TextMessage, b); err != nil {
			return fmt.Errorf("write: %w", err)
		}
		if pace > 0 {
			time.Sleep(pace)
		}
	}
	return nil
}
