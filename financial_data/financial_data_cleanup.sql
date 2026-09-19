/*
Problem Statement
Our Finace team exported 5 years of company transactions
- but the amount column is a mess
Dollar signs, commas, and random text like "Declined", and "Pending" makes it impossible to do any math.
*/

--USE financial_data;

--SELECT * FROM raw_transactions_final;

WITH cleaned AS (
SELECT 
	category,
	YEAR(CAST(transaction_date AS DATE)) AS [year],
	TRY_CAST(
		REPLACE(REPLACE(amount, '$',''),',','') AS DECIMAL(10,2)) AS [amount]
	FROM raw_transactions_final
),

yearly AS (
SELECT category, 
	   year, 
	   SUM(amount) AS [total_spend]
FROM cleaned
GROUP BY category,
	     year),

yoy AS (
SELECT 
category,
year,
total_spend,
LAG(total_spend) OVER(PARTITION BY category ORDER BY year) AS [prev_year_spend],
(total_spend - LAG(total_spend) OVER(PARTITION BY category ORDER BY year)) 
/LAG(total_spend) OVER(PARTITION BY category ORDER BY year) * 100 AS [pct_change_yoy]
FROM yearly)

SELECT category,
	   AVG(pct_change_yoy) AS [average_yoy_growth]
FROM yoy
GROUP BY category
ORDER BY [average_yoy_growth] DESC