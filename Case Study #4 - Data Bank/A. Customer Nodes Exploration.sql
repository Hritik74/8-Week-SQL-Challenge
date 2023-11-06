
-- 1. How many unique nodes are there on the Data Bank system?

select count(distinct node_id) as unique_nodes
from customer_nodes;

-- 2. What is the number of nodes per region?

select c.region_id,count(c.node_id) as number_of_nodes from customer_nodes c
inner join regions r 
on c.region_id=r.region_id
group by c.region_id;

-- 3. How many customers are allocated to each region?

select c.region_id,r.region_name,count(distinct(customer_id)) as number_of_customers
from customer_nodes c
inner join regions r 
on c.region_id=r.region_id
group by c.region_id,r.region_name;

-- 4. How many days on average are customers reallocated to a different node?

with cte as (
	SELECT customer_id,node_id,sum(datediff(end_date,start_date)) as days_in_node 
	FROM customer_nodes
	WHERE end_date!='9999-12-31'
	group by  customer_id,node_id 
)
select avg(days_in_node) as average_days 
from cte

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

-- Learning how to calcualte median in SQL, will come back to this.