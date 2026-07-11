-- run "duckdb md:data_jobs" in terminal

/*
- Find the top 10 companies for posting jobs
- They must have >3000 postings
- Limit only to US jobs
*/

PRAGMA show_tables;
DESCRIBE company_dim;
DESCRIBE job_postings_fact;

/*
Note:
- you can't have column name alias in CLAUSES
- but you can have table name alias in CLAUSES
- this is due to order of execution
*/

--EXPLAIN ANALYZE
SELECT 
    cd.name AS company_name,
    COUNT(jpf.job_id) AS total_jobs,
FROM
    job_postings_fact AS jpf
LEFT JOIN
    company_dim AS cd
    ON jpf.company_id = cd.company_id
WHERE
    jpf.job_country = 'United States' 
GROUP BY 
    cd.name
HAVING 
    COUNT(jpf.job_id) > 3000
ORDER BY
    COUNT(jpf.job_id) DESC
LIMIT 10;

 