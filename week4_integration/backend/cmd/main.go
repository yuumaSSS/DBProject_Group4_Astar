package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/jackc/pgx/v5/pgxpool"
	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/joho/godotenv"

	"backend/pkg/handler"
)

func main() {
	_ = godotenv.Load("base.env")

	dbUrl := os.Getenv("DATABASE_URL")
	if dbUrl == "" {
		dbUser := os.Getenv("DB_USER")
		dbPass := os.Getenv("DB_PASS")
		dbHost := os.Getenv("DB_HOST")
		dbPort := os.Getenv("DB_PORT")
		dbName := os.Getenv("DB_NAME")
		dbSSL  := os.Getenv("DB_SSL")
		dbUrl = fmt.Sprintf("postgres://%s:%s@%s:%s/%s?%s", dbUser, dbPass, dbHost, dbPort, dbName, dbSSL)
	}

	db, err := pgxpool.New(context.Background(), dbUrl)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	h := handler.NewHttpServer(db)
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(EnableCORS)

	r.Get("/api/products", h.HandleListPublicProducts)
	r.Get("/api/products/{id}", h.HandleGetProductDetail)

	r.Route("/api/admin", func(r chi.Router) {
		r.Get("/products", h.HandleAdminListProducts)
		r.Post("/products", h.HandleCreateProduct)
		r.Put("/products/{id}", h.HandleUpdateProduct)
		r.Delete("/products/{id}", h.HandleDeleteProduct)
		r.Get("/orders/pending", h.HandleListPendingOrders)
		r.Post("/orders/{id}/status", h.HandleUpdateOrderStatus)
	})

	log.Println("Server running on port 8080")
	http.ListenAndServe(":8080", r)
}

func EnableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}