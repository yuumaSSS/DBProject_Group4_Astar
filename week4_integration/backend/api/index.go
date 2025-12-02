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

	"backend/pkg/handler"
)

var (
	db   *pgxpool.Pool
	once sync.Once
)

func InitDB() *pgxpool.Pool {
	once.Do(func() {
		dbUrl := os.Getenv("DATABASE_URL")
		var err error
		db, err = pgxpool.New(context.Background(), dbUrl)
		if err != nil {
			log.Printf("DB Connection Error: %v", err)
		}
	})
	return db
}

func Handler(w http.ResponseWriter, r *http.Request) {
	database := InitDB()
	if database == nil {
		http.Error(w, "Database Connection Failed", 500)
		return
	}

	h := handler.NewHttpServer(database)
	
	router := chi.NewRouter()
	router.Use(EnableCORS)

	
	// Public
	router.Get("/api/products", h.HandleListPublicProducts)
	router.Get("/api/products/{id}", h.HandleGetProductDetail)

	// Admin (Mobile)
	router.Route("/api/admin", func(ar chi.Router) {
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