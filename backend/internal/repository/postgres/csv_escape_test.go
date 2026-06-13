package postgres

import "testing"

func TestEscapeCSVCell(t *testing.T) {
	cases := map[string]string{
		"=cmd()":  "'=cmd()",
		"+1":      "'+1",
		"-1":      "'-1",
		"@SUM(A)": "'@SUM(A)",
		"normal":  "normal",
		"":        "",
	}
	for in, want := range cases {
		if got := escapeCSVCell(in); got != want {
			t.Fatalf("escapeCSVCell(%q)=%q want %q", in, got, want)
		}
	}
}
