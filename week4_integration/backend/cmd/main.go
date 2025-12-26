package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/jackc/pgx/v5/pgxpool"
	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/joho/godotenv"
	"github.com/nedpals/supabase-go"

	"backend/pkg/handler"
)

func main() {
	_ = godotenv.Load("base.env")

	dbUrl := os.Getenv("DATABASE_URL")
	db, err := pgxpool.New(context.Background(), dbUrl)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	sbURL := os.Getenv("SUPABASE_URL")
	sbKey := os.Getenv("SUPABASE_KEY")
	sbClient := supabase.CreateClient(sbURL, sbKey)

	h := handler.NewHttpServer(db, sbClient)

	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(EnableCORS)

	r.Post("/api/auth/register", h.HandleRegister)

	r.Get("/api/products", h.HandleListPublicProducts)
	r.Get("/api/products/{id}", h.HandleGetProductDetail)

	r.Route("/api/admin", func(r chi.Router) {
		r.Use(h.AdminOnly)

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
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}