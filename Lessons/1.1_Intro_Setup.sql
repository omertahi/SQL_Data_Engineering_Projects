-- run "duckdb md:data_jobs" in terminal

-- add data_jobs shared database to duckdb
ATTACH 'md:_share/data_jobs/87603155-cdc7-4c80-85ad-3a6b0d760d93';

-- view all tables in data_jobs
from data_jobs.main.job_postings_fact
select
	job_id,
	company_id,
	job_title_short,
	job_title,
	job_location,
	job_via,
	job_schedule_type,
	job_work_from_home,
	search_location,
	job_posted_date,
	job_no_degree_mention,
	job_health_insurance,
	job_country,
	salary_rate,
	salary_year_avg,
	salary_hour_avg
limit 100