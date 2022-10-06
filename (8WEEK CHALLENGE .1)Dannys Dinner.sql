CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');


  select * from myportfolio..members
  select * from myportfolio..sales
  select * from myportfolio..menu

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?



--1.what is the total amount each customer spent at the resaurant.
SELECT 
s.customer_id, SUM(m.price) AS total_sales
FROM 
myportfolio..sales AS s JOIN myportfolio..menu AS m
  ON s.product_id = m.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT 
customer_id, COUNT(distinct(order_date)) AS total_visiting
from myportfolio..sales
group by customer_id

-- 3. What was the first item from the menu purchased by each customer?
WITH order_time_CTE AS
( SELECT customer_id, order_date, product_name,
		DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date, m.product_name) RANK
	FROM myportfolio..sales AS s JOIN myportfolio..menu AS m ON s.product_id = m.product_id)

SELECT 
customer_id, product_name
FROM 
order_time_CTE
WHERE RANK = 1
GROUP BY customer_id, product_name;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT 
m.product_name, COUNT(s.product_id) as product_total_count, DENSE_RANK() OVER(ORDER by COUNT(s.product_id) DESC) AS RANK
FROM 
myportfolio..sales AS s join myportfolio..menu AS m on s.product_id = m.product_id
GROUP BY m.product_name

-- 5. Which item was the most popular for each customer?
WITH Favorite_each_CTE AS 
( SELECT s.customer_id, m.product_name, COUNT(s.product_id) orderd_each_menu, DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY COUNT(s.product_id) desc) AS RANK
FROM
myportfolio..sales AS s join myportfolio..menu AS m on s.product_id = m.product_id
group by s.customer_id, m.product_name)
SELECT 
  customer_id, 
  product_name, 
  orderd_each_menu
FROM 
Favorite_each_CTE 
WHERE RANK = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH me_purchase_CTE as 
(SELECT s.customer_id, s.order_date, s.product_id, DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS RANK
FROM
myportfolio..sales AS s join myportfolio..members AS me on s.customer_id = me.customer_id
WHERE s.order_date > me.join_date)

SELECT  p.customer_id, p.order_date, m.product_name
FROM 
me_purchase_CTE AS p join myportfolio..menu AS m on p.product_id = m.product_id
WHERE rank = 1

-- 7. Which item was purchased just before the customer became a member?
WITH me_purchase_CTE AS
(SELECT s.customer_id, s.order_date, s.product_id, DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC, s.product_id) AS RANK
FROM 
myportfolio..sales AS s join myportfolio..members AS me on s.customer_id = me.customer_id
WHERE s.order_date < me.join_date)

select  p.customer_id, p.order_date, m.product_name
from me_purchase_CTE AS p join myportfolio..menu AS m on p.product_id = m.product_id
where rank = 1

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
s.customer_id, COUNT(distinct s.product_id) AS unique_item, SUM(m.price)
FROM 
myportfolio..sales AS s join myportfolio..members AS me on s.customer_id = me.customer_id join myportfolio..menu AS m on s.product_id = m.product_id 
WHERE me.join_date > s.order_date
GROUP BY s.customer_id
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH price_points_CTE AS 
(SELECT *, CASE WHEN product_name = 'sushi' THEN price * 20
                    ELSE price * 10 END AS points from myportfolio..menu)
SELECT s.customer_id, SUM(p.points) AS total_point
FROM price_points_CTE AS p join myportfolio..sales as s on p.product_id = s.product_id
group by s.customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH price_points_CTE AS 
(SELECT *, DATEADD(day,6,join_date) AS event_date, EOMONTH('2021-01-31') AS end_date 
from 
myportfolio..members AS m)

SELECT
  e.customer_id, 
	SUM( 
    CASE WHEN m.product_name = 'sushi' THEN 20 * m.price
		WHEN s.order_date BETWEEN e.join_date AND e.event_date THEN 20 * m.price
		ELSE 10 * m.price END) AS points
FROM price_points_CTE AS e
JOIN myportfolio..sales AS s
	ON e.customer_id = s.customer_id
JOIN myportfolio..menu AS m
	ON s.product_id = m.product_id
WHERE s.order_date < e.end_date
GROUP BY e.customer_id

