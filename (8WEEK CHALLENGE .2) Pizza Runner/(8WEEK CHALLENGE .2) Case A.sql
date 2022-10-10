--------------------------------
--CASE STUDY #1: Pizza runner
--------------------------------

--Author: Juyong Lee
--Date: 09/10/2022
--Tool used: MS SQL Server

CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);

INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

DROP TABLE IF EXISTS myportfolio..customer_orders
CREATE TABLE myportfolio..customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(20),
  "extras" VARCHAR(20),
  "order_time" VARCHAR(19)
);

INSERT INTO myportfolio..customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', 'NULL', '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS myportfolio..runner_orders;
CREATE TABLE myportfolio..runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO myportfolio..runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');

DROP TABLE IF EXISTS myportfolio..pizza_names;
CREATE TABLE myportfolio..pizza_names 
(
  "pizza_id" VARCHAR,
  "pizza_name" VARCHAR(20)
);
INSERT INTO myportfolio..pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

 SELECT
 *
 FROM
myportfolio..runners


SELECT
*
FROM
myportfolio..customer_orders

SELECT
*
FROM
myportfolio..runner_orders


SELECT
*
FROM
myportfolio..pizza_names

SELECT
*
FROM
myportfolio..pizza_recipes

SELECT
*
FROM
myportfolio..pizza_toppings



---------------------data cleaning and transforming--------------------------------------
 SELECT
 *
 FROM
myportfolio..runners

--------------runners' table does not seem like have problems.---------------------------

SELECT
*
FROM
myportfolio..customer_orders

-----------------------------------------------------------------------------------------
-- customer_orders needs to clean the table.
-- first order_id column has duplicated id. It could occurs error or incorrect analysis, So it should be fixed.
-- exlusion column have blanks and null. It also need to be filled values.
-- extra column have same problems too.
-----------------------------------------------------------------------------------------

DROP TABLE IF EXISTS myportfolio..customer_orders_CLEANING
SELECT 
  order_id, 
  customer_id, 
  pizza_id, 
  CASE
	  WHEN exclusions IS null OR exclusions LIKE 'null' THEN ''
	  ELSE exclusions
	  END AS exclusions,
  CASE
	  WHEN extras IS NULL or extras LIKE 'null' THEN ''
	  ELSE extras
	  END AS extras,
	order_time
INTO  myportfolio..customer_orders_CLEANING
FROM
myportfolio..customer_orders
------------------------------------------------------------------------------------------
-- runner_orders also have problems.
-- pickup_time has null values
-- distance column and duration's measuremnt are not standarize.
-- cancellation column has empty values and null values
------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS myportfolio..runner_orders_CLEANING
SELECT
order_id, runner_id,
   CASE WHEN pickup_time like 'null' THEN ' ' ELSE pickup_time END AS pickup_time, 
   CASE WHEN distance like '%km' THEN TRIM('km' from distance) WHEN distance like 'null' THEN ' ' ELSE distance END AS distance_km,
   CASE WHEN duration like 'null' THEN ' '
        WHEN duration is NULL THEN ' '
	    WHEN duration like '%mins' THEN TRIM('mins' from duration)
	    WHEN duration like '%minute' THEN TRIM('minute' from duration)
	    WHEN duration like '%minutes' THEN TRIM('minutes' from duration) 
		ELSE duration END AS duration_min,
   CASE WHEN cancellation is NULL or cancellation like 'null' THEN ' ' 
        ELSE cancellation END AS cancellation
		INTO myportfolio..runner_orders_CLEANING
FROM
myportfolio..runner_orders

select * from myportfolio..runner_orders_CLEANING

-- Change table type
ALTER TABLE myportfolio..runner_orders_CLEANING
ALTER COLUMN pickup_time DATETIME;
ALTER COLUMN distance_km FLOAT;
ALTER COLUMN duration_min INT; 

-------------------------------------- Case study A -------------------------------------
-- A. Pizza Metrics
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