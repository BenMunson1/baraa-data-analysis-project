/*
Customer Report

Purpose:
	- This report consolidates key customer metrics and behaviors.

Highlights:
	1. Gathers relevant fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (months)
	4. Calculates valuable KPIs:
	   - recency (months since last order)
	   - average order value (AOV)
	   - average monthly spend
*/

CREATE VIEW gold.report_customers AS 
WITH base_query AS (
/*
	1) Base Query: Retrieves core columns from tables
*/
SELECT
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL
)

, customer_aggregation AS (
/*
	2) Customer Aggregations: Summarizes key metrics at the customer level
*/
SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
GROUP BY 
	customer_key,
	customer_number,
	customer_name,
	age
)
SELECT
customer_key,
customer_number,
customer_name,
age,
CASE WHEN age < 20 THEN 'Under 20'
	 WHEN age BETWEEN 20 AND 29 THEN '20-29'
	 WHEN age BETWEEN 30 AND 39 THEN '30-39'
	 WHEN age BETWEEN 40 AND 49 THEN '40-49'
	 ELSE '50 and above'
END AS age_group,
CASE
	WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
	ELSE 'New'
END AS customer_segment,
last_order_date,
DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency_in_months,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
-- Average order value (AVO)
CASE WHEN total_sales = 0 THEN 0
	 ELSE total_sales / total_orders
END AS avg_order_value,
-- Average monthly spend
CASE WHEN lifespan = 0 THEN total_sales
	 ELSE total_sales / lifespan 
END AS avg_monthly_spend
FROM customer_aggregation;
/*
customer_key	customer_number	customer_name	age	age_group		customer_segment	last_order_date	recency_in_months	total_orders	total_sales	total_quantity	total_products	lifespan	avg_order_value	avg_monthly_spend
1				AW00011000		Jon Yang		54	50 and above	VIP					2013-05-03		151					3				8249		8				8				28			2749			294
2				AW00011001		Eugene Huang	49	40-49			VIP					2013-12-10		144					3				6384		11				10				35			2128			182
3				AW00011002		Ruben Torres	54	50 and above	VIP					2013-02-23		154					3				8114		4				4				25			2704			324
*/