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