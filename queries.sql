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


