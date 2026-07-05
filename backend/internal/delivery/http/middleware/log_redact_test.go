package middleware

import "testing"

func TestRedactQueryToken(t *testing.T) {
	cases := []struct{ in, want string }{
		{"/api/ws?token=eyJhbGciOi.abc.def", "/api/ws?token=%5BREDACTED%5D"},
		{"/api/ws?foo=1&token=xyz&bar=2", "/api/ws?foo=1&token=%5BREDACTED%5D&bar=2"},
		{"/api/health", "/api/health"},
		{"/api/rides?page=2", "/api/rides?page=2"},
	}
	for _, c := range cases {
		if got := RedactQueryToken(c.in); got != c.want {
			t.Errorf("RedactQueryToken(%q) = %q, want %q", c.in, got, c.want)
		}
	}
}
