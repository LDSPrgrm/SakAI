package ws

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestCheckOrigin_Allowlist(t *testing.T) {
	SetAllowedOrigins([]string{"https://app.sakai.ph"})
	check := upgrader.CheckOrigin

	mk := func(origin string) *http.Request {
		r := httptest.NewRequest(http.MethodGet, "/ws", nil)
		if origin != "" {
			r.Header.Set("Origin", origin)
		}
		return r
	}
	if !check(mk("https://app.sakai.ph")) {
		t.Fatal("allowed origin rejected")
	}
	if check(mk("https://evil.example")) {
		t.Fatal("untrusted origin accepted")
	}
	if !check(mk("")) {
		t.Fatal("no-Origin client rejected")
	}
}
