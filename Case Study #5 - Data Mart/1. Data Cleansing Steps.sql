
-- In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:

-- Convert the week_date to a DATE format
-- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
-- Add a month_number with the calendar month for each week_date value as the 3rd column
-- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
-- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value

-- use data_mart;

CREATE TABLE data_mart.clean_weekly_sales
  (WITH date_cte AS
     (SELECT *,
             str_to_date(week_date, '%d/%m/%Y') AS formatted_date
      FROM weekly_sales) SELECT formatted_date AS week_date,
                                extract(WEEK
                                        FROM formatted_date) week_number,
                                extract(MONTH
                                        FROM formatted_date) month_number,
                                extract(YEAR
                                        FROM formatted_date) calendar_year,
                                SEGMENT,
                                CASE
                                    WHEN RIGHT(SEGMENT, 1) = '1' THEN 'Young Adults'
                                    WHEN RIGHT(SEGMENT, 1) = '2' THEN 'Middle Aged'
                                    WHEN RIGHT(SEGMENT, 1) in ('3',
                                                               '4') THEN 'Retirees'
                                    ELSE 'unknown'
                                END AS age_band,
                                CASE
                                    WHEN LEFT(SEGMENT, 1) = 'C' THEN 'Couples'
                                    WHEN LEFT(SEGMENT, 1) = 'F' THEN 'Families'
                                    ELSE 'unknown'
                                END AS demographic,
                                ROUND(sales/transactions, 2) avg_transaction,
                                region,
                                platform,
                                customer_type,
                                sales,
                                transactions
   FROM date_cte);
