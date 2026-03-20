-- ============================================================
-- E-COMMERCE SALES & PROFIT ANALYSIS — SQL QUERY LAYER
-- Dataset: ecommerce_cleaned.csv (loaded as table: ecommerce)
-- Covers: Revenue trends, customer segments, profit drivers
-- ============================================================


-- ─── TABLE SETUP (SQLite / PostgreSQL compatible) ─────────────────────────────
-- CREATE TABLE ecommerce (
--   transaction_id   INTEGER,
--   date             DATE,
--   region           TEXT,
--   category         TEXT,
--   product          TEXT,
--   revenue          NUMERIC,
--   cost             NUMERIC,
--   units            INTEGER,
--   customer_id      TEXT,
--   segment          TEXT,
--   status           TEXT,
--   profit           NUMERIC,
--   margin_pct       NUMERIC,
--   month            TEXT,
--   quarter          TEXT,
--   year             INTEGER,
--   revenue_per_unit NUMERIC,
--   margin_flag      TEXT
-- );


-- ─── Q1: OVERALL KPI SUMMARY ──────────────────────────────────────────────────
-- Total revenue, cost, profit, and average margin across all transactions
SELECT
    COUNT(*)                          AS total_orders,
    SUM(revenue)                      AS total_revenue,
    SUM(cost)                         AS total_cost,
    SUM(profit)                       AS total_profit,
    ROUND(AVG(margin_pct), 2)         AS avg_margin_pct,
    SUM(units)                        AS total_units_sold,
    COUNT(DISTINCT customer_id)       AS unique_customers,
    COUNT(DISTINCT product)           AS unique_products
FROM ecommerce;


-- ─── Q2: REVENUE & PROFIT BY REGION ──────────────────────────────────────────
-- Identifies which regions drive the most revenue and profit
SELECT
    region,
    COUNT(*)                          AS orders,
    SUM(revenue)                      AS total_revenue,
    SUM(profit)                       AS total_profit,
    ROUND(AVG(margin_pct), 2)         AS avg_margin_pct,
    SUM(units)                        AS units_sold,
    ROUND(SUM(revenue) * 100.0 / (SELECT SUM(revenue) FROM ecommerce), 2) AS revenue_share_pct
FROM ecommerce
GROUP BY region
ORDER BY total_revenue DESC;


-- ─── Q3: REVENUE & PROFIT BY CATEGORY ────────────────────────────────────────
-- Identifies top-performing product categories
SELECT
    category,
    COUNT(*)                          AS orders,
    SUM(revenue)                      AS total_revenue,
    SUM(profit)                       AS total_profit,
    ROUND(AVG(margin_pct), 2)         AS avg_margin_pct,
    SUM(units)                        AS units_sold,
    ROUND(AVG(revenue_per_unit), 2)   AS avg_revenue_per_unit
FROM ecommerce
GROUP BY category
ORDER BY total_revenue DESC;


-- ─── Q4: TOP 10 PRODUCTS BY REVENUE ──────────────────────────────────────────
SELECT
    product,
    SUM(revenue)                      AS total_revenue,
    SUM(profit)                       AS total_profit,
    SUM(units)                        AS total_units,
    ROUND(AVG(margin_pct), 2)         AS avg_margin_pct,
    COUNT(*)                          AS times_ordered
FROM ecommerce
GROUP BY product
ORDER BY total_revenue DESC
LIMIT 10;


-- ─── Q5: MONTHLY REVENUE TREND ────────────────────────────────────────────────
-- Used to visualize seasonality and growth patterns
SELECT
    month,
    SUM(revenue)                      AS monthly_revenue,
    SUM(profit)                       AS monthly_profit,
    ROUND(AVG(margin_pct), 2)         AS avg_margin_pct,
    SUM(units)                        AS units_sold,
    COUNT(*)                          AS orders,
    -- Month-over-month revenue delta (LAG requires PostgreSQL/SQL Server)
    SUM(revenue) - LAG(SUM(revenue)) OVER (ORDER BY month) AS mom_revenue_delta
FROM ecommerce
GROUP BY month
ORDER BY month;


-- ─── Q6: QUARTERLY PERFORMANCE ────────────────────────────────────────────────
SELECT
    quarter,
    SUM(revenue)                      AS quarterly_revenue,
    SUM(profit)                       AS quarterly_profit,
    ROUND(AVG(margin_pct), 2)         AS avg_margin_pct,
    COUNT(DISTINCT customer_id)       AS active_customers,
    SUM(units)                        AS units_sold
FROM ecommerce
GROUP BY quarter
ORDER BY quarter;


-- ─── Q7: CUSTOMER SEGMENT ANALYSIS ───────────────────────────────────────────
-- Compares revenue, profit, and order value across Enterprise, SMB, Retail
SELECT
    segment,
    COUNT(DISTINCT customer_id)       AS customers,
    COUNT(*)                          AS total_orders,
    SUM(revenue)                      AS total_revenue,
    SUM(profit)                       AS total_profit,
    ROUND(AVG(revenue), 2)            AS avg_order_value,
    ROUND(AVG(margin_pct), 2)         AS avg_margin_pct,
    ROUND(SUM(revenue) * 100.0 / (SELECT SUM(revenue) FROM ecommerce), 2) AS revenue_share_pct
FROM ecommerce
GROUP BY segment
ORDER BY total_revenue DESC;


-- ─── Q8: CUSTOMER LIFETIME VALUE (LTV) ───────────────────────────────────────
-- Ranks customers by total spend; identifies high-value accounts
SELECT
    customer_id,
    segment,
    COUNT(*)                          AS total_orders,
    SUM(revenue)                      AS lifetime_revenue,
    SUM(profit)                       AS lifetime_profit,
    ROUND(AVG(revenue), 2)            AS avg_order_value,
    MIN(date)                         AS first_order_date,
    MAX(date)                         AS last_order_date
FROM ecommerce
GROUP BY customer_id, segment
ORDER BY lifetime_revenue DESC;


-- ─── Q9: PROFIT MARGIN ANALYSIS BY PRODUCT ────────────────────────────────────
-- Flags products with healthy vs. low margins
SELECT
    product,
    category,
    ROUND(AVG(margin_pct), 2)         AS avg_margin_pct,
    MIN(margin_pct)                   AS min_margin_pct,
    MAX(margin_pct)                   AS max_margin_pct,
    SUM(revenue)                      AS total_revenue,
    margin_flag,
    CASE
        WHEN AVG(margin_pct) >= 40 THEN 'High Margin'
        WHEN AVG(margin_pct) >= 25 THEN 'Medium Margin'
        ELSE 'Low Margin — Review Pricing'
    END AS margin_health
FROM ecommerce
GROUP BY product, category, margin_flag
ORDER BY avg_margin_pct DESC;


-- ─── Q10: REGION × CATEGORY CROSS-TAB (PIVOT) ────────────────────────────────
-- Revenue breakdown per region per category
SELECT
    region,
    SUM(CASE WHEN category = 'Electronics' THEN revenue ELSE 0 END) AS Electronics,
    SUM(CASE WHEN category = 'Apparel'     THEN revenue ELSE 0 END) AS Apparel,
    SUM(CASE WHEN category = 'Home'        THEN revenue ELSE 0 END) AS Home,
    SUM(revenue)                                                     AS total_revenue
FROM ecommerce
GROUP BY region
ORDER BY total_revenue DESC;


-- ─── Q11: COHORT — FIRST ORDER MONTH BY CUSTOMER ─────────────────────────────
-- Assigns each customer their acquisition cohort month
SELECT
    customer_id,
    segment,
    MIN(date)                         AS first_order_date,
    SUBSTR(MIN(date), 1, 7)           AS cohort_month,
    COUNT(*)                          AS total_orders,
    SUM(revenue)                      AS total_revenue
FROM ecommerce
GROUP BY customer_id, segment
ORDER BY cohort_month, total_revenue DESC;


-- ─── Q12: REVENUE FORECAST BASE — LINEAR TREND INPUT ─────────────────────────
-- Prepares monthly index for forecasting model input
SELECT
    month,
    ROW_NUMBER() OVER (ORDER BY month)   AS month_index,
    SUM(revenue)                         AS actual_revenue,
    SUM(profit)                          AS actual_profit,
    ROUND(AVG(margin_pct), 2)            AS avg_margin_pct
FROM ecommerce
GROUP BY month
ORDER BY month;
