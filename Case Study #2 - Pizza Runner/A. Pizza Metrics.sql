CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
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

CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
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


CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
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
  
  
  -- 1. How many pizzas were ordered?

select count(*) as number_of_pizzas_ordered
from customer_orders;
  
 -- 2. How many unique customer orders were made?
 
 select count(distinct(order_id))
 from customer_orders;
  
 -- 3. How many successful orders were delivered by each runner?
 
 select runner_id, 
  COUNT(order_id) AS successful_orders
  from runner_orders
 where duration != 0
 GROUP BY runner_id;
 
 -- 4. How many of each type of pizza was delivered?
 
 select p.pizza_name,count(co.pizza_id) 
 from customer_orders co
 inner join runner_orders ro
 on co.order_id=ro.order_id
 inner join pizza_names p 
 on co.pizza_id=p.pizza_id
 where ro.duration != 0
 GROUP BY p.pizza_name;
  
 -- 5. How many Vegetarian and Meatlovers were ordered by each customer?
 
 select co.customer_id,p.pizza_name,count(co.pizza_id) as pizzas_ordered 
 from customer_orders co
 inner join pizza_names p 
 on co.pizza_id=p.pizza_id
 GROUP BY p.pizza_name, co.customer_id
 order by 1; 

 -- 6. What was the maximum number of pizzas delivered in a single order?
 
 select c.order_id,count(c.pizza_id) as no_of_pizzas_delivered
 from customer_orders c
 inner join runner_orders r on c.order_id=r.order_id
 where pickup_time!=0
 group by order_id, r.pickup_time
 order by no_of_pizzas_delivered desc
 limit 1;
 
/* Maximum number of pizza delivered in a single order is 3 pizzas.*/
 
 -- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
 
 select c.customer_id,
 sum(case when
	 (c.exclusions is not null and c.exclusions != 'null' and length(c.exclusions)>0)
	 or (c.extras is not null and c.extras != 'null' and length(c.extras)>0) then 1
 else 0 end ) as changes,
sum(case when
	(c.exclusions is not null and c.exclusions != 'null' and length(c.exclusions)>0)
	 or (c.extras is not null and c.extras != 'null' and length(c.extras)>0) then 0
 else 1 end ) as no_changes
 from customer_orders c
 join runner_orders r
 on c.order_id=r.order_id
 where r.distance != 0
 group by c.customer_id;
 
 -- 8. How many pizzas were delivered that had both exclusions and extras?
 
 select count(pizza_id) as pizzas_delivered_with_exclusions_and_extras
 from customer_orders c
 inner join runner_orders r on c.order_id=r.order_id
 where pickup_time != 'null' 
 and (exclusions is not null and exclusions != 'null' and length(exclusions)>0)
 and (extras is not null and extras != 'null' and length(extras)>0);
 
 -- 9. What was the total volume of pizzas ordered for each hour of the day?
 
 select HOUR(order_time) as hours,
 count(pizza_id) as pizzas_ordered 
 from customer_orders
 group by hours
 order by 1;
 
 -- 10. What was the volume of orders for each day of the week?

SELECT dayname(order_time) AS day_of_week,
       COUNT(order_id) AS pizzas_ordered
FROM customer_orders
GROUP BY day_of_week;
  
  
  