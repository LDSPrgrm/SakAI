package main

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
)

// Phase 2 — rides + ride_payments + ratings + driver_payouts (+ lines).
//
// Layout: 6 completed, 1 in_progress, 1 accepted, 2 cancelled. Active-ride
// uniqueness (migration 006) requires the in_progress and accepted rides to
// use distinct passenger AND distinct driver from each other; completed and
// cancelled rides do not count as active.
//
// IDs:
//   20000003-...001..010   rides
//   20000004-...001..006   ride_payments (one per completed ride)
//   2000000F-...001..004   ratings (4 of the 6 completed rides)
//   20000005-...001        driver_payouts (single batch)
//   20000006-...001..003   driver_payout_lines (drivers 1-3)

type demoRide struct {
	id                  string
	passengerIdx        int    // 1..5 → passenger UUID 20000001-...00N
	driverIdx           int    // 1..5 → driver    UUID 20000002-...00N (0 = nil driver)
	status              string // requested|accepted|in_progress|completed|cancelled
	rideType            string // motorcycle|car|tricycle
	originLat, originLng float64
	destLat, destLng    float64
	originAddr, destAddr string
	estimatedFare       float64
	actualFare          float64 // 0 → NULL
	createdAgo          string  // SQL INTERVAL string for NOW() - INTERVAL ...
	cancelledBy         string  // passenger|driver|system, only for cancelled
	cancellationReason  string  // only for cancelled
}

// Metro Manila coordinates: Makati / BGC / QC / Manila / Pasig.
var demoRides = []demoRide{
	// 6 completed — backdated across 14 days for chart density
	{"20000003-0000-0000-0000-000000000001", 1, 1, "completed", "motorcycle",
		14.5547, 121.0244, 14.5511, 121.0467,
		"Ayala Triangle, Makati", "BGC High Street, Taguig",
		180.00, 180.00, "13 days", "", ""},
	{"20000003-0000-0000-0000-000000000002", 2, 2, "completed", "car",
		14.5511, 121.0467, 14.6760, 121.0437,
		"BGC High Street, Taguig", "UP Diliman, Quezon City",
		350.00, 350.00, "11 days", "", ""},
	{"20000003-0000-0000-0000-000000000003", 3, 3, "completed", "tricycle",
		14.6760, 121.0437, 14.5995, 120.9842,
		"Quezon City Hall", "Manila City Hall",
		120.00, 120.00, "9 days", "", ""},
	{"20000003-0000-0000-0000-000000000004", 4, 1, "completed", "motorcycle",
		14.5995, 120.9842, 14.5764, 121.0851,
		"Intramuros, Manila", "Ortigas Center, Pasig",
		200.00, 200.00, "7 days", "", ""},
	{"20000003-0000-0000-0000-000000000005", 5, 2, "completed", "car",
		14.5764, 121.0851, 14.5547, 121.0244,
		"Ortigas Center, Pasig", "Ayala Triangle, Makati",
		280.00, 280.00, "5 days", "", ""},
	{"20000003-0000-0000-0000-000000000006", 1, 3, "completed", "tricycle",
		14.5547, 121.0244, 14.6760, 121.0437,
		"Salcedo Village, Makati", "SM North EDSA, QC",
		150.00, 150.00, "3 days", "", ""},

	// 1 in_progress — distinct passenger AND driver (must satisfy mig 006)
	{"20000003-0000-0000-0000-000000000007", 2, 4, "in_progress", "car",
		14.5511, 121.0467, 14.5764, 121.0851,
		"BGC Bonifacio High Street", "Ortigas Center, Pasig",
		320.00, 0, "30 minutes", "", ""},

	// 1 accepted — distinct passenger AND driver from in_progress
	{"20000003-0000-0000-0000-000000000008", 3, 5, "accepted", "motorcycle",
		14.6760, 121.0437, 14.5547, 121.0244,
		"Eastwood City, QC", "Greenbelt, Makati",
		220.00, 0, "5 minutes", "", ""},

	// 2 cancelled
	{"20000003-0000-0000-0000-000000000009", 4, 0, "cancelled", "car",
		14.5764, 121.0851, 14.5995, 120.9842,
		"Capitol Commons, Pasig", "Binondo, Manila",
		260.00, 0, "8 days", "passenger", "Found another ride"},
	{"20000003-0000-0000-0000-000000000010", 5, 2, "cancelled", "car",
		14.5547, 121.0244, 14.5511, 121.0467,
		"Greenbelt, Makati", "BGC High Street, Taguig",
		180.00, 0, "2 days", "driver", "Vehicle issue"},
}

type demoPayment struct {
	id           string // 20000004-...
	rideIdx      int    // 0-based index into demoRides (must be completed)
	method       string // cash|card|gcash|paymaya
	amount       float64
}

// Six payments, one per completed ride, methods cycle.
var demoPayments = []demoPayment{
	{"20000004-0000-0000-0000-000000000001", 0, "gcash", 180.00},
	{"20000004-0000-0000-0000-000000000002", 1, "paymaya", 350.00},
	{"20000004-0000-0000-0000-000000000003", 2, "cash", 120.00},
	{"20000004-0000-0000-0000-000000000004", 3, "card", 200.00},
	{"20000004-0000-0000-0000-000000000005", 4, "gcash", 280.00},
	{"20000004-0000-0000-0000-000000000006", 5, "cash", 150.00},
}

type demoRating struct {
	id      string // 2000000F-...
	rideIdx int    // 0-based into demoRides
	stars   int    // 1..5
	feedback string
}

// 4 ratings on 4 of the 6 completed rides.
var demoRatings = []demoRating{
	{"2000000F-0000-0000-0000-000000000001", 0, 5, "Smooth ride, courteous driver."},
	{"2000000F-0000-0000-0000-000000000002", 1, 5, "On time, very professional."},
	{"2000000F-0000-0000-0000-000000000003", 2, 4, "Good driver, clean tricycle."},
	{"2000000F-0000-0000-0000-000000000004", 3, 3, "Took a longer route than expected."},
}

type demoPayoutLine struct {
	id        string
	driverIdx int // 1..5
	amount    float64
	rideCount int
}

const demoPayoutID = "20000005-0000-0000-0000-000000000001"

var demoPayoutLines = []demoPayoutLine{
	{"20000006-0000-0000-0000-000000000001", 1, 264.00, 2}, // D1: rides 1 + 4
	{"20000006-0000-0000-0000-000000000002", 2, 504.00, 2}, // D2: rides 2 + 5
	{"20000006-0000-0000-0000-000000000003", 3, 216.00, 2}, // D3: rides 3 + 6
}

func passengerIDFor(idx int) string {
	return fmt.Sprintf("20000001-0000-0000-0000-00000000000%d", idx)
}

func driverIDFor(idx int) string {
	return fmt.Sprintf("20000002-0000-0000-0000-00000000000%d", idx)
}

func seedPhase2Rides(ctx context.Context, tx pgx.Tx) error {
	// Precondition: Phase 1 must have run.
	var passengerCount, driverCount int
	if err := tx.QueryRow(ctx, `SELECT COUNT(*) FROM users WHERE id::text LIKE '20000001-%'`).Scan(&passengerCount); err != nil {
		return fmt.Errorf("count demo passengers: %w", err)
	}
	if err := tx.QueryRow(ctx, `SELECT COUNT(*) FROM users WHERE id::text LIKE '20000002-%'`).Scan(&driverCount); err != nil {
		return fmt.Errorf("count demo drivers: %w", err)
	}
	if passengerCount < 5 || driverCount < 5 {
		return fmt.Errorf("phase 2 requires phase 1 (users) — found %d passengers / %d drivers; run `./seed-admin -demo -demo-phases=users` first", passengerCount, driverCount)
	}

	// ─── Rides ────────────────────────────────────────────────────────────────
	// Backdated via NOW() - INTERVAL so re-runs (ON CONFLICT DO NOTHING) are
	// no-ops while first-run timestamps land in the chart window.
	for _, r := range demoRides {
		var driverID any // nullable for cancelled-before-accept
		if r.driverIdx > 0 {
			driverID = driverIDFor(r.driverIdx)
		} else {
			driverID = nil
		}

		var actualFare any
		if r.actualFare > 0 {
			actualFare = r.actualFare
		} else {
			actualFare = nil
		}

		var cancelledBy, cancellationReason, cancelledAtExpr any
		var acceptedAtExpr, startedAtExpr, completedAtExpr any

		switch r.status {
		case "completed":
			// accepted_at = created + 2m, started_at = +5m, completed_at = +25m
			acceptedAtExpr = sqlAfterCreate(r.createdAgo, "INTERVAL '2 minutes'")
			startedAtExpr = sqlAfterCreate(r.createdAgo, "INTERVAL '5 minutes'")
			completedAtExpr = sqlAfterCreate(r.createdAgo, "INTERVAL '25 minutes'")
		case "in_progress":
			acceptedAtExpr = sqlAfterCreate(r.createdAgo, "INTERVAL '2 minutes'")
			startedAtExpr = sqlAfterCreate(r.createdAgo, "INTERVAL '5 minutes'")
		case "accepted":
			acceptedAtExpr = sqlAfterCreate(r.createdAgo, "INTERVAL '1 minute'")
		case "cancelled":
			cancelledBy = r.cancelledBy
			cancellationReason = r.cancellationReason
			cancelledAtExpr = sqlAfterCreate(r.createdAgo, "INTERVAL '5 minutes'")
		}

		// We can't bind raw SQL fragments via parameters; rebuild the query
		// per-row with computed timestamp expressions inlined.
		query := buildRideInsert(acceptedAtExpr, startedAtExpr, completedAtExpr, cancelledAtExpr)
		if _, err := tx.Exec(ctx, query,
			r.id, passengerIDFor(r.passengerIdx), driverID, r.status, r.rideType,
			r.originLat, r.originLng, r.destLat, r.destLng,
			r.originAddr, r.destAddr,
			r.estimatedFare, actualFare,
			cancelledBy, cancellationReason,
			r.createdAgo,
		); err != nil {
			return fmt.Errorf("insert ride %s: %w", r.id, err)
		}
	}
	fmt.Printf("  ✅ %d rides (6 completed, 1 in_progress, 1 accepted, 2 cancelled)\n", len(demoRides))

	// ─── Ride payments ────────────────────────────────────────────────────────
	// Payment timeline: payment created right after ride completion (+26m),
	// processed shortly after (+28m). Ride completed_at is +25m past the
	// synthetic ride created_at, so these stay strictly after the ride.
	const insertPayment = `
		INSERT INTO ride_payments (
			id, ride_id, passenger_id, amount, currency, method, status, processed_at, created_at
		) VALUES (
			$1, $2, $3, $4, 'PHP', $5::payment_method, 'completed',
			NOW() - $6::interval + INTERVAL '28 minutes',
			NOW() - $6::interval + INTERVAL '26 minutes'
		)
		ON CONFLICT (id) DO NOTHING`

	for _, p := range demoPayments {
		ride := demoRides[p.rideIdx]
		if _, err := tx.Exec(ctx, insertPayment,
			p.id, ride.id, passengerIDFor(ride.passengerIdx), p.amount, p.method, ride.createdAgo,
		); err != nil {
			return fmt.Errorf("insert payment %s: %w", p.id, err)
		}
	}
	fmt.Printf("  ✅ %d ride_payments (PHP, mixed methods)\n", len(demoPayments))

	// ─── Ratings ──────────────────────────────────────────────────────────────
	// Rating left ~30m after ride completion (which is +25m past ride created).
	const insertRating = `
		INSERT INTO ratings (id, ride_id, rater_id, ratee_id, stars, feedback, created_at)
		VALUES ($1, $2, $3, $4, $5, $6, NOW() - $7::interval + INTERVAL '30 minutes')
		ON CONFLICT (id) DO NOTHING`

	for _, rt := range demoRatings {
		ride := demoRides[rt.rideIdx]
		if _, err := tx.Exec(ctx, insertRating,
			rt.id, ride.id,
			passengerIDFor(ride.passengerIdx),
			driverIDFor(ride.driverIdx),
			rt.stars, rt.feedback, ride.createdAgo,
		); err != nil {
			return fmt.Errorf("insert rating %s: %w", rt.id, err)
		}
	}
	fmt.Printf("  ✅ %d ratings (passenger → driver, %s)\n", len(demoRatings), "5,5,4,3 stars")

	// ─── Driver payout batch + lines ──────────────────────────────────────────
	var totalPayout float64
	for _, l := range demoPayoutLines {
		totalPayout += l.amount
	}

	const insertPayout = `
		INSERT INTO driver_payouts (
			id, batch, period_start, period_end, period_label,
			driver_count, total_amount, status, created_at, approved_at
		) VALUES (
			$1, $2, DATE '2026-04-21', DATE '2026-04-27', 'Apr 21–27 2026',
			$3, $4, 'paid', NOW() - INTERVAL '4 days', NOW() - INTERVAL '3 days'
		)
		ON CONFLICT (id) DO NOTHING`
	if _, err := tx.Exec(ctx, insertPayout,
		demoPayoutID, "DEMO-2026-W17", len(demoPayoutLines), totalPayout,
	); err != nil {
		return fmt.Errorf("insert driver_payout: %w", err)
	}

	const insertPayoutLine = `
		INSERT INTO driver_payout_lines (id, payout_id, driver_id, amount, ride_count, created_at)
		VALUES ($1, $2, $3, $4, $5, NOW() - INTERVAL '4 days')
		ON CONFLICT (id) DO NOTHING`
	for _, l := range demoPayoutLines {
		if _, err := tx.Exec(ctx, insertPayoutLine,
			l.id, demoPayoutID, driverIDFor(l.driverIdx), l.amount, l.rideCount,
		); err != nil {
			return fmt.Errorf("insert payout line %s: %w", l.id, err)
		}
	}
	fmt.Printf("  ✅ 1 driver_payout (paid, ₱%.2f) + %d lines\n", totalPayout, len(demoPayoutLines))

	return nil
}

// sqlAfterCreate returns a SQL expression of the form
// "NOW() - INTERVAL '<createdAgo>' + <postOffset>". The result is a moment
// `postOffset` after the synthetic created_at, which lands later in absolute
// time. Used for derived ride lifecycle timestamps.
func sqlAfterCreate(createdAgo, postOffset string) any {
	if createdAgo == "" && postOffset == "" {
		return nil
	}
	return fmt.Sprintf("NOW() - INTERVAL '%s' + %s", createdAgo, postOffset)
}

// buildRideInsert assembles the rides INSERT statement, inlining computed
// timestamp expressions where present and substituting NULL otherwise. We
// can't bind fragments like "NOW() - INTERVAL '5 minutes'" via $-args, so this
// function builds the literal SQL for each ride. Inputs are constants — no
// untrusted user input — so concatenation is safe here.
func buildRideInsert(acceptedAt, startedAt, completedAt, cancelledAt any) string {
	expr := func(v any) string {
		if v == nil {
			return "NULL"
		}
		return v.(string)
	}
	return fmt.Sprintf(`
		INSERT INTO rides (
			id, passenger_id, driver_id, status, ride_type,
			origin_lat, origin_lng, destination_lat, destination_lng,
			origin_address, destination_address,
			estimated_fare, actual_fare,
			cancelled_by, cancellation_reason, cancelled_at,
			accepted_at, started_at, completed_at,
			created_at, updated_at
		) VALUES (
			$1, $2, $3, $4::ride_status, $5,
			$6, $7, $8, $9,
			$10, $11,
			$12, $13,
			$14::cancelled_by, $15, %s,
			%s, %s, %s,
			NOW() - $16::interval, NOW() - $16::interval
		)
		ON CONFLICT (id) DO NOTHING`,
		expr(cancelledAt), expr(acceptedAt), expr(startedAt), expr(completedAt))
}
