-- Tabel Product
CREATE TABLE Product
(
  ProductID INT NOT NULL,
  ProductName VARCHAR(100) NOT NULL,
  Category VARCHAR(50) NOT NULL,
  UnitPrice DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (ProductID)
);

-- Tabel Customers
CREATE TABLE Customers
(
  CustomerID INT NOT NULL,
  FullName VARCHAR(100) NOT NULL,
  Username VARCHAR(50) NOT NULL,
  ContactNumber VARCHAR(20) NOT NULL,
  City VARCHAR(50) NOT NULL,
  PostCode VARCHAR(10) NOT NULL,
  Street VARCHAR(100) NOT NULL,
  PRIMARY KEY (CustomerID)
);

-- Tabel Order
CREATE TABLE Order
(
  OrderID INT NOT NULL,
  OrderDate DATE NOT NULL,
  TotalAmount DECIMAL(12, 2) NOT NULL,
  CustomerID INT NOT NULL,
  PRIMARY KEY (OrderID),
  FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Tabel Order_Details
CREATE TABLE Order_Details
(
  DetailID INT NOT NULL,
  QuantitySold INT NOT NULL,
  Subtotal DECIMAL(12, 2) NOT NULL,
  OrderID INT NOT NULL,
  ProductID INT NOT NULL,
  PRIMARY KEY (DetailID),
  FOREIGN KEY (OrderID) REFERENCES Order(OrderID),
  FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

-- Tabel Inventory
CREATE TABLE Inventory
(
  InventoryID INT NOT NULL,
  Quantity INT NOT NULL,
  LastUpdated DATETIME NOT NULL,
  ProductID INT NOT NULL,
  PRIMARY KEY (InventoryID),
  FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);
