package main

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
)

type demoPassenger struct {
	id    string
	name  string
	email string
}

type demoDriver struct {
	id          string
	name        string
	email       string
	vehicleType string // motorcycle | car | tricycle
	make        string
	model       string
	color       string
	plate       string
	online      bool
	lat         float64
	lng         float64
}

// 5 passengers — UUIDs 20000001-...001..005
var demoPassengers = []demoPassenger{
	{"20000001-0000-0000-0000-000000000001", "Maria Santos", "passenger1@demo.sakai.com"},
	{"20000001-0000-0000-0000-000000000002", "Juan Dela Cruz", "passenger2@demo.sakai.com"},
	{"20000001-0000-0000-0000-000000000003", "Ana Reyes", "passenger3@demo.sakai.com"},
	{"20000001-0000-0000-0000-000000000004", "Liza Garcia", "passenger4@demo.sakai.com"},
	{"20000001-0000-0000-0000-000000000005", "Mark Tan", "passenger5@demo.sakai.com"},
}

// 5 drivers — UUIDs 20000002-...001..005. Drivers 1-3 online with PostGIS
// last-known location across BGC / Makati / QC; 4-5 offline.
var demoDrivers = []demoDriver{
	{"20000002-0000-0000-0000-000000000001", "Pedro Cruz", "driver1@demo.sakai.com", "motorcycle", "Honda", "Click", "Red", "ABC 1234", true, 14.5511, 121.0467},
	{"20000002-0000-0000-0000-000000000002", "Roberto Lim", "driver2@demo.sakai.com", "car", "Toyota", "Vios", "White", "XYZ 5678", true, 14.5547, 121.0244},
	{"20000002-0000-0000-0000-000000000003", "Joselito Ramos", "driver3@demo.sakai.com", "tricycle", "Bajaj", "RE", "Blue", "TRI 9012", true, 14.6760, 121.0437},
	{"20000002-0000-0000-0000-000000000004", "Andres Bonifacio", "driver4@demo.sakai.com", "car", "Mitsubishi", "Mirage", "Black", "MIR 3456", false, 14.5764, 121.0851},
	{"20000002-0000-0000-0000-000000000005", "Lorenzo Reyes", "driver5@demo.sakai.com", "motorcycle", "Yamaha", "Mio", "Gray", "YAM 7890", false, 14.5995, 120.9842},
}

const demoPassword = "demo123"

func seedPhase1Users(ctx context.Context, tx pgx.Tx) error {
	hash, err := demoBcrypt(demoPassword)
	if err != nil {
		return err
	}

	const insertUser = `
		INSERT INTO users (id, name, email, password_hash, role)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (id) DO NOTHING`

	for _, p := range demoPassengers {
		if _, err := tx.Exec(ctx, insertUser, p.id, p.name, p.email, hash, "passenger"); err != nil {
			return fmt.Errorf("insert passenger %s: %w", p.email, err)
		}
	}
	fmt.Printf("  ✅ %d passengers (password: %s)\n", len(demoPassengers), demoPassword)

	const insertVehicle = `
		INSERT INTO vehicles (user_id, make, model, color, plate, vehicle_type)
		VALUES ($1, $2, $3, $4, $5, $6)
		ON CONFLICT (user_id) DO NOTHING`

	// NOTE: ST_MakePoint takes (lng, lat) — easy to swap. lng → $3, lat → $4.
	const insertDriver = `
		INSERT INTO drivers (user_id, status, location, heading, updated_at)
		VALUES ($1, $2, ST_SetSRID(ST_MakePoint($3, $4), 4326), $5, NOW())
		ON CONFLICT (user_id) DO UPDATE SET
		  status     = EXCLUDED.status,
		  location   = EXCLUDED.location,
		  heading    = EXCLUDED.heading,
		  updated_at = NOW()`

	for _, d := range demoDrivers {
		if _, err := tx.Exec(ctx, insertUser, d.id, d.name, d.email, hash, "driver"); err != nil {
			return fmt.Errorf("insert driver user %s: %w", d.email, err)
		}
		if _, err := tx.Exec(ctx, insertVehicle, d.id, d.make, d.model, d.color, d.plate, d.vehicleType); err != nil {
			return fmt.Errorf("insert vehicle for %s: %w", d.email, err)
		}

		status := "offline"
		if d.online {
			status = "online"
		}
		if _, err := tx.Exec(ctx, insertDriver, d.id, status, d.lng, d.lat, 90.0); err != nil {
			return fmt.Errorf("insert driver record %s: %w", d.email, err)
		}
	}
	fmt.Printf("  ✅ %d drivers + vehicles + driver records (3 online, 2 offline)\n", len(demoDrivers))

	return nil
}
