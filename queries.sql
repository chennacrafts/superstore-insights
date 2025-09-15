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
