-- duckdb md:data_jobs
/*
TEXT FUNCTIONS
*/

-- CHAR_LENGTH() or LENGHT()
SELECT CHAR_LENGTH('SQL');

-- UPPER('string to capitalize')
SELECT UPPER('Sql');

-- UPPER('string to lower case')
SELECT LOWER('SQL');

-- LEFT('string', no_characters_to_choose_from_left)
SELECT LEFT ('SQL', 2);

-- RIGHT('string', no_characters_to_choose_from_right)
SELECT RIGHT('SQL', 2);

-- SUBSTRING('string', starting_position, string_length)
SELECT SUBSTRING('SQL', 2, 1);

-- CONCAT()
SELECT CONCAT('SQL', '-', 'Functions');

SELECT 'SQL' || '-' || 'Functions';

-- TRIM('trim white space of given string')
SELECT TRIM(' SQL ');

-- REPLACE('string', 'substring to replace', 'replacement string')
SELECT REPLACE('SQL', 'Q', '_');

-- REGEXP_REPLACE('string', 'regular expression', 'use chatgpt')
SELECT REGEXP_REPLACE('data.nerd@gmail.com' '^.*(@)' , '\1');


-- FINAL EXAMPLE - Cleanup this using Text Functions
-- (standardize all the text values into lowercase with no whitespace)
WITH title_lower AS (
    SELECT
        job_title,
        LOWER(TRIM(job_title)) AS job_title_clean
    FROM job_postings_fact
)
SELECT
    job_title,
    CASE
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Analyst%' THEN 'Data Analyst'
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Scientist%' THEN 'Data Scientist'
        WHEN job_title LIKE '%Data%' AND job_title LIKE '%Engineer%' THEN 'Data Engineer'
        ELSE 'Other'
    END AS job_title_category
FROM title_lower
ORDER BY RANDOM() 
LIMIT 30;



/*
NULL FUNCTIONS
*/

-- NULLIF(expression1, expression2) returns NULL values whenever value of expression1 = value of expression2
SELECT NULLIF(5+5, 20);

-- use NULLIF() when using aggregation like MEDIAN(), AVG() to exclude 0 values from influencing result
SELECT
    NULLIF(salary_year_avg, 0),
    NULLIF(salary_hour_avg, 0)
FROM
    job_postings_fact
WHERE salary_hour_avg IS NOT NULL OR salary_year_avg IS NOT NULL
LIMIT 10;


-- COALESCE() returns the fist non-NULL value
SELECT COALESCE(NULL, NULL, 2, 3);

-- Use COALESCE() to standardize salary_year_avg and salary_hour_avg columns
SELECT
    salary_year_avg,
    salary_hour_avg,
    COALESCE(salary_year_avg, salary_hour_avg * 40 * 52)
FROM
    job_postings_fact
WHERE salary_hour_avg IS NOT NULL 
    OR salary_year_avg IS NOT NULL
LIMIT 10;

/*
-- Use COALESCE() to simplify the following query

WITH salaries AS (
    SELECT
        job_title_short,
        salary_year_avg,
        salary_hour_avg,
        CASE
            WHEN salary_year_avg IS NULL THEN salary_hour_avg*40*52
            WHEN salary_hour_avg IS NULL THEN salary_year_avg
        END AS standardized_salary
    FROM job_postings_fact
)
SELECT
    *,
    CASE
        WHEN standardized_salary IS NULL THEN 'Missing'
        WHEN standardized_salary < 75_000 THEN 'Low'
        WHEN standardized_salary < 150_000 THEN 'Medium'
        ELSE 'High'
    END AS salary_bucket
FROM salaries
ORDER BY standardized_salary DESC
LIMIT 10;
*/

SELECT
    job_title_short,
    salary_year_avg,
    salary_hour_avg,
    COALESCE(salary_year_avg, salary_hour_avg *40*52) AS standardized_salary,
    CASE
        WHEN COALESCE(salary_year_avg, salary_hour_avg *40*52) IS NULL THEN 'Missing'
        WHEN COALESCE(salary_year_avg, salary_hour_avg *40*52) < 75_000 THEN 'Low'
        WHEN COALESCE(salary_year_avg, salary_hour_avg *40*52) < 150_000 THEN 'Medium'
        ELSE 'High'
    END AS salary_bucket
FROM job_postings_fact
ORDER BY standardized_salary DESC;