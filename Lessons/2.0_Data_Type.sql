-- run "duckdb md:data_jobs" in terminal

/*
Consult the documentation any time you do conversions:

https://duckdb.org/docs/current/sql/data_types/overview

*/

-- check DATA_TYPES for SELECTED columns using information_schema
SELECT
    table_name,
    column_name,
    data_type
FROM 
    information_schema.columns
WHERE
    table_name = 'job_postings_fact';

-- CAST() is used to change data type of column
SELECT CAST('123' AS INTEGER);

-- certain conversions break logic
SELECT CAST('abdc' AS INTEGER);

/* 
BOOLEAN to INTEGER conversion
    - FALSE=0
    - TRUE=1

DECIMAL(a, b) has two arguments
    a - precision (full amount of numbers)
    b - scale (number of decimal places after)
*/
SELECT
    job_id,
    company_id,
    CAST(job_work_from_home AS INT) AS job_work_from_home, -- from boolean to numeric
    CAST(job_posted_date AS DATE) AS job_posted_date, -- from timestamp to date
    CAST(salary_year_avg AS DECIMAL(10, 0)) AS salary_year_avg -- from double to no decimal
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
LIMIT 10;

-- "::" operator can substitue CAST()
SELECT
    job_id,
    company_id,
    job_work_from_home::INT AS job_work_from_home,
    job_posted_date::DATE AS job_posted_date,
    salary_year_avg::DECIMAL(10, 0) AS salary_year_avg
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL
LIMIT 10;

/*

CONCAT(a, b, ...) is used to append values of two columns into one
"||" operator can substitute CONCAT(...)

*/
SELECT
    job_id::VARCHAR || '-' || company_id::VARCHAR AS unique_id,
FROM
    job_postings_fact
LIMIT 10;