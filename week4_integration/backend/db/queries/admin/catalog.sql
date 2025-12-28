-- name: ListAllProductsAdmin :many
-- Requirement: Mobile app fetching data product list
SELECT 
    image_url, 
    product_id, 
    product_name, 
    category,
    description,
    unit_price, 
    stock
FROM products
ORDER BY product_id ASC;

-- name: CreateProduct :one
-- Requirement: Mobile app menambah product
INSERT INTO products (
    product_name, 
    category, 
    description, 
    unit_price, 
    image_url, 
    stock
) VALUES (
    $1, $2, $3, $4, $5, $6
)
RETURNING product_id;

-- name: UpdateProduct :exec
-- Requirement: Mobile app update product
UPDATE products 
SET 
    product_name = $2,
    category = $3,
    description = $4,
    unit_price = $5,
    image_url = $6,
    stock = $7,
    updated_at = NOW()
WHERE product_id = $1;

-- name: DeleteProduct :exec
-- Requirement: Mobile app delete product
DELETE FROM products 
WHERE product_id = $1;