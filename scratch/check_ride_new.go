
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
	err = pool.QueryRow(context.Background(), "SELECT id, status FROM rides WHERE id = 'bd44dff6-3125-431a-a396-dbef6b36663f'").Scan(&id, &status)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("Ride ID: %s, Status: %s\n", id, status)
}
