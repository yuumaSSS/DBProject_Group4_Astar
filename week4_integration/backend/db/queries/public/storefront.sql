-- name: ListAvailableProducts :many
-- Requirement: Web fetch data product
SELECT 
    product_id,
    image_url, 
    product_name, 
    stock, 
    unit_price, 
    category
FROM products
WHERE stock > 0 -- Hanya tampilkan yang ada stok
ORDER BY created_at DESC;

-- name: GetProductDetail :one
-- Requirement: Web fetch detail product
SELECT 
    product_id,
    image_url, 
    product_name, 
    stock, 
    unit_price, 
    category,
    description
FROM products
WHERE product_id = $1;