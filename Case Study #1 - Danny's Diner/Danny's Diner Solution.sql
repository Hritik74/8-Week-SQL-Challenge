CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);


INSERT INTO sales
  (customer_id, order_date, product_id)
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
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu (product_id, product_name,price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  -- 1. What is the total amount each customer spent at the restaurant?
  
select s.customer_id,sum(m.price) as amount_spent from sales s
inner join menu m
on s.product_id=m.product_id
group by s.customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT order_date) AS no_of_days
FROM sales
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

SELECT s.customer_id, m.product_name AS first_purchased_item
FROM (
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM sales
    GROUP BY customer_id
) AS first_orders
JOIN sales AS s ON first_orders.customer_id = s.customer_id AND first_orders.first_order_date = s.order_date
JOIN menu AS m ON s.product_id = m.product_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select count(product_id) as count_of_prod from sales;

SELECT 
  m.product_name,
  COUNT(s.product_id) AS most_purchased_item
FROM sales s
INNER JOIN menu m
  ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY most_purchased_item DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

WITH ProductRank AS (
    SELECT customer_id, product_id,
        dense_rank() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS ranks
    FROM sales
    GROUP BY customer_id, product_id)
SELECT pr.customer_id, m.product_name AS most_popular_item
FROM ProductRank pr JOIN 
    menu m ON pr.product_id = m.product_id
WHERE pr.ranks = 1
order by pr.customer_id;

-- 6. Which item was purchased first by the customer after they became a member?

with cte as (
select s.customer_id, order_date, join_date, product_name,
rank() over(partition by s.customer_id order by order_date) as rnk,
row_number() over(partition by s.customer_id order by order_date) as rn
from sales s
inner join members mem
on mem.customer_id=s.customer_id
inner join menu m
on s.product_id=m.product_id
where order_date>= join_date			
)
select customer_id,product_name
from cte where rnk=1;

-- 7. Which item was purchased just before the customer became a member?

with cte as (
select s.customer_id, order_date, join_date, product_name,
rank() over(partition by s.customer_id order by order_date) as rnk,
row_number() over(partition by s.customer_id order by order_date) as rn
from sales s
inner join members mem
on mem.customer_id=s.customer_id
inner join menu m
on s.product_id=m.product_id
where order_date < join_date			
)
select customer_id,product_name
from cte where rnk=1;

-- 8. What is the total items and amount spent for each member before they became a member?

select s.customer_id, count(product_name),sum(price)
from sales s
inner join members mem
on mem.customer_id=s.customer_id
inner join menu m
on s.product_id=m.product_id
where order_date < join_date
group by s.customer_id
order by 1;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

select customer_id,
sum(case when product_name='sushi' then price*10*2
else price*10
END )AS POINTS
from menu m
inner join sales s on s.product_id=m.product_id
group by customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi — how many points do customer A and B have at the end of January?

SELECT S.customer_id, 
  SUM(CASE 
      WHEN S.order_date BETWEEN MEM.join_date AND DATE_ADD(MEM.join_date, INTERVAL 6 DAY) THEN M.price * 10 * 2 
      WHEN M.product_name = 'sushi' THEN M.price * 10 * 2 
      ELSE M.price * 10 
    END
  ) as points 
FROM MENU as M 
  INNER JOIN SALES as S ON S.product_id = M.product_id
  INNER JOIN MEMBERS AS MEM ON MEM.customer_id = S.customer_id 
WHERE DATE_FORMAT(S.order_date, '%Y-%m-01') = '2021-01-01' 
GROUP BY S.customer_id
order by 1;

-- Bonus Questions -------

-- Recreate the following table output using the available data:

select s.customer_id, s.order_date, m.product_name, m.price,
case when s.order_date < mem.join_date then 'N'
when s.order_date >= mem.join_date then 'Y'
else 'N' end as member_status
from sales s
inner join menu m on s.product_id=m.product_id
left join members mem on mem.customer_id=s.customer_id;

/* Rank All The Things
Danny also requires further information about the ranking of customer products, but he purposely does not 
need the ranking for non-member purchases so he expects null ranking values for the records when 
customers are not yet part of the loyalty program.*/

with cte as (
	select s.customer_id, s.order_date, m.product_name, m.price,
	case when s.order_date < mem.join_date then 'N'
	when s.order_date >= mem.join_date then 'Y'
	else 'N' end as member_status
	from sales s
	inner join menu m on s.product_id=m.product_id
	left join members mem on mem.customer_id=s.customer_id
)
select *,
case when member_status='N' then null
else rank() over(partition by customer_id,member_status order by order_date)
end as ranking
from cte;