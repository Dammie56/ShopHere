DROP DATABASE IF EXISTS ShopHere;
CREATE DATABASE ShopHere;
USE ShopHere;

-- EMPLOYEES1
DROP TABLE IF EXISTS employees1;
CREATE TABLE Employees1 (
       Employee_ID INT NOT NULL AUTO_INCREMENT,
       First_Name VARCHAR(100) NOT NULL, 
       Last_Name VARCHAR(100)NOT NULL, 
       City VARCHAR(50) NOT NULL, 
       Phone VARCHAR(20) NOT NULL,
       CHECK(
              Phone REGEXP '^(081|080)-[0-9]{4}-[0-9]{4}$'),
	   PRIMARY KEY(Employee_ID)
);
DESC employees1;

INSERT INTO employees1 (first_name, last_name, city, phone)
VALUES
      (  'Anjorin', 'Oluwadamilola', 'Mowe', '081-2211-6302'),
      ( 'Toluwalope', 'Gabriel', 'yaba', '081-7933-9892'),
      ( 'Adekunle', 'Adetunji', 'Akure', '081-3265-2712');
SELECT * FROM employees1;

-- Items.ProductCategory 
DROP TABLE IF EXISTS product_category;
CREATE TABLE Product_Category(
  Category_ID INT NOT NULL AUTO_INCREMENT,
  Category_name ENUM('Household', 'Sports', 'Accessories', 'Clothing') NOT NULL,
  Category_description VARCHAR(255) NOT NULL,
  PRIMARY KEY(Category_ID)
);

INSERT INTO Product_Category (category_name, category_description)
VALUES ('Household', 'Home and kitchen appliances'),
	   ('Clothing', 'For kids and teens'),
       ('Sports', 'Shorts for running');
SELECT * FROM product_category;


-- SUPPLIERDETAILS
USE ShopHere;
ALTER TABLE Supplier_Details1
MODIFY COLUMN Phone BIGINT;
USE shophere;
DROP TABLE IF EXISTS Supplier_details;
CREATE TABLE Supplier_Details (
    Supplier_ID INT AUTO_INCREMENT, 
    First_Name VARCHAR(100) NOT NULL, 
    Last_Name VARCHAR(100) NOT NULL, 
    Address VARCHAR(50) NOT NULL, 
    Phone VARCHAR(20) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    PRIMARY KEY(Supplier_ID),
   CHECK(
              Phone REGEXP '^(081|080|090)-[0-9]{4}-[0-9]{4}$')
);
INSERT INTO supplier_details (first_name, last_name, address, phone, country)
VALUES ('Ambur', 'Oluwadamilola', 'OFada, Mowe', '081-1234-5678', 'Nigeria'),
       ('Adewole', 'Ayomide', 'Ikeja,Lagos', '090-3997-6189', 'Canada'),
       ('Adewole', 'Demilade', 'Ikeja, Lagos', '081-1985-4641', 'Canada');

SELECT *FROM Supplier_Details;
DESC Supplier_Details1;
USE shophere;
DROP TABLE IF EXISTS Item_details;
-- ITEMDETAILS
CREATE TABLE Item_details (
  item_id INT NOT NULL AUTO_INCREMENT,
  Item_name VARCHAR(50) NOT NULL,
  Item_description VARCHAR(50) NOT NULL,
  Quantity_in_hand INT CHECK( Quantity_in_hand > 0 ),
  Unit_price DECIMAL(9,2) CHECK( Unit_price  > 0 ),
  Reorder_quantity INT CHECK (Reorder_quantity > 0), 
  Reorder_level INT CHECK (Reorder_level > 0),
  Category_id INT,
  Supplier_id INT,
  PRIMARY KEY(item_id),
  FOREIGN KEY (Category_id) REFERENCES Product_category(Category_id),
  FOREIGN KEY (Supplier_id) REFERENCES Supplier_Details(Supplier_id)
  );
  INSERT INTO item_details (item_name, item_description, quantity_in_hand, unit_price, reorder_quantity, reorder_level, category_id, supplier_id)
  VALUES  ('clothes', 'These are kids wears', 10, 8.23, 5, 3, 2, 1),
          ('Appliances', 'Non-stick pots, frying pan', 15, 150, 4, 3, 1, 3),
          ('footwears', 'running boots, football boots', 20, 70.90, 10, 13, 3, 2);
SELECT * FROM item_details;
  
 
 -- Transactions.OrderDetails
 
 DROP TABLE IF EXISTS order_details;
 CREATE TABLE Order_Details(
     Purchase_Order_ID INT NOT NULL AUTO_INCREMENT,
     Order_Date DATE,
     Quantity_Ordered INT CHECK(Quantity_ordered > 0),
	 Quantity_Received INT CHECK (Quantity_Received > 0),
     Unit_Price INT CHECK(Unit_Price > 0),
     Ship_method VARCHAR(50),
     Order_Status ENUM('InTransit', 'Received', 'Cancelled'), 
	 Receiving_Date DATE DEFAULT NULL,
     Employee_id INT,
     Item_id INT,
     Supplier_id INT,
     CHECK (Quantity_Received <= Quantity_Ordered), 
	 CHECK (Receiving_Date > Order_Date),
     PRIMARY KEY (Purchase_Order_ID),
     FOREIGN KEY(Employee_Id) REFERENCES Employees1(employee_id),
     FOREIGN KEY(Item_id) REFERENCES Item_details(Item_id),
     FOREIGN KEY(Supplier_id) REFERENCES supplier_details(supplier_id)
);

DROP TRIGGER IF EXISTS date_before_insert;
DELIMITER $$
CREATE TRIGGER date_before_insert
       BEFORE INSERT ON order_details
	   FOR EACH ROW
BEGIN
    SET NEW.Order_date = NOW();
END$$

USE shophere;
INSERT INTO order_details (Quantity_Ordered, Quantity_Received, Unit_price, Ship_method, order_status, receiving_date, employee_id, item_id, Supplier_id)
VALUES (10, 9, 50.67, 'By sea', 'Intransit', '2026-01-01', 2, 3, 3),
	   (11, 10, 190, 'By air', 'Cancelled', '2024-10-12', 3 , 2, 2),
       (50, 40, 50.10, 'By road', 'Received', '2024-04-26', 1, 1, 3);
       
SELECT * FROM order_details;

DELIMITER $$
 CREATE TRIGGER Quantity_inHand_after_insert
      AFTER INSERT ON Order_details
	  FOR EACH ROW
BEGIN
     UPDATE item_details
	 SET Quantity_in_hand = quantity_in_hand + NEW.Quantity_Received
     WHERE Item_id = NEW.item_id;
END $$

INSERT INTO order_details (quantity_ordered, Quantity_Received , Unit_price, Ship_method, order_status, receiving_date, employee_id, item_id)
VALUES ( 10, 9, 50, 'By sea', 'Intransit', '2026-02-08', 2, 1);

-- QUESTION 6A
SELECT * 
FROM order_details
WHERE order_date >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
                         AND order_date < DATE_FORMAT(CURDATE() + INTERVAL 1 MONTH, '%Y-%m-01');
			
-- QUESTION 6B
SELECT * 
FROM order_details
WHERE order_date < DATE_SUB(CURDATE(), INTERVAL 2 YEAR);
 
 
 USE shophere;
-- QUESTION 6C
SELECT 
    s.supplier_id,
    s.first_name,
    s.last_name,
    s.address,
    s.phone,
    COUNT(o.purchase_order_id) AS Total_order
FROM order_details o
JOIN supplier_details s
     USING(supplier_id)
WHERE o.order_date >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
                         AND o.order_date < DATE_FORMAT(CURDATE() + INTERVAL 1 MONTH, '%Y-%m-01')
GROUP BY  s.supplier_id,
          s.first_name,
		  s.last_name,
		  s.address,
		  s.phone
ORDER BY Total_order DESC
LIMIT 2;

-- QUESTION 7
CREATE VIEW Total_costs AS
SELECT 
     purchase_order_id,
     SUM(quantity_ordered * unit_price ) AS Total_price
FROM order_details
GROUP BY purchase_order_id;
	
USE shophere;
INSERT INTO order_details (Quantity_Ordered, Quantity_Received, Unit_price, Ship_method, order_status, receiving_date, employee_id, item_id, Supplier_id)
VALUES (10, 9, 50.67, 'By sea', 'Intransit', '2026-01-01', 2, 3, 3),
	   (11, 10, 190, 'By air', 'Cancelled', '2024-10-12', 3 , 2, 2),
       (50, 40, 50.10, 'By road', 'Received', '2024-04-29', 1, 1, 3);

INSERT INTO order_details (Order_date, Quantity_Ordered, Quantity_Received, Unit_price, Ship_method, order_status, receiving_date, employee_id, item_id, Supplier_id)
VALUES ('2025-04-29', 10, 9, 50.67, 'By sea', 'Intransit', '2026-01-01', 2, 3, 3);

SELECT * FROM order_details;

DELIMITER $$
 CREATE TRIGGER Quantity_inHand_after_insert
      AFTER INSERT ON Order_details
	  FOR EACH ROW
BEGIN
     UPDATE item_details
	 SET Quantity_in_hand = quantity_in_hand + NEW.quantity_recieved
     WHERE Item_id = NEW.item_id;
END $$
  SELECT DATE_FORMAT(NOW(), '%Y-%M-01');
  
 -- QUESTION 6A 
  SELECT * 
FROM order_details
WHERE order_date >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
                         AND order_date < DATE_FORMAT(CURDATE() + INTERVAL 1 MONTH, '%Y-%m-01');
   
-- QUESTION 6B
-- QUESTION 6B
SELECT * 
FROM order_details
WHERE order_date < DATE_SUB(CURDATE(), INTERVAL 2 YEAR);
USE shophere;
-- QUESTION 6C
SELECT 
    s.supplier_id,
    s.first_name,
    s.last_name,
    s.address,
    s.phone,
    COUNT(o.purchase_order_id) AS Total_order
FROM order_details o
JOIN supplier_details s
     USING(supplier_id)
WHERE o.order_date >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
                         AND o.order_date < DATE_FORMAT(CURDATE() + INTERVAL 1 MONTH, '%Y-%m-01')
GROUP BY  s.supplier_id,
          s.first_name,
		  s.last_name,
		  s.address,
		  s.phone
ORDER BY Total_order
LIMIT 2;

DROP TRIGGER IF EXISTS order_date_not_greater;
DELIMITER $$
CREATE TRIGGER order_date_not_greater
BEFORE INSERT ON order_details
FOR EACH ROW
BEGIN 
    IF NEW.order_date > CURDATE() THEN
         SIGNAL SQLSTATE '45000' 
         SET MESSAGE_TEXT = 'KO POSSIBLE.';
	END IF;
END$$
INSERT INTO order_details (Order_date, Quantity_Ordered, Quantity_Received, Unit_price, Ship_method, order_status, receiving_date, employee_id, item_id, Supplier_id)
VALUES ('2025-04-29', 10, 9, 50.67, 'By sea', 'Intransit', '2026-01-01', 2, 3, 3);

DELIMITER $$
CREATE TRIGGER order_date_not_entered
BEFORE INSERT ON order_details
FOR EACH ROW
BEGIN 
    IF NEW.order_date IS NULL THEN
         SET NEW.Order_date = NOW() ;
	END IF;
END$$

INSERT INTO order_details ( Quantity_Ordered, Quantity_Received, Unit_price, Ship_method, order_status, receiving_date, employee_id, item_id, Supplier_id)
VALUES (10, 9, 50.67, 'By sea', 'Intransit', '2026-01-01', 2, 3, 3);
SELECT * FROM order_details;
USE shophere;
-- QUESTION 6C
SELECT 
    s.supplier_id,
    s.first_name,
    s.last_name,
    s.address,
    s.phone,
    COUNT(o.purchase_order_id) AS Total_order
FROM order_details o
JOIN supplier_details s
     USING(supplier_id)
WHERE o.order_date >= DATE_FORMAT(CURDATE(), '%Y-%m-01')
                         AND o.order_date < DATE_FORMAT(CURDATE() + INTERVAL 1 MONTH, '%Y-%m-01')
GROUP BY  s.supplier_id,
          s.first_name,
		  s.last_name,
		  s.address,
		  s.phone
ORDER BY Total_order DESC
LIMIT 2;

-- QUESTION 7
DROP VIEW IF EXISTS Total_costs;
CREATE VIEW Total_costs AS
SELECT 
     purchase_order_id,
     SUM(quantity_ordered * unit_price ) AS Total_price
FROM order_details
GROUP BY purchase_order_id;


SELECT Total_price 
FROM Total_costs
WHERE purchase_order_id= 1;

-- HHH
SELECT 
     SUM(quantity_ordered * unit_price ) AS Total_price
FROM order_details
WHERE purchase_order_id =1;


DROP TRIGGER IF EXISTS order_date_not_greater;
DELIMITER $$
CREATE TRIGGER order_date_not_greater
BEFORE INSERT ON order_details
FOR EACH ROW
BEGIN 
    IF NEW.order_date > CURDATE() THEN
         SET order_date = 'KO POSSIBLE.';
	END IF;
END$$


INSERT INTO order_details (Order_date, Quantity_Ordered, Quantity_Received, Unit_price, Ship_method, order_status, receiving_date, employee_id, item_id, Supplier_id)
VALUES ('2025-04-29', 10, 9, 50.67, 'By sea', 'Intransit', '2026-01-01', 2, 3, 3);
  
