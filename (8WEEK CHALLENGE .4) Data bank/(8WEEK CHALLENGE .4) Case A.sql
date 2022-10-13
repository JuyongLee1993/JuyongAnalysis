A. Customer Nodes Exploration
--How many unique nodes are there on the Data Bank system?
SELECT
COUNT(DISTINCT(node_id)) unique_node
FROM
customer_nodes
--What is the number of nodes per region?
SELECT
node_id, COUNT(region_id)
FROM
customer_nodes
GROUP BY node_id
ORDER BY 1
--How many customers are allocated to each region?
SELECT
c.region_id, region_name,COUNT(customer_id) AS Region
FROM
customer_nodes c Join
regions r on c.region_id = r.region_id
GROUP BY
c.region_id, region_name
ORDER BY
1

--How many days on average are customers reallocated to a different node?
SELECT
AVG(DATEDIFF(day,start_date,end_date)) AS AVG_nodes
FROM
customer_nodes
WHERE
end_date != '9999-12-31'

--What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
