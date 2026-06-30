package configs

import (
	"strings"
	"testing"
)

// panics reports whether validateJWTSecret panicked for the given inputs.
func panics(secret, appEnv string) (panicked bool) {
	defer func() {
		if r := recover(); r != nil {
			panicked = true
		}
	}()
	validateJWTSecret(secret, appEnv)
	return false
}

func TestValidateJWTSecret(t *testing.T) {
	strong := strings.Repeat("a", 40) // 40 chars, not denylisted

	cases := []struct {
		name      string
		secret    string
		appEnv    string
		wantPanic bool
	}{
		{"dev allows weak default", "change-me-in-production", "development", false},
		{"dev allows short", "x", "development", false},
		{"prod rejects sentinel", "change-me-in-production", "production", true},
		{"prod rejects committed long value", "change-me-in-production-use-a-long-random-string", "production", true},
		{"prod rejects short", "tooshort", "production", true},
		{"prod rejects empty", "", "production", true},
		{"prod accepts strong", strong, "production", false},
		{"unset env treated as non-dev, rejects weak", "change-me-in-production", "", true},
		{"unset env accepts strong", strong, "", false},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := panics(tc.secret, tc.appEnv); got != tc.wantPanic {
				t.Fatalf("validateJWTSecret(%q,%q): panic=%v want %v", tc.secret, tc.appEnv, got, tc.wantPanic)
			}
		})
	}
}
