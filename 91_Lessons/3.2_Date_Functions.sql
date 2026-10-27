-- run "duckdb md:data_jobs" in terminal

/*
Date Functions:
    - EXTRACT()
    - DATE_TRUNC()
    - AT TIME ZONE
*/

-- DATE/TIME datatypes
SELECT 
    job_posted_date,
    job_posted_date::DATE AS date,
    job_posted_date::TIME AS time,
    job_posted_date::TIMESTAMP AS timestamp,
    job_posted_date::TIMESTAMPTZ AS timestamptz
FROM job_postings_fact
LIMIT 10;


-- EXTRACT() function
SELECT 
    job_posted_date,
    EXTRACT(year FROM job_posted_date) AS job_posted_year,
    EXTRACT(month FROM job_posted_date) AS job_posted_month,
    EXTRACT(day FROM job_posted_date) AS job_posted_day
FROM job_postings_fact
LIMIT 10;


-- Example: Monthly job posting over time using EXTRACT()
SELECT
    EXTRACT(year FROM job_posted_date) AS job_posted_year,
    EXTRACT(month FROM job_posted_date) AS job_posted_month,
    COUNT(job_id) AS job_count
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
GROUP BY
    EXTRACT(year FROM job_posted_date),
    EXTRACT(month FROM job_posted_date)
ORDER BY
    job_posted_year,
    job_posted_month;


-- DATE_TRUNC() function
SELECT
    job_posted_date,
    DATE_TRUNC('year', job_posted_date) AS truncated_year,
    DATE_TRUNC('quarter', job_posted_date) AS truncated_quarter,
    DATE_TRUNC('month', job_posted_date) AS truncated_month,
    DATE_TRUNC('week', job_posted_date) AS truncated_week,
    DATE_TRUNC('day', job_posted_date) AS truncated_day,
    DATE_TRUNC('hour', job_posted_date) AS truncated_hour
FROM job_postings_fact
ORDER BY RANDOM()
LIMIT 10;


-- Example: Monthly job posting over time using DATE_TRUNC()
SELECT
    DATE_TRUNC('month', job_posted_date) AS job_posted_month,
    COUNT(job_id) AS job_count
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
GROUP BY
    DATE_TRUNC('month', job_posted_date)
ORDER BY
    job_posted_month;


-- Example: Monthly job posting over time using DATE_TRUNC() and EXTRACT()
SELECT
    DATE_TRUNC('month', job_posted_date) AS job_posted_month,
    COUNT(job_id) AS job_count
FROM job_postings_fact
WHERE job_title_short = 'Data Engineer'
    AND EXTRACT(year FROM job_posted_date) = 2024
--      DATE_TRUNC('year', job_posted_date) = '2024-01-01'
GROUP BY
    DATE_TRUNC('month', job_posted_date)
ORDER BY
    job_posted_month;


-- AT TIME ZONE
SELECT
    '2026-01-01 00:00:00+00':: TIMESTAMPTZ AT TIME ZONE 'EST';

-- Example: look at job post date/times of New York in local NY time
SELECT
    job_title_short,
    job_location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
FROM
    job_postings_fact
WHERE
    job_location LIKE 'New York, NY';

-- Example: Hourly job postings over local time in New York (using AT TIME ZONE and EXTRACT())
SELECT
    EXTRACT(hour FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST') AS job_posted_hour,
    COUNT(job_id)
FROM
    job_postings_fact
WHERE
    job_location LIKE 'New York, NY'
GROUP BY
    EXTRACT(hour FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST')
ORDER BY
    job_posted_hour;