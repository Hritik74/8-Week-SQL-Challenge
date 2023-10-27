-- 1. What are the standard ingredients for each pizza?

with cte as (
	select pizza_id,
	  SUBSTRING_INDEX(SUBSTRING_INDEX(toppings, ',', n.digit + 1), ',', -1) as split_value
	from pizza_recipes 
	join 
	  (select 0 as digit union all select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 7 union all select 8 union all select 9) n
	on LENGTH(toppings) - LENGTH(replace(toppings, ',', '')) >= n.digit
	order by pizza_recipes.pizza_id, n.digit
) select topping_name from cte
inner join pizza_toppings
on split_value=topping_id
group by topping_name
having count(distinct(pizza_id))=2;

-- The standard ingredients for each pizza are cheese and mushrooms.
 
-- 2. What was the most commonly added extra?

SELECT  extras,
    topping_name,
    COUNT(extras) AS times_ordered
FROM (
	SELECT order_id,
		CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(extras, ',', numbers.n), ',', -1) AS UNSIGNED) AS extras
        FROM customer_orders,
        (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) numbers
        WHERE numbers.n <= (LENGTH(extras) - LENGTH(REPLACE(extras, ',', '')))+1
    ) AS ordered_extras
JOIN pizza_toppings ON pizza_toppings.topping_id = ordered_extras.extras
GROUP BY extras,
    topping_name
ORDER BY times_ordered DESC
limit 1;

-- 3. What was the most common exclusion?

SELECT 
    topping_name,
    COUNT(exclusions) AS times_ordered
FROM (
	SELECT order_id,
		CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(exclusions, ',', numbers.n), ',', -1) AS UNSIGNED) AS exclusions
        FROM customer_orders,
        (SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5) numbers
        WHERE numbers.n <= (LENGTH(exclusions) - LENGTH(REPLACE(exclusions, ',', '')))+1
    ) AS ordered_exclusions
JOIN pizza_toppings ON pizza_toppings.topping_id = ordered_exclusions.exclusions
GROUP BY exclusions,
    topping_name
ORDER BY times_ordered DESC
limit 1;