----------------------------------------------------------------------
--B. Data Analysis
--What day of the week is used for each week_date value?
--What range of week numbers are missing from the dataset?
--How many total transactions were there for each year in the dataset?
--What is the total sales for each region for each month?
--What is the total count of transactions for each platform
--What is the percentage of sales for Retail vs Shopify for each month?
--What is the percentage of sales by demographic for each year in the dataset?
--Which age_band and demographic values contribute the most to Retail sales?
--Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
-------------------------------------------------------------------------
select * from clean_weekly_sales

--What range of week numbers are missing from the dataset?
select distinct
	DATENAME(WEEKDAY, week_date) day_name
from clean_weekly_sales

-------------------------------

WITH bweek AS
(
SELECT top 52 
ROW_NUMBER() OVER(ORDER BY name) week_NO
FROM master.sys.all_columns
)
SELECT 
	COUNT(n.week_NO) missing
FROM bweek n
left join clean_weekly_sales c on n.week_NO = c.week_number
WHERE c.week_number is null;

--3. How many total transactions were there for each year in the dataset?
select
calendar_year,
SUM(transactions) total_transactions
from clean_weekly_sales
group by calendar_year
order by calendar_year;

--4. What is the total sales for each region for each month?
select
region,
month_number,
SUM(sales) total_sales
from
clean_weekly_sales
group by region, month_number
order by region, month_number;

--What is the total count of transactions for each platform
SELECT
Platform,SUM(transactions) total
FROM
clean_weekly_sales
GROUP BY
Platform
--What is the percentage of sales for Retail vs Shopify for each month?

WITH sales_contribution_cte AS
(
SELECT
calendar_year,
month_number,
platform,
sum(sales) AS sales_contribution
FROM
clean_weekly_sales
GROUP BY
calendar_year,month_number,platform
),
total_sales_cte AS
(
SELECT 
*,
sum(sales_contribution) over(PARTITION BY calendar_year, month_number) AS total_sales
FROM 
sales_contribution_cte)
SELECT
calendar_year,
month_number,
ROUND(sales_contribution/total_sales*100, 2) AS retail_percent,
100-ROUND(sales_contribution/total_sales*100, 2) AS shopify_percent
FROM total_sales_cte
WHERE platform = 'Retail'
ORDER BY 1,2


WITH sales_cte AS
(
SELECT
calendar_year,
month_number,
SUM(CASE WHEN platform='Retail' THEN sales END) AS retail_sales,
SUM(CASE WHEN platform='Shopify' THEN sales END) AS shopify_sales,
sum(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY calendar_year,month_number
)
SELECT
calendar_year,
month_number,
ROUND(retail_sales/total_sales*100, 2) AS retail_percent,
ROUND(shopify_sales/total_sales*100, 2) AS shopify_percent
FROM sales_cte;

--What is the percentage of sales by demographic for each year in the dataset?
WITH CTE as
(
SELECT
calendar_year, SUM(sales) AS sales_sum
FROM
clean_weekly_sales
GROUP BY
calendar_year
)
SELECT
c.calendar_year,w.demographic, ROUND(sum(w.sales) / sales_sum * 100,2) as percentage
FROM CTE c JOIN clean_weekly_sales w on c.calendar_year = w.calendar_year
GROUP BY
c.calendar_year,w.demographic,sales_sum
order by 1



WITH cte AS
(
SELECT
calendar_year,
SUM(CASE WHEN demographic='Couples' THEN sales END) AS couple_sales,
SUM(CASE WHEN demographic='Families' THEN sales END) AS family_sales,
SUM(CASE WHEN demographic='unknown' THEN sales END) AS unknown_sales,
sum(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY 1
ORDER BY 1)
SELECT calendar_year,
ROUND(couple_sales/total_sales*100, 2) AS couple_percent,
ROUND(family_sales/total_sales*100, 2) AS family_percent,
ROUND(unknown_sales/total_sales*100, 2) AS unknown_percent
FROM cte;
--Which age_band and demographic values contribute the most to Retail sales?
SELECT 
age_band,
demographic,
ROUND(100*sum(sales)/(SELECT SUM(sales) FROM clean_weekly_sales
WHERE platform='Retail'), 2) AS retail_sales_percentage
FROM clean_weekly_sales
WHERE platform='Retail'
GROUP BY age_band,demographic
ORDER BY 3 DESC;
--Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT
calendar_year,
platform,
ROUND(SUM(sales)/SUM(transactions), 2) AS correct_avg,
ROUND(AVG(avg_transaction), 2) AS incorrect_avg
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY 1,2