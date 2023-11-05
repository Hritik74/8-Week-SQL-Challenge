
-- 1. How many customers has Foodie-Fi ever had?

select count(distinct(customer_id)) 
as Total_customers
from subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset
-- use the start of the month as the group by value.

select 
	month(start_date) as month_date, 
	monthname(start_date) as months,
	count(s.customer_id) as COUNTS 
from subscriptions s
inner join plans p
on s.plan_id=p.plan_id
where p.plan_name='trial'
group by month_date,months
order by 1;

-- 3. What plan start_date values occur after the year 2020 for our dataset? 
-- Show the breakdown by count of events for each plan_name

select 
	p.plan_name,
	count(start_date) as count_of_events
from subscriptions s
inner join plans p
on s.plan_id=p.plan_id
where year(start_date)>2020
group by p.plan_name;

-- 4. What is the customer count and percentage of customers 
-- who have churned rounded to 1 decimal place?

SELECT
  COUNT(DISTINCT s.customer_id) AS churned_customers,
  ROUND(100 * COUNT(s.customer_id)
    / (SELECT COUNT(DISTINCT customer_id) 
    	FROM subscriptions)
  ,1) AS churn_percentage
FROM subscriptions s
JOIN plans p
  ON s.plan_id = p.plan_id
WHERE p.plan_id = 4;

-- 5. How many customers have churned straight after their initial free trial 
-- what percentage is this rounded to the nearest whole number?
 
 with cte as (
	select customer_id,
	plan_name,
	row_number() over(partition by customer_id order by start_date) as rn
	from subscriptions as s
	inner join plans p
	on s.plan_id=p.plan_id
) 
select count(distinct customer_id) as churned_customers_id,
round((count(distinct customer_id)/(SELECT  count(distinct customer_id) from subscriptions))*100) as percentage
 from cte
where rn = 2 and plan_name='churn'
;

-- 6. What is the number and percentage of customer plans after their initial free trial?

with cte as (
	select customer_id,
	plan_name,
	row_number() over(partition by customer_id order by start_date) as rn
	from subscriptions as s
	inner join plans p
	on s.plan_id=p.plan_id
) 
select plan_name,
count(customer_id) as customer_count,
round(count(customer_id)/(select count(distinct customer_id) from cte )* 100,1) as percentages
from cte 
where rn = 2
group by plan_name;

-- 7. What is the customer count and 
-- percentage breakdown of all 5 plan_name values at 2020-12-31?

with cte as (
	select *,
	row_number() over(partition by customer_id order by start_date desc) as rn
	from subscriptions
	where start_date <= '2020-12-31'
)  
select plan_name,
count(customer_id) as customer_count,
round(count(customer_id)/(select count(distinct customer_id) from cte )* 100,1) as percentage
 from cte
inner join plans p on cte.plan_id=p.plan_id
where rn=1
group by plan_name;

-- 8. How many customers have upgraded to an annual plan in 2020?

SELECT  
COUNT(customer_id) as no_of_customers
FROM subscriptions s
WHERE start_date < '2021-01-01' 
AND plan_id = 3 ;

-- 9. How many days on average does it take for a customer to an annual plan 
-- from the day they join Foodie-Fi?

with trial as (
select customer_id, start_date as trial_start from subscriptions where plan_id=0
)
, annual as (
select customer_id, start_date as annual_start from subscriptions where plan_id=3
)
select 
round(avg(datediff(annual_start,trial_start)),0) as average_no_of_customers
from trial T
inner join annual as A on T.customer_id=A.customer_id;

-- 10. Can you further breakdown this average value
--  into 30 day periods (i.e. 0-30 days, 31-60 days etc).
 
-- Learning how to create buckets in SQL, will come back to this.
 
-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

SELECT
 COUNT(*) as number_downgraded_customer
FROM  (
	SELECT  
	customer_id
	, p.plan_id planid 
	, plan_name
	, start_date
	, LEAD(p.plan_id, 1) OVER(PARTITION BY customer_id ORDER BY start_date) as lead_date
	FROM subscriptions s
JOIN plans p on p.plan_id = s.plan_id
WHERE start_date <= '2020-12-31') t
WHERE  t.planid = 2
and lead_date = 1;
