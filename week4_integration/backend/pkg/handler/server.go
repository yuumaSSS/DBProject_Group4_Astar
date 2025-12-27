package handler

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/nedpals/supabase-go"

	"backend/pkg/app/admindb"
	"backend/pkg/app/publicdb"
)

type HttpServer struct {
	DB             *pgxpool.Pool
	PublicQ        *publicdb.Queries
	AdminQ         *admindb.Queries
	SupabaseClient *supabase.Client
}

func NewHttpServer(db *pgxpool.Pool, sb *supabase.Client) *HttpServer {
	return &HttpServer{
		DB:             db,
		PublicQ:        publicdb.New(db),
		AdminQ:         admindb.New(db),
		SupabaseClient: sb,
	}
}

func writeJSON(w http.ResponseWriter, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(data)
}

// Web

func (h *HttpServer) HandleRegister(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Email       string `json:"email"`
		Password    string `json:"password"`
		Username    string `json:"username"`
		FullName    string `json:"full_name"`
		PhoneNumber string `json:"phone_number"`
		Street      string `json:"street"`
		City        string `json:"city"`
		PostCode    string `json:"post_code"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid input", 400)
		return
	}

	_, err := h.SupabaseClient.Auth.SignUp(r.Context(), supabase.UserCredentials{
		Email:    req.Email,
		Password: req.Password,
		Data: map[string]interface{}{
			"username":     req.Username,
			"full_name":    req.FullName,
			"phone_number": req.PhoneNumber,
			"street":       req.Street,
			"city":         req.City,
			"post_code":    req.PostCode,
		},
	})

	if err != nil {
		http.Error(w, "Gagal mendaftar: "+err.Error(), 500)
		return
	}

	writeJSON(w, map[string]string{"message": "Registrasi berhasil"})
}

func (h *HttpServer) HandleListPublicProducts(w http.ResponseWriter, r *http.Request) {
	products, err := h.PublicQ.ListAvailableProducts(r.Context())
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	writeJSON(w, products)
}

func (h *HttpServer) HandleGetProductDetail(w http.ResponseWriter, r *http.Request) {
	idStr := chi.URLParam(r, "id")
	id, _ := strconv.Atoi(idStr)

	product, err := h.PublicQ.GetProductDetail(r.Context(), int32(id))
	if err != nil {
		if err == sql.ErrNoRows {
			http.Error(w, "Product not found", 404)
		} else {
			http.Error(w, err.Error(), 500)
		}
		return
	}
	writeJSON(w, product)
}

// Mobile

func (h *HttpServer) HandleAdminListProducts(w http.ResponseWriter, r *http.Request) {
	products, err := h.AdminQ.ListAllProductsAdmin(r.Context())
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	writeJSON(w, products)
}

func (h *HttpServer) HandleCreateProduct(w http.ResponseWriter, r *http.Request) {
	var req struct {
		Name        string  `json:"name"`
		Category    string  `json:"category"`
		Description string  `json:"description"`
		Price       float64 `json:"price"`
		ImageUrl    string  `json:"image_url"`
		Stock       int32   `json:"stock"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", 400)
		return
	}

	var priceNum pgtype.Numeric
	priceNum.Scan(fmt.Sprintf("%f", req.Price))

	id, err := h.AdminQ.CreateProduct(r.Context(), admindb.CreateProductParams{
		ProductName: req.Name,
		Category:    req.Category,
		Description: req.Description,
		UnitPrice:   priceNum,
		ImageUrl:    req.ImageUrl,
		Stock:       req.Stock,
	})

	if err != nil {
		http.Error(w, "Gagal create product: "+err.Error(), 500)
		return
	}

	writeJSON(w, map[string]int32{"product_id": id})
}

func (h *HttpServer) HandleUpdateProduct(w http.ResponseWriter, r *http.Request) {
	idStr := chi.URLParam(r, "id")
	id, _ := strconv.Atoi(idStr)

	var req struct {
		Name        string  `json:"name"`
		Category    string  `json:"category"`
		Description string  `json:"description"`
		Price       float64 `json:"price"`
		ImageUrl    string  `json:"image_url"`
		Stock       int32   `json:"stock"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", 400)
		return
	}

	var priceNum pgtype.Numeric
	priceNum.Scan(fmt.Sprintf("%f", req.Price))

	err := h.AdminQ.UpdateProduct(r.Context(), admindb.UpdateProductParams{
		ProductID:   int32(id),
		ProductName: req.Name,
		Category:    req.Category,
		Description: req.Description,
		UnitPrice:   priceNum,
		ImageUrl:    req.ImageUrl,
		Stock:       req.Stock,
	})

	if err != nil {
		http.Error(w, "Gagal update: "+err.Error(), 500)
		return
	}
	writeJSON(w, map[string]string{"status": "success"})
}

func (h *HttpServer) HandleCreateOrder(w http.ResponseWriter, r *http.Request) {
	var req struct {
		UserID      string  `json:"user_id"`
		ProductID   int32   `json:"product_id"`
		Quantity    int32   `json:"quantity"`
		TotalAmount float64 `json:"total_amount"`
		Status      string  `json:"status"`
	}

	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid Input Format: "+err.Error(), 400)
		return
	}

	var userUUID pgtype.UUID
	if err := userUUID.Scan(req.UserID); err != nil {
		http.Error(w, "Invalid UUID format", 400)
		return
	}

	var totalAmountNum pgtype.Numeric
	if err := totalAmountNum.Scan(fmt.Sprintf("%.2f", req.TotalAmount)); err != nil {
		http.Error(w, "Invalid Total Amount", 400)
		return
	}

	err := h.AdminQ.CreateOrder(r.Context(), admindb.CreateOrderParams{
		UserID:      userUUID,
		ProductID:   req.ProductID,
		Quantity:    req.Quantity,
		TotalAmount: totalAmountNum,
		Status:      req.Status,
	})

	if err != nil {
		fmt.Println("DB ERROR:", err)
		http.Error(w, "Database Error: "+err.Error(), 500)
		return
	}

	writeJSON(w, map[string]string{"message": "Order Created Successfully"})
}

func (h *HttpServer) HandleDeleteProduct(w http.ResponseWriter, r *http.Request) {
	idStr := chi.URLParam(r, "id")
	id, _ := strconv.Atoi(idStr)

	err := h.AdminQ.DeleteProduct(r.Context(), int32(id))
	if err != nil {
		http.Error(w, "Gagal delete: "+err.Error(), 500)
		return
	}
	writeJSON(w, map[string]string{"status": "deleted"})
}

func (h *HttpServer) HandleListOrders(w http.ResponseWriter, r *http.Request) {
	orders, err := h.AdminQ.ListOrders(r.Context())
	if err != nil {
		http.Error(w, err.Error(), 500)
		return
	}
	writeJSON(w, orders)
}

func (h *HttpServer) HandleUpdateOrderStatus(w http.ResponseWriter, r *http.Request) {
	idStr := chi.URLParam(r, "id")
	orderID, _ := strconv.Atoi(idStr)

	var req struct {
		Status string `json:"status"`
	}
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid JSON", 400)
		return
	}

	tx, err := h.DB.Begin(r.Context())
	if err != nil {
		http.Error(w, "Tx Error", 500)
		return
	}
	defer tx.Rollback(r.Context())

	qtx := h.AdminQ.WithTx(tx)

	err = qtx.UpdateOrderStatus(r.Context(), admindb.UpdateOrderStatusParams{
		OrderID: int32(orderID),
		Status:  req.Status,
	})
	if err != nil {
		http.Error(w, "Gagal update status: "+err.Error(), 500)
		return
	}

	if req.Status == "paid" {
		orderInfo, err := qtx.GetOrderQuantityAndProduct(r.Context(), int32(orderID))
		if err != nil {
			http.Error(w, "Order info not found", 404)
			return
		}

		err = qtx.DecreaseProductStock(r.Context(), admindb.DecreaseProductStockParams{
			ProductID: orderInfo.ProductID,
			Stock:     orderInfo.Quantity,
		})
		if err != nil {
			http.Error(w, "Gagal kurangi stok", 400)
			return
		}
	}

	if err := tx.Commit(r.Context()); err != nil {
		http.Error(w, "Commit Failed", 500)
		return
	}

	writeJSON(w, map[string]string{"status": "updated"})
}
