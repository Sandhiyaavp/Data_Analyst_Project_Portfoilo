-- SQL Project Portfolio - Bike Store Relational Database --
-- Database Creation --

Create Database Bike_Store;
use Bike_Store;

-- BRANDS TABLE -- 
CREATE TABLE Brands (brand_id INT PRIMARY KEY, brand_name VARCHAR(100));

-- CATEGORIES TABLE --
CREATE TABLE Categories (category_id INT PRIMARY KEY, category_name VARCHAR(100));

-- CUSTOMERS TABLE --
CREATE TABLE Customers (customer_id INT PRIMARY KEY, first_name VARCHAR(50), last_name VARCHAR(50),
phone VARCHAR(20), email VARCHAR(100), street VARCHAR(100), city VARCHAR(50), state VARCHAR(50),
zip_code VARCHAR(10));

-- ORDERS TABLE --
CREATE TABLE Orders (order_id INT PRIMARY KEY, customer_id INT, order_status INT, order_date DATE,
required_date DATE, shipped_date DATE, store_id INT, staff_id INT,
FOREIGN KEY (customer_id) REFERENCES Customers(customer_id));

-- PRODUCTS TABLE --
CREATE TABLE Products (product_id INT PRIMARY KEY, product_name VARCHAR(150), brand_id INT,
category_id INT, model_year INT, list_price DECIMAL(10, 2),
FOREIGN KEY (brand_id) REFERENCES Brands(brand_id),
FOREIGN KEY (category_id) REFERENCES Categories(category_id));

-- ORDER-ITEMS TABLE --
CREATE TABLE Order_Items (order_id INT, item_id INT, product_id INT,  
quantity INT, list_price DECIMAL(10, 2),discount DECIMAL(4, 2), 
FOREIGN KEY (order_id) REFERENCES Orders(order_id),
FOREIGN KEY (product_id) REFERENCES Products(product_id));

-- Preview data --
select * from Brands;
select * from Categories;
select * from Customers;
select * from Orders;
select * from Order_Items;
select * from Products;

--  Total Revenue Calculation --
SELECT 
ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) 
AS total_revenue 
FROM Order_items oi;

-- Revenue By Category --
SELECT c.category_name, ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS revenue
FROM Order_items oi
JOIN Products p ON oi.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY revenue DESC;

-- Top 5 Selling Products --
SELECT p.product_name, SUM(oi.quantity) AS total_quantity_sold
FROM Order_items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- Top 5 Customers By Spending --
SELECT CONCAT(c.first_name , ' ' , c.last_name) AS customer_name,
ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS total_spent
FROM Order_items oi
JOIN Orders o ON oi.order_id = o.order_id   
JOIN Customers c ON o.customer_id = c.customer_id 
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 5;

-- Brand Performance – Revenue by Brand --
SELECT b.brand_name,
ROUND(SUM(oi.quantity * oi.list_price * (1 - oi.discount)), 2) AS brand_revenue
FROM Order_items oi
JOIN Products p ON oi.product_id = p.product_id
JOIN Brands b ON p.brand_id = b.brand_id
GROUP BY b.brand_name
ORDER BY brand_revenue DESC;

-- Rank Products by Total Revenue --
WITH product_sales AS (
SELECT p.product_name,
SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS total_revenue
FROM Order_items oi
JOIN Products p ON oi.product_id = p.product_id
GROUP BY p.product_name)
SELECT *, RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank FROM product_sales;

-- Top 3 Products per Category (Window Function + CTE) --
WITH category_sales AS (
SELECT c.category_name, p.product_name,
SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS revenue
FROM Order_items oi
JOIN Products p ON oi.product_id = p.product_id
JOIN Categories c ON p.category_id = c.category_id
GROUP BY c.category_name, p.product_name),
ranked_products AS (
SELECT *, RANK() OVER (PARTITION BY category_name ORDER BY revenue DESC) AS category_rank
FROM category_sales)
SELECT * FROM ranked_products
WHERE category_rank <= 3;

-- Average Time to Ship Per Order --
SELECT order_id, order_date, shipped_date, 
DATEDIFF(
STR_TO_DATE(shipped_date, '%Y-%m-%d'),
STR_TO_DATE(order_date, '%Y-%m-%d')) 
AS days_to_ship
FROM Orders
WHERE order_date IS NOT NULL and shipped_date IS NOT NULL ;
