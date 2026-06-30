package main

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
)

// Phase 3 — incidents + kyc_submissions + driver_documents.
//
// Layout:
//   20000007-...001..005  incidents (5 rows)
//   20000008-...001..005  kyc_submissions (5 rows, one per driver 1..5)
//   20000009-...001..00F  driver_documents (15 rows, 3 per driver)
//
// Preconditions: Phase 1 (drivers 1..5) + Phase 2 (completed rides 1..6) seeded,
// and superadmin@sakai.com exists (acts as kyc reviewer + audit actor).
//
// The migration-021 trigger auto-inserts an incident_status_history row on
// incident insert, so the SOS timeline renders without manual history rows.
// We deliberately do NOT update incidents post-insert: each incident lands at
// its "final" status with one timeline entry — adequate for demo render.

type demoIncident struct {
	id             string
	rideIdx        int    // 0-based index into demoRides; must be a completed ride
	triggeredBy    string // 'rider' | 'driver'
	incidentType   string // 'sos_triggered' | 'reported_incident' | 'safety_complaint'
	status         string // 'open' | 'investigating' | 'resolved' | 'escalated'
	resolution     string // populated when status='resolved'
	createdAgo     string // SQL INTERVAL for backdating
	resolvedOffset string // INTERVAL after created_at for resolved_at; empty → NULL
}

// 5 incidents per plan: 2 sos (1 open, 1 resolved), 2 safety_complaint
// (open, investigating), 1 reported_incident (escalated).
var demoIncidents = []demoIncident{
	{"20000007-0000-0000-0000-000000000001", 0, "rider", "sos_triggered", "open",
		"", "12 days", ""},
	{"20000007-0000-0000-0000-000000000002", 1, "rider", "sos_triggered", "resolved",
		"False alarm — rider phone slipped in pocket. Confirmed safe by phone callback.",
		"10 days", "INTERVAL '45 minutes'"},
	{"20000007-0000-0000-0000-000000000003", 2, "rider", "safety_complaint", "open",
		"", "6 days", ""},
	{"20000007-0000-0000-0000-000000000004", 3, "driver", "safety_complaint", "investigating",
		"", "4 days", ""},
	{"20000007-0000-0000-0000-000000000005", 4, "rider", "reported_incident", "escalated",
		"", "2 days", ""},
}

type demoKYC struct {
	id               string
	driverIdx        int    // 1..5
	status           string // pending|approved|rejected|needs_more_info
	rejectionReason  string
	notes            string
	submittedAgo     string // INTERVAL
	reviewedOffset   string // INTERVAL after submitted_at; empty → NULL reviewed_at + reviewed_by
}

var demoKYCs = []demoKYC{
	{"20000008-0000-0000-0000-000000000001", 1, "pending", "", "",
		"5 days", ""},
	{"20000008-0000-0000-0000-000000000002", 2, "pending", "", "",
		"3 days", ""},
	{"20000008-0000-0000-0000-000000000003", 3, "approved", "",
		"All documents verified against LTFRB registry.",
		"14 days", "INTERVAL '2 days'"},
	{"20000008-0000-0000-0000-000000000004", 4, "rejected",
		"License image blurred; registration expired.", "",
		"8 days", "INTERVAL '1 day'"},
	{"20000008-0000-0000-0000-000000000005", 5, "needs_more_info", "",
		"Insurance certificate missing policy number — please re-upload.",
		"6 days", "INTERVAL '12 hours'"},
}

type demoDocument struct {
	id              string
	driverIdx       int    // 1..5 → links to demoKYCs[driverIdx-1].id via submission_id
	docType         string // license|registration|insurance
	docNumber       string
	expiry          string // YYYY-MM-DD or empty for NULL
	uploadStatus    string // uploaded|under_review|approved|rejected
	rejectionReason string
	uploadedAgo     string // INTERVAL — must match parent KYC submitted_at
}

// Status alignment per plan:
//   driver 1 (kyc pending)         → uploaded
//   driver 2 (kyc pending)         → uploaded
//   driver 3 (kyc approved)        → approved
//   driver 4 (kyc rejected)        → rejected   (reason set)
//   driver 5 (kyc needs_more_info) → under_review
//
// Document numbers are realistic-looking PH license / OR-CR / insurance ids.
// Unique index `idx_documents_driver_type_unique` allows multiple non-rejected
// rows only if they're different document_types — which they are (license,
// registration, insurance per driver). Driver 4 rows are all 'rejected' so the
// partial index does not conflict.
var demoDocuments = []demoDocument{
	// Driver 1 — pending
	{"20000009-0000-0000-0000-000000000001", 1, "license", "N01-12-345678", "2028-06-15", "uploaded", "", "5 days"},
	{"20000009-0000-0000-0000-000000000002", 1, "registration", "OR-1234567-CR", "2027-03-01", "uploaded", "", "5 days"},
	{"20000009-0000-0000-0000-000000000003", 1, "insurance", "MAPFRE-PH-998877", "2027-01-20", "uploaded", "", "5 days"},

	// Driver 2 — pending
	{"20000009-0000-0000-0000-000000000004", 2, "license", "N02-15-223344", "2029-09-30", "uploaded", "", "3 days"},
	{"20000009-0000-0000-0000-000000000005", 2, "registration", "OR-7654321-CR", "2026-11-12", "uploaded", "", "3 days"},
	{"20000009-0000-0000-0000-000000000006", 2, "insurance", "PRUDENTIAL-PH-554433", "2027-08-08", "uploaded", "", "3 days"},

	// Driver 3 — approved
	{"20000009-0000-0000-0000-000000000007", 3, "license", "N03-09-887766", "2028-12-25", "approved", "", "14 days"},
	{"20000009-0000-0000-0000-000000000008", 3, "registration", "OR-2468013-CR", "2027-07-04", "approved", "", "14 days"},
	{"20000009-0000-0000-0000-000000000009", 3, "insurance", "STANDARD-PH-112233", "2027-05-15", "approved", "", "14 days"},

	// Driver 4 — rejected
	{"20000009-0000-0000-0000-00000000000a", 4, "license", "N04-21-665544", "2027-02-10", "rejected", "Image blurred; please re-upload at higher resolution.", "8 days"},
	{"20000009-0000-0000-0000-00000000000b", 4, "registration", "OR-1357924-CR", "2025-12-01", "rejected", "Registration expired Dec 2025; renew with LTO before resubmitting.", "8 days"},
	{"20000009-0000-0000-0000-00000000000c", 4, "insurance", "BPI-MS-PH-778899", "2027-04-22", "rejected", "Policy holder name does not match license.", "8 days"},

	// Driver 5 — needs_more_info
	{"20000009-0000-0000-0000-00000000000d", 5, "license", "N05-18-334455", "2028-03-18", "under_review", "", "6 days"},
	{"20000009-0000-0000-0000-00000000000e", 5, "registration", "OR-8642097-CR", "2027-09-10", "under_review", "", "6 days"},
	{"20000009-0000-0000-0000-00000000000f", 5, "insurance", "FPG-PH-665544", "", "under_review", "", "6 days"},
}

func seedPhase3Safety(ctx context.Context, tx pgx.Tx) error {
	// Precondition: Phase 1 drivers + Phase 2 rides must exist.
	var driverCount, completedRideCount int
	if err := tx.QueryRow(ctx, `SELECT COUNT(*) FROM users WHERE id::text LIKE '20000002-%'`).Scan(&driverCount); err != nil {
		return fmt.Errorf("count demo drivers: %w", err)
	}
	if err := tx.QueryRow(ctx, `SELECT COUNT(*) FROM rides WHERE id::text LIKE '20000003-%' AND status='completed'`).Scan(&completedRideCount); err != nil {
		return fmt.Errorf("count completed demo rides: %w", err)
	}
	if driverCount < 5 {
		return fmt.Errorf("phase 3 requires phase 1 (users) — found %d demo drivers; run `./seed-admin -demo -demo-phases=users` first", driverCount)
	}
	if completedRideCount < 5 {
		return fmt.Errorf("phase 3 requires phase 2 (rides) — found %d completed demo rides; run `./seed-admin -demo -demo-phases=rides` first", completedRideCount)
	}

	superadminID, err := resolveSuperadminID(ctx, tx)
	if err != nil {
		return err
	}

	// ─── Incidents ────────────────────────────────────────────────────────────
	// `assigned_to` is the superadmin for non-open incidents; open incidents
	// have NULL assignee so the "unassigned" filter in SafetyCompliance shows
	// content. The mig-021 trigger auto-creates the initial history row using
	// `created_at`, so the SOS timeline renders without a manual insert.
	for _, inc := range demoIncidents {
		ride := demoRides[inc.rideIdx]
		var assignee any
		if inc.status != "open" {
			assignee = superadminID
		} else {
			assignee = nil
		}

		var resolutionNotes any
		if inc.resolution != "" {
			resolutionNotes = inc.resolution
		} else {
			resolutionNotes = nil
		}

		resolvedAtExpr := "NULL"
		if inc.resolvedOffset != "" {
			resolvedAtExpr = fmt.Sprintf("NOW() - INTERVAL '%s' + %s", inc.createdAgo, inc.resolvedOffset)
		}

		// Inline resolved_at expression — can't bind SQL fragments via $-args.
		query := fmt.Sprintf(`
			INSERT INTO incidents (
				id, ride_id, triggered_by, rider_id, driver_id,
				type, status, assigned_to, resolution_notes,
				created_at, resolved_at
			) VALUES (
				$1, $2, $3, $4, $5,
				$6, $7, $8, $9,
				NOW() - $10::interval, %s
			)
			ON CONFLICT (id) DO NOTHING`, resolvedAtExpr)

		if _, err := tx.Exec(ctx, query,
			inc.id, ride.id, inc.triggeredBy,
			passengerIDFor(ride.passengerIdx), driverIDFor(ride.driverIdx),
			inc.incidentType, inc.status, assignee, resolutionNotes,
			inc.createdAgo,
		); err != nil {
			return fmt.Errorf("insert incident %s: %w", inc.id, err)
		}
	}
	fmt.Printf("  ✅ %d incidents (2 sos, 2 safety_complaint, 1 reported_incident)\n", len(demoIncidents))

	// ─── KYC submissions ──────────────────────────────────────────────────────
	const insertKYC = `
		INSERT INTO kyc_submissions (
			id, driver_id, status, submitted_at, reviewed_at, reviewed_by,
			rejection_reason, notes
		) VALUES (
			$1, $2, $3,
			NOW() - $4::interval,
			%s, %s,
			$5, $6
		)
		ON CONFLICT (id) DO NOTHING`

	for _, k := range demoKYCs {
		var rejectionReason, notes any
		if k.rejectionReason != "" {
			rejectionReason = k.rejectionReason
		} else {
			rejectionReason = nil
		}
		if k.notes != "" {
			notes = k.notes
		} else {
			notes = nil
		}

		reviewedAtExpr := "NULL"
		reviewedByExpr := "NULL"
		args := []any{k.id, driverIDFor(k.driverIdx), k.status, k.submittedAgo, rejectionReason, notes}
		if k.reviewedOffset != "" {
			reviewedAtExpr = fmt.Sprintf("NOW() - $4::interval + %s", k.reviewedOffset)
			reviewedByExpr = "$7"
			args = append(args, superadminID)
		}

		query := fmt.Sprintf(insertKYC, reviewedAtExpr, reviewedByExpr)
		if _, err := tx.Exec(ctx, query, args...); err != nil {
			return fmt.Errorf("insert kyc submission %s: %w", k.id, err)
		}
	}
	fmt.Printf("  ✅ %d kyc_submissions (2 pending, 1 approved, 1 rejected, 1 needs_more_info)\n", len(demoKYCs))

	// ─── Driver documents ─────────────────────────────────────────────────────
	// `submission_id` FKs the matching kyc_submissions row (one per driver),
	// so the review queue can render documents grouped by submission.
	const insertDoc = `
		INSERT INTO driver_documents (
			id, driver_id, submission_id,
			document_type, document_number, image_url, expiry_date,
			upload_status, rejection_reason,
			uploaded_at, reviewed_at, reviewed_by
		) VALUES (
			$1, $2, $3,
			$4::document_type, $5, $6, %s,
			$7::upload_status, $8,
			NOW() - $9::interval, %s, %s
		)
		ON CONFLICT (id) DO NOTHING`

	for _, d := range demoDocuments {
		submissionID := fmt.Sprintf("20000008-0000-0000-0000-00000000000%d", d.driverIdx)
		imageURL := fmt.Sprintf("https://demo.sakai.local/docs/%s.jpg", d.id)

		expiryExpr := "NULL"
		if d.expiry != "" {
			expiryExpr = fmt.Sprintf("DATE '%s'", d.expiry)
		}

		var rejectionReason any
		if d.rejectionReason != "" {
			rejectionReason = d.rejectionReason
		} else {
			rejectionReason = nil
		}

		// Reviewed timestamp + reviewer match the parent KYC's review state:
		// approved + rejected → reviewed; uploaded + under_review → not yet.
		reviewedAtExpr := "NULL"
		reviewedByExpr := "NULL"
		args := []any{
			d.id, driverIDFor(d.driverIdx), submissionID,
			d.docType, d.docNumber, imageURL,
			d.uploadStatus, rejectionReason, d.uploadedAgo,
		}
		if d.uploadStatus == "approved" || d.uploadStatus == "rejected" {
			reviewedAtExpr = "NOW() - $9::interval + INTERVAL '1 day'"
			reviewedByExpr = "$10"
			args = append(args, superadminID)
		}

		query := fmt.Sprintf(insertDoc, expiryExpr, reviewedAtExpr, reviewedByExpr)
		if _, err := tx.Exec(ctx, query, args...); err != nil {
			return fmt.Errorf("insert driver_document %s: %w", d.id, err)
		}
	}
	fmt.Printf("  ✅ %d driver_documents (3 per driver — license, registration, insurance)\n", len(demoDocuments))

	return nil
}
