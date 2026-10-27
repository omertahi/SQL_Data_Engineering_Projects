-- run "duckdb md:data_jobs" in terminal

PRAGMA show_tables;
DESCRIBE job_postings_fact;
DESCRIBE company_dim;

/*
- LEFT JOIN:        All rows from the main table plus matches from the joining table
- INNER JOIN:       Only returns rows where there are matches in both tables
- FULL OUTER JOIN:  Checking for data completeness or orphan data
*/

-- LEFT JOIN example
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.company_id,
    cd.name AS company_name,
    jpf.job_location
FROM
    job_postings_fact AS jpf
LEFT JOIN company_dim AS cd
    ON jpf.company_id = cd.company_id
LIMIT 10;


DESCRIBE skills_job_dim;
DESCRIBE skills_dim;

-- JOIN three tables
SELECT
    jpf.job_id,
    jpf.job_title_short,
    sjd.skill_id,
    sd.skills AS skill_name
FROM
    job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id;


-- INNER JOIN on same example
SELECT
    jpf.job_id,
    jpf.job_title_short,
    sjd.skill_id,
    sd.skills AS skill_name
FROM
    job_postings_fact AS jpf
INNER JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id;