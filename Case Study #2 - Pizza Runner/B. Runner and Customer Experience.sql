-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

 select week(registration_date) as registration_week,
 count(runner_id) as runners_signup 
 from runners
 group by registration_week;
 
-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

select r.runner_id,
round(avg(timestampdiff(minute, c.order_time,r.pickup_time))) as arrival_time
from customer_orders c
inner join runner_orders r
on c.order_id=r.order_id
group by r.runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
with cte as (
	select c.order_id,
	count(pizza_id) as number_of_pizzas,
	max(timestampdiff(minute, c.order_time,r.pickup_time)) as prep_time
	from customer_orders c
	inner join runner_orders r
	on c.order_id=r.order_id
	group by c.order_id
)
select number_of_pizzas,
avg(prep_time) as avg_pre_time
from cte
group by number_of_pizzas;

/* On average, a single pizza order takes 12 minutes to prepare.
An order with 3 pizzas takes around half an hour at an average of 10 minutes per pizza.
It takes 18 minutes to prepare an order with 2 pizzas which is 8 minutes per pizza — making 2 pizzas in a single order the ultimate efficiency rate. */

 -- 4. What was the average distance travelled for each customer?
 
 select c.customer_id,round(avg(r.distance),2) as avg_dist_traveled_by_cust
 from customer_orders c
 inner join runner_orders r
 on c.order_id=r.order_id
 where distance != 'null'
 group by customer_id;
 
 -- Customer 104 stays the nearest to Pizza Runner HQ at average distance of 10km, whereas Customer 105 stays the furthest at 25km.
 
 -- 5. What was the difference between the longest and shortest delivery times for all orders?
 
 select max(cast(duration as decimal))-min(cast(duration as decimal)) as difference 
 from runner_orders
 where duration not like 'null';
  
-- The difference between longest (40 minutes) and shortest (10 minutes) delivery time for all orders is 30 minutes.
  
 -- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
 
 select runner_id,order_id,avg((cast(distance as decimal)/(cast(duration as decimal)/60))) as speed
 from runner_orders
 where duration != 'null'
 group by runner_id,order_id;
  
 -- 7. What is the successful delivery percentage for each runner?
 
select 
  runner_id, 
  round(100 * sum(
    case when distance = 0 then 0
    else 1 end) / count(*), 0) as success_perc
from runner_orders
group by runner_id;

/* Runner 1 has 100% successful delivery percentage.
   Runner 2 has 75% successful delivery percentage.
   Runner 3 has 50% successful delivery percentage. */