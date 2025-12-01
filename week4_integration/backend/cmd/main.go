package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/joho/godotenv"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	"backend/internal/app/publicdb"
	"backend/internal/handler"
	"backend/pb"
)

func main() {
	_ = godotenv.Load("base.env")

	certContent := os.Getenv("DB_ROOT_CERT_CONTENT")
	if certContent != "" {
		decoded, err := base64.StdEncoding.DecodeString(certContent)
		if err != nil {
			log.Fatalf("Gagal decode sertifikat SSL: %v", err)
		}

		fileName := "prod-ca-2021.crt" 
		err = os.WriteFile(fileName, decoded, 0644)
		if err != nil {
			log.Fatalf("Gagal menulis file sertifikat SSL: %v", err)
		}
		log.Println("File sertifikat SSL berhasil dibuat dari Environment Variable")
	}

	dbUrl := os.Getenv("DATABASE_URL")
	if dbUrl == "" {
		dbUser := os.Getenv("DB_USER")
		dbPass := os.Getenv("DB_PASS")
		dbHost := os.Getenv("DB_HOST")
		dbPort := os.Getenv("DB_PORT")
		dbName := os.Getenv("DB_NAME")
		dbSSL := os.Getenv("DB_SSL")
		dbUrl = fmt.Sprintf("postgres://%s:%s@%s:%s/%s?%s",
			dbUser, dbPass, dbHost, dbPort, dbName, dbSSL)
	}

	db, err := sql.Open("pgx", dbUrl)
	if err != nil {
		log.Fatalf("❌ Failed connect DB: %v", err)
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		log.Fatalf("❌ Failed ping DB: %v", err)
	}

	mode := os.Getenv("SERVER_MODE")
	if mode == "" {
		mode = "both"
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	stop := make(chan struct{})

// Mobile

	if mode == "grpc" || mode == "both" {
		go func() {
			listenPort := port
			if mode == "both" {
				listenPort = "50051"
			}

			lis, err := net.Listen("tcp", ":"+listenPort)
			if err != nil {
				log.Fatalf("Failed listen gRPC: %v", err)
			}

			grpcServer := grpc.NewServer()
			astarService := handler.NewastarServer(db)
			pb.RegisterStorefrontServiceServer(grpcServer, astarService)
			pb.RegisterAdminServiceServer(grpcServer, astarService)
			reflection.Register(grpcServer)

			log.Printf("gRPC Server running on port %s", listenPort)
			if err := grpcServer.Serve(lis); err != nil {
				log.Fatalf("Failed serve gRPC: %v", err)
			}
		}()
	}

// Web

	if mode == "http" || mode == "both" {
		go func() {
			listenPort := port
			if mode == "both" {
				listenPort = "8080"
			}

			r := chi.NewRouter()
			publicQ := publicdb.New(db)
			r.Use(middleware.Logger)
			r.Use(middleware.Recoverer)
			r.Use(EnableCORS)

			// Routes
			r.Get("/api/products", func(w http.ResponseWriter, req *http.Request) {
				products, err := publicQ.ListAvailableProducts(req.Context())
				if err != nil {
					http.Error(w, "Internal Error", 500); return
				}
				writeJSON(w, products)
			})

			r.Get("/api/products/{id}", func(w http.ResponseWriter, req *http.Request) {
				idStr := chi.URLParam(req, "id")
				id, _ := strconv.Atoi(idStr)
				product, err := publicQ.GetProductDetail(req.Context(), int32(id))
				if err != nil {
					http.Error(w, "Not Found", 404); return
				}
				writeJSON(w, product)
			})

			log.Printf("HTTP Server running on port %s", listenPort)
			if err := http.ListenAndServe(":"+listenPort, r); err != nil {
				log.Fatal(err)
			}
		}()
	}

	<-stop
}

func writeJSON(w http.ResponseWriter, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(data)
}

func EnableCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
		if r.Method == "OPTIONS" {
			w.WriteHeader(http.StatusOK)
			return
		}
		next.ServeHTTP(w, r)
	})
}