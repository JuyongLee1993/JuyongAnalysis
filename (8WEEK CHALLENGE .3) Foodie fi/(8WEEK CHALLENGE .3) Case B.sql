
-------------------------------------- Case study B ----------------------------------------------------------------------------
--How many customers has Foodie-Fi ever had?
--What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
--What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
--What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
--How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
--What is the number and percentage of customer plans after their initial free trial?
--What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
--How many customers have upgraded to an annual plan in 2020?
--How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
--Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
--How many customers downgraded from a pro monthly to a basic monthly plan in
----------------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM
myportfolio..plans

SELECT *
FROM
myportfolio..subscriptions

----------------------------------------How many customers has Foodie-Fi ever had?-------------------------------------------------

SELECT 
  COUNT(DISTINCT customer_id) AS unique_customer
FROM myportfolio..subscriptions;

--What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

SELECT DATEPART(month,s.start_date) AS month_date,
FORMAT(start_date, 'MMMM', 'en-US') AS month_name, 
COUNT(*) AS trial_subscriptions
FROM myportfolio..subscriptions s
JOIN myportfolio..plans p
  ON s.plan_id = p.plan_id
WHERE s.plan_id = 0
GROUP BY DATEPART(month,s.start_date), FORMAT(start_date, 'MMMM', 'en-US')
ORDER BY DATEPART(month,s.start_date)

----What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan---------
SELECT 
 s.plan_id,
 p.plan_name,
 SUM(
   CASE WHEN s.start_date <= '2020-12-31' THEN 1
   ELSE 0 END
   ) AS events_2020,
 SUM(
   CASE WHEN s.start_date >= '2021-01-01' THEN 1
   ELSE 0 END
   ) AS events_2021
FROM myportfolio..subscriptions s
JOIN myportfolio..plans p
  ON s.plan_id = p.plan_id
GROUP BY s.plan_id, p.plan_name
ORDER BY s.plan_id;

-------------------What is the customer count and percentage of customers who have churned rounded to 1 decimal place?-------------------
SELECT 
 COUNT(*) AS count,
 CAST(ROUND(100 * COUNT(*) / 
  (SELECT COUNT(DISTINCT customer_id) 
  FROM myportfolio..subscriptions),1) AS decimal) AS percentage
  FROM myportfolio..subscriptions
WHERE plan_id = 4;

--How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?---
WITH ranking AS 
(
SELECT 
  s.customer_id, 
  s.plan_id, 
  p.plan_name,
  ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.plan_id) AS plan_rank
FROM myportfolio..subscriptions s
JOIN myportfolio..plans p
  ON s.plan_id = p.plan_id
)
  
SELECT 
  COUNT(*) AS churn_count,
  ROUND(100 * COUNT(*) / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM myportfolio..subscriptions),0) AS churn_percentage
FROM ranking
WHERE plan_id = 4
  AND plan_rank = 2;


 -------------------What is the number and percentage of customer plans after their initial free trial? *Important*-------------------

  WITH next_CTE AS (
SELECT 
  customer_id, 
  plan_id, 
  LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY plan_id) as next_plan
FROM myportfolio..subscriptions)

SELECT 
  next_plan, 
  COUNT(*),
  ROUND(100 * COUNT(*) / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM myportfolio..subscriptions),1) AS conversion_percentage
FROM next_CTE
WHERE next_plan IS NOT NULL 
  AND plan_id = 0
GROUP BY next_plan
ORDER BY next_plan


-------------------What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31? *Important*-----------------
WITH next_plan AS (
SELECT 
  customer_id, 
  plan_id, 
  start_date,
  LEAD(start_date, 1) OVER (PARTITION BY customer_id ORDER BY start_date) as next_date
FROM myportfolio..subscriptions
WHERE start_date <= '2020-12-31'
),
customer_breakdown AS (
SELECT plan_id, COUNT(DISTINCT customer_id) AS customers
  FROM next_plan
  WHERE (next_date IS NOT NULL AND (start_date < '2020-12-31' AND next_date > '2020-12-31'))
    OR (next_date IS NULL AND start_date < '2020-12-31')
  GROUP BY plan_id)

SELECT plan_id, customers, 
  ROUND(100 * customers  / (
    SELECT COUNT(DISTINCT customer_id) 
    FROM myportfolio..subscriptions),1) AS percentage
FROM customer_breakdown
GROUP BY plan_id, customers
ORDER BY plan_id;



----------------------------------------How many customers have upgraded to an annual plan in 2020?--------------------------------------
WITH annual AS
(
SELECT
*
FROM
myportfolio..subscriptions
WHERE
year(start_date) = 2020 and plan_id = 3
)
SELECT
COUNT(customer_id) AS sum_anuual_2020
FROM
annual
---------------------How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?-------------------
WITH DATE_CTE AS
(
SELECT
customer_id, 
plan_id,
start_date, LEAD(start_date, 1) OVER (PARTITION BY customer_id ORDER BY start_date) as next_date,
LEAD(plan_id, 1) OVER (PARTITION BY customer_id ORDER BY start_date) as next_plan
FROM
myportfolio..subscriptions
)
SELECT
AVG(DATEDIFF(day,start_date,next_date)) as gap_date
FROM
DATE_CTE
WHERE
next_plan = 3


---------------------How many customers downgraded from a pro monthly to a basic monthly plan in----------------------------------------------------
WITH CTE as
(
SELECT
customer_id, plan_id, lead(plan_id) over (PARTITION BY customer_id ORDER BY start_date)  as next_plan
FROM
myportfolio..subscriptions
)
SELECT
COUNT(*)
FROM
CTE
WHERE
next_plan=1 and plan_id =2

