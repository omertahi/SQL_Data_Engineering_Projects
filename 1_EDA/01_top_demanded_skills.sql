/*
Question: What are the most in-demand skills for data engineers in Pakistan?
- Identify the top 10 in-demand skills for data engineers
- Focus on job postings in Pakistan
- Why?
    - Retrieves the top 10 skills with the highest demand in Pakistan's job market,
     providing insights into the most valuable skills for data engineers seeking work in Pakistan
*/

PRAGMA show_tables;
DESCRIBE job_postings_fact;
DESCRIBE skills_job_dim;
DESCRIBE skills_dim;


SELECT
    sd.skills,
    COUNT(sd.*) AS count
FROM
    job_postings_fact AS jpf
INNER JOIN skills_job_dim as sjd
    ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim AS sd
    ON sjd.skill_id = sd.skill_id
WHERE 
    jpf.job_country = 'Pakistan'
    AND jpf.job_title_short = 'Data Engineer'
GROUP BY
    sd.skills
ORDER BY
    COUNT(sd.*) DESC
LIMIT 10;

/*
Here's the breakdown of the most demanded skills for data engineers:
SQL and Python are by far the most in-demand skills, with around 1,000 job postings each - nearly double the cloud skills.
Cloud platforms round out the top skills, with AWS leading at ~650 postings, followed by Azure at 570.
Apache Spark completes the top 5 with nearly 450 postings, highlighting the importance of big data processing skills.

Key takeaways:

- SQL and Python remain the foundational skills for data engineers
- Cloud platforms (AWS, Azure) are critical for modern data engineering
- Big data tools like Spark continue to be highly valued
- Data pipeline tools (Airflow) show growing demand
- Java, Kafka, Hadoop and Mongodb round out the top 10 most requested skills
┌─────────┬───────┐
│ skills  │ count │
│ varchar │ int64 │
├─────────┼───────┤
│ sql     │  1061 │
│ python  │   924 │
│ aws     │   657 │
│ azure   │   570 │
│ spark   │   451 │
│ airflow │   296 │
│ java    │   290 │
│ kafka   │   276 │
│ hadoop  │   271 │
│ mongodb │   252 │
└─────────┴───────┘


*/