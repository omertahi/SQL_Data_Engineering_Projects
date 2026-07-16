-- Step 7: Mart - Create company mart (dimensional mart)
-- Run this after Step 6
-- This mart focuses on company hiring trends by role, location, and month.

-- Drop existing mart schema if it exists (for idempotency)
DROP SCHEMA IF EXISTS company_mart CASCADE;

-- Step 1: Create the mart schema
CREATE SCHEMA company_mart;

-- Step 2: Create dimension tables
-- 1. Job Title dimension
SELECT '=== Loading Job Title Dim for COMPANY MART ===' AS info;

CREATE TABLE company_mart.dim_job_title (
    job_title_id    INTEGER PRIMARY KEY,
    job_title       VARCHAR
);

INSERT INTO company_mart.dim_job_title (
    job_title_id,
    job_title
)
WITH distinct_job_titles AS (
    SELECT DISTINCT
        job_title
    FROM job_postings_fact
    WHERE job_title IS NOT NULL
)
SELECT
    ROW_NUMBER() OVER(
        ORDER BY job_title
    ) AS job_title_id,
    job_title
FROM distinct_job_titles
ORDER BY job_title_id;

-- 2. Job Title Short dimension
SELECT '=== Loading Job Title Short Dim for COMPANY MART ===' AS info;

CREATE TABLE company_mart.dim_job_title_short (
    job_title_short_id  INTEGER PRIMARY KEY,
    job_title_short     VARCHAR
);

INSERT INTO company_mart.dim_job_title_short (
    job_title_short_id,
    job_title_short
)
WITH distinct_job_titles_short AS (
    SELECT DISTINCT
        job_title_short
    FROM job_postings_fact
    WHERE job_title_short IS NOT NULL
)
SELECT
    ROW_NUMBER() OVER(
        ORDER BY job_title_short
    ) AS job_title_short_id,
    job_title_short
FROM distinct_job_titles_short
ORDER BY job_title_short_id;

-- 3. Company dimension
SELECT '=== Loading Company Dim for COMPANY MART ===' AS info;

CREATE TABLE company_mart.dim_company (
    company_id      INTEGER PRIMARY KEY,
    company_name    VARCHAR
);

INSERT INTO company_mart.dim_company (
    company_id,
    company_name
)
SELECT
    company_id,
    name
FROM company_dim 
ORDER BY company_id;

-- 4. Location dimension
SELECT '=== Loading Location Dim for COMPANY MART ===' AS info;

CREATE TABLE company_mart.dim_location (
    location_id     INTEGER PRIMARY KEY,
    job_country     VARCHAR,
    job_location    VARCHAR
);

INSERT INTO company_mart.dim_location (
    location_id,
    job_country,
    job_location
)
WITH distinct_job_locations AS (
    SELECT DISTINCT
        job_country,
        job_location
    FROM job_postings_fact
    WHERE 
        job_country IS NOT NULL
        AND job_location IS NOT NULL
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY job_country, job_location
    ) AS location_id,
    job_country,
    job_location
FROM distinct_job_locations;

-- 4. Date/Month dimension
SELECT '=== Loading Date/Month Dim for COMPANY MART ===' AS info;

CREATE TABLE company_mart.dim_date_month (
    month_start_date    DATE PRIMARY KEY,
    year                INTEGER,
    month               INTEGER
);

INSERT INTO company_mart.dim_date_month (
    month_start_date,
    year,
    month
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT(YEAR FROM month_start_date) AS year,
    EXTRACT(MONTH FROM month_start_date) AS month
FROM job_postings_fact
ORDER BY month_start_date;


-- Step 3: Create bridge tables
-- 1. Job Title bridge
SELECT '=== Loading Job Title Bridge for COMPANY MART ===' AS info;

CREATE TABLE company_mart.bridge_job_title (
    job_title_short_id  INTEGER,
    job_title_id        INTEGER,
    PRIMARY KEY (job_title_short_id, job_title_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (job_title_id) REFERENCES company_mart.dim_job_title(job_title_id)
);

INSERT INTO company_mart.bridge_job_title (
    job_title_short_id,
    job_title_id
)
SELECT DISTINCT
    djs.job_title_short_id,
    djt.job_title_id
FROM job_postings_fact jpf
INNER JOIN company_mart.dim_job_title_short djs 
    ON jpf.job_title_short = djs.job_title_short
INNER JOIN company_mart.dim_job_title djt
    ON jpf.job_title = djt.job_title
WHERE jpf.job_title_short IS NOT NULL
    AND jpf.job_title IS NOT NULL;

/* ALTERNATIVE SOLUTION
===================================
WITH distinct_jobs AS (
    SELECT DISTINCT
        job_title_short,
        job_title
FROM job_postings_fact
WHERE 
    job_title_short IS NOT NULL
    AND job_title IS NOT NULL
)
SELECT
    DENSE_RANK() OVER (
        ORDER BY job_title_short
    ) AS job_title_short_id,
    ROW_NUMBER() OVER (
        ORDER BY job_title
    ) AS job_title_id
FROM distinct_jobs;
*/

-- 2. Company location bridge
SELECT '=== Loading Company Location Bridge for COMPANY MART ===' AS info;

CREATE TABLE company_mart.bridge_company_location (
    company_id  INTEGER,
    location_id INTEGER,
    PRIMARY KEY (company_id, location_id),
    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (location_id) REFERENCES company_mart.dim_location(location_id)
);

INSERT INTO company_mart.bridge_company_location (
    company_id,
    location_id
)
SELECT DISTINCT
    jpf.company_id,
    loc.location_id
FROM job_postings_fact jpf
INNER JOIN company_mart.dim_location loc 
    ON jpf.job_country = loc.job_country 
    AND jpf.job_location = loc.job_location
WHERE jpf.company_id IS NOT NULL;

/* ALTERNATIVE SOLUTION
===================================
WITH distinct_company_location AS (
    SELECT DISTINCT
        company_id,
        job_country,
        job_location
    FROM job_postings_fact
    WHERE 
        job_country IS NOT NULL
        AND job_location IS NOT NULL
    ORDER BY 
        job_country,
        job_location
)
SELECT
    company_id,
    DENSE_RANK() OVER (
        ORDER BY job_country, job_location
    ) AS location_id
FROM distinct_company_location;
*/

-- Step 4: Create fact table - fact_company_hiring_monthly
-- Grain: company_id + job_title_short_id + job_country + posted_month
SELECT '=== Loading Company Hiring Monthly FACT TABLE for COMPANY MART ===' AS info;

CREATE TABLE company_mart.fact_company_hiring_monthly (
    company_id              INTEGER,
    job_title_short_id      INTEGER,
    job_country             VARCHAR,
    month_start_date        DATE,
    postings_count          INTEGER,
    median_salary_year      DOUBLE,
    min_salary_year         DOUBLE,
    max_salary_year         DOUBLE,
    remote_share            DOUBLE,
    health_insurance_share  DOUBLE,
    no_degree_mention_share DOUBLE,
    PRIMARY KEY (company_id, job_title_short_id, job_country, month_start_date),
    FOREIGN KEY (company_id) REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (month_start_date) REFERENCES company_mart.dim_date_month(month_start_date)
);

INSERT INTO company_mart.fact_company_hiring_monthly (
    company_id,
    job_title_short_id,
    month_start_date,
    job_country,
    postings_count,
    median_salary_year,
    min_salary_year,
    max_salary_year,
    remote_share,
    health_insurance_share,
    no_degree_mention_share
)
WITH job_postings_prepared AS (
    SELECT
        -- PK/FK
        jpf.company_id,
        djts.job_title_short_id,
        DATE_TRUNC('month', jpf.job_posted_date)::DATE AS month_start_date,
        jpf.job_country,
        -- Regular fields
        jpf.salary_year_avg,
        -- Convert boolean flags to numeric values (1.0 or 0.0)
        CASE WHEN jpf.job_work_from_home = TRUE THEN 1.0 ELSE 0.0 END AS is_remote,
        CASE WHEN jpf.job_health_insurance = TRUE THEN 1.0 ELSE 0.0 END AS has_health_insurance,
        CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1.0 ELSE 0.0 END AS no_degree_required
    FROM 
        job_postings_fact AS jpf
    INNER JOIN 
        company_mart.dim_job_title_short AS djts
        ON jpf.job_title_short = djts.job_title_short
    WHERE
        jpf.company_id IS NOT NULL
        AND jpf.job_posted_date IS NOT NULL
        AND jpf.job_country IS NOT NULL
)
SELECT
    company_id,
    job_title_short_id,
    month_start_date,
    job_country,
    COUNT(*) AS postings_count,
    MEDIAN(salary_year_avg) AS median_salary_year,
    MIN(salary_year_avg) AS min_salary_year,
    MAX(salary_year_avg) AS max_salary_year,
    AVG(is_remote) AS remote_share,
    AVG(has_health_insurance) AS health_insurance_share,
    AVG(no_degree_required) AS no_degree_mention_share
FROM
    job_postings_prepared
GROUP BY
    company_id,
    job_title_short_id,
    job_country,
    month_start_date;


-- DATA VALIDATION
-- Verify mart was created
SELECT 'Company Dimension' AS table_name, COUNT(*) as record_count FROM company_mart.dim_company
UNION ALL
SELECT 'Job Title Short Dimension', COUNT(*) FROM company_mart.dim_job_title_short
UNION ALL
SELECT 'Job Title Dimension', COUNT(*) FROM company_mart.dim_job_title
UNION ALL
SELECT 'Location Dimension', COUNT(*) FROM company_mart.dim_location
UNION ALL
SELECT 'Date Month Dimension', COUNT(*) FROM company_mart.dim_date_month
UNION ALL
SELECT 'Company Location Bridge', COUNT(*) FROM company_mart.bridge_company_location
UNION ALL
SELECT 'Job Title Bridge', COUNT(*) FROM company_mart.bridge_job_title
UNION ALL
SELECT 'Company Hiring Fact', COUNT(*) FROM company_mart.fact_company_hiring_monthly;

-- Show sample data from each table
SELECT '=== Company Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_company LIMIT 5;

SELECT '=== Job Title Short Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_job_title_short LIMIT 10;

SELECT '=== Job Title Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_job_title LIMIT 10;

SELECT '=== Location Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_location LIMIT 10;

SELECT '=== Date Month Dimension Sample ===' AS info;
SELECT * FROM company_mart.dim_date_month ORDER BY month_start_date DESC LIMIT 10;

SELECT '=== Company Location Bridge Sample ===' AS info;
SELECT 
    bcl.company_id,
    dc.company_name,
    bcl.location_id,
    dl.job_country,
    dl.job_location
FROM company_mart.bridge_company_location bcl
JOIN company_mart.dim_company dc ON bcl.company_id = dc.company_id
JOIN company_mart.dim_location dl ON bcl.location_id = dl.location_id
LIMIT 10;

SELECT '=== Job Title Bridge Sample ===' AS info;
SELECT 
    bjt.job_title_short_id,
    djs.job_title_short,
    bjt.job_title_id,
    djt.job_title
FROM company_mart.bridge_job_title bjt
JOIN company_mart.dim_job_title_short djs ON bjt.job_title_short_id = djs.job_title_short_id
JOIN company_mart.dim_job_title djt ON bjt.job_title_id = djt.job_title_id
WHERE djs.job_title_short = 'Data Engineer'
LIMIT 10;

SELECT '=== Company Hiring Fact Sample ===' AS info;
SELECT 
    fchm.company_id,
    dc.company_name,
    djs.job_title_short,
    fchm.job_country,
    fchm.month_start_date,
    ddm.year,
    ddm.month,
    fchm.postings_count,
    fchm.median_salary_year
FROM company_mart.fact_company_hiring_monthly fchm
JOIN 
    company_mart.dim_company dc 
    ON fchm.company_id = dc.company_id
JOIN 
    company_mart.dim_job_title_short djs 
    ON fchm.job_title_short_id = djs.job_title_short_id
JOIN
    company_mart.dim_date_month ddm
    ON fchm.month_start_date = ddm.month_start_date
ORDER BY 
    fchm.postings_count DESC,
    fchm.median_salary_year DESC 
LIMIT 10;