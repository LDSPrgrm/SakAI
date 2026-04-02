package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	"github.com/sakai/backend/configs"
	"github.com/sakai/backend/internal/domain"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	roleFlag := flag.String("role", string(domain.RoleAdmin), "Role to create (admin or superadmin)")
	nameFlag := flag.String("name", "Admin", "Name of the admin user")
	emailFlag := flag.String("email", "admin@sakai.com", "Email of the admin user")
	passwordFlag := flag.String("password", "admin123", "Password for the admin user")

	flag.Parse()

	// Validate role
	role := domain.UserRole(*roleFlag)
	if role != domain.RoleAdmin && role != domain.RoleSuperadmin {
		log.Fatalf("Invalid role: %s. Must be 'admin' or 'superadmin'", *roleFlag)
	}

	// Load environment variables. We try both current dir and parent dir
	// in case the script is run from the root or backend folder.
	_ = godotenv.Load("../../.env")
	_ = godotenv.Load()

	cfg := configs.Load()

	if cfg.DatabaseURL == "" {
		log.Fatal("DATABASE_URL is not set")
	}

	ctx := context.Background()
	pool, err := pgxpool.New(ctx, cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer pool.Close()

	if err := pool.Ping(ctx); err != nil {
		log.Fatalf("Database ping failed: %v", err)
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(*passwordFlag), bcrypt.DefaultCost)
	if err != nil {
		log.Fatalf("Failed to hash password: %v", err)
	}

	userID := uuid.New()
	const q = `
		INSERT INTO users (id, name, email, password_hash, role) 
		VALUES ($1, $2, $3, $4, $5)`

	_, err = pool.Exec(ctx, q, userID, *nameFlag, *emailFlag, string(hash), role)
	if err != nil {
		log.Fatalf("Failed to insert admin user: %v", err)
	}

	fmt.Printf("✅ Successfully created %s account!\n", role)
	fmt.Printf("ID: %s\n", userID)
	fmt.Printf("Name: %s\n", *nameFlag)
	fmt.Printf("Email: %s\n", *emailFlag)
	os.Exit(0)
}
