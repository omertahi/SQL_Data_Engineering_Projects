-- run "duckdb md:jobs_mart" in terminal

/*
CTAS, VIEW and TEMP TABLE
- CTAS is a persistnet snapshot 
    - CREATE TABLE AS SELECT
    - CTAS allows you to create a table out by querying a Source Table
- VIEW is always live
    - stored query definition
    - no data stored
    - always reflects latest data
    - slower (recomputes)
- TEMP TABLE is a session-scoped table
    - auto-deleted when session disconnected
    - used when you're working with a complex query
    - great for debugging
    - NOTE: lives OUTSIDE of SCHEMA so do NOT use scheme.table_name when creating temp table

To make code IDEMPOTENT
    - use CREATE OR REPLACE command
    - .read Lessons/1.8_DDL_DML_Part2.sql
*/

-- create table using CTAS
CREATE OR REPLACE TABLE staging.job_postings_flat AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_title,
    jpf.job_location,
    jpf.job_via,
    jpf.job_schedule_type,
    jpf.job_work_from_home,
    jpf.search_location,
    jpf.job_posted_date,
    jpf.job_no_degree_mention,
    jpf.job_health_insurance,
    jpf.job_country,
    jpf.salary_rate,
    jpf.salary_year_avg,
    jpf.salary_hour_avg,
    cd.name AS company_name
FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id;

-- show CTAS table
SELECT *
FROM staging.job_postings_flat
LIMIT 10;

-- show tables and schemas in jobs_mart
SELECT *
FROM information_schema.tables
WHERE table_catalog = 'jobs_mart';

-- create VIEW 
CREATE OR REPLACE VIEW staging.priority_jobs_flat_view AS
SELECT 
    jpf.*
FROM staging.job_postings_flat AS jpf
LEFT JOIN staging.priority_roles AS r
    ON jpf.job_title_short = r.role_name
WHERE r.priority_lvl = 1;

-- visualize summary of VIEW
SELECT 
    job_title_short,
    COUNT(*) AS job_count,
FROM staging.priority_jobs_flat_view
GROUP BY
    job_title_short
ORDER BY
    job_count DESC;

-- create TEMP TABLE
CREATE TEMPORARY TABLE senior_jobs_flat_temp AS
SELECT *
FROM staging.priority_jobs_flat_view
WHERE job_title_short = 'Senior Data Engineer';

-- visualize summary of TEMP TABLE
SELECT 
    job_title_short,
    COUNT(*) AS job_count,
FROM senior_jobs_flat_temp
GROUP BY
    job_title_short
ORDER BY
    job_count DESC;

/*
See how the use of DELETE (DML command) on the CTAS table effects the following:
    - CTAS table
    - VIEW table
    - TEMP table
*/
-- show row counts for CTAS table, VIEW table, TEMP table
SELECT COUNT(*) FROM staging.job_postings_flat;
SELECT COUNT(*) FROM staging.priority_jobs_flat_view;
SELECT COUNT(*) FROM senior_jobs_flat_temp;

-- DELETE rows prior to 2024 from CTAS table
DELETE FROM staging.job_postings_flat
WHERE job_posted_date < '2024-01-01';

-- show resultant row counts for CTAS table, VIEW table, TEMP table
SELECT COUNT(*) FROM staging.job_postings_flat;         -- shows reduced count (due to DML performed on it)
SELECT COUNT(*) FROM staging.priority_jobs_flat_view;   -- shows reduced count (auto-recompute data)
SELECT COUNT(*) FROM senior_jobs_flat_temp;             -- stays the same

/*
See how the use of TRUNCATE (DDL command) on the CTAS table effects the following:
    - CTAS table
    - VIEW table
    - TEMP table
*/

-- TRUNCATE (delete all rows) CTAS table
TRUNCATE TABLE staging.job_postings_flat;

-- show resultant row counts for CTAS table, VIEW table, TEMP table
SELECT COUNT(*) FROM staging.job_postings_flat;         -- shows 0 count (due to DDL performed on it)
SELECT COUNT(*) FROM staging.priority_jobs_flat_view;   -- shows 0 count (auto-recompute data)
SELECT COUNT(*) FROM senior_jobs_flat_temp;             -- stays the same

/*
See how the use of INSERT (DML command) on the CTAS table effects the following:
    - CTAS table
    - VIEW table
    - TEMP table
*/

-- INSERT rows into CTAS table
INSERT INTO staging.job_postings_flat (
    SELECT
        jpf.job_id,
        jpf.job_title_short,
        jpf.job_title,
        jpf.job_location,
        jpf.job_via,
        jpf.job_schedule_type,
        jpf.job_work_from_home,
        jpf.search_location,
        jpf.job_posted_date,
        jpf.job_no_degree_mention,
        jpf.job_health_insurance,
        jpf.job_country,
        jpf.salary_rate,
        jpf.salary_year_avg,
        jpf.salary_hour_avg,
        cd.name AS company_name
    FROM data_jobs.job_postings_fact AS jpf
    LEFT JOIN data_jobs.company_dim AS cd
        ON jpf.company_id = cd.company_id
    WHERE jpf.job_posted_date >= '2024-01-01'
);

-- show resultant row counts for CTAS table, VIEW table, TEMP table
SELECT COUNT(*) FROM staging.job_postings_flat;         -- shows new count (due to DML performed on it)
SELECT COUNT(*) FROM staging.priority_jobs_flat_view;   -- shows new count (auto-recompute data)
SELECT COUNT(*) FROM senior_jobs_flat_temp;             -- stays the same

