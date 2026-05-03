use ecom;
show tables ;
desc olist_customers_dataset;

SELECT * FROM olist_customers_dataset;

SELECT * FROM olist_orders_dataset;

SELECT * FROM geolocation;

SELECT * FROM product_category_name_translation;

SELECT * FROM olist_sellers_dataset;

SELECT * FROM olist_products_dataset;

SELECT * FROM olist_order_reviews_dataset;

SELECT * FROM olist_order_payments_dataset;

SELECT * FROM olist_order_items_dataset;

--  Fetch first 10 orders
SELECT * 
FROM olist_orders_dataset
LIMIT 10;
--  Used for data exploration.

-- 2. Count Total Customers
-- Total number of customers
SELECT COUNT(*) AS total_customers
FROM olist_customers_dataset;

-- 3. Filter Delivered Orders
-- Get only delivered orders
SELECT *
FROM olist_orders_dataset
WHERE order_status = 'delivered';

-- 4. Orders After 2017
-- Orders placed after 2017
SELECT *
FROM olist_orders_dataset
WHERE order_purchase_timestamp > '2017-01-01';

-- 5. Payments Greater than 500
-- High value payments
SELECT *
FROM olist_order_payments_dataset
WHERE payment_value > 500;

-- 2. JOIN QUERIES (6–10) ✅ (5 required)
-- 6. Orders with Customer Info
-- Join orders with customers
SELECT o.order_id, c.customer_city, c.customer_state
FROM olist_orders_dataset o
INNER JOIN olist_customers_dataset c
ON o.customer_id = c.customer_id;

-- Basic join.

-- 7. Orders + Payments
-- Join orders with payment details
SELECT o.order_id, o.order_status, p.payment_value
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id;

-- 8. Orders + Items + Products
-- Full order details
SELECT 
    o.order_id,
    p.product_category_name,
    oi.price
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_products_dataset p ON oi.product_id = p.product_id;

-- 9. Orders + Customers + Reviews
-- Get customer reviews with location
SELECT 
    o.order_id,
    c.customer_city,
    r.review_score
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id;

-- 10. Orders + Sellers + Products
-- Seller and product info per order
SELECT 
    oi.order_id,
    s.seller_city,
    p.product_category_name
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s ON oi.seller_id = s.seller_id
JOIN olist_products_dataset p ON oi.product_id = p.product_id;
-- 3. AGGREGATE + GROUP BY (11–16)
-- 11. Total Revenue
-- Total revenue
SELECT SUM(payment_value) AS total_revenue
FROM olist_order_payments_dataset;

-- 12. Orders Per State
-- Count orders by state
SELECT c.customer_state, COUNT(*) AS total_orders
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
GROUP BY c.customer_state;
-- 13. Avg Payment per Order
-- Average payment
SELECT AVG(payment_value) AS avg_payment
FROM olist_order_payments_dataset;

-- 14. Revenue per Category
-- Revenue by product category
SELECT p.product_category_name, SUM(oi.price) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name;

-- 15. Orders per City
-- Orders count by city
SELECT c.customer_city, COUNT(*) AS total_orders
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
GROUP BY c.customer_city;

-- 16. Avg Delivery Time
-- Average delivery days
SELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS avg_days
FROM olist_orders_dataset
WHERE order_status = 'delivered';

-- 4. HAVING (17–19)
-- 17. States with >1000 Orders
-- Filter high order states
SELECT c.customer_state, COUNT(*) AS total_orders
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
HAVING COUNT(*) > 1000;

-- 18. Categories with High Revenue
-- Categories with revenue > 100000
SELECT p.product_category_name, SUM(oi.price) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
HAVING SUM(oi.price) > 100000;

-- 19. Customers with Multiple Orders
-- Customers with more than 5 orders
SELECT customer_id, COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY customer_id
HAVING COUNT(*) > 5;

-- 5. SUBQUERIES (20–22) ✅ (3 required)
-- 20. Orders Above Avg Payment
-- Orders above average payment
SELECT *
FROM olist_order_payments_dataset
WHERE payment_value > (
    SELECT AVG(payment_value)
    FROM olist_order_payments_dataset
);

-- 21. Top Spending Customer
-- Customer with max spending
SELECT customer_id
FROM olist_orders_dataset
WHERE order_id IN (
    SELECT order_id
    FROM olist_order_payments_dataset
    ORDER BY payment_value DESC
    LIMIT 1
);
-- 22. Products Above Avg Price
-- Products with price above average
SELECT *
FROM olist_order_items_dataset
WHERE price > (
    SELECT AVG(price)
    FROM olist_order_items_dataset
);
-- 6. WINDOW FUNCTIONS (23–26)
  -- 23. Rank Customers
-- Rank customers by spending
SELECT 
    o.customer_id,
    SUM(p.payment_value) AS total_spent,
    RANK() OVER (ORDER BY SUM(p.payment_value) DESC) AS rank_pos
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
GROUP BY o.customer_id;

-- 24. Running Revenue
-- Running total revenue
SELECT 
    o.order_purchase_timestamp,
    SUM(p.payment_value) OVER (ORDER BY o.order_purchase_timestamp) AS running_total
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id;

-- 25. Dense Rank Categories
-- Rank categories by revenue
SELECT 
    p.product_category_name,
    SUM(oi.price) AS revenue,
    DENSE_RANK() OVER (ORDER BY SUM(oi.price) DESC) AS rank_pos
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name;

-- 26. Row Number per Order
-- Assign row number per order
SELECT 
    order_id,
    ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY price DESC) AS rn
FROM olist_order_items_dataset;

-- 7. VIEWS (27–28) ✅ (2 required)
-- 27. Order Summary View
-- Create view for order summary
CREATE VIEW order_summary AS
SELECT 
    o.order_id,
    c.customer_city,
    p.payment_value
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id;

-- 28. Category Revenue View
-- Create category revenue view
CREATE VIEW category_revenue AS
SELECT 
    p.product_category_name,
    SUM(oi.price) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name;

-- 8. STORED PROCEDURES (29–30) ✅ (2 required)
-- 29. Orders by State
DELIMITER //
CREATE PROCEDURE GetOrdersByState(IN state_name VARCHAR(5))
BEGIN
    SELECT o.order_id, c.customer_state
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
    WHERE c.customer_state = state_name;
END //

DELIMITER ;

-- calling sp 

CALL GetOrdersByState('SP');
-- 30. Customer Spending
DELIMITER //

CREATE PROCEDURE GetCustomerSpending(IN cust_id VARCHAR(50))
BEGIN
    SELECT 
        o.customer_id,
        SUM(p.payment_value) AS total_spent
    FROM olist_orders_dataset o
    JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
    WHERE o.customer_id = cust_id
    GROUP BY o.customer_id;
END //
DELIMITER ;

CALL GetCustomerSpending('your_customer_id_here');
CALL GetCustomerSpending('3ce436f183e68e07877b285a838db11a');

--  9. KPI + ADVANCED (31–35)
-- 31. Total Revenue KPI
SELECT SUM(payment_value) AS total_revenue
FROM olist_order_payments_dataset;

-- 32. Top 5 Categories
SELECT p.product_category_name, SUM(oi.price) AS revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY revenue DESC
LIMIT 5;

-- 33. Top Cities by Orders
SELECT c.customer_city, COUNT(*) AS total_orders
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
GROUP BY c.customer_city
ORDER BY total_orders DESC
LIMIT 5;

--  Payment Type Distribution
SELECT payment_type, COUNT(*) AS count
FROM olist_order_payments_dataset
GROUP BY payment_type;

--  Seller Performance
SELECT s.seller_id, COUNT(oi.order_id) AS total_orders
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s ON oi.seller_id = s.seller_id
GROUP BY s.seller_id
ORDER BY total_orders DESC;

-- indexing 
-- Create index on customer_id
CREATE INDEX idx_customer_id
ON olist_orders_dataset(customer_id);

SHOW INDEX FROM olist_orders_dataset;

-- Create index on order_id
CREATE INDEX idx_order_id
ON olist_order_items_dataset(order_id);

SHOW INDEX FROM olist_order_items_dataset;

-- CONSTRAINTS (Data Integrity)
-- Example: Add primary key
ALTER TABLE olist_orders_dataset
ADD PRIMARY KEY (order_id);

-- Add foreign key
ALTER TABLE olist_orders_dataset
ADD CONSTRAINT fk_customer
FOREIGN KEY (customer_id)
REFERENCES olist_customers_dataset(customer_id);

-- triggers  
-- I used triggers to automate actions after data insertion.
 
 -- Check null values  data cleaning 
 
SELECT *
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NULL;

