// Package displayid renders Postgres-assigned `seq` numbers as the
// human-readable references shown in the admin UI (e.g. INC-0042,
// RIDE-000123).
//
// Width is per-entity policy: low-volume tables use 4 digits;
// high-volume tables (rides, transactions) use 6 to delay rollover.
package displayid

import "fmt"

const (
	PrefixIncident    = "INC"
	PrefixRide        = "RIDE"
	PrefixUser        = "USR"
	PrefixTransaction = "TXN"
	PrefixAuditLog    = "AUD"

	WidthLow  = 4
	WidthHigh = 6
)

// Format renders prefix + zero-padded seq, e.g. Format("INC", 4, 42) → "INC-0042".
// Returns an empty string when seq is non-positive (caller decides whether to
// surface a placeholder).
func Format(prefix string, width int, seq int64) string {
	if seq <= 0 {
		return ""
	}
	return fmt.Sprintf("%s-%0*d", prefix, width, seq)
}

// Convenience wrappers so call sites stay terse and the prefix/width policy
// has a single source of truth.

func Incident(seq int64) string    { return Format(PrefixIncident, WidthLow, seq) }
func Ride(seq int64) string        { return Format(PrefixRide, WidthHigh, seq) }
func User(seq int64) string        { return Format(PrefixUser, WidthLow, seq) }
func Transaction(seq int64) string { return Format(PrefixTransaction, WidthHigh, seq) }
func AuditLog(seq int64) string    { return Format(PrefixAuditLog, WidthLow, seq) }
