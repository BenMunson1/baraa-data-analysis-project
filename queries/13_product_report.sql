/*
Product Report

Purpose:
	- This report consolidates key product metrics and behaviors.

Highlights:
	1. Gathers relevant fields such as product name, category, subcategory, and cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
	3. Aggregates product-level metrics:
	   - total orders
	   - total sales
	   - total quantity sold
	   - total customers (unique)
	   - lifespan (months)
	4. Calculates valuable KPIs:
	   - recency (months since last sale)
	   - average order revenue (AOR)
	   - average monthly revenue
*/

CREATE VIEW gold.report_products AS 
WITH base_query AS (
/*
	1) Base Query: Retrieves core columns from fact_sales and dim_products
*/
SELECT
	f.order_number,
	f.order_date,
	f.customer_key,
	f.sales_amount,
	f.quantity,
	p.product_key,
	p.product_name,
	p.category,
	p.subcategory,
	p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
WHERE order_date IS NOT NULL -- only valid sales dates
)

, product_aggregation AS (
/*
	2) Product Aggregations: Summarizes key metrics at the product level
*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_sale_date,
	COUNT(DISTINCT order_number) AS total_orders,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
FROM base_query
GROUP BY 
	product_key,
	product_name,
	category,
	subcategory,
	cost
)

/* 
	3) Final Query: Combines all product results into one output.
*/
SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_date,
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Average Order Revenue (AOR)
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,

	-- Average Monthly Revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue
FROM product_aggregation;
/*
product_key	product_name			category	subcategory		cost	last_sale_date	recency_in_months	product_segment	lifespan	total_orders	total_sales	total_quantity	total_customers	avg_selling_price	avg_order_revenue	avg_monthly_revenue
3			Mountain-100 Black- 38	Bikes		Mountain Bikes	1898	2011-12-27		168					High-Performer	11			49				165375		49				49				3375				3375				15034
4			Mountain-100 Black- 42	Bikes		Mountain Bikes	1898	2011-12-27		168					High-Performer	11			45				151875		45				45				3375				3375				13806
5			Mountain-100 Black- 44	Bikes		Mountain Bikes	1898	2011-12-21		168					High-Performer	11			60				202500		60				60				3375				3375				18409
*/