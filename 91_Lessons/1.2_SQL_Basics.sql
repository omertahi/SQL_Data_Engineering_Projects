-- run "duckdb md:data_jobs" in terminal

/*
- Get job details for BOTH 'Data Engineert or Data Analyst positions
    - For Data Engineer, I want jobs only $75K - $100k
    - For Data Analyst, I only want jobs $100K - $125K
        - Sidenote, I want a higher salary for this role because I have DE skills
- Only include jobs located in EITHER:
    - Bentonville, AR
    - San Diego, CA (if I have to move I'm going to a cicy I love)
    - Remote Jobs
*/

SELECT 
  job_id,
  job_title_short,
  job_location,
  job_via,
  salary_year_avg
FROM 
  job_postings_fact
WHERE
  (
    (job_title_short = 'Data Engineer' AND salary_year_avg BETWEEN 75_000 AND 100_000)
    OR
    (job_title_short = 'Data Analyst' AND salary_year_avg BETWEEN 100_000 AND 125_000)
  )
  AND
  (
    (job_location IN ('Bentonville, AR', 'San Diego, CA'))
    OR
    (job_work_from_home = TRUE)
  )
ORDER BY
  salary_year_avg DESC;



  /*
- Look for non-senior data engineer and non-senior software engineer roles
    - Only get job titles that include either 'Data' or 'Software'
    - Also include those with 'Engineer' in any part of the title
    - Don't include any job titles with 'Senior' or 'Sr' followed by any character
- Get the job_id, job title, location, and job platform
    - rename the columns appropriately
*/

SELECT 
  job_id AS id,
  job_title,
  job_location AS location,
  job_via AS paltform
FROM 
  job_postings_fact
WHERE
  job_title LIKE '%Engineer%'
  AND (job_title LIKE '%Data%' OR job_title LIKE '%Software%')
  AND NOT (job_title LIKE '%Senior%' OR job_title LIKE 'Sr%');


