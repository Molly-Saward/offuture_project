
-- Creating the master table
create view team12 as 
SELECT 
o.order_id,
oi.product_id,
sales AS basket_total,
quantity,
discount,
profit,
shipping_cost,
order_date,
ship_date,
ship_mode,
customer_id,
a.address_id,
market,
region,
order_priority,
city,
state,
country,
postal_code,
product_name,
category,
sub_category,
customer_name,
segment AS client_type 
FROM offuture.order_item oi
JOIN offuture.order o
ON oi.order_id = o.order_id 
JOIN offuture.address a
ON a.address_id = o.address_id 
JOIN offuture.product p
ON p.product_id = oi.product_id 
LEFT JOIN offuture.customer c
ON o.customer_id = c.customer_id_long
OR o.customer_id = c.customer_id_short;
--Slide 1 
--Intro Slide 

--Slide 2
--Revenue subsection 

--Slide 3
-- Revenue, Quarterly/Yearly, Shows the total sales per year, used for graph and table
SELECT 
    EXTRACT(YEAR FROM order_date) AS order_year,
    SUM(basket_total) AS sum_basket_total
FROM all_2509.team12
GROUP BY 
    EXTRACT(YEAR FROM order_date);

--Slide 4
-- Revenue By Market/Area, Shows the total sales for each area, for each year
--checked against Tableau graph at year status. 
SELECT 
    EXTRACT(YEAR FROM order_date) AS order_year,
    market,
    SUM(basket_total) AS sum_basket_total
FROM all_2509.team12
GROUP BY 
    EXTRACT(YEAR FROM order_date),
    market
ORDER BY 
    market;

--Slide 5
-- Question Time

--Slide 6
--Revenue Per Category 
--Shows the total sales per category
-- Used for graph and table 
SELECT 
        SUM(basket_total), 
        category
FROM all_2509.team12
GROUP BY category;
-- Shows total sales per sub-category
SELECT 
        SUM(basket_total), 
        category,
        sub_category
FROM all_2509.team12
GROUP BY category, sub_category;

--Side 7 
--Profit Subsection slide 

-- Slide 8 
-- Used to check figure on graph when x-axis was annual.
-- Used for total profit per year on table
SELECT 
    EXTRACT(YEAR FROM order_date) AS order_year,
    SUM(profit) AS total_profit
FROM all_2509.team12
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY total_profit ;

--Slide 9
--Profit Country Performance: Top and Bottom 5 graph and table
SELECT 
    SUM(profit),
    country
FROM 
    all_2509.team12
GROUP BY
    country
ORDER BY SUM(profit) ASC
LIMIT 5;
-- Top 5
SELECT 
    SUM(profit),
    country
FROM 
    all_2509.team12
GROUP BY
    country
ORDER BY SUM(profit) DESC
LIMIT 5;

--Slide 10
-- Profit by customer type and category of good for table 
SELECT 
    client_type
    ,category
    ,SUM(Profit) AS Total_Profit
FROM 
    all_2509.team12
GROUP BY client_type, category;
--Profit by customer type totals for graph 
SELECT 
    client_type
    ,SUM(Profit) AS Total_Profit
FROM 
    all_2509.team12
GROUP BY client_type;


--Slide 11 
-- Total profit per category table 
SELECT 
    category,
    SUM(profit) AS total_profit
FROM all_2509.team12
GROUP BY category
ORDER BY total_profit DESC;
--Year on Year Growth table  
SELECT 
    EXTRACT(YEAR FROM order_date) AS order_year,
    category,
    SUM(profit) AS total_profit
FROM all_2509.team12
GROUP BY EXTRACT(YEAR FROM order_date), category
ORDER BY category DESC;
--Profit distribution across product categories graph 
SELECT 
    category,
    sub_category,
    SUM(profit) AS total_profit
FROM all_2509.team12
GROUP BY category , sub_category
ORDER BY total_profit DESC;

--Slide 12
-- averages each product, then selects the max average of each proudct 
--for each sub category, shown in graph.  
SELECT 
    avg_table.sub_category,
    avg_table.product_name,
    avg_table.avg_profit
FROM (
    SELECT 
        t12.sub_category,
        t12.product_name,
        AVG(t12.profit) AS avg_profit
    FROM 
        all_2509.team12 t12
    GROUP BY 
        t12.sub_category, t12.product_name
) AS avg_table
INNER JOIN (
    SELECT 
        inner_avg.sub_category,
        MAX(inner_avg.avg_profit) AS max_avg_profit
    FROM (
        SELECT 
            t12.sub_category,
            t12.product_name,
            AVG(t12.profit) AS avg_profit
        FROM 
            all_2509.team12 t12
        GROUP BY 
            t12.sub_category, t12.product_name
    ) AS inner_avg
    GROUP BY 
        inner_avg.sub_category
) AS max_table
ON avg_table.sub_category = max_table.sub_category
   AND avg_table.avg_profit = max_table.max_avg_profit
ORDER BY 
    avg_table.sub_category;

--Slide 13 
--Additional Insights

--SLide 14
--Question Time

-- Slide 15
--Used to create pairs of top 10 most purchased items together. 
--chooses each unique pairing per order.
SELECT 
    sc1.sub_category AS subcat_a,
    sc2.sub_category AS subcat_b,
    COUNT(*) AS times_bought_together
FROM (
    SELECT DISTINCT order_id, sub_category
    FROM all_2509.team12
) sc1
JOIN (
    SELECT DISTINCT order_id, sub_category
    FROM all_2509.team12
) sc2
  ON sc1.order_id = sc2.order_id
 AND sc1.sub_category < sc2.sub_category   
GROUP BY sc1.sub_category, sc2.sub_category
ORDER BY times_bought_together desc
limit 10 ;

--Slide 16
--Shows the worst 7 countries for average standard shipping duration
SELECT AVG(ship_date - order_date) AS shipping,
       country
FROM all_2509.team12
WHERE ship_mode = 'Standard Class'
GROUP BY country
ORDER BY shipping DESC
LIMIT 7;

--Shows the best 7 countries for average standard shipping duration
SELECT AVG(ship_date - order_date) AS shipping,
       country
FROM all_2509.team12
WHERE ship_mode = 'Standard Class'
GROUP BY country
ORDER BY shipping
LIMIT 7;


--Slide 17
--Shows the average discount is 0.15 the same as trend line on graph 1.  
SELECT AVG(discount) average_discount
FROM 
(SELECT DISTINCT m.order_id, m.discount
FROM all_2509.team12 m)

-- SLide 18 
--Q and A silde