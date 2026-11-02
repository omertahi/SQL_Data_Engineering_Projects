/*
1. Note: If sql_practice.duckdb exists, then use the database by running the following in Terminal:
    - duckdb sql_practice.duckdb

2. Note: If no practice database exists, then initialize an empty database and load tables into it using:
    - duckdb sql_practice.duckdb -c ".read 92_SQL_practice/build_practice_database.sql"
    - duckdb sql_practice.duckdb

Practice Questions and their associated tables:
Q1, Q2, Q3, Q6 -> transactions
Q4 -> customers + staging_customers
Q5 -> patient_records
Q7 -> Person + Address
Q8, Q11 -> Department + Employee 
Q9 -> Scores
Q10 -> Logs
Q12 -> Weather
*/
PRAGMA show_tables;





/*
Q1 — Basic Aggregation: 
You have a `transactions` table with columns: 
    - transaction_id
    - customer_id
    - amount
    - transaction_date
Write a query to find the top 5 customers by total transaction amount in 2024.
*/
SELECT * FROM transactions;





/*
Q2 — Window Function: 
Using the same `transactions` table, write a query that 
ranks each customer's transactions by amount within each month.
*/
SELECT * FROM transactions;





/*
Q3 — CTE + Conditional: 
Given the `transactions` table, find all customers 
who made more than 3 transactions in any single month. 
*/
SELECT * FROM transactions;





/*
Q4 — MERGE (Upsert):
Given `customers` and `staging_customers`,
where staging_customers table contains new/updated records,
write a MERGE statement to upsert into customers.
*/
SELECT * FROM customers;
SELECT * FROM staging_customers;





/*
Q5 — Data Quality Check: 
Given `Person` and `Address`, write a query to 
find duplicate rows in a patient_records table 
based on patient_id and admission_date.
*/
SELECT * FROM  patient_records;





/*
Q6 — LAG/LEAD (common in pipeline monitoring): 
Given the `transactions` tables, find the difference in transaction amount
between each customer's current and previous transaction.
*/
SELECT * FROM transactions;





/*
Q7 — Combine Two Tables (#175)
Given `Person` and `Address`, return each person’s first and last name,
along with their city and state. 
Include every person, even if they have no matching address;
in that case, the address fields should be `NULL`.

Result columns: `firstName`, `lastName`, `city`, `state`
*/
SELECT * FROM Person;
SELECT * FROM Address;





/*
Q8 — Second Highest Salary (#176)
Given the `Employee` table, return the second-highest **distinct** salary.
If there is no second-highest salary, return `NULL`.

Result column: `SecondHighestSalary`
*/
SELECT * FROM Employee;





/*
Q9 — Rank Scores (#178)
Given the `Scores` table, rank each score from highest to lowest. 
Equal scores share the same rank, and 
the next distinct score gets the next consecutive rank (no gaps).

Result columns: `score`, `rank`
*/
SELECT * FROM Scores;





/*
Q10 — Consecutive Numbers (#180)
Given the `Logs` table, find each number that 
appears at least three times consecutively in rows ordered by `id`.
Return each qualifying number once.

Result column: `ConsecutiveNums`
*/
SELECT * FROM Logs;





/*
Q11 — Department Highest Salary (#184)
Given `Employee` and `Department`, 
find the employee or employees with the highest salary in each department. 
Include all employees tied for the department’s highest salary.

Result columns: `Department`, `Employee`, `Salary`
*/
SELECT * FROM Department;
SELECT * FROM Employee;





/*
Q12 — Rising Temperature (#197)
Given the `Weather` table, find the IDs of records whose 
temperature is higher than the temperature on the previous calendar day. 
A record only qualifies if the previous row’s date is exactly one day earlier.

Result column: `id`
*/
SELECT * FROM Weather;





