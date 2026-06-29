package main

import (
	"context"
	"fmt"
	"log"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	"github.com/sakai/backend/configs"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	godotenv.Load("../.env")
	cfg := configs.Load()
	
	ctx := context.Background()
	pool, err := pgxpool.New(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer pool.Close()

	users := []struct {
		name     string
		email    string
		password string
		role     string
	}{
		{"Passenger", "passenger@example.com", "password123", "passenger"},
		{"Driver", "driver@example.com", "password123", "driver"},
	}

	for _, u := range users {
		hash, _ := bcrypt.GenerateFromPassword([]byte(u.password), bcrypt.DefaultCost)
		id := uuid.New()
		_, err := pool.Exec(ctx, `
			INSERT INTO users (id, name, email, password_hash, role)
			VALUES ($1, $2, $3, $4, $5)
			ON CONFLICT (email) DO UPDATE SET password_hash = $4
		`, id, u.name, u.email, string(hash), u.role)
		if err != nil {
			fmt.Printf("Failed to seed %s: %v\n", u.email, err)
		} else {
			fmt.Printf("Seeded %s\n", u.email)
		}
	}
}
