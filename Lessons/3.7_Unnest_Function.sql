-- Arrays - Final Example (1)
-- Build a flat skill table for co-workers to access job titles, salary info, and skills in one table

CREATE OR REPLACE TEMP TABLE job_skills_array AS 
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    LIST(sd.skills) AS skills_array
FROM
    job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
GROUP BY 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg;


-- View table
SELECT * FROM job_skills_array LIMIT 20;


-- Analyze the median salary per skill

WITH flat_skills AS (
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_array) AS skill
    FROM job_skills_array
)
SELECT
    skill,
    MEDIAN(salary_year_avg) AS median_salary
FROM flat_skills
GROUP BY skill
ORDER BY median_salary DESC;

-- Array of Structs - Final Example (2)
-- Build a flat skill & type table for co-workers to access job titles, salary info, skills, and type in one table

SELECT * FROM skills_dim LIMIT 20;

CREATE OR REPLACE TEMP TABLE job_skills_array_struct AS 
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    LIST(
        STRUCT_PACK(
            skill_type := sd.type,
		    skill_name := sd.skills
        )
    ) AS skills_type
FROM
    job_postings_fact AS jpf
LEFT JOIN skills_job_dim AS sjd
    ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
GROUP BY 
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg;


-- View table
SELECT * FROM job_skills_array_struct LIMIT 20;

-- Analyze the median salary per type of skill

WITH flat_skills AS (
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_type).skill_type AS skill_type,
        UNNEST(skills_type).skill_name AS skill_name,
    FROM job_skills_array_struct
)
SELECT
    skill_type,
    MEDIAN(salary_year_avg) AS median_salary
FROM flat_skills
GROUP BY skill_type
ORDER BY median_salary DESC;


