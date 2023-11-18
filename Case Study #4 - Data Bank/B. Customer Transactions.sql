 
-- 1. What is the unique count and total amount for each transaction type?

select txn_type,
count(txn_type) as unique_count,
sum(txn_amount) as total_amount 
from customer_transactions
group by txn_type;

-- 2. What is the average total historical deposit counts and amounts for all customers?

with cte as (
select customer_id,count(txn_type) txn_count,
round(avg(txn_amount),2) as txn_total 
from customer_transactions
where txn_type='deposit'
group by customer_id
)
select round(avg(txn_count),0) as average_count,
round(avg(txn_total),2) as average_amount
from cte;

-- 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?

with cte as (
select customer_id,
month(txn_date) as months,
sum(case when txn_type='deposit' then 1 else 0 end) as deposits,
sum(case when txn_type <> 'deposit' then 1 else 0 end) as purchase_or_withdrawal
from customer_transactions
group by customer_id,months
having deposits > 1 and purchase_or_withdrawal =1
order by 1)
select months, count(customer_id) as customers
from cte 
group by months;

-- 4. What is the closing balance for each customer at the end of the month?

WITH txn_monthly_balance_cte AS (
  SELECT
    customer_id,
    MONTH(txn_date) AS txn_month,
    SUM(CASE WHEN txn_type = 'deposit' THEN txn_amount ELSE -txn_amount END) AS net_transaction_amt
  FROM customer_transactions
  GROUP BY customer_id, MONTH(txn_date)
  ORDER BY customer_id, txn_month
)
SELECT
  customer_id,
  txn_month,
  net_transaction_amt,
  SUM(net_transaction_amt) OVER (PARTITION BY customer_id ORDER BY txn_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS closing_balance
FROM txn_monthly_balance_cte;
