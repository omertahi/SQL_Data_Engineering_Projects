/*
    - Install VS Code extensions "SQLTools" and "SQLTool PostgreSQL Driver" 
    - Download and install pgAdmin via PostgreSQL installer
    - Open pgAdmin
    - Initialize "postgres" database if not created
        - username: postgres
        - password: password
    - Make sure "postgres" database is active
    - From VS Code, establish connection to PostgreSQL database called "postgres"
        - connection_name: postgres
        - username: postgres
        - password: password
    - To run any SQL queries in PostgreSQL via PostgreSQL connection, highlight query and press ⌘E + ⌘E
        - you will see result in SQLTool window in the right panel
*/

-- Create a database called sql_course in PostgreSQL
CREATE DATABASE IF NOT EXISTS sql_course;

/*
    - From VSCode, establish a new connection to the newly created PostgreSQL database called "sql_course"
        - connection_name: sql_course
        - username: postgres
        - password: password
    - Note: public schema is the default schema created with a new PostgreSQL database 
*/

-- Drop existing tables if they exist (for idempotency)
DROP TABLE IF EXISTS skills_job_dim;
DROP TABLE IF EXISTS job_postings_fact;
DROP TABLE IF EXISTS skills_dim;
DROP TABLE IF EXISTS company_dim;

-- Create company_dim table
CREATE TABLE public.company_dim (
    company_id INTEGER PRIMARY KEY,
    name VARCHAR,
    link VARCHAR,
    link_google VARCHAR,
    thumbnail VARCHAR
);

-- Create skills_dim table
CREATE TABLE public.skills_dim (
    skill_id INTEGER PRIMARY KEY,
    skills VARCHAR,
    type VARCHAR
);

-- Create job_postings_fact table (must be created before skills_job_dim)
CREATE TABLE public.job_postings_fact (
    job_id INTEGER PRIMARY KEY,
    company_id INTEGER,
    job_title_short VARCHAR,
    job_title VARCHAR,
    job_location VARCHAR,
    job_via VARCHAR,
    job_schedule_type VARCHAR,
    job_work_from_home BOOLEAN,
    search_location VARCHAR,
    job_posted_date TIMESTAMP,
    job_no_degree_mention BOOLEAN,
    job_health_insurance BOOLEAN,
    job_country VARCHAR,
    salary_rate VARCHAR,
    salary_year_avg NUMERIC,
    salary_hour_avg NUMERIC,
    FOREIGN KEY (company_id) REFERENCES company_dim(company_id)
);

-- Create skills_job_dim bridge table (after job_postings_fact exists)
CREATE TABLE public.skills_job_dim (
    skill_id INTEGER,
    job_id INTEGER,
    PRIMARY KEY (skill_id, job_id),
    FOREIGN KEY (skill_id) REFERENCES skills_dim(skill_id),
    FOREIGN KEY (job_id) REFERENCES job_postings_fact(job_id)
);

-- Set ownership of the tables to the postgres user
ALTER TABLE public.company_dim OWNER to postgres;
ALTER TABLE public.skills_dim OWNER to postgres;
ALTER TABLE public.job_postings_fact OWNER to postgres;
ALTER TABLE public.skills_job_dim OWNER to postgres;

-- Create indexes on foreign key columns for better performance
-- PostgreSQL can be tuned for analytical performance using indexing
CREATE INDEX idx_company_id ON public. job_postings_fact (company_id);
CREATE INDEX idx_skill_id ON public.skills_job_dim (skill_id);
CREATE INDEX idx_job_id ON public.skills_job_dim (job_id); 

