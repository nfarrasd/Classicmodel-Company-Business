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