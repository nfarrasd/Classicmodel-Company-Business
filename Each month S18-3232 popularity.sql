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