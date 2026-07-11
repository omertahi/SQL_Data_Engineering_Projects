-- run "duckdb md:data_jobs" in terminal

/*
- information_schema allows you to inspect all of the metadata contained inside the database
    - contains a collection of read-only Views that expose the metadata about the database
    - portable across database systems
    - https://duckdb.org/docs/current/sql/meta/information_schema
    - it is standardized across other databases therefore it can be applied to other databases
    - other databases implement this View or catalogue of metadata that you can query
    - since it is a collection of Views, we have to use the "dot" notation to access different things
    - check out information_schema .notation documentation for
        - tables
        - columns
        - table_constraints 
        - key_column_usage
    - PRAGMA (SQLite only) (easier way to inspect metadata)
    - DESCRIBE (DuckDB only) (great way to quickly describe tables)
*/

-- Tables
SELECT 
    *
FROM 
    information_schema.tables
WHERE
    table_catalog = 'data_jobs';

-- Columns
SELECT
    *
FROM
    information_schema.columns
WHERE 
    table_catalog = 'data_jobs';

-- Table constraints
SELECT
    *
FROM
    information_schema.table_constraints
WHERE
    table_catalog = 'data_jobs';

-- Key column usage
SELECT
    *
FROM
    information_schema.key_column_usage
WHERE
    table_catalog = 'data_jobs';

-- Show table names contained within database
PRAGMA show_tables;

-- Show table names and column names associated with each table w/ column types
PRAGMA show_tables_expanded;

-- Show column names and column types of a single table
DESCRIBE job_postings_fact;
