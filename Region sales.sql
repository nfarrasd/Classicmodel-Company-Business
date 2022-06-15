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