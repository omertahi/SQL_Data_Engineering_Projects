/*

Objective: 
Whenever "priority_roles" table is manipulated, executing this batch load script should reflect latest changes
in the target table, where the target table is the "priority_jobs_snapshot" table in initial_load.sql

Batch load query info:
    - target table = priority_jobs_snapshot
    - source table = TEMPORARY TABLE src_priority_jobs
        - created using query of our target table
    - reference source table into UPDATE, INSERT, DELETE statements to maintain the target table


Check if batch load query works:
    1. manipulate "priority_roles" table
        - save changes
        - run ".read Lessons/2.4_BP_priority_roles.sql"
    2. perform batch load v1
        - run ".read Lessons/2.6_BP_batch_load_v1.sql"
        - the last query in the script displays the target table
        - "job_postings_snapshot" (target table) should reflect the changes
        
*/

-- Create TEMP TABLE
CREATE OR REPLACE TEMPORARY TABLE src_priority_jobs AS 
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    r.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM data_jobs.job_postings_fact AS jpf
LEFT JOIN data_jobs.company_dim AS cd
    ON jpf.company_id = cd.company_id
INNER JOIN staging.priority_roles AS r
    ON jpf.job_title_short = r.role_name;


-- UPDATE statement
UPDATE main.priority_jobs_snapshot AS tgt
SET
    priority_lvl = src.priority_lvl,
    updated_at = src.updated_at
FROM src_priority_jobs AS src
WHERE tgt.job_id = src.job_id
    AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl;


-- INSERT statment
INSERT INTO main.priority_jobs_snapshot AS tgt (
	SELECT
--        src.*
        src.job_id,
        src.job_title_short,
        src.company_name,
        src.job_posted_date,
        src.salary_year_avg,
        src.priority_lvl,
        src.updated_at
	FROM src_priority_jobs AS src
	WHERE NOT EXISTS (
        SELECT 1
        FROM main.priority_jobs_snapshot AS tgt
        WHERE src.job_id = tgt.job_id
    )
);


-- DELETE statement
DELETE FROM main.priority_jobs_snapshot AS tgt
WHERE NOT EXISTS (
    SELECT 1
    FROM src_priority_jobs AS src
    WHERE src.job_id = tgt.job_id
);



-- View summary of "priority_jobs_snapshot" table
SELECT
    job_title_short,
    COUNT(*) AS job_count,
    MIN(priority_lvl) AS priority_lvl,
    MIN(updated_at) AS updated_at
FROM priority_jobs_snapshot
GROUP BY job_title_short
ORDER BY job_count DESC;



-- .read Lessons/2.4_BP_priority_roles.sql
-- .read Lessons/2.6_BP_batch_load_v1.sql