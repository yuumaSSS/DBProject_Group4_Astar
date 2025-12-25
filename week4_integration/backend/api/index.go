package api

import (
	"context"
	"log"
	"net/http"
	"os"
	"sync"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/nedpals/supabase-go"

	"backend/pkg/handler"
)

var (
	db       *pgxpool.Pool
	sb       *supabase.Client
	dbOnce   sync.Once
	sbOnce   sync.Once
)

func InitDB() *pgxpool.Pool {
	dbOnce.Do(func() {
		dbUrl := os.Getenv("DATABASE_URL")
		var err error
		db, err = pgxpool.New(context.Background(), dbUrl)
		if err != nil {
			log.Printf("DB Connection Error: %v", err)
		}
	})
	return db
}

func InitSupabase() *supabase.Client {
	sbOnce.Do(func() {
		sbURL := os.Getenv("SUPABASE_URL")
		sbKey := os.Getenv("SUPABASE_KEY")
		sb = supabase.CreateClient(sbURL, sbKey)
	})
	return sb
}

func Handler(w http.ResponseWriter, r *http.Request) {
	database := InitDB()
	supabaseClient := InitSupabase()

	if database == nil || supabaseClient == nil {
		http.Error(w, "Service Configuration Failed", 500)
		return
	}

	h := handler.NewHttpServer(database, supabaseClient)
	
	router := chi.NewRouter()
	router.Use(EnableCORS)

	router.Post("/api/auth/register", h.HandleRegister)

	router.Get("/api/products", h.HandleListPublicProducts)
	router.Get("/api/products/{id}", h.HandleGetProductDetail)

	router.Route("/api/admin", func(ar chi.Router) {
		ar.Use(h.AdminOnly)

		ar.Get("/products", h.HandleAdminListProducts)
		ar.Post("/products", h.HandleCreateProduct)
		ar.Put("/products/{id}", h.HandleUpdateProduct)
		ar.Delete("/products/{id}", h.HandleDeleteProduct)
		
		ar.Get("/orders/pending", h.HandleListPendingOrders)
		ar.Post("/orders/{id}/status", h.HandleUpdateOrderStatus)
	})

	router.ServeHTTP(w, r)
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