USE superstore_db;

-- 1) Sales & Profit by Region
SELECT region,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(100 * SUM(profit) / NULLIF(SUM(sales),0),2) AS profit_pct
FROM superstore
GROUP BY region
ORDER BY total_sales DESC;

-- 2) Monthly Sales Trend
SELECT order_month,
       ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY order_month
ORDER BY order_month;

-- 3) Top 10 Products by Sales
SELECT product_name,
       ROUND(SUM(sales),2) AS sales,
       ROUND(SUM(profit),2) AS profit
FROM superstore
GROUP BY product_name
ORDER BY sales DESC
LIMIT 10;

-- 4) Customer behavior: total orders & avg order value
SELECT customer_id,
       COUNT(DISTINCT order_id) AS num_orders,
       ROUND(SUM(sales)/NULLIF(COUNT(DISTINCT order_id),0),2) AS avg_order_value,
       ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY customer_id
ORDER BY total_profit DESC
LIMIT 20;

-- 5) Category performance
SELECT category,
       ROUND(SUM(sales),2) AS sales,
       ROUND(SUM(profit),2) AS profit,
       ROUND(100 * SUM(profit) / NULLIF(SUM(sales),0),2) AS profit_margin_pct
FROM superstore
GROUP BY category
ORDER BY sales DESC;

-- 6) Returns rate by Category
SELECT category,
       COUNT(DISTINCT CASE WHEN returned='Yes' THEN order_id END) AS returned_orders,
       COUNT(DISTINCT order_id) AS total_orders,
       ROUND(100 * COUNT(DISTINCT CASE WHEN returned='Yes' THEN order_id END) / NULLIF(COUNT(DISTINCT order_id),0),2) AS return_rate_pct
FROM superstore
GROUP BY category
ORDER BY return_rate_pct DESC;

-- 7) Monthly trend by actual date for plotting (first-of-month)
SELECT DATE_FORMAT(order_date, '%Y-%m-01') AS month_start,
       ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY month_start
ORDER BY month_start;

-- 8) Top product per category
SELECT category, product_name, sales
FROM (
  SELECT category, product_name,
         SUM(sales) AS sales,
         ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(sales) DESC) AS rn
  FROM superstore
  GROUP BY category, product_name
) t
WHERE rn = 1
ORDER BY category;

-- 9) Cumulative sales
SELECT order_date,
       SUM(SUM(sales)) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_sales
FROM superstore
GROUP BY order_date
ORDER BY order_date;

-- 10) Profit contribution (%) per product
SELECT product_name,
       ROUND(SUM(profit),2) AS profit,
       ROUND(100 * SUM(profit) / (SELECT SUM(profit) FROM superstore),2) AS profit_pct_of_total
FROM superstore
GROUP BY product_name
ORDER BY profit DESC
LIMIT 10;

-- 11)Yearly Sales & Profit Trend
SELECT YEAR(order_date) AS order_year,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY order_year
ORDER BY order_year;

-- 12) Top 5 Customers by Total Sales
SELECT customer_id,
       customer_name,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY customer_id, customer_name
ORDER BY total_sales DESC
LIMIT 5;

--13) Profit by Sub-Category
SELECT sub_category,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(100 * SUM(profit)/NULLIF(SUM(sales),0),2) AS profit_margin_pct
FROM superstore
GROUP BY sub_category
ORDER BY profit_margin_pct DESC;

--14) Sales by Ship Mode
SELECT ship_mode,
       COUNT(DISTINCT order_id) AS num_orders,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit
FROM superstore
GROUP BY ship_mode
ORDER BY total_sales DESC;

--15) Discount Impact on Profit
SELECT 
       CASE 
         WHEN discount = 0 THEN 'No Discount'
         WHEN discount BETWEEN 0.01 AND 0.20 THEN 'Low Discount (0-20%)'
         WHEN discount BETWEEN 0.21 AND 0.50 THEN 'Medium Discount (21-50%)'
         ELSE 'High Discount (50%+)' 
       END AS discount_band,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       ROUND(100 * SUM(profit)/NULLIF(SUM(sales),0),2) AS profit_margin_pct
FROM superstore
GROUP BY discount_band
ORDER BY total_sales DESC;

-- 16) Region-wise Top Category
SELECT region, category, sales
FROM (
   SELECT region, category, SUM(sales) AS sales,
          RANK() OVER (PARTITION BY region ORDER BY SUM(sales) DESC) AS rnk
   FROM superstore
   GROUP BY region, category
) t
WHERE rnk = 1;

-- 17) SELECT region, category, sales
FROM (
   SELECT region, category, SUM(sales) AS sales,
          RANK() OVER (PARTITION BY region ORDER BY SUM(sales) DESC) AS rnk
   FROM superstore
   GROUP BY region, category
) t
WHERE rnk = 1;

--18) Cumulative Monthly Sales (Running Total)
SELECT order_month,
       SUM(SUM(sales)) OVER (ORDER BY order_month) AS cumulative_sales
FROM superstore
GROUP BY order_month
ORDER BY order_month;

-- 19) Most Frequently Ordered Products
SELECT product_name,
       COUNT(DISTINCT order_id) AS num_orders,
       ROUND(SUM(sales),2) AS total_sales
FROM superstore
GROUP BY product_name
ORDER BY num_orders DESC
LIMIT 10;

--20) Customer Lifetime Value
SELECT customer_id,
       ROUND(SUM(sales),2) AS total_sales,
       ROUND(SUM(profit),2) AS total_profit,
       MIN(order_date) AS first_purchase,
       MAX(order_date) AS last_purchase,
       DATEDIFF(MAX(order_date), MIN(order_date)) AS days_active
FROM superstore
GROUP BY customer_id
ORDER BY total_profit DESC
LIMIT 10;





