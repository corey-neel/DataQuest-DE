/*customers contains all customer data
employees contain all employee data
offices: sales office information 
orderdetails: details of each order separated by order number and line number. 
orders: shipping information/status by order number, contains customer number. 
payments: payment information, contains customer number, check no, and amount. 
productlines: product line and description
products: detailed information about each product
*/

SELECT
    'Customers' AS table_name,
    (SELECT COUNT(*)
     FROM pragma_table_info('Customers')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM customers

UNION

SELECT
    'Employees' AS table_name,
    (SELECT COUNT(*)
     FROM pragma_table_info('employees')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM employees

UNION

SELECT
    'Offices' AS table_name,
    (SELECT COUNT(*)
     FROM pragma_table_info('Offices')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM offices

UNION

SELECT
    'Order Details' AS table_name,
    (SELECT COUNT(*)
     FROM pragma_table_info('OrderDetails')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM orderdetails

UNION

SELECT
    'Orders' AS table_name,
    (SELECT COUNT(*)
     FROM pragma_table_info('Orders')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM orders

UNION

SELECT
    'Payments' AS table_name,
    (SELECT COUNT(*)
     FROM pragma_table_info('Payments')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM payments

UNION

SELECT
    'ProductLines' AS table_name,
    (SELECT COUNT(*)
     FROM pragma_table_info('productlines')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM productlines

UNION

SELECT
    'Products' AS table_name,
    (SELECT COUNT(*)
     FROM pragma_table_info('Products')) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM products;

--Question 1:
WITH low_stock AS 
(
SELECT p.productCode, 
	   SUM(od.quantityOrdered) AS ordered,
	   p.quantityInStock AS in_stock,
	   ROUND(SUM(od.quantityOrdered) / CAST(p.quantityInStock AS REAL), 2) AS stock_ratio
  FROM orderdetails AS od
  JOIN products AS p
    ON p.productCode = od.productCode
 GROUP BY p.productCode
 ORDER BY stock_ratio DESC
LIMIT 10
),
product_perf AS
(SELECT productCode, SUM(quantityOrdered * priceEach) AS product_performance
FROM orderdetails AS od
GROUP BY productCode
ORDER BY product_performance DESC
LIMIT 10)

SELECT ls.productCode AS productCode
  FROM low_stock AS ls
 WHERE ls.productCode IN (SELECT productCode
							FROM product_perf)
;

--Question 2: Determining most and least engaged customers by profit. 
WITH customer_profit AS (
SELECT o.customerNumber, 
	   SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  FROM orders AS o
  JOIN orderdetails AS od
    ON o.orderNumber = od.orderNumber
  JOIN products AS p
    ON p.productCode = od.productCode
 GROUP BY o.customerNumber)

SELECT c.contactLastName AS last_name,
       c.contactFirstName AS first_name,
	   c.city,
	   c.country,
	   cp.profit
  FROM customers AS c
  JOIN customer_profit AS cp
    ON cp.customerNumber = c.customerNumber
 ORDER BY cp.profit DESC --DESC determines top 5 more valuable customers by profit, remove or change to ASC to determine 5 least valuable customers by profit. 
 LIMIT 5;

--Question 3: How much can we spend on acquiring new customers
WITH customer_profit AS (
SELECT o.customerNumber, 
	   SUM(od.quantityOrdered * (od.priceEach - p.buyPrice)) AS profit
  FROM orders AS o
  JOIN orderdetails AS od
    ON o.orderNumber = od.orderNumber
  JOIN products AS p
    ON p.productCode = od.productCode
 GROUP BY o.customerNumber)

SELECT ROUND(AVG(profit),2) AS avg_profit_per_customer
FROM customer_profit;
