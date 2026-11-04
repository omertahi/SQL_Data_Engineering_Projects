-- Step 4: Mart - Create skills demand mart (dimensional mart)
-- Run this after Step 3
-- This mart focuses on skills demand over time with clean additive measures

-- Drop existing mart schema if it exists (for idempotency)
DROP SCHEMA IF EXISTS skills_mart CASCADE;

-- Step 1: Create the mart schema
CREATE SCHEMA skills_mart;

-- Step 2: Create dimension tables
-- 1. Skills dimension
SELECT '=== Loading Skills Dim for Skills Mart ===' AS info;

CREATE TABLE skills_mart.dim_skill (
    skill_id INTEGER PRIMARY KEY,
    skills VARCHAR,
    type VARCHAR
);

INSERT INTO skills_mart.dim_skill (
    skill_id,
    skills,
    type
)
SELECT
    skill_id,
    skills,
    type
FROM main.skills_dim;

-- 2. Month-level date dimension (enhanced with quarter and other attributes)
SELECT '=== Loading Date Dim for Skills Mart ===' AS info;

CREATE TABLE skills_mart.dim_date_month (
    month_start_date DATE PRIMARY KEY,
    year INTEGER,
    month INTEGER,
    quarter INTEGER,
    quarter_name VARCHAR,
    year_quarter VARCHAR
);

INSERT INTO skills_mart.dim_date_month (
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    year_quarter
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(QUARTER FROM job_posted_date) AS quarter,
    -- Quarter name
    'Q-' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS quarter_name,
    -- Year-Quarter combination for easy filtering
    EXTRACT(YEAR FROM job_posted_date)::VARCHAR || '-Q' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS year_quarter
FROM main.job_postings_fact
ORDER BY month_start_date;

-- Step 3: Create fact table - fact_skill_demand_monthly
-- Grain: skill_id + month_start_date + job_title_short
-- All measures are additive (counts and sums) - safe to re-aggregate
SELECT '=== Loading Skills Fact for Skills Mart ===' AS info;

CREATE TABLE skills_mart.fact_skill_demand_monthly (
    -- PK/FK fields
    skill_id INTEGER,
    month_start_date DATE,
    job_title_short VARCHAR,
    -- regular fields
    postings_count INTEGER,
    remote_postings_count INTEGER,
    health_insurance_postings_count INTEGER,
    no_degree_mention_postings_count INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skills_mart.dim_skill(skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skills_mart.dim_date_month(month_start_date)
);

INSERT INTO skills_mart.fact_skill_demand_monthly (
    -- PK/FK fields
    skill_id,
    month_start_date,
    job_title_short,
    -- regular fields
    postings_count,
    remote_postings_count,
    health_insurance_postings_count,
    no_degree_mention_postings_count
)
WITH job_postings_prep AS (
    SELECT
        -- PK/FK fields
        sjd.skill_id,
        DATE_TRUNC('month', jpf.job_posted_date) AS month_start_date,
        jpf.job_title_short,
        -- regular fields
        CASE WHEN jpf.job_work_from_home = TRUE THEN 1 ELSE 0 END AS is_remote,
        CASE WHEN jpf.job_health_insurance = TRUE THEN 1 ELSE 0 END AS has_health_insurance,
        CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_mentioned 
    FROM 
        job_postings_fact AS jpf
    INNER JOIN
        skills_job_dim AS sjd
        ON jpf.job_id = sjd.job_id
)
SELECT
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(*) AS postings_count,
    SUM(is_remote) AS remote_postings_count,
    SUM(has_health_insurance) AS health_insurance_postings_count,
    SUM(no_degree_mentioned) AS no_degree_mention_postings_count
FROM 
    job_postings_prep
GROUP BY 
    skill_id,
    month_start_date,
    job_title_short
ORDER BY 
    skill_id,
    month_start_date,
    job_title_short;

-- Verify mart was created
SELECT
    'Skill Dimension' AS table_name,
    COUNT(*) AS record_count
FROM skills_mart.dim_skill
UNION ALL
SELECT 
    'Date Month Dimension',
    COUNT(*)
FROM skills_mart.dim_date_month
UNION ALL
SELECT 
    'Skill Demand Fact',
    COUNT(*)
FROM skills_mart.fact_skill_demand_monthly;

-- Show sample data from each table
SELECT '=== Skill Dimension Sample ===' AS info;
SELECT * FROM skills_mart.dim_skill LIMIT 5;

SELECT '=== Date Month Dimension Sample ===' AS info;
SELECT * FROM skills_mart.dim_date_month LIMIT 5;

SELECT '=== Skill Demand Fact Sample ===' AS info;
SELECT * FROM skills_mart.fact_skill_demand_monthly LIMIT 5;
