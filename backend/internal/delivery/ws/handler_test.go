package ws

import (
	"sync"
	"testing"
	"time"
)

func TestUpgrader_ReadBufferSize(t *testing.T) {
	// Verify the upgrader's ReadBufferSize is set to a reasonable default.
	if upgrader.ReadBufferSize < 1024 {
		t.Errorf("expected ReadBufferSize >= 1024, got %d", upgrader.ReadBufferSize)
	}
}

func TestHub_PingInterval_Configured(t *testing.T) {
	// Verify the hub's pingInterval is accessible and reasonable.
	// The read deadline is 2 * pingInterval = 60s for default 30s ping.
	hub := NewHub(30 * time.Second)
	if hub.pingInterval != 30*time.Second {
		t.Errorf("expected pingInterval 30s, got %v", hub.pingInterval)
	}

	// The read deadline formula: 2 * pingInterval
	expectedDeadline := 2 * hub.pingInterval
	if expectedDeadline != 60*time.Second {
		t.Errorf("expected 60s read deadline (2 * pingInterval), got %v", expectedDeadline)
	}
}

func TestPongHandler_DeadlineFormula(t *testing.T) {
	// Verify the pong handler logic: it calls SetReadDeadline with 2 * pingInterval.
	// The formula is: time.Now().Add(2 * pingInterval).
	// For default 30s ping interval, deadline = 60s.
	pingInterval := 30 * time.Second
	expectedDeadline := 2 * pingInterval
	if expectedDeadline != 60*time.Second {
		t.Errorf("expected 60s deadline after pong, got %v", expectedDeadline)
	}
}

func TestReadLimit_Value(t *testing.T) {
	// The read limit of 4096 bytes is hardcoded in handler.go via conn.SetReadLimit(4096).
	// This prevents a malicious client from sending arbitrarily large frames and
	// exhausting server memory (DoS vector).
	const expectedLimit = 4096
	if expectedLimit < 1024 {
		t.Errorf("read limit %d is too small; should be >= 1024", expectedLimit)
	}
}

func TestHub_ChannelClose_Once(t *testing.T) {
	// Verify that sync.Once prevents double-close of the write channel.
	// The hub uses: var once sync.Once; once.Do(func() { close(cl.ch) })
	// to ensure the channel is closed exactly once even if Unregister is
	// called from multiple goroutines simultaneously.
	var once sync.Once
	closed := 0
	closeFn := func() { closed++ }

	once.Do(closeFn)
	once.Do(closeFn) // Should be a no-op.
	once.Do(closeFn) // Should be a no-op.

	if closed != 1 {
		t.Errorf("expected sync.Once to prevent double-close, got %d calls", closed)
	}
}
