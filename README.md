🧹 Data Cleaning

The raw dataset was processed using Python (Pandas) by removing null values and filtering out invalid entries such as zero or negative revenue, cost, and units. New features like profit, margin percentage, revenue per unit, and time-based attributes (month, quarter, year) were created to enrich the dataset. A margin classification flag was also added to categorize performance, and no duplicate records were found after validation.

🧠 SQL Analysis

A set of 12 SQL queries was developed to extract key business insights from the cleaned dataset. These queries covered overall KPIs, regional and category-wise performance, top products, monthly trends using window functions, customer segmentation, lifetime value analysis, and cohort identification. Additional queries enabled cross-tab analysis and prepared base data for forecasting models.

📊 Power BI Dashboard

An interactive 6-page Power BI dashboard was built to visualize insights effectively. It includes an executive overview with KPI cards and trends, product and regional performance analysis, customer segmentation and LTV insights, cohort retention visualization, and a forecasting page with projected revenue trends. The dashboard focuses on clarity, interactivity, and decision-making support.
