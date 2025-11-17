package models

type Product struct {
	ProductID   int     `json:"product_id"`
	ProductName string  `json:"product_name"`
	Category    string  `json:"category"`
	UnitPrice   float64 `json:"unit_price"`
}

type Customer struct {
	CustomerID    int    `json:"customer_id"`
	FullName      string `json:"full_name"`
	Username      string `json:"username"`
	ContactNumber string `json:"contact_number"`
	City          string `json:"city"`
	PostCode      string `json:"post_code"`
	Street        string `json:"street"`
}

type Orders struct {
	OrderID     int     `json:"order_id"`
	OrderDate   string  `json:"order_date"`
	TotalAmount float64 `json:"total_amount"`
	CustomerID  int     `json:"customer_id"`
}

type OrderDetail struct {
	DetailID     int     `json:"detail_id"`
	QuantitySold int     `json:"quantity_sold"`
	Subtotal     float64 `json:"subtotal"`
	OrderID      int     `json:"order_id"`
	ProductID    int     `json:"product_id"`
}

type Inventory struct {
	InventoryID int    `json:"inventory_id"`
	Quantity    int    `json:"quantity"`
	LastUpdated string `json:"last_updated"`
	ProductID   int    `json:"product_id"`
}
