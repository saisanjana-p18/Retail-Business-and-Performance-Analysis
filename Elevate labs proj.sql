create database retail_db;
use retail_db;
CREATE TABLE retail_inventory (
    `date` DATE,
    store_id VARCHAR(10),
    product_id VARCHAR(20),
    category VARCHAR(50),
    region VARCHAR(30),
    inventory_level INT,
    units_sold INT,
    units_ordered INT,
    demand_forecast DECIMAL(10,2),
    price DECIMAL(10,2),
    discount_pct INT,
    weather_condition VARCHAR(30),
    holiday_promotion TINYINT,
    competitor_pricing DECIMAL(10,2),
    seasonality VARCHAR(20)
);
SELECT COUNT(*) AS total_rows
FROM retail_inventory;

SELECT *
FROM retail_inventory
LIMIT 10;

#Category-wise Sales Performance
SELECT
    category,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(units_sold * price), 2) AS total_revenue,
    ROUND(AVG(price), 2) AS average_price
FROM retail_inventory
GROUP BY category
ORDER BY total_revenue DESC;

#Inventory Performance Analysis
SELECT
    category,
    SUM(inventory_level) AS total_inventory,
    SUM(units_sold) AS total_units_sold,
    ROUND(
        SUM(units_sold) / NULLIF(SUM(inventory_level), 0), 2
    ) AS inventory_turnover_proxy
FROM retail_inventory
GROUP BY category
ORDER BY inventory_turnover_proxy DESC;

#Seasonal Sales Analysis
SELECT
    seasonality,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(units_sold * price), 2) AS total_revenue
FROM retail_inventory
GROUP BY seasonality
ORDER BY total_revenue DESC;

#Monthly Sales Trend Analysis
SELECT
    MONTHNAME(date) AS month_name,
    MONTH(date) AS month_number,
    SUM(units_sold) AS total_units_sold,
    ROUND(SUM(units_sold * price), 2) AS total_revenue
FROM retail_inventory
GROUP BY MONTH(date), MONTHNAME(date)
ORDER BY month_number;

#Discount analysis
SELECT
    MIN(discount_pct) AS minimum_discount,
    MAX(discount_pct) AS maximum_discount,
    AVG(discount_pct) AS average_discount,
    COUNT(*) AS total_records
FROM retail_inventory;

#Calculate Net Revenue
SELECT
    category,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100)),
        2
    ) AS net_revenue,
    ROUND(
        SUM(units_sold * price),
        2
    ) AS revenue_before_discount
FROM retail_inventory
GROUP BY category
ORDER BY net_revenue DESC;

#Estimated Gross Profit Analysis
SELECT
    category,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100)),
        2
    ) AS net_revenue,
    ROUND(
        SUM(units_sold * price * 0.70),
        2
    ) AS estimated_cost,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100))
        - SUM(units_sold * price * 0.70),
        2
    ) AS estimated_gross_profit
FROM retail_inventory
GROUP BY category
ORDER BY estimated_gross_profit DESC;

#Regional Sales and Profitability Analysis
SELECT
    region,
    SUM(units_sold) AS total_units_sold,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100)),
        2
    ) AS net_revenue,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100))
        - SUM(units_sold * price * 0.70),
        2
    ) AS estimated_gross_profit
FROM retail_inventory
GROUP BY region
ORDER BY net_revenue DESC;

#Stock Shortage and Excess Inventory Analysis
SELECT
    CASE
        WHEN inventory_level < demand_forecast
            THEN 'Stock Shortage Risk'
        WHEN inventory_level > demand_forecast
            THEN 'Excess Stock'
        ELSE 'Balanced Stock'
    END AS inventory_status,
    COUNT(*) AS total_records,
    SUM(units_sold) AS total_units_sold
FROM retail_inventory
GROUP BY inventory_status
ORDER BY total_records DESC;

#Identify Categories with Inventory Problems
SELECT
    category,
    SUM(CASE
        WHEN inventory_level < demand_forecast THEN 1
        ELSE 0
    END) AS shortage_records,
    SUM(CASE
        WHEN inventory_level > demand_forecast THEN 1
        ELSE 0
    END) AS excess_stock_records,
    SUM(inventory_level) AS total_inventory,
    SUM(demand_forecast) AS total_forecast
FROM retail_inventory
GROUP BY category
ORDER BY shortage_records DESC;

#Product-wise Inventory Analysis
SELECT
    product_id,
    category,
    SUM(inventory_level) AS total_inventory,
    SUM(units_sold) AS total_units_sold,
    SUM(demand_forecast) AS total_forecast,
    SUM(CASE
        WHEN inventory_level < demand_forecast THEN 1
        ELSE 0
    END) AS shortage_records
FROM retail_inventory
GROUP BY product_id, category
ORDER BY shortage_records DESC
LIMIT 10;

#Store-wise Performance Analysis
SELECT
    store_id,
    SUM(units_sold) AS total_units_sold,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100)), 2
    ) AS net_revenue,
    ROUND(AVG(inventory_level), 2) AS avg_inventory,
    SUM(CASE
        WHEN inventory_level < demand_forecast THEN 1
        ELSE 0
    END) AS shortage_records
FROM retail_inventory
GROUP BY store_id
ORDER BY net_revenue DESC;

#Year-wise Sales Trend
SELECT
    YEAR(date) AS sales_year,
    SUM(units_sold) AS total_units_sold,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100)), 2
    ) AS net_revenue
FROM retail_inventory
GROUP BY YEAR(date)
ORDER BY sales_year;

#Check yearly data coverage
SELECT
    YEAR(date) AS sales_year,
    MIN(date) AS first_date,
    MAX(date) AS last_date,
    COUNT(*) AS total_records
FROM retail_inventory
GROUP BY YEAR(date)
ORDER BY sales_year;

#Promotion vs Non-Promotion Sales
SELECT
    holiday_promotion,
    COUNT(*) AS total_records,
    SUM(units_sold) AS total_units_sold,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100)), 2
    ) AS net_revenue,
    ROUND(AVG(units_sold), 2) AS average_units_sold
FROM retail_inventory
GROUP BY holiday_promotion
ORDER BY holiday_promotion;

#Weather-wise Sales Performance
SELECT
    weather_condition,
    COUNT(*) AS total_records,
    SUM(units_sold) AS total_units_sold,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100)), 2
    ) AS net_revenue,
    ROUND(AVG(units_sold), 2) AS average_units_sold
FROM retail_inventory
GROUP BY weather_condition
ORDER BY net_revenue DESC;

#Category-wise Seasonal Performance
SELECT
    category,
    seasonality,
    SUM(units_sold) AS total_units_sold,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100)), 2
    ) AS net_revenue
FROM retail_inventory
GROUP BY category, seasonality
ORDER BY category, net_revenue DESC;

#Top 10 Products by Net Revenue
SELECT
    product_id,
    category,
    SUM(units_sold) AS total_units_sold,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100)), 2
    ) AS net_revenue
FROM retail_inventory
GROUP BY product_id, category
ORDER BY net_revenue DESC
LIMIT 10;

#Top 10 Products by Estimated Gross Profit
SELECT
    product_id,
    category,
    SUM(units_sold) AS total_units_sold,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100))
        - SUM(units_sold * price * 0.70),
        2
    ) AS estimated_gross_profit
FROM retail_inventory
GROUP BY product_id, category
ORDER BY estimated_gross_profit DESC
LIMIT 10;

#Average Discount by Category
SELECT
    category,
    ROUND(AVG(discount_pct), 2) AS average_discount,
    MIN(discount_pct) AS minimum_discount,
    MAX(discount_pct) AS maximum_discount,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100)), 2
    ) AS net_revenue
FROM retail_inventory
GROUP BY category
ORDER BY average_discount DESC;

#Monthly Net Revenue by Year
SELECT
    YEAR(date) AS sales_year,
    MONTHNAME(date) AS month_name,
    MONTH(date) AS month_number,
    SUM(units_sold) AS total_units_sold,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100)), 2
    ) AS net_revenue
FROM retail_inventory
WHERE YEAR(date) IN (2022, 2023)
GROUP BY YEAR(date), MONTH(date), MONTHNAME(date)
ORDER BY sales_year, month_number;

#Final data-quality check: Negative demand forecasts
SELECT
    COUNT(*) AS negative_forecast_records,
    MIN(demand_forecast) AS minimum_forecast,
    MAX(demand_forecast) AS maximum_forecast
FROM retail_inventory
WHERE demand_forecast < 0;

#Recalculate inventory risk using valid forecasts
SELECT
    CASE
        WHEN inventory_level < demand_forecast
            THEN 'Stock Shortage Risk'
        WHEN inventory_level > demand_forecast
            THEN 'Excess Stock'
        ELSE 'Balanced Stock'
    END AS inventory_status,
    COUNT(*) AS total_records,
    SUM(units_sold) AS total_units_sold
FROM retail_inventory
WHERE demand_forecast >= 0
GROUP BY inventory_status
ORDER BY total_records DESC;

#Category-wise adjusted inventory risk
SELECT
    category,
    SUM(CASE
        WHEN inventory_level < demand_forecast THEN 1
        ELSE 0
    END) AS shortage_records,
    SUM(CASE
        WHEN inventory_level > demand_forecast THEN 1
        ELSE 0
    END) AS excess_stock_records,
    COUNT(*) AS valid_records
FROM retail_inventory
WHERE demand_forecast >= 0
GROUP BY category
ORDER BY shortage_records DESC;

#Category-wise Average Selling Price and Discount
SELECT
    category,
    ROUND(AVG(price), 2) AS average_price,
    ROUND(AVG(discount_pct), 2) AS average_discount,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100)), 2
    ) AS net_revenue
FROM retail_inventory
GROUP BY category
ORDER BY net_revenue DESC;

#Overall project performance summary
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT store_id) AS total_stores,
    COUNT(DISTINCT product_id) AS total_products,
    SUM(units_sold) AS total_units_sold,
    ROUND(
        SUM(units_sold * price * (1 - discount_pct / 100)), 2
    ) AS total_net_revenue,
    ROUND(AVG(discount_pct), 2) AS average_discount,
    COUNT(DISTINCT category) AS total_categories
FROM retail_inventory;

#Missing and NULL value verification
SELECT
    COUNT(*) AS total_records,
    SUM(
        CASE
            WHEN date IS NULL
              OR store_id IS NULL
              OR product_id IS NULL
              OR category IS NULL
              OR region IS NULL
              OR inventory_level IS NULL
              OR units_sold IS NULL
              OR units_ordered IS NULL
              OR demand_forecast IS NULL
              OR price IS NULL
              OR discount_pct IS NULL
              OR weather_condition IS NULL
              OR holiday_promotion IS NULL
              OR competitor_pricing IS NULL
              OR seasonality IS NULL
            THEN 1 ELSE 0
        END
    ) AS records_with_nulls
FROM retail_inventory;