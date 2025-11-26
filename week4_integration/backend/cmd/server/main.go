package main

import (
	"fmt"
	"context"
	"log"
	"os"
	"github.com/jackc/pgx/v5"
	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load("base.env")
	if err != nil {
		log.Fatal("Error loading base.env")
	}

	dbUser := os.Getenv("DB_USER")
	dbPass := os.Getenv("DB_PASS")
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbName := os.Getenv("DB_NAME")
	dbSSL  := os.Getenv("DB_SSL")

	dbUrl := fmt.Sprintf("postgresql://%s:%s@%s:%s/%s?%s",
		dbUser, dbPass, dbHost, dbPort, dbName, dbSSL)
	
	conn, err := pgx.Connect(context.Background(), dbUrl)
	if err != nil {
		log.Fatalf("Failed to connect to the database: %v", err)
	}
	defer conn.Close(context.Background())

	// Testing connection
	var version string
	if err := conn.QueryRow(context.Background(), "SELECT version()").Scan(&version); err != nil {
		log.Fatalf("Query failed: %v", err)
	}
	log.Println("Connected to:", version)
}