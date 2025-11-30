-- name: ListPendingOrders :many
-- Requirement: Mobile app fetching data order yang pending
SELECT 
    o.order_id,
    o.order_date,
    o.total_amount,
    o.quantity,
    o.status,
    -- Ambil info User biar admin tau siapa yang beli
    u.full_name AS customer_name,
    u.phone_number,
    -- Ambil info Product biar admin tau barang apa
    p.product_name,
    p.image_url
FROM orders o
JOIN users u ON o.user_id = u.user_id
JOIN products p ON o.product_id = p.product_id
WHERE o.status = 'pending'
ORDER BY o.order_date ASC;

-- name: UpdateOrderStatus :exec
-- Requirement: Mobile app mengubah data pending menjadi paid atau cancelled
UPDATE orders 
SET status = $2 
WHERE order_id = $1;