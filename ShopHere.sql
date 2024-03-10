CREATE DATABASE ShopHere;
-- EMPLOYEES1
CREATE TABLE Employees1 (
       Employee_ID INT NOT NULL,
       First_Name VARCHAR(100), 
       LastName VARCHAR(100), 
       City VARCHAR(50), 
       Phone BIGINT,
       CHECK(
              Phone LIKE '[0-9][0-9]-[0-9] [0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9] [0-9]-[0-9] [0-9] [0-9]')
);
-- Items.ProductCategory 

CREATE TABLE Product_Category(
  Category_ID INT NOT NULL AUTO_INCREMENT,
  Category_name VARCHAR (100) NOT NULL,
  Category_description VARCHAR(200) NOT NULL,
  CHECK(Category_name IN ('Household', 'Sports', 'Accessories', 'Clothing')),
  PRIMARY KEY(Category_ID)
);
-- SUPPLIERDETAILS
CREATE TABLE Supplier_Details1 (
    Supplier_ID INT AUTO_INCREMENT, 
    First_Name VARCHAR(50) NOT NULL, 
    Last_Name VARCHAR(50) NOT NULL, 
    Address VARCHAR(255) NOT NULL, 
    Phone VARCHAR(20) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    PRIMARY KEY(Supplier_ID),
     CHECK(
              Phone LIKE '[0-9][0-9]-[0-9] [0-9][0-9]-[0-9][0-9][0-9][0-9]-[0-9][0-9] [0-9]-[0-9] [0-9] [0-9]')
);

-- ITEMDETAILS
CREATE TABLE Item_details (
  item_id INT NOT NULL AUTO_INCREMENT,
  Item_name VARCHAR(50) NOT NULL,
  Item_description VARCHAR(50) NOT NULL,
  Quantity_in_hand INT CHECK( Quantity_in_hand > 0 ),
  Unit_price INT CHECK( Unit_price  > 0 ),
  ReorderQuantity INT CHECK (ReorderQuantity > 0), 
  ReorderLevel INT CHECK (ReorderLevel > 0),
  Category_id INT,
  Supplier_id INT,
  PRIMARY KEY(item_id),
  FOREIGN KEY (Category_id) REFERENCES Product_category(Category_id),
  FOREIGN KEY (Supplier_id) REFERENCES Supplier_Details(Supplier_id)
  );
 
  