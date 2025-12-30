/*
Change Over Time Analysis

Purpose:
    - Track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - Measure growth or decline over specific periods.

SQL Functions Used:
    - Date Functions: DATEPART(), DATETRUNC(), FORMAT()
    - Aggregate Functions: SUM(), COUNT(), AVG()
*/

-- Analyze sales performance over time
-- Quick Date Functions
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);
/*
order_year	order_month	total_sales	total_customers	total_quantity
2010	    12	        43419	    14	            14
2011	    1	        469795	    144	            144
2011	    2	        466307	    144	            144
2011	    3	        485165	    150         	150
2011	    4	        502042	    157	            157
*/

-- DATETRUNC()
SELECT
    DATETRUNC(month, order_date) AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);
/*
order_date	total_sales	total_customers	total_quantity
2010-12-01	43419	    14	            14
2011-01-01	469795	    144	            144
2011-02-01	466307	    144	            144
2011-03-01	485165	    150	            150
2011-04-01	502042	    157	            157
*/

-- FORMAT()
SELECT
    FORMAT(order_date, 'yyyy-MMM') AS order_date,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM');
/*
order_date	total_sales	total_customers	total_quantity
2010-Dec	43419	    14	            14
2011-Apr	502042  	157	            157
2011-Aug	614516	    193         	193
2011-Dec	669395	    222	            222
2011-Feb	466307	    144	            144
*/