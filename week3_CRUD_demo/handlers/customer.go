package handlers

import(
	"database/sql"
	"encoding/json"
	"net/http"
	"strconv"

	"week3_CRUD_demo/config"
	"week3_CRUD_demo/models"

	"github.com/gorilla/mux"	
)

func GetCustomers(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	rows, err := config.DB.Query("SELECT CustomerID, FullName, Username, ContactNumber, City, PostCode, Street FROM Customers")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var customers []models.Customers
	for rows.Next() {
		var c models.Customers
		if err := rows.Scan(&c.CustomerID, &c.FullName, &c.Username, &c.ContactNumber, &c.City, &c.PostCode, &c.Street); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		customers = append(customers, c)
	}

	json.NewEncoder(w).Encode(customers)
}

func GetCustomer(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])

	var c models.Customers
	err := config.DB.QueryRow("SELECT CustomerID, FullName, Username, ContactNumber, City, PostCode, Street FROM Customers WHERE CustomerID = $1", id).
		Scan(&c.CustomerID, &c.FullName, &c.Username, &c.ContactNumber, &c.City, &c.PostCode, &c.Street)

	if err == sql.ErrNoRows {
		http.Error(w, "Customer not found", http.StatusNotFound)
		return
	} else if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	json.NewEncoder(w).Encode(c)
}

func CreateCustomer(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	var c models.Customers
	if err := json.NewDecoder(r.Body).Decode(&c); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	_, err := config.DB.Exec("INSERT INTO Customers (CustomerID, FullName, Username, ContactNumber, City, PostCode, Street) VALUES ($1, $2, $3, $4, $5, $6, $7)",
		c.CustomerID, c.FullName, c.Username, c.ContactNumber, c.City, c.PostCode, c.Street)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(c)
}

func UpdateCustomer(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])

	var c models.Customers
	if err := json.NewDecoder(r.Body).Decode(&c); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	result, err := config.DB.Exec("UPDATE Customers SET FullName = $1, Username = $2, ContactNumber = $3, City = $4, PostCode = $5, Street = $6 WHERE CustomerID = $7",
		c.FullName, c.Username, c.ContactNumber, c.City, c.PostCode, c.Street, id)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		http.Error(w, "Customer not found", http.StatusNotFound)
		return
	}

	c.CustomerID = id
	json.NewEncoder(w).Encode(c)
}

func DeleteCustomer(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	params := mux.Vars(r)
	id, _ := strconv.Atoi(params["id"])

	result, err := config.DB.Exec("DELETE FROM Customers WHERE CustomerID = $1", id)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		http.Error(w, "Customer not found", http.StatusNotFound)
		return
	}

	json.NewEncoder(w).Encode(map[string]string{"message": "Customer deleted successfully"})
}