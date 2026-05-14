package displayid

import "testing"

func TestFormat(t *testing.T) {
	tests := []struct {
		name   string
		prefix string
		width  int
		seq    int64
		want   string
	}{
		{"low width pads to 4", "INC", 4, 42, "INC-0042"},
		{"low width edge 1", "USR", 4, 1, "USR-0001"},
		{"low width no truncation past width", "AUD", 4, 12345, "AUD-12345"},
		{"high width pads to 6", "RIDE", 6, 123, "RIDE-000123"},
		{"high width edge max-low", "TXN", 6, 9999, "TXN-009999"},
		{"zero seq returns empty", "INC", 4, 0, ""},
		{"negative seq returns empty", "INC", 4, -1, ""},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := Format(tt.prefix, tt.width, tt.seq); got != tt.want {
				t.Errorf("Format(%q, %d, %d) = %q, want %q", tt.prefix, tt.width, tt.seq, got, tt.want)
			}
		})
	}
}

func TestConvenienceWrappers(t *testing.T) {
	cases := map[string]string{
		Incident(7):    "INC-0007",
		Ride(7):        "RIDE-000007",
		User(7):        "USR-0007",
		Transaction(7): "TXN-000007",
		AuditLog(7):    "AUD-0007",
	}
	for got, want := range cases {
		if got != want {
			t.Errorf("got %q, want %q", got, want)
		}
	}
}
