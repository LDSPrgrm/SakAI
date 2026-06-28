// Package corrid carries the request correlation ID through context.
//
// Every HTTP request entering the API is tagged with a `corr_id` — either
// extracted from the inbound X-Correlation-ID header or freshly minted as a
// UUIDv4 by the Gin middleware. The same ID is propagated downstream:
//
//   - HTTP response header (`X-Correlation-ID`) so callers can correlate
//     their client logs with our server logs.
//   - context.Context (via FromContext / WithCorrID) so any code path
//     reachable from the request handler can read it.
//   - Outbound WebSocket envelopes (RFC v2 §4.3 / §12.4) — the WS dispatcher
//     reads the value from the same context and stamps Envelope.CorrID on
//     publish, so a UI event can be traced back to the API call that
//     produced it.
//
// Keeping the helpers in a tiny standalone package avoids an import cycle
// between the `middleware` package (Gin entry point) and the `ws` package
// (envelope stamping).
package corrid

import (
	"context"

	"github.com/google/uuid"
)

// HeaderName is the canonical inbound/outbound HTTP header name for the
// correlation ID. Matches the convention used by upstream proxies and most
// observability stacks (Datadog, Honeycomb, OTLP).
const HeaderName = "X-Correlation-ID"

type ctxKey struct{}

// New returns a fresh UUIDv4 string suitable for use as a correlation ID.
// Kept here (rather than at call sites) so the format stays consistent — the
// audit pipeline and downstream WS payloads rely on a parseable shape.
func New() string {
	return uuid.NewString()
}

// WithCorrID returns a new context carrying id. id="" is a no-op so callers
// can safely chain even when the upstream context already had no value.
func WithCorrID(ctx context.Context, id string) context.Context {
	if id == "" {
		return ctx
	}
	return context.WithValue(ctx, ctxKey{}, id)
}

// FromContext extracts the correlation ID from ctx. Returns "" when ctx
// carries no value (e.g. background goroutines, tests) — callers should
// treat that as "no correlation available" and skip stamping rather than
// fabricate one.
func FromContext(ctx context.Context) string {
	if ctx == nil {
		return ""
	}
	v, _ := ctx.Value(ctxKey{}).(string)
	return v
}
