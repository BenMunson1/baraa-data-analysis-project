/*
Cumulative Analysis

Purpose:
    - Calculate running totals or moving averages for key metrics.
    - Track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.

SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
*/

-- Calculate the total sales per month and the running total of sales over time 
SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
	AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
    SELECT 
        DATETRUNC(year, order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(year, order_date)
) t
/*
order_date	total_sales	running_total_sales	moving_average_price
2010-01-01	43419	    43419	            3101
2011-01-01	7075088	    7118507	            3146
2012-01-01	5842231 	12960738	        2670
2013-01-01	16344878	29305616	        2080
2014-01-01	45642	    29351258	        1668
*/