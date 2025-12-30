/*
Performance Analysis (Year-over-Year, Month-over-Month)

Purpose:
    - Measure the performance of products, customers, or regions over time.
    - Benchmarking and identifying high-performing entities.
    - Track yearly trends and growth.

SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY 
        YEAR(f.order_date),
        p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    -- Year-over-Year Analysis
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;
/*
order_year	product_name	        current_sales	avg_sales	diff_avg	avg_change	py_sales	diff_py	py_change
2012	    All-Purpose Bike Stand	159	            13197	    -13038	    Below Avg	NULL	    NULL	No Change
2013	    All-Purpose Bike Stand	37683	        13197	    24486	    Above Avg	159	        37524	Increase
2014	    All-Purpose Bike Stand	1749	        13197	    -11448	    Below Avg	37683	    -35934	Decrease
2012	    AWC Logo Cap	        72	            6570	    -6498	    Below Avg	NULL	    NULL	No Change
2013	    AWC Logo Cap	        18891	        6570	    12321	    Above Avg	72	        18819	Increase
*/