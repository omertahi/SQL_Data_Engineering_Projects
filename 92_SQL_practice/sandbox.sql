/*
1. Note: If sql_practice.duckdb exists, then use the database by running the following in Terminal:
    - duckdb sql_practice.duckdb

2. Note: If no practice database exists, then initialize an empty database and load tables into it using:
    - cd 99_SQL_practice
    - duckdb sql_practice.duckdb -c ".read build_practice_database.sql"
    - duckdb sql_practice.duckdb

Practice questions:
Q1, Q2, Q3, Q6 -> transactions
Q4 -> customers + staging_customers
Q5 -> patient_records
*/
PRAGMA show_tables;
DESCRIBE transactions;
DESCRIBE customers;
DESCRIBE staging_customers;
DESCRIBE patient_records;


/*
Q1 — Basic Aggregation: 
You have a transactions table with columns: 
    - transaction_id
    - customer_id
    - amount
    - transaction_date
Write a query to find the top 5 customers by total transaction amount in 2024.
*/
SELECT
    customer_id,
    SUM(amount) AS total_amount
FROM transactions
WHERE EXTRACT(year FROM transaction_date) = 2024
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 5;

/*
Q2 — Window Function: 
Using the same table, write a query that ranks each customer's transactions by amount within each month.
*/
SELECT 
    customer_id,
    transaction_id,
    amount,
    transaction_date,
    DENSE_RANK() OVER(
        PARTITION BY 
            customer_id,
            DATE_TRUNC('month', transaction_date)
        ORDER BY amount DESC
    ) AS monthly_rank
FROM transactions
ORDER BY transaction_date;

/*
Q3 — CTE + Conditional: 
Find all customers who made more than 3 transactions in any single month.
*/
WITH monthly_counts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', transaction_date) AS txn_month,
        COUNT(transaction_id) AS txn_count
    FROM transactions
    GROUP BY 
        customer_id,
        txn_month
    HAVING COUNT(transaction_id) >= 3
)
SELECT DISTINCT
    customer_id
FROM monthly_counts;

/*
Q4 — MERGE (Upsert):
- You have a staging_customers table with new/updated records. 
- Write a MERGE statement to upsert into customers.
*/
SELECT * FROM customers;
SELECT * FROM staging_customers;


MERGE INTO customers AS tgt
USING staging_customers AS src
ON tgt.customer_id = src.customer_id
	
WHEN MATCHED THEN
	UPDATE SET
		name = src.name,
		email = src.email

WHEN NOT MATCHED THEN
	INSERT (
		customer_id,
		name,
		email
	)
	VALUES (
        src.customer_id,
		src.name,
		src.email
	);

/*
Q5 — Data Quality Check: 
Write a query to find duplicate rows in a patient_records table based on patient_id and admission_date.
*/
SELECT
    t1.record_id AS record_id_1,
    t2.record_id AS record_id_2,
    t1.patient_id,
    t1.admission_date
FROM patient_records AS t1
JOIN patient_records AS t2
    ON t1.record_id < t2.record_id
    AND t1.patient_id = t2.patient_id
    AND t1.admission_date = t2.admission_date;

-- OR
SELECT
    patient_id,
    admission_date,
    COUNT(*) AS duplicate_count
FROM patient_records
GROUP BY 
    patient_id,
    admission_date
HAVING COUNT(*) > 1;

/*
Q6 — LAG/LEAD (common in pipeline monitoring): 
Find the difference in transaction amount between each customer's current and previous transaction.
*/
SELECT 
    customer_id,
    amount,
    LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY transaction_date
    ) AS prev_amount,
    amount - LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY transaction_date
    ) AS diff_amount
FROM transactions
ORDER BY customer_id, transaction_date;
