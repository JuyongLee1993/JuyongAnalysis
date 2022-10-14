
--------------------------------------------------------------------------------------------------------------
--A. Data Cleaning
--Convert the week_date to a DATE format
--Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
--Add a month_number with the calendar month for each week_date value as the 3rd column
--Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
--Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
----------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS clean_weekly_sales;
select 
CAST(week_date as date) week_date,
DATEPART(WEEK, CAST(week_date as date)) week_number,
DATEPART(M, CAST(week_date as date)) month_number,
DATEPART(YY, CAST(week_date as date)) calendar_year,
region,
platform,
segment,
CASE WHEN RIGHT(segment, 1) = '1' then 'Young Adults'
WHEN RIGHT(segment, 1) = '2' then 'Middle Aged'
WHEN RIGHT(segment, 1) = '3' or RIGHT(segment, 1) = '4' then 'Retirees'
ELSE 'unknown' end age_band,
CASE WHEN LEFT(segment, 1) = 'C' then 'Couples'
WHEN LEFT(segment, 1) = 'F' then 'Families'
ELSE 'unknown' end demographic,
customer_type,
CAST(transactions as float) transactions,
CAST(sales as float) sales,
ROUND(CAST(sales as float)/CAST(transactions as float), 2) avg_transaction
into clean_weekly_sales
from weekly_sales

-------------------------------------------------------------------
select
*
from
weekly_sales_clean

