--------------------------------
--CASE STUDY #3: Foodie-Fi
--------------------------------

--Author: Juyong Lee
--Date: 11/10/2022
--Tool used: MS SQL Server

----------------------------------- Data Cleanung and transforming -----------------------------------
SELECT 
CASE
price = null then 0 
else price END
from
myportfolio..plans
-------------------------------------- Case study A ---------------------------------------------------
-----What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?------
SELECT
*
FROM
myportfolio..plans


SELECT
*
FROM
myportfolio..subscriptions



SELECT 
CASE
price = null then 0 
else price END
from
myportfolio..plans


SELECT
  s.customer_id,
  f.plan_id, 
  f.plan_name,  
  s.start_date
FROM myportfolio..plans f
JOIN myportfolio..subscriptions s
  ON f.plan_id = s.plan_id
WHERE s.customer_id IN (1,2,11,13,15,16,18,19);

