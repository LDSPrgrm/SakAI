package corrid_test

import (
	"context"
	"testing"

	"github.com/sakai/backend/internal/observability/corrid"
)

func TestFromContext_empty(t *testing.T) {
	if got := corrid.FromContext(context.Background()); got != "" {
		t.Fatalf("FromContext on bare ctx = %q, want empty", got)
	}
	if got := corrid.FromContext(nil); got != "" { //nolint:staticcheck // explicit nil ctx path
		t.Fatalf("FromContext(nil) = %q, want empty", got)
	}
}

func TestWithCorrID_roundtrip(t *testing.T) {
	ctx := corrid.WithCorrID(context.Background(), "abc-123")
	if got := corrid.FromContext(ctx); got != "abc-123" {
		t.Fatalf("FromContext = %q, want abc-123", got)
	}
}

func TestWithCorrID_emptyIsNoop(t *testing.T) {
	ctx := corrid.WithCorrID(context.Background(), "")
	if got := corrid.FromContext(ctx); got != "" {
		t.Fatalf("FromContext after empty WithCorrID = %q, want empty", got)
	}
}

func TestNew_unique(t *testing.T) {
	a := corrid.New()
	b := corrid.New()
	if a == "" || b == "" {
		t.Fatal("New() returned empty string")
	}
	if a == b {
		t.Fatalf("New() returned duplicate value %q", a)
	}
}
