-- PostgreSQL Version

-- Drop tables jika sudah ada
DROP TABLE IF EXISTS Inventory CASCADE;
DROP TABLE IF EXISTS Order_Details CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;
DROP TABLE IF EXISTS Product CASCADE;

-- Tabel Product
CREATE TABLE Product (
    ProductID SERIAL PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    UnitPrice DECIMAL(10, 2) NOT NULL CHECK (UnitPrice >= 0)
);

-- Tabel Customers
CREATE TABLE Customers (
    CustomerID SERIAL PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    Username VARCHAR(50) NOT NULL UNIQUE,
    ContactNumber VARCHAR(20) NOT NULL,
    City VARCHAR(50) NOT NULL,
    PostCode VARCHAR(10) NOT NULL,
    Street VARCHAR(100) NOT NULL
);

-- Tabel Orders
CREATE TABLE Orders (
    OrderID SERIAL PRIMARY KEY,
    OrderDate DATE NOT NULL DEFAULT CURRENT_DATE,
    TotalAmount DECIMAL(12, 2) NOT NULL CHECK (TotalAmount >= 0),
    CustomerID INT NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE
);

-- Tabel Order_Details
CREATE TABLE Order_Details (
    DetailID SERIAL PRIMARY KEY,
    QuantitySold INT NOT NULL CHECK (QuantitySold > 0),
    Subtotal DECIMAL(12, 2) NOT NULL CHECK (Subtotal >= 0),
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID) ON DELETE RESTRICT
);

-- Tabel Inventory
CREATE TABLE Inventory (
    InventoryID SERIAL PRIMARY KEY,
    Quantity INT NOT NULL CHECK (Quantity >= 0),
    LastUpdated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ProductID INT NOT NULL UNIQUE,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID) ON DELETE CASCADE
);

-- Index untuk performa query yang lebih baik
CREATE INDEX idx_orders_customer ON Orders(CustomerID);
CREATE INDEX idx_orders_date ON Orders(OrderDate);
CREATE INDEX idx_order_details_order ON Order_Details(OrderID);
CREATE INDEX idx_order_details_product ON Order_Details(ProductID);
CREATE INDEX idx_inventory_product ON Inventory(ProductID);
