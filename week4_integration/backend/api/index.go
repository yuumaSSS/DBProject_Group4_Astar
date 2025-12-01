package api

import (
	"database/sql"
	"encoding/base64"
	"log"
	"net/http"
	"os"
	"sync"

	"github.com/go-chi/chi/v5"
	_ "github.com/jackc/pgx/v5/stdlib"

	"backend/internal/handler"
)

var (
	db   *sql.DB
	once sync.Once
)

func InitDB() *sql.DB {
	once.Do(func() {
		certContent := os.Getenv("DB_ROOT_CERT_CONTENT")
		if certContent != "" {
			decoded, _ := base64.StdEncoding.DecodeString(certContent)
			_ = os.WriteFile("/tmp/prod-ca-2021.crt", decoded, 0644)
		}

		dbUrl := os.Getenv("DATABASE_URL")
		var err error
		db, err = sql.Open("pgx", dbUrl)
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
	router.Route("/api/admin", func(r chi.Router) {
		r.Get("/products", h.HandleAdminListProducts)
		r.Post("/products", h.HandleCreateProduct)
		r.Put("/products/{id}", h.HandleUpdateProduct)
		r.Delete("/products/{id}", h.HandleDeleteProduct)
		
		r.Get("/orders/pending", h.HandleListPendingOrders)
		r.Post("/orders/{id}/status", h.HandleUpdateOrderStatus)
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