
package main

import (
	"context"
	"fmt"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	dsn := "postgres://postgres:postgres@127.0.0.1:5432/sakai?sslmode=disable"
	pool, err := pgxpool.New(context.Background(), dsn)
	if err != nil {
		log.Fatal(err)
	}
	defer pool.Close()

	var id string
	var status string
	var passengerID string
	var driverID *string
	err = pool.QueryRow(context.Background(), "SELECT id, status, passenger_id, driver_id FROM rides WHERE id = 'bd44dff6-3125-431a-a396-dbef6b36663f'").Scan(&id, &status, &passengerID, &driverID)
	if err != nil {
		log.Fatal(err)
	}

	dID := "nil"
	if driverID != nil {
		dID = *driverID
	}

	fmt.Printf("Ride ID: %s, Status: %s, Passenger: %s, Driver: %s\n", id, status, passengerID, dID)
}
