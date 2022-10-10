-------------------------------------- Case study A -------------------------------------
-- How many pizzas were ordered?
-- How many unique customer orders were made?
-- How many successful orders were delivered by each runner?
-- How many of each type of pizza was delivered?
-- How many Vegetarian and Meatlovers were ordered by each customer?
-- What was the maximum number of pizzas delivered in a single order?
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- How many pizzas were delivered that had both exclusions and extras?
-- What was the total volume of pizzas ordered for each hour of the day?
-- What was the volume of orders for each day of the week?
-- B. Runner and Customer Experience
-------------------------------------------------------------------------------------------


--------------------------How many pizzas were ordered?------------------------------------

SELECT
*
FROM
myportfolio..runner_orders_CLEANING

SELECT
*
FROM
myportfolio..customer_orders_CLEANING
SELECT
COUNT(order_id) AS ordered_pizza
FROM
myportfolio..customer_orders_CLEANING


--A : Total of 14 pizzas were ordered.


--------------------How many unique customer orders were made?-------------------------------
SELECT
COUNT(DISTINCT(order_id)) AS ordered_pizza
FROM
myportfolio..customer_orders 

--A : There are 10 unique customer orders.
-----------------How many successful orders were delivered by each runner?-------------------
SELECT
runner_id, COUNT(order_id)
FROM
myportfolio..runner_orders_CLEANING
WHERE
cancellation = ''
GROUP BY runner_id
--A :Runner 1 has 4 successful delivered orders.
--Runner 2 has 3 successful delivered orders.
--Runner 3 has 1 successful delivered order.
--------------------------How many of each type of pizza was delivered?----------------------
SELECT
COUNT(DISTINCT(pizza_id)) AS type_of_pizza
FROM
myportfolio..customer_orders_CLEANING
--A :There are 9 delivered Meatlovers pizzas and 3 Vegetarian pizzas.
-------------How many Vegetarian and Meatlovers were ordered by each customer?---------------

SELECT
co.customer_id, pn.pizza_name, COUNT(co.pizza_id) AS Orders
FROM
myportfolio..customer_orders_CLEANING AS co join myportfolio..pizza_names AS pn on co.pizza_id = pn.pizza_id
GROUP BY co.customer_id, pn.pizza_name
ORDER BY 1
--A :Customer 101 ordered 2 Meatlovers pizzas and 1 Vegetarian pizza.
--Customer 102 ordered 2 Meatlovers pizzas and 2 Vegetarian pizzas.
--Customer 103 ordered 3 Meatlovers pizzas and 1 Vegetarian pizza.
--Customer 104 ordered 1 Meatlovers pizza.
--Customer 105 ordered 1 Vegetarian pizza.
-------------What was the maximum number of pizzas delivered in a single order? ----------------
 WITH pizza_count_CTE AS
 (
 SELECT 
    order_id, 
    COUNT(pizza_id) AS pizza_per_order
FROM
myportfolio..customer_orders_CLEANING
GROUP BY order_id 
)
SELECT
MAX(pizza_per_order) AS MAXIMUM_ORDER
FROM
pizza_count_CTE
--A :Maximum number of pizza delivered in a single order is 3 pizzas.

--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?-----
SELECT customer_id,   
SUM(CASE WHEN exclusions <> ''
         or extras <> '' THEN 1
         ELSE 0 
		 END) AS at_least_1_change,
SUM(CASE WHEN exclusions = ''
	     and extras = '' THEN 1
         ELSE 0 
		 END) AS no_1_change
FROM
myportfolio..customer_orders_CLEANING AS co join myportfolio..runner_orders_CLEANING AS ro on co.order_id = ro.order_id
WHERE duration_min <> 0
GROUP BY customer_id

--A :Customer 101 and 102 likes his/her pizzas per the original recipe.
--   Customer 103, 104 and 105 have their own preference for pizza topping and requested at least 1 change (extra or exclusion topping) on their pizza.
--------------How many pizzas were delivered that had both exclusions and extras? ----------------------

SELECT
co.order_id, exclusions, extras
FROM
myportfolio..customer_orders_CLEANING AS co 
join myportfolio..runner_orders_CLEANING AS ro on co.order_id = ro.order_id
WHERE 
ro.distance_km != '' and exclusions != '' and extras != ''
--A :  Only 1 pizza delivered that had both extra and exclusion topping. That¡¯s one fussy customer!
------------What was the total volume of pizzas ordered for each hour of the day?-------------------------
SELECT 
  DATEPART(HOUR, [order_time]) AS hour_of_day,  COUNT(order_id) AS pizza_count
FROM 
myportfolio..customer_orders_CLEANING
GROUP BY DATEPART(HOUR, [order_time]);


--A : Highest volume of pizza ordered is at 13 (1:00 pm), 18 (6:00 pm) and 21 (9:00 pm).
-- Lowest volume of pizza ordered is at 11 (11:00 am), 19 (7:00 pm) and 23 (11:00 pm).
--------------------------What was the volume of orders for each day of the week?--------------------------
SELECT 
  FORMAT(DATEADD(DAY, 2, order_time),'dddd') AS day_week,
  COUNT(order_id) AS total_pizzas_ordered
FROM myportfolio..customer_orders
GROUP BY FORMAT(DATEADD(DAY, 2, order_time),'dddd');

--A :There are 5 pizzas ordered on Friday and Monday.
--There are 3 pizzas ordered on Saturday.
--There is 1 pizza ordered on Sunday.