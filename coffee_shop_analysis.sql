-- Monday Coffee -- Data Analysis 

SELECT *
FROM monday_coffee_db.city;
SELECT *
FROM monday_coffee_db.products;
SELECT *
FROM monday_coffee_db.customers;
SELECT *
FROM monday_coffee_db.sales;

-- Reports & Data Analysis 

-- Q.1 Coffee Consumers Count 
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT city_name, 
ROUND(
(population * 0.25)/1000000, 2) as 'coffee_consumers_in_millions', 
city_rank
FROM monday_coffee_db.city
ORDER BY 2 DESC
;

-- Q2. Total revenue from coffee sales 
-- What's the total revenue generated from coffee sales across all cities in the last quarter of 2023? 

-- Total revenue of all cities 

SELECT 
	SUM(total) as total_revenue
-- 	EXTRACT(YEAR FROM sale_date) AS year,
-- 	EXTRACT(QUARTER FROM sale_date) AS qtr
FROM monday_coffee_db.sales
    WHERE 
    EXTRACT(YEAR FROM sale_date) >= 2023
    AND EXTRACT(QUARTER FROM sale_date) = 4
;

-- Total revenues of each cities respectively

SELECT 
	ci.city_name, 
	SUM(s.total) AS total_revenue
FROM monday_coffee_db.sales AS s
JOIN monday_coffee_db.customers AS c
ON s.customer_id = c.customer_id 
JOIN monday_coffee_db.city AS ci
ON ci.city_id = c.city_id 
    WHERE 
    EXTRACT(YEAR FROM s.sale_date) = 2023
    AND 
    EXTRACT(quarter FROM s.sale_date) = 4
GROUP BY 1
ORDER BY 2 DESC 
;

-- Q3. Sales count for each products
-- How may units of each coffee products that has been produced?  


SELECT 
	 p.product_name,
     COUNT(s.sale_id) AS total_orders
FROM monday_coffee_db.products AS p
LEFT JOIN monday_coffee_db.sales AS s
ON s.product_id = p.product_id
GROUP BY 1 
ORDER BY 2 DESC
;

-- Q4 Average Sales Amount per City
-- What is the average sales amount per customers in each city?

-- 1. Find city and total sales
-- 2. Find the number customers in each of these city


SELECT 
	ci.city_name, 
	SUM(s.total) AS total_revenue,
    COUNT(DISTINCT s.customer_id) AS total_cust,              -- If I don't add the distinct, it's going to give the total amount that has been bought. The distinct helps to show the amount of customers
	ROUND(
		SUM(s.total)/
					COUNT(DISTINCT s.customer_id, 2)) 
                    AS avg_sales_per_cust
FROM monday_coffee_db.sales AS s
JOIN monday_coffee_db.customers AS c
ON s.customer_id = c.customer_id 
JOIN monday_coffee_db.city AS ci
ON ci.city_id = c.city_id 
GROUP BY 1
ORDER BY 2 DESC 
;

-- Q.5 City Population and Coffee Consumers (25%)
-- Provide a list of cities along with their populations and estimated coffee consumers 

-- Make sure to return city_name, estimated coffe consumers (25%), total current cust, 

-- Estimated coffee consumers 
SELECT 
	 city_name,
     ROUND((population * 0.25)/1000000) AS coffee_consumers
FROM monday_coffee_db.city ;

-- Customers in our database who already purchased our products
SELECT 
	ci.city_name,
    COUNT(DISTINCT c.customer_id) AS unique_cust
FROM monday_coffee_db.sales AS s 
JOIN monday_coffee_db.customers AS c
	ON c.customer_id = s.customer_id
JOIN monday_coffee_db.city AS ci
	ON ci.city_id = c.city_id
GROUP BY 1;


WITH city_table AS
(SELECT 
	 city_name,
     ROUND((population * 0.25)/1000000) AS coffee_consumers
FROM monday_coffee_db.city
),
customers_table
AS
(	SELECT 
		ci.city_name,
		COUNT(DISTINCT c.customer_id) AS unique_cust
	FROM monday_coffee_db.sales AS s 
	JOIN monday_coffee_db.customers AS c
		ON c.customer_id = s.customer_id
	JOIN monday_coffee_db.city AS ci
		ON ci.city_id = c.city_id
	GROUP BY 1
)
SELECT 
	customers_table.city_name,
    city_table.coffee_consumers AS coffee_consumers_in_millions,
    customers_table.unique_cust
FROM city_table 
JOIN customers_table 
	ON city_table.city_name = customers_table.city_name
;

SELECT 
    ci.city_name,
    COUNT(DISTINCT c.customer_id) AS unique_cust,
    ROUND(ci.population * 0.25 / 1000000, 2) AS coffee_consumers_in_millions
FROM monday_coffee_db.city AS ci
LEFT JOIN monday_coffee_db.customers AS c
    ON c.city_id = ci.city_id
--    GROUP BY 1
--    ORDER BY 2;
 GROUP BY ci.city_name, ci.population   -- better to explicitly list columns
 ORDER BY unique_cust DESC;




-- Q6 Top Selling Products by City
-- What are the 3 top selling products in each cities based on sales volume?

-- Finding each cities, the product id, sales id 

-- Combining all tables together 

SELECT *
FROM monday_coffee_db.sales AS s 
JOIN monday_coffee_db.products AS p
	ON s.product_id = p.product_id
JOIN monday_coffee_db.customers as c
	ON c.customer_id = s.customer_id 
JOIN monday_coffee_db.city as ci
	ON ci.city_id = c.city_id 
;

-- Finding city name, product name, total order. Then, organize it from highest order to lowest to find the top 3 best selling 

SELECT * 
FROM 
(
SELECT 
	ci.city_name,
    p.product_name,
    COUNT(s.sale_id) AS total_order,
    DENSE_RANK() OVER(
		  PARTITION BY ci.city_name 
          ORDER BY COUNT(s.sale_id) DESC
          ) AS product_rank
FROM monday_coffee_db.sales AS s 
JOIN monday_coffee_db.products AS p
	ON s.product_id = p.product_id
JOIN monday_coffee_db.customers AS c
	ON c.customer_id = s.customer_id 
JOIN monday_coffee_db.city AS ci
	ON ci.city_id = c.city_id 
    GROUP BY 1, 2
--  ORDER BY 1, 3 DESC
) as t1
WHERE product_rank <= 3
;


-- Q7. Customer's Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products? 

-- Find and filter only the coffee products, then find distinct customers

SELECT 
	ci.city_name,
    COUNT(DISTINCT c.customer_id) AS unique_cust
FROM monday_coffee_db.city AS ci
LEFT JOIN monday_coffee_db.customers AS c
    ON c.city_id = ci.city_id
JOIN monday_coffee_db.sales AS s 
	ON s.customer_id = c.customer_id 
JOIN monday_coffee_db.products AS p
	ON p.product_id = s.product_id
WHERE 
	s.product_id IN (1, 2, 3 , 4, 5, 6, 7, 8 , 9, 10, 11, 12, 13, 14)
GROUP BY 1
;

-- Q8. Average Sale vs Rent 
-- Find each city and their average sale per customer and average rent per customer
-- Conclusion

-- Joining the tables -- 
SELECT *
FROM monday_coffee_db.city AS ci
LEFT JOIN monday_coffee_db.customers AS c
	ON c.city_id = ci.city_id 
JOIN monday_coffee_db.sales AS s
	ON s.customer_id = c.customer_id
JOIN monday_coffee_db.products AS p
	ON p.product_id = s.product_id
-- GROUP BY 1
;

-- Average sale and rent (Average sale = sale/customer Average rent = rent/customer 
WITH city_table
AS 
(
	SELECT                                                        -- Total cust, AVG sale 
		ci.city_name, 
		COUNT(DISTINCT s.customer_id) AS total_cust,              
		ROUND(
			SUM(s.total)/
						COUNT(DISTINCT s.customer_id)
                        ,2)AS avg_sales_per_cust
	FROM monday_coffee_db.sales AS s
	JOIN monday_coffee_db.customers AS c
		ON s.customer_id = c.customer_id 
	JOIN monday_coffee_db.city AS ci
		ON ci.city_id = c.city_id 
    GROUP BY 1
    ORDER BY 2 DESC
),
city_rent
AS 
(
SELECT 
	city_name,                                                     -- Estimated rent 
	estimated_rent 
FROM monday_coffee_db.city
)
SELECT 
	cr.city_name,
    cr.estimated_rent,
    ct.total_cust,
    ct.avg_sales_per_cust, 
    ROUND(
    cr.estimated_rent/ct.total_cust,
    2) AS avg_rent_per_cust
FROM city_rent AS cr
JOIN city_table AS ct
	ON cr.city_name = ct.city_name 
ORDER BY 4 DESC
;

-- Q9. Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)

-- By each city
WITH
monthly_sales
AS 
(
	SELECT 
		ci.city_name,
		EXTRACT(MONTH FROM sale_date) AS 'month',            -- sale join cust, because city doesn't have city_id 
		EXTRACT(YEAR FROM sale_date) AS 'year',
		SUM(s.total) AS total_sale,
		LAG(SUM(s.total), 1) OVER(PARTITION BY ci.city_name)                          -- previous rows, prev sales in this case 
	FROM monday_coffee_db.sales AS s
	JOIN monday_coffee_db.customers AS c
		ON c.customer_id = s.customer_id
	JOIN monday_coffee_db.city AS ci
	ON ci.city_id = c.city_id
	GROUP BY 1, 2, 3
	ORDER BY 1, 3, 2
)
,
growth_ratio
AS
( 
	SELECT
		city_name,
		month,
		year,
		total_sale as cr_month_sale,
		LAG(total_sale, 1) OVER (PARTITION BY city_name ORDER BY `year`, `month` ) AS last_month_sale
	FROM monthly_sales
)

SELECT 
	city_name,
    month,
    year,
    cr_month_sale,
    last_month_sale,
    ROUND(
		(cr_month_sale - last_month_sale)/last_month_sale *100, 2
        ) AS percentage
FROM growth_ratio
WHERE 
	last_month_sale IS NOT NULL
;


-- Q10 Market Potential Analysis 
-- Identify top 3 city based on the highest sales, return city name, total sale, total rent, total customers, estimated coffee consumers 

WITH city_table
AS 
(
	SELECT                                                        -- Total cust, AVG sale 
		ci.city_name, 
		COUNT(DISTINCT s.customer_id) AS total_cust, 
        SUM(s.total) AS total_revenue, 
		ROUND(
			SUM(s.total)/
						COUNT(DISTINCT s.customer_id)
                        ,2)AS avg_sales_per_cust
	FROM monday_coffee_db.sales AS s
	JOIN monday_coffee_db.customers AS c
		ON s.customer_id = c.customer_id 
	JOIN monday_coffee_db.city AS ci
		ON ci.city_id = c.city_id 
    GROUP BY 1
    ORDER BY 2 DESC
),
city_rent
AS 
(
SELECT 
	city_name,                                                     -- Estimated rent 
	estimated_rent,
    ROUND(population * 0.25/1000000, 3) AS estimated_coffee_consumer_in_millions
FROM monday_coffee_db.city
)
SELECT 
	cr.city_name,
    ct.total_revenue,
    cr.estimated_rent AS total_rent,
    ct.total_cust,
    cr.estimated_coffee_consumer_in_millions,
    ct.avg_sales_per_cust, 
    ROUND(
    cr.estimated_rent/ct.total_cust,
    2) AS avg_rent_per_cust
FROM city_rent AS cr
JOIN city_table AS ct
	ON cr.city_name = ct.city_name 
ORDER BY 2 DESC
;

-- Recommendation
-- City 1: Pune 
-- Low average rent per customer, big profit, avg sale per customer is also high
-- City 2: Delhi
-- Highest estimated coffee consumer which is 7.7M (Better chance to acquaire more potential custs
-- Highest total cost which is 68
-- Average rent per cust is 330 (still under 500)
-- City 3. Jaipur
-- Highest current customers is 69
-- Average rent per cusotomer is less (156)
-- Average sale per customer is better which is at 11.6k


