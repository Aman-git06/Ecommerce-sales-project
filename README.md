================================================================
  E-COMMERCE SALES & PROFIT ANALYSIS PROJECT
  August 2024
================================================================

FOLDER STRUCTURE
────────────────
ecommerce_sales_project/
│
├── data/
│   ├── ecommerce_raw.csv          — Original dataset (25 transactions, 10 columns)
│   ├── ecommerce_cleaned.csv      — Cleaned data with derived columns
│   │                                (profit, margin_pct, month, quarter, margin_flag)
│   ├── monthly_summary.csv        — Revenue & profit aggregated by month
│   ├── region_summary.csv         — Revenue breakdown by region
│   ├── category_summary.csv       — Revenue breakdown by category
│   ├── product_summary.csv        — Top products by revenue & margin
│   └── customer_ltv.csv           — Customer lifetime value & order history
│
├── sql/
│   └── ecommerce_analysis.sql     — 12 SQL queries covering all KPIs,
│                                    segment analysis, cross-tabs, cohorts,
│                                    and forecast base data
│
├── powerbi/
│   └── powerbi_setup.txt          
│                                    
│                                  
│
├── dashboard_screenshot/
│   └── images
│                                     │
├── cohort_analysis/
│   ├── cohort_summary.csv          — Customers & CLV grouped by acquisition month
│   └── retention_matrix.csv        — M0–M4 retention % per cohort
│
└── README.txt                      


DATA CLEANING STEPS (Python/Pandas)
────────────────────────────────────
1. Loaded raw CSV (25 rows, 10 columns)
2. Dropped nulls in: revenue, cost, units, date, product
3. Filtered: revenue > 0, cost > 0, units > 0
4. Derived columns:
   - profit          = revenue - cost
   - margin_pct      = (profit / revenue) × 100
   - month           = date[:7]
   - quarter         = Q1/Q2/Q3/Q4 from date
   - year            = year from date
   - revenue_per_unit= revenue / units
   - margin_flag     = Good (≥40%) / Average (25–40%) / Low (<25%)
5. Zero duplicates found
6. Result: 25/25 rows passed all checks


SQL ANALYSIS LAYER (12 Queries)
─────────────────────────────────
Q1  — Overall KPI summary (revenue, profit, margin, units)
Q2  — Revenue & profit by region
Q3  — Revenue & profit by category
Q4  — Top 10 products by revenue
Q5  — Monthly revenue trend with MoM delta (window function)
Q6  — Quarterly performance
Q7  — Customer segment analysis (Enterprise/SMB/Retail)
Q8  — Customer LTV ranking
Q9  — Profit margin analysis with margin health flags
Q10 — Region × Category cross-tab pivot
Q11 — Cohort: first order month per customer
Q12 — Forecast base: monthly index for linear trend model


POWER BI DASHBOARD (6 Pages)
──────────────────────────────
Page 1 — Executive Overview   (KPIs, trend line, donut, bar chart)
Page 2 — Product Performance  (horizontal bar, scatter, margin table)
Page 3 — Regional Analysis    (map, stacked bar, matrix table)
Page 4 — Customer & Segments  (donut, LTV ranking, avg order value)
Page 5 — Cohort & Retention   (retention matrix, CLV by cohort)
Page 6 — Forecasting          (3-month linear forecast with confidence band)


COHORT ANALYSIS
────────────────
- Customers bucketed by first purchase month
- Retention tracked across M0 → M4 intervals
- CLV = total revenue per cohort / customers in cohort
- Result: Enterprise cohorts show higher CLV and better retention


FORECASTING MODEL (Linear Regression)
───────────────────────────────────────
Method: Ordinary Least Squares linear trend on monthly revenue
Inputs: monthly_summary.csv (month_index + actual_revenue)
Output: Forecast for 3 future months with trend slope
Note:   No ML used — pure statistical linear regression
================================================================
