-- run "duckdb md:data_jobs" in terminal

-- UNION
SELECT UNNEST([1, 1, 1, 2])
UNION
SELECT UNNEST([1, 1, 3]);

-- UNION ALL
SELECT UNNEST([1, 1, 1, 2])
UNION ALL
SELECT UNNEST([1, 1, 3]);

-- INTERSECT
SELECT UNNEST([1, 1, 1, 2])
INTERSECT
SELECT UNNEST([1, 1, 3]);

-- INTERSECT ALL
SELECT UNNEST([1, 1, 1, 2])
INTERSECT ALL
SELECT UNNEST([1, 1, 3]);

-- EXCEPT
SELECT UNNEST([1, 1, 1, 2])
EXCEPT
SELECT UNNEST([1, 1, 3]);

-- EXCEPT
SELECT UNNEST([1, 1, 1, 2])
EXCEPT ALL
SELECT UNNEST([1, 1, 3]);

/*
1) Which unique job postings appeared in either 2023 or 2024?
2) Which job postings appeared across both years, counting duplicates?
3) Which job postings appeared in both 2023 and 2024?
4) Which job postings appeared in both years, preserving duplicate counts?
5) Which job postings appeared in 2023 but not in 2024?
6) Which job postings from 2023 remain after subtracting matching 2024 postings, one-for-one?
*/

-- Initialize 2023 jobs table
CREATE TEMP TABLE jobs_2023 AS
SELECT * EXCLUDE(job_id, job_posted_date)
FROM job_postings_fact
WHERE EXTRACT(year FROM job_posted_date) = 2023;
-- Show jobs_2023 table
SELECT * FROM jobs_2023;


-- Initialize 2024 jobs table
CREATE TEMP TABLE jobs_2024 AS
SELECT * EXCLUDE(job_id, job_posted_date)
FROM job_postings_fact
WHERE EXTRACT(year FROM job_posted_date) = 2024;
-- Show jobs_2024 table
SELECT * FROM jobs_2024;

-- (1)
SELECT * FROM jobs_2023
UNION
SELECT * FROM jobs_2024;


-- (2)
SELECT * FROM jobs_2023
UNION ALL
SELECT * FROM jobs_2024;


-- (3)
SELECT * FROM jobs_2023
INTERSECT
SELECT * FROM jobs_2024;


--(4)
SELECT * FROM jobs_2023
INTERSECT ALL
SELECT * FROM jobs_2024;


-- (5)
SELECT * FROM jobs_2023
EXCEPT
SELECT * FROM jobs_2024;


-- (6)
SELECT * FROM jobs_2023
EXCEPT ALL
SELECT * FROM jobs_2024;