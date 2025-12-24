-- name: ListPendingOrders :many
SELECT 
    o.order_id,
    o.order_date,
    o.total_amount,
    o.quantity,
    o.status,
    u.full_name AS customer_name,
    u.phone_number,
    p.product_name,
    p.image_url
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN products p ON o.product_id = p.product_id
WHERE o.status = 'pending'
ORDER BY o.order_date ASC;

-- name: UpdateOrderStatus :exec
UPDATE orders 
SET status = $2 
WHERE order_id = $1;

-- name: GetOrderQuantityAndProduct :one
-- PENTING: Dipakai Go untuk mengetahui jumlah stok yang harus dikurangi
SELECT product_id, quantity 
FROM orders 
WHERE order_id = $1;

-- name: DecreaseProductStock :exec
-- PENTING: Dipakai Go saat status berubah jadi 'paid'
UPDATE products 
SET stock = stock - $2 
WHERE product_id = $1;