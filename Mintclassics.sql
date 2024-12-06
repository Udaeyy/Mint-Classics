SHOW TABLES ;

SELECT *
FROM warehouses ;
SELECT *
FROM products;
SELECT *
FROM productlines;
SELECT *
FROM orderdetails;
SELECT *
FROM payments;
SELECT *
FROM customers;
SELECT *
FROM orders;
SELECT *
FROM employees;
SELECT *
FROM offices;


-- Get total stock in each warehouse
SELECT warehouseName , sum(quantityInStock) AS TotalStock
FROM products
INNER JOIN warehouses ON warehouses.warehouseCode = products.warehouseCode
GROUP BY warehouseName
ORDER BY TotalStock DESC;

-- Get total stock for each Product Line by Warehouse
SELECT 
    w.warehouseName, 
    pl.productLine, 
    SUM(p.quantityInStock) AS TotalStock
FROM 
    products p
INNER JOIN 
    warehouses w ON w.warehouseCode = p.warehouseCode
INNER JOIN 
    productlines pl ON pl.productLine = p.productLine
GROUP BY 
    w.warehouseName, pl.productLine
ORDER BY 
    w.warehouseName, TotalStock DESC;


-- Get total stock for each product
SELECT 
    productCode,
    productName,
    SUM(quantityInStock) AS totalStock
FROM 
    products
GROUP BY 
    productCode, productName
ORDER BY 
    totalStock DESC;


-- Get comparative data between total stock & total order
SELECT productName, quantityInStock, sum(quantityOrdered) AS totalOrdered, ( quantityInStock - sum(quantityOrdered) ) AS currentInventory
FROM products
LEFT JOIN orderdetails ON products.productCode = orderdetails.productCode
GROUP BY productName
ORDER BY currentInventory DESC; 

-- Get total orders by time
SELECT orderDate, totalOrder
FROM orders AS o
LEFT JOIN ( SELECT
			orderNumber,
            sum(quantityOrdered) AS totalOrder
            FROM orderdetails
            GROUP BY orderNumber) od
ON o.orderNumber = od.orderNumber
ORDER BY orderDate;

-- Get the total revenue for each warehouse
SELECT warehouseName AS warehouse , sum(quantityOrdered) AS totalOrder , sum(quantityOrdered * priceEach) AS totalRevenue
FROM (products  
INNER JOIN orderdetails ON products.productCode = orderdetails.productCode) 
RIGHT JOIN warehouses ON warehouses.warehouseCode = products.warehouseCode
GROUP BY warehouse
ORDER BY totalRevenue DESC;

-- Get the total revenue and stock for each warehouse
SELECT 
    w.warehouseName, 
    SUM(p.quantityInStock) AS totalStock, 
    SUM(od.totalOrdered) AS totalOrdered, 
    SUM(od.totalRevenue) AS totalRevenue
FROM 
    warehouses w
LEFT JOIN 
    products p ON w.warehouseCode = p.warehouseCode
LEFT JOIN (
    SELECT 
        productCode,
        SUM(quantityOrdered) AS totalOrdered,
        SUM(quantityOrdered * priceEach) AS totalRevenue
    FROM 
        orderdetails
    GROUP BY 
        productCode
) od ON p.productCode = od.productCode
GROUP BY 
    w.warehouseName
ORDER BY 
    totalRevenue DESC;

    
-- Get the total revenue for each product line
SELECT productLine, sum(quantityOrdered) AS totalOrdered, sum(quantityOrdered * priceEach) AS totalRevenue
FROM products
INNER JOIN orderdetails ON products.productCode = orderdetails.productCode
GROUP BY productLine
ORDER BY totalRevenue;

-- Get the total revenue for each product
SELECT 
    p.productName, 
    p.quantityInStock, 
    p.buyPrice, 
    od.priceEach, 
    SUM(od.quantityOrdered) AS totalOrder, 
    SUM(od.quantityOrdered * od.priceEach) AS totalRevenue
FROM 
    products p
INNER JOIN 
    orderdetails od ON p.productCode = od.productCode
GROUP BY 
    p.productName, 
    p.quantityInStock, 
    p.buyPrice, 
    od.priceEach
ORDER BY 
    totalRevenue DESC;


-- Get customer profile data including orders and payments
SELECT  c.customerNumber, c.customerName, c.country, c.creditLimit, totalOrder, totalPayment, (totalPayment - c.creditLimit) AS creditLimitdiff
FROM (SELECT
		customerNumber,
        customerName,
        country,
        creditLimit
	FROM customers) c
LEFT JOIN 
	 (SELECT
     customerNumber,
     sum(amount) AS totalPayment
     FROM payments
     GROUP BY customerNumber) p
ON c.customerNumber = p.customerNumber
LEFT JOIN
	(SELECT
    customerNumber,
    count(orderNumber) AS totalOrder
    FROM orders
    GROUP BY  customerNumber) o
ON c.customerNumber = o.customerNumber
GROUP BY customerNumber
ORDER BY totalPayment DESC;

-- Get data on the number of employees in each office
SELECT  
    o.officeCode,
    o.city,
    o.country,
    COUNT(e.employeeNumber) AS totalEmployees
FROM 
    offices AS o
LEFT JOIN 
    employees AS e ON o.officeCode = e.officeCode
GROUP BY 
    o.officeCode, o.city, o.country
ORDER BY 
    totalEmployees DESC;


-- Get employee performance data
SELECT e.employeeNumber, 
		e.firstName, 
        e.lastName,
        e.jobTitle,
        count(o.orderNumber) AS totalSales
FROM employees AS e
LEFT JOIN customers AS c ON e.employeeNumber = c.salesRepEmployeeNumber
LEFT JOIN orders AS o ON c.customerNumber = o.customerNumber
GROUP BY employeeNumber
ORDER BY totalSales DESC;
        