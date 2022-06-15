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
FROM cte