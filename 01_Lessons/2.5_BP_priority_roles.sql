-- run "duckdb md:jobs_mart"

/*
==================
BATCH PROCESSING
==================

The MERGE command is part of the DDL_DML chapter, and falls specifically under DML.
It allows us to wrap up within one statement the ability to perform:
    - INSERT
    - UPDATE
    - DELETE

Before we move into the MERGE command, we will go through a brief refresher by building out our query using:
    - INSERT
    - UPDATE
    - DELETE
    - we will use this in combination with WHERE EXIST filtering to achieve the desired result

Then, we will build the same query using:
    - MERGE

What are we building?
    We will build the "job_postings_snapshot" table using the following tables:
        - job_postings_fact (Engineer-Owned)
        - company_dim       (Engineer-Owned)
        - priority_roles    (Business-Owned)

What are we trying to demonstrate?
    The Business-Owned "priority_roles" table is going to be updated by the business in various ways:
        - change priority level associated with role_name
        - add a new job/role
        - it can be update as frequently as daily
    Therefore, updates will effect our downstream table "job_postings_snapshot"

What is the data pipeline for such tables that can get changed or updated
    1. Create a script called inital_load.sql
        - initialize the "job_postings_snapshot" table
        - load data into the table
        - it will only be run ONCE
        - refer to "2.5_BP_initial_load.sql" file
    2. Create the sript for "priority_roles" table (in the current file)
        - initialize the "priority_roles" table
        - add data into the table
        - manipulate the table and run this script .read 2.4_BP_priority_role.sql
    3. Create version 1 of batch processing using INSERT/UPDATE/DELETE statements
        - create batch_processing_v1.sql script
        - use UPDATE, INSERT, DELETE statements to maintain the "job_postings_snapshot" table
        - manipulate "priority_roles" table and perform this batch load to see if "job_postings_snapshot" table is updated
    4. Create version 2 of batch batch processing using MERGE statement
        - create batch_processing_v2.sql script
        - use MERGE statement to maintain "job_postings_snapshot" table
        - manipulate "priority_roles" table and perform this batch load to see if "job_postings_snapshot" table is updated

*/


-- Initalize "priority_roles" (Business-Owned) table
CREATE OR REPLACE TABLE staging.priority_roles (
    role_id     INTEGER PRIMARY KEY,
    role_name   VARCHAR,
    priority_lvl INTEGER
);

-- Create and insert data into "priority_roles" table
INSERT INTO staging.priority_roles (role_id, role_name, priority_lvl)
VALUES 
    (1, 'Data Engineer', 1),
    (2, 'Senior Data Engineer', 1),
    (3, 'Software Engineer', 3),
    (4, 'Data Scientist', 4);

-- Show priority_roles table
SELECT *
FROM staging.priority_roles;


-- .read Lessons/2.4_BP_priority_roles.sql

