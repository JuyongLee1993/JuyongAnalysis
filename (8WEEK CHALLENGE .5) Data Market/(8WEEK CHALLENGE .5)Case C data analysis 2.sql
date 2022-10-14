--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--C. Before & After Analysis
--This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.
--Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect. We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before.
--Using this analysis approach - answer the following questions:
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
SELECT 
  DISTINCT week_number
FROM clean_weekly_sales
WHERE week_date = '2020-06-15' 


WITH changes AS 
(
SELECT 
week_date, 
week_number, 
SUM(sales) AS total
FROM clean_weekly_sales
WHERE (week_number BETWEEN 21 AND 28) AND (calendar_year = 2020)
GROUP BY week_date, week_number
),
changes_2 AS 
(
SELECT 
SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN total END) AS before_change,
SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN total END) AS after_change
FROM changes
)
SELECT 
before_change, 
after_change, 
after_change - before_change AS variance, 
ROUND(100 * (after_change - before_change) / before_change,2)  percentage
FROM changes_2


--What about the entire 12 weeks before and after?
WITH changes AS 
(
SELECT 
week_date, 
week_number, 
SUM(sales) AS total
FROM clean_weekly_sales
WHERE (week_number BETWEEN 13 AND 37) and (calendar_year = 2020)
GROUP BY week_date, week_number
),
changes_2 AS 
(
SELECT 
SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN total END) AS before_change,
SUM(CASE WHEN week_number BETWEEN  25 AND 37 THEN total END) AS after_change
FROM changes
)
SELECT 
before_change, 
after_change, 
after_change - before_change AS variance, 
ROUND(100 * (after_change - before_change) / before_change,2)  percentage
FROM changes_2


--How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
WITH changes AS 
(
SELECT 
calendar_year,
week_date, 
week_number, 
SUM(sales) AS total
FROM clean_weekly_sales
WHERE (week_number BETWEEN 21 AND 28)
GROUP BY week_date, week_number,calendar_year
),
changes_2 AS 
(
SELECT
calendar_year,
SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN total END) AS before_change,
SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN total END) AS after_change
FROM changes
group by calendar_year
)
SELECT
calendar_year,
before_change, 
after_change, 
after_change - before_change AS variance, 
ROUND(100 * (after_change - before_change) / before_change,2)  percentage
FROM changes_2
