-- Demographic classification: Classify the customers based on available demography such as age group, gender, occupation etc. and provide insights based on them.
WITH total_customers AS 
(
    SELECT
        age_group,
        occupation,
        gender,
        customer_id AS customers
    FROM
        Banking..dim_customers
)
SELECT 
    age_group,
    occupation,
    gender,
    COUNT(DISTINCT customers) AS total_customers,
    payment_type
FROM 
    total_customers
JOIN
    Banking..fact_spends fs ON fs.customer_id = total_customers.customers
GROUP BY
    age_group,
    occupation,
    gender,
    payment_type
ORDER BY
    total_customers DESC;

-- Avg income utilisation %: Find the average income utilisation % of customers (avg_spends/avg_income). This will be your key metric. The higher the average income utilisation %, the more is their likelihood to use credit cards.

SELECT
		age_group AS customer_age,
		city,
		occupation,
		COUNT(dm.customer_id) AS total_customer,
		CAST(AVG(fs.spend) * 1.0 / dm.avg_income AS FLOAT) * 100 AS 'income %'
FROM
		Banking..dim_customers dm
JOIN
		Banking..fact_spends fs ON fs.customer_id = dm.customer_id
GROUP BY
		avg_income,
		city,
		occupation,
		age_group
ORDER BY
		(AVG(spend)*1.0/avg_income)*100 DESC

-- Spending Insights: Where do people spend money the most? Does it have any impact due to occupation, gender, city, age etc.? This can help you to add relevant credit card features for specific target groups.

SELECT
		category,
		occupation,
		gender,
		city,
		age_group,
		SUM(spend) AS money_spend,
		AVG(spend) AS avg_spend
FROM
		Banking..fact_spends fs
JOIN
		Banking..dim_customers dc ON dc.customer_id = fs.customer_id
GROUP BY
		category,
		occupation,
		gender,
		city,
		age_group
ORDER BY
		SUM(spend) DESC

-- Key Customer Segments: By doing above, you should be able to identify and profile key customer segments that are likely to be the highest-value users of the new credit cards. This includes understanding their demographics, spending behaviours, and financial preferences.

SELECT
		DISTINCT(fs.customer_id) AS customer,
		category,
		gender,
		city,
		age_group,
		payment_type,
		SUM(spend) AS money_spend
FROM
		Banking..fact_spends fs
JOIN
		Banking..dim_customers dc ON dc.customer_id = fs.customer_id
GROUP BY
		category,
		occupation,
		gender,
		payment_type,
		city,
		fs.customer_id,
		age_group
ORDER BY
		SUM(spend) DESC OFFSET 0 ROWS FETCH NEXT 10 ROWS ONLY