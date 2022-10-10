-------------------------------------- Case study A --------------------------------------
--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
--Is there any relationship between the number of pizzas and how long the order takes to prepare?
--What was the average distance travelled for each customer?
--What was the difference between the longest and shortest delivery times for all orders?
--What was the average speed for each runner for each delivery and do you notice any trend for these values?
--What is the successful delivery percentage for each runner?
------------------------------------------------------------------------------------------
--------------------How many runners signed up for each 1 week period?--------------------
SELECT
DATEPART(ww, registration_date) AS week , count(DATEPART(ww, registration_date)) AS count_week
FROM
myportfolio..runners
GROUP BY DATEPART(ww, registration_date)
------------------------------------------------------------------------------------------
SELECT 
  DATEPART(WEEK, registration_date) AS registration_week,
  COUNT(runner_id) AS runner_signup
FROM myportfolio..runners
GROUP BY DATEPART(WEEK, registration_date);

--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?--
WITH avg_time_CTE AS
(
SELECT
co.order_id, 
co.order_time, 
ro.pickup_time, 
datediff(MINUTE, order_time, pickup_time)  AS time_diff_min
FROM 
myportfolio..runner_orders_CLEANING AS ro join 
myportfolio..customer_orders_CLEANING AS co on co.order_id = ro.order_id
where datediff(MINUTE, order_time, pickup_time) > 0 and distance_km != 0
GROUP BY co.order_id, co.order_time, ro.pickup_time
)
SELECT
avg(time_diff_min) AS ave_time_min
FROM
avg_time_CTE


--How long does it take for customers to get their pizzas? Is there any relationship between the number of pizzas and delivery time?--
SELECT
co.order_id,DATEDIFF(MINUTE,order_time,pickup_time) AS delivery_time, COUNT(co.order_id) AS order_count
FROM
myportfolio..customer_orders_CLEANING AS co JOIN
myportfolio..runner_orders_CLEANING AS ro on co.order_id = ro.order_id
WHERE cancellation = ''
GROUP BY
co.order_id, DATEDIFF(MINUTE,order_time,pickup_time)
ORDER BY
1


------------------What was the average distance travelled for each customer?----------------------------
SELECT
customer_id, AVG(distance_km)
FROM
myportfolio..customer_orders_CLEANING AS co JOIN
myportfolio..runner_orders_CLEANING AS ro on co.order_id = ro.order_id
GROUP BY customer_id

----------What was the difference between the longest and shortest delivery times for all orders?-------
SELECT
MAX(DATEDIFF(MINUTE,co.order_time,ro.pickup_time)) AS longest, MIN(DATEDIFF(MINUTE,co.order_time,ro.pickup_time)) AS shortest,MAX(DATEDIFF(MINUTE,co.order_time,ro.pickup_time)) - MIN(DATEDIFF(MINUTE,co.order_time,ro.pickup_time)) 
FROM
myportfolio..customer_orders_CLEANING AS co JOIN
myportfolio..runner_orders_CLEANING AS ro on co.order_id = ro.order_id
WHERE
cancellation = ''


--What was the average speed for each runner for each delivery and do you notice any trend for these values?--
SELECT 
  r.runner_id, 
  c.customer_id, 
  c.order_id, 
  COUNT(c.order_id) AS pizza_count, 
  r.distance_km, 
  (r.duration_min / 60) AS duration_hr , 
  ROUND((r.distance_km/r.duration_min * 60), 2) AS avg_speed
FROM myportfolio..runner_orders_CLEANING AS r
JOIN myportfolio..customer_orders_CLEANING AS c
  ON r.order_id = c.order_id
WHERE distance_km != 0
GROUP BY r.runner_id, c.customer_id, c.order_id, r.distance_km, r.duration_min
ORDER BY c.order_id;



------------------What is the successful delivery percentage for each runner?------------------------------------
SELECT 
  runner_id, 
  100 * SUM(CASE WHEN distance_km = 0 THEN 0 ELSE 1 END) / COUNT(*) AS success
FROM myportfolio..runner_orders_CLEANING
GROUP BY runner_id
