
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

	rows, err := pool.Query(context.Background(), "SELECT rater_id, stars FROM ratings WHERE ride_id = 'bd44dff6-3125-431a-a396-dbef6b36663f'")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	fmt.Println("Ratings for ride bd44dff6-3125-431a-a396-dbef6b36663f:")
	for rows.Next() {
		var raterID string
		var stars int
		if err := rows.Scan(&raterID, &stars); err != nil {
			log.Fatal(err)
		}
		fmt.Printf("Rater: %s, Stars: %d\n", raterID, stars)
	}
}
