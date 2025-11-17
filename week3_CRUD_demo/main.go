package main

import (
	"log"
	"net/http"

	"week3_CRUD_demo/config"
	"week3_CRUD_demo/handlers"

	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
)

func main() {
	// Load .env file
	err := godotenv.Load()
	if err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Inisialisasi database
	config.InitDB()
	defer config.DB.Close()

	// Setup router
	r := mux.NewRouter()

	// Routes
	r.HandleFunc("/products", handlers.GetProducts).Methods("GET")
	r.HandleFunc("/products/{id}", handlers.GetProduct).Methods("GET")
	r.HandleFunc("/products", handlers.CreateProduct).Methods("POST")
	r.HandleFunc("/products/{id}", handlers.UpdateProduct).Methods("PUT")
	r.HandleFunc("/products/{id}", handlers.DeleteProduct).Methods("DELETE")

	r.HandleFunc("/customers", handlers.GetCustomers).Methods("GET")
	r.HandleFunc("/customers/{id}", handlers.GetCustomer).Methods("GET")
	r.HandleFunc("/customers", handlers.CreateCustomer).Methods("POST")
	r.HandleFunc("/customers/{id}", handlers.UpdateCustomer).Methods("PUT")
	r.HandleFunc("/customers/{id}", handlers.DeleteCustomer).Methods("DELETE")

	log.Println("Server berjalan di http://localhost:8080")
	log.Fatal(http.ListenAndServe(":8080", r))
}
