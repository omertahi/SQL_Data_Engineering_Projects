-- run "duckdb md:data_jobs" in terminal

/*
- As a Data Engineer you are responsible for creating scripts that are idempotent.
- Idempotent: build script in a way where re-running it would not throw any errors
    - IF NOT EXISTS helps you to achieve this
- To check for indempotency, run the following in your terminal:
    - .read relative_path/file_name
    - .read Lessons/1.7_DDL_DML_Part1.sql
*/

-- specify database you want to use to avoid specifying each time
USE data_jobs;

/*

-- create a database
CREATE DATABASE jobs_mart;

-- delete database (DO NOT RUN)
DROP DATABASE jobs_mart;

*/

-- for automation
DROP DATABASE IF EXISTS jobs_mart;

-- when automating scripts to create database you want to prevent throwing an already-exists-error that stops executions
CREATE DATABASE IF NOT EXISTS jobs_mart;

USE jobs_mart;

-- show databases
SHOW DATABASES;

-- check schemas inside of database (Note: main schema is created by default in a new database)
SELECT *
FROM information_schema.schemata
WHERE catalog_name = 'jobs_mart';

-- delete schema
DROP SCHEMA IF EXISTS staging;

-- create schema (Note: the argument would be jobs_mart.staging if we did not specify USE jobs_mart)
CREATE SCHEMA IF NOT EXISTS staging;

-- create table (default: main schema)
CREATE TABLE IF NOT EXISTS preferred_roles (
	role_id INTEGER PRIMARY KEY,
	role_name VARCHAR
);

-- check to see under which schemas each table is located
SELECT *
FROM information_schema.tables
WHERE table_catalog = 'jobs_mart';

-- delete table from schema (default: main schema)
DROP TABLE IF EXISTS main.preferred_roles;

-- create table inside custom schema
CREATE TABLE IF NOT EXISTS staging.preferred_roles (
	role_id INTEGER PRIMARY KEY,
	role_name VARCHAR
);

-- insert rows/values into preferred_roles table
INSERT INTO staging.preferred_roles (role_id, role_name)
VALUES 
    (1, 'Data Engineer'),
    (2, 'Senior Data Engineer'),
    (3, 'Software Engineer');

-- view preferred_roles table
SELECT *
FROM staging.preferred_roles;

-- add column called preferred_role that only notes data engineer roles as true
ALTER TABLE staging.preferred_roles
ADD COLUMN preferred_role BOOLEAN;

-- update rows
UPDATE staging.preferred_roles
SET preferred_role = TRUE
WHERE 
    role_id IN (1, 2);

-- update rows
UPDATE staging.preferred_roles
SET preferred_role = FALSE
WHERE 
    role_id = 3;

-- rename table name
ALTER TABLE staging.preferred_roles
RENAME TO priority_roles;

-- view priority_roles table
SELECT *
FROM staging.priority_roles;

-- rename column name
ALTER TABLE staging.priority_roles
RENAME COLUMN preferred_role TO priority_lvl;

-- alter column [column type]
ALTER TABLE staging.priority_roles
ALTER COLUMN priority_lvl TYPE INTEGER;

-- update row
UPDATE staging.priority_roles
SET priority_lvl = 3
WHERE role_id = 3;

-- view priority_roles table
SELECT *
FROM staging.priority_roles;