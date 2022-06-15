USE classicmodels;

-- Best Sales Rep Employee
SELECT
	t1.salesRepEmployeeNumber AS employee_number,
	SUM(t2.total_sales) AS employee_sales
FROM customers AS t1
LEFT JOIN
(
	SELECT
		o.customerNumber,
        SUM(od.sales) AS total_sales
    FROM orders AS o
    LEFT JOIN
    (
		SELECT
			orderNumber,
            SUM(quantityOrdered*priceEach) AS sales
		FROM orderdetails
        GROUP BY 1
    ) AS od
    ON o.orderNumber = od.orderNumber
    GROUP BY 1
) AS t2
ON t1.customerNumber = t2.customerNumber
GROUP BY 1
ORDER BY 1;


-- Region Sales
SELECT
	b.territory,
    SUM(a.employee_sales) AS territory_sales
FROM (	
    SELECT
		t1.salesRepEmployeeNumber AS employee_number,
		SUM(t2.total_sales) AS employee_sales
	FROM customers AS t1
	LEFT JOIN
	(
		SELECT
			o.customerNumber,
			SUM(od.sales) AS total_sales
		FROM orders AS o
		LEFT JOIN
		(
			SELECT
				orderNumber,
				SUM(quantityOrdered*priceEach) AS sales
			FROM orderdetails
			GROUP BY 1
		) AS od
		ON o.orderNumber = od.orderNumber
		GROUP BY 1
	) AS t2
	ON t1.customerNumber = t2.customerNumber
	GROUP BY 1
) AS a
RIGHT JOIN
(
	SELECT
		t3.employeeNumber,
		t4.territory
	FROM employees AS t3
    LEFT JOIN offices AS t4
    ON t3.officeCode = t4.officeCode
) AS b
ON a.employee_number = b.employeeNumber
GROUP BY 1
ORDER BY 2 DESC;


-- Monthly revenue
SELECT
	YEAR(t1.orderDate) AS year,
    MONTH(t1.orderDate) AS month,
    IFNULL(SUM(t2.revenue), 0) AS monthly_revenue
FROM orders AS t1
LEFT JOIN 
(
    SELECT
	    od.orderNumber,
        od.quantityOrdered*(od.priceEach - t3.buyPrice) AS revenue
    FROM orderdetails AS od
    RIGHT JOIN
    (
        SELECT
	        p.productCode,
            p.buyPrice
        FROM products AS p
        LEFT JOIN productlines AS pl
        ON p.productLine = pl.productLine
    ) AS t3
    ON od.productCode = t3.productCode
    GROUP BY 1
    ORDER BY 1
) AS t2
ON t1.orderNumber = t2.orderNumber
WHERE YEAR(t1.orderDate) BETWEEN 2003 AND 2005
GROUP BY 1, 2
ORDER BY 1, 2;


-- Quarterly revenue per country
SELECT
	b.year,
	b.quarter,
	a.country,
    IFNULL(SUM(b.revenue), 0) AS quarterly_revenue
FROM customers AS a
RIGHT JOIN
(	
	SELECT
		YEAR(t1.orderDate) AS year,
		QUARTER(t1.orderDate) AS quarter,
        t1.customerNumber,
		t2.revenue
	FROM orders AS t1
	LEFT JOIN 
	(
		SELECT
			od.orderNumber,
			od.quantityOrdered*(od.priceEach - t3.buyPrice) AS revenue
		FROM orderdetails AS od
		RIGHT JOIN
		(
			SELECT
				p.productCode,
				p.buyPrice
			FROM products AS p
			LEFT JOIN productlines AS pl
			ON p.productLine = pl.productLine
		) AS t3
		ON od.productCode = t3.productCode
		GROUP BY 1
		ORDER BY 1
	) AS t2
	ON t1.orderNumber = t2.orderNumber
	WHERE YEAR(t1.orderDate) BETWEEN 2003 AND 2005
) AS b
ON a.customerNumber = b.customerNumber
GROUP BY 1, 2, 3;


-- TSGW Transaction Record
WITH cte AS 
(
	SELECT
		YEAR(t2.orderDate) AS year,
		MONTH(t2.orderDate) AS month,
        t2.status,
        t2.orderNumber,
        SUM(t2.spent) AS spentAmount,
		SUM(SUM(t2.spent)) OVER (ORDER BY t2.orderNumber) AS cummulativeSpent,
        t1.creditLimit
	FROM customers AS t1
	LEFT JOIN
	(	
		SELECT
			o.orderDate,
			o.orderNumber,
			o.customerNumber,
            o.status,
            od.quantityOrdered*priceEach AS spent
		FROM orderdetails AS od
		RIGHT JOIN orders AS o
		ON od.orderNumber = o.orderNumber
	) AS t2
	ON t1.customerNumber = t2.customerNumber
	WHERE t1.customerName = 'The Sharp Gifts Warehouse'
	GROUP BY 4
)
SELECT
	year,
    month,
    orderNumber,
    spentAmount,
    IFNULL(creditLimit - LAG(cummulativeSpent) OVER (), creditLimit) AS creditLeft,
    status
FROM cte;


-- All Product Popularity (Monthly)
WITH cte AS
(	
    SELECT
		YEAR(t2.orderDate) AS year,
		MONTH(t2.orderDate) AS month,
		t2.orderNumber,
		t2.status,
		t1.productCode,
		SUM(t2.quantityOrdered) AS n_order,
        t1.quantityInStock
	FROM products AS t1
	JOIN
	(
		SELECT
			od.orderNumber,
			od.productCode,
			od.quantityOrdered,
			o.orderDate,
			o.status
		FROM orderdetails AS od
		LEFT JOIN orders AS o
		ON od.orderNumber = o.orderNumber
		WHERE o.status IN ('Shipped', 'Resolved', 'In Process')
	) AS t2
	ON t1.productCode = t2.productCode
	GROUP BY 5, 1, 2
	ORDER BY 3 ASC
	LIMIT 3000
)

SELECT
	*,
    (SELECT SUM(n_order) FROM cte cte1 WHERE cte.productCode = cte1.productCode AND ((cte1.year = cte.year AND cte1.month <= cte.month) OR (cte1.year < cte.year))) AS cummulative,
    quantityInStock - (SELECT SUM(n_order) FROM cte cte1 WHERE cte.productCode = cte1.productCode AND ((cte1.year = cte.year AND cte1.month <= cte.month) OR (cte1.year < cte.year))) AS stockLeft
FROM cte;


-- S18-3232 Product Popularity (Monthly)
WITH cte AS
(	
    SELECT
		YEAR(t2.orderDate) AS year,
		MONTH(t2.orderDate) AS month,
		t2.orderNumber,
		t2.status,
		t1.productCode,
		SUM(t2.quantityOrdered) AS n_order,
        t1.quantityInStock
	FROM products AS t1
	JOIN
	(
		SELECT
			od.orderNumber,
			od.productCode,
			od.quantityOrdered,
			o.orderDate,
			o.status
		FROM orderdetails AS od
		LEFT JOIN orders AS o
		ON od.orderNumber = o.orderNumber
		WHERE o.status IN ('Shipped', 'Resolved', 'In Process')
	) AS t2
	ON t1.productCode = t2.productCode
	GROUP BY 5, 1, 2
	ORDER BY 3 ASC
	LIMIT 3000
)

SELECT
	*,
    (SELECT SUM(n_order) FROM cte cte1 WHERE cte.productCode = cte1.productCode AND ((cte1.year = cte.year AND cte1.month <= cte.month) OR (cte1.year < cte.year))) AS cummulative,
    quantityInStock - (SELECT SUM(n_order) FROM cte cte1 WHERE cte.productCode = cte1.productCode AND ((cte1.year = cte.year AND cte1.month <= cte.month) OR (cte1.year < cte.year))) AS stockLeft
FROM cte
WHERE productCode = 'S18_3232';
