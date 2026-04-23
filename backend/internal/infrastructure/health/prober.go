// Package health implements a background worker that periodically probes
// critical platform dependencies (database, Redis, WebSocket hub) and writes
// the results to the system_health_probes table. The SystemHealth admin page
// reads the latest row per service + 24h uptime from that table instead of the
// previously hard-coded values in system_repo.go.
package health

import (
	"context"
	"log"
	"sync"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/redis/go-redis/v9"
	"github.com/sakai/backend/internal/domain"
)

// HubSizer exposes the current WebSocket connection count. ws.Hub implements it.
type HubSizer interface {
	Size() int
}

// Prober periodically probes each registered dependency and records the result
// via domain.SystemRepository.RecordProbe.
type Prober struct {
	repo     domain.SystemRepository
	pool     *pgxpool.Pool
	rdb      *redis.Client
	hub      HubSizer
	interval time.Duration
	timeout  time.Duration
}

// New builds a Prober. interval <= 0 defaults to 30s.
func New(repo domain.SystemRepository, pool *pgxpool.Pool, rdb *redis.Client, hub HubSizer, interval time.Duration) *Prober {
	if interval <= 0 {
		interval = 30 * time.Second
	}
	return &Prober{
		repo:     repo,
		pool:     pool,
		rdb:      rdb,
		hub:      hub,
		interval: interval,
		timeout:  3 * time.Second,
	}
}

// Run starts the probe loop until ctx is cancelled. One immediate probe runs
// at startup so the dashboard has data without waiting for the first tick.
func (p *Prober) Run(ctx context.Context) {
	log.Printf("health-prober: worker started (interval=%s)", p.interval)
	p.tick(ctx)

	t := time.NewTicker(p.interval)
	defer t.Stop()
	for {
		select {
		case <-ctx.Done():
			log.Println("health-prober: worker stopped")
			return
		case <-t.C:
			p.tick(ctx)
		}
	}
}

func (p *Prober) tick(ctx context.Context) {
	var wg sync.WaitGroup
	probes := []struct {
		name string
		run  func(context.Context) error
	}{
		{"database", p.probeDB},
		{"redis", p.probeRedis},
		{"websocket", p.probeHub},
	}

	for _, pr := range probes {
		pr := pr
		wg.Add(1)
		go func() {
			defer wg.Done()
			pctx, cancel := context.WithTimeout(ctx, p.timeout)
			defer cancel()
			start := time.Now()
			err := pr.run(pctx)
			latency := int(time.Since(start).Milliseconds())
			// The SystemHealth dashboard shows live WebSocket connection count
			// from probe rows. Overwrite the latency dimension for the websocket
			// probe with the hub size — it's effectively a gauge, not latency.
			if pr.name == "websocket" && p.hub != nil && err == nil {
				latency = p.hub.Size()
			}
			status, msg := classify(err)
			if recErr := p.repo.RecordProbe(ctx, pr.name, status, latency, msg); recErr != nil {
				log.Printf("health-prober: record %s: %v", pr.name, recErr)
			}
		}()
	}
	wg.Wait()
}

func (p *Prober) probeDB(ctx context.Context) error {
	if p.pool == nil {
		return errNotConfigured
	}
	return p.pool.Ping(ctx)
}

func (p *Prober) probeRedis(ctx context.Context) error {
	if p.rdb == nil {
		return errNotConfigured
	}
	return p.rdb.Ping(ctx).Err()
}

// probeHub is synthetic: the hub is in-process, so "down" means the caller
// forgot to pass one. Returns nil when the hub is configured.
func (p *Prober) probeHub(_ context.Context) error {
	if p.hub == nil {
		return errNotConfigured
	}
	return nil
}

type staticErr string

func (e staticErr) Error() string { return string(e) }

const errNotConfigured staticErr = "not configured"

func classify(err error) (string, string) {
	if err == nil {
		return "ok", ""
	}
	if err == errNotConfigured {
		return "down", err.Error()
	}
	return "down", err.Error()
}
