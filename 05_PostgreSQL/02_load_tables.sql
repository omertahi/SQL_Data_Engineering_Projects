/*
    - Note: you need to have duckdb installed on your machine
    - In this file, we will leverage DuckDB engine to push .csv files stored on the cloud to our local PostgreSQL instance 
    - Since our .csv files are stored on the cloud, we can not directly read them into our local PostgreSQL instance
    - Alternatively, we can download all the .csv files on our local machine and COPY them into Postgres tables

    - All the SQL queries below will therefore be run in DuckDB engine via DuckDB CLI
    - To use DuckDB CLI, run "duckdb" command in the terminal (using Shift+Enter) 
    - The duckdb plugin called postgres allows your DuckDB engine to:
        - establish a connection/bridge to any existing PostgreSQL server
        - connect to, read from, and write to any existing PostgreSQL server
        - auto-detect and stream the .csv files directly into our respective Postgres tables
*/

-- Step 1: Install and load the DuckDB extension

duckdb
INSTALL postgres;
LOAD postgres;

-- Step 2: Connect to your local PostgreSQL database

/*
    - pg is just a temporary "alias" that we will define inside DuckDB when you we run the ATTACH command.
    - Therefore, writing pg.company_dim tells DuckDB to look inside your attached database (alias pg) 
        - Note: default schema is set to public, therefore we do not need to explicitly state pg.public.table_name 
*/
ATTACH 'dbname=sql_course user=postgres password=password host=localhost' AS pg (TYPE postgres);

-- Step 3: Stream/load data from the .csv files via URL into tables directly inside PostgreSQL

-- Load dimension tables first (no FK dependencies)
INSERT INTO pg.company_dim (
    company_id,
    name,
    link,
    link_google,
    thumbnail
)
SELECT 
    company_id,
    name,
    link,
    link_google,
    thumbnail
FROM read_csv('https://storage.googleapis.com/sql_de/company_dim.csv', 
    AUTO_DETECT=true,
    HEADER=true);

-- Load skills dimension table
INSERT INTO pg.skills_dim (
    skill_id,
    skills,
    type
)
SELECT 
    skill_id,
    skills,
    type
FROM read_csv('https://storage.googleapis.com/sql_de/skills_dim.csv', 
    AUTO_DETECT=true,
    HEADER=true)
WHERE skills IS NOT NULL;

-- Load fact table second (FK references company_dim - must load after dimensions)
INSERT INTO pg.job_postings_fact (
    job_id, company_id, job_title_short, job_title, job_location, 
    job_via, job_schedule_type, job_work_from_home, search_location,
    job_posted_date, job_no_degree_mention, job_health_insurance, 
    job_country, salary_rate, salary_year_avg, salary_hour_avg
)
SELECT 
    job_id, company_id, job_title_short, job_title, job_location, 
    job_via, job_schedule_type, job_work_from_home, search_location,
    job_posted_date, job_no_degree_mention, job_health_insurance, 
    job_country, salary_rate, salary_year_avg, salary_hour_avg
FROM read_csv('https://storage.googleapis.com/sql_de/job_postings_fact.csv', 
    AUTO_DETECT=true,
    HEADER=true);

-- Load bridge table last (FKs reference skills_dim and job_postings_fact)
INSERT INTO pg.skills_job_dim (
    skill_id,
    job_id
)
SELECT 
    skill_id,
    job_id
FROM read_csv('https://storage.googleapis.com/sql_de/skills_job_dim.csv', 
    AUTO_DETECT=true,
    HEADER=true);

/*
    - Congratulations, you have now initialized the entire data_jobs database just like you did in the following files:
        - ../2_DW_Mart_Build/01_create_tables_dw.sql
        - ../2_DW_Mart_Build/02_load_schema_dw.sql
    - You can proceed to run the same sql queries created in files 03-07 in the 2_DW_Mart_Build directory 
*/

-- Step 4: Mart - Create flat mart (denormalized table)
.read 03_create_flat_mart.sql

-- Step 5: Mart - Create skills demand mart
.read 04_create_skills_mart.sql

-- Step 6: Mart - Create priority mart
.read 05_create_priority_mart.sql

-- Step 7: Mart - Update priority mart
.read 06_update_priority_mart.sql

-- Step 8: Mart - Create company prospecting mart
.read 07_create_company_mart.sql