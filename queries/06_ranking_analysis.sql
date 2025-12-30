/*
Ranking Analysis

Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
*/

-- Which 5 products generate the highest revenue?
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;
/*
product_name	        total_revenue
Mountain-200 Black-46	1373454
Mountain-200 Black-42	1363128
Mountain-200 Silver-38	1339394
Mountain-200 Silver-46	1301029
Mountain-200 Black-38	1294854
*/

-- Ranking Using Window Functions
SELECT *
FROM (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        RANK() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE rank_products <= 5;
/*
product_name	        total_revenue	rank_products
Mountain-200 Black- 46	1373454	        1
Mountain-200 Black- 42	1363128	        2
Mountain-200 Silver- 38	1339394	        3
Mountain-200 Silver- 46	1301029	        4
Mountain-200 Black- 38	1294854	        5
*/

-- 5 worst-performing products in terms of sales
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue;
/*
product_name	        total_revenue
Racing Socks- L	        2430
Racing Socks- M	        2682
Patch Kit/8 Patches	    6382
Bike Wash - Dissolver	7272
Touring Tire Tube	    7440
*/

-- Top 10 customers who have generated the highest revenue
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;
/*
customer_key	first_name	last_name	total_revenue
1133	        Kaitlyn	    Henderson	13294
1302	        Nichole	    Nara	    13294
1309	        Margaret	He	        13268
1132	        Randall	    Dominguez	13265
1301	        Adriana	    Gonzalez	13242
1322	        Rosa	    Hu	        13215
1125	        Brandi	    Gill	    13195
1308	        Brad	    She	        13172
1297	        Francisco	Sara	    13164
434	            Maurice	    Shan	    12914
*/

-- The 3 customers with the fewest orders placed
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders;
/*
customer_key	first_name	last_name	total_orders
16	            Chloe	    Young	    1
17	            Wyatt	    Hill	    1
21          	Jordan	    King	    1
*/