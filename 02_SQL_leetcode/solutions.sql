/*
Q1 — Basic Aggregation: 
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
*/
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





/*
Q7 — Combine Two Tables (#175)
*/
SELECT
    p.firstName,
    p.lastName,
    a.city,
    a.state
FROM Person AS p
LEFT JOIN Address AS a
    ON p.personId = a.personId;





/*
Q8 — Second Highest Salary (#176)
*/
SELECT (
    SELECT DISTINCT salary
    FROM Employee
    ORDER BY salary DESC
    LIMIT 1 OFFSET 1
) AS SecondHighestSalary;

-- The inner query sorts distinct salaries from highest to lowest 
-- and skips the first one. If there isn’t a second distinct salary,
-- the scalar subquery returns NULL, while the outer query still returns one row.





/*
Q9 — Rank Scores (#178)
*/
SELECT
    score,
    DENSE_RANK() OVER(
        ORDER BY score DESC
    ) AS rank
FROM Scores
ORDER BY score DESC;





/*
Q10 — Consecutive Numbers (#180)
*/
WITH cte AS (
    SELECT
        id,
        num,
        LAG(num, 1) OVER(ORDER BY id) AS lag_1,
        LAG(num, 2) OVER(ORDER BY id) AS lag_2
    FROM Logs
)
SELECT DISTINCT
    num AS ConsecutiveNums
FROM cte
WHERE 
    num = lag_1 AND 
    num = lag_2;





/*
Q11 — Department Highest Salary (#184)
*/
WITH cte AS (
    SELECT
        e.name AS Employee,
        e.salary AS Salary,
        d.name AS Department,
        RANK() OVER(
            PARTITION BY e.departmentId
            ORDER BY e.salary DESC
        ) AS ranked_salary
    FROM Employee AS e
    LEFT JOIN Department AS d
        ON e.departmentId = d.id
)
SELECT
    Department,
    Employee,
    Salary
FROM cte
WHERE 
    ranked_salary = 1;





/*
Q12 — Rising Temperature (#197)
*/
WITH cte AS (
    SELECT
        id,
        recordDate,
        temperature,
        LAG(temperature) OVER(ORDER BY id) AS previous_temp,
        LAG(recordDate) OVER(ORDER BY id) AS previous_date
    FROM Weather
)
SELECT id
FROM cte
WHERE 
    temperature > previous_temp AND
    DATEDIFF('day', previous_date, recordDate) = 1;