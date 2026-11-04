-- SQL practice dataset for Q1-Q6
-- Dialect: DuckDB
-- Run this script in a scratch DuckDB database.

DROP TABLE IF EXISTS staging_customers;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS patient_records;
DROP TABLE IF EXISTS transactions;
-- Leetcode practice tables
DROP TABLE IF EXISTS Person;
DROP TABLE IF EXISTS Address;
DROP TABLE IF EXISTS Department;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Scores;
DROP TABLE IF EXISTS Logs;
DROP TABLE IF EXISTS Weather;


CREATE TABLE transactions (
    transaction_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    transaction_date DATE NOT NULL
);

INSERT INTO transactions (transaction_id, customer_id, amount, transaction_date) VALUES
-- 2024 transactions
(1001, 101, 120.00, DATE '2024-01-05'),
(1002, 101, 300.00, DATE '2024-01-18'),
(1003, 101,  75.00, DATE '2024-01-29'),
(1004, 101, 220.00, DATE '2024-02-03'),
(1005, 101, 180.00, DATE '2024-02-14'),
(1006, 101, 220.00, DATE '2024-02-27'),
(1007, 102, 500.00, DATE '2024-01-07'),
(1008, 102,  90.00, DATE '2024-01-21'),
(1009, 102, 160.00, DATE '2024-03-02'),
(1010, 102, 240.00, DATE '2024-03-12'),
(1011, 102, 110.00, DATE '2024-03-20'),
(1012, 102,  80.00, DATE '2024-03-28'),
(1013, 103, 250.00, DATE '2024-01-11'),
(1014, 103, 250.00, DATE '2024-01-22'),
(1015, 103, 250.00, DATE '2024-02-09'),
(1016, 103, 100.00, DATE '2024-04-15'),
(1017, 104, 800.00, DATE '2024-02-01'),
(1018, 104,  50.00, DATE '2024-02-06'),
(1019, 104, 400.00, DATE '2024-02-10'),
(1020, 104, 100.00, DATE '2024-02-24'),
(1021, 105, 700.00, DATE '2024-03-05'),
(1022, 105, 650.00, DATE '2024-03-09'),
(1023, 105,  25.00, DATE '2024-04-01'),
(1024, 106, 350.00, DATE '2024-04-03'),
(1025, 106, 350.00, DATE '2024-04-17'),
(1026, 106, 350.00, DATE '2024-04-25'),
(1027, 107, 100.00, DATE '2024-05-01'),
(1028, 107, 200.00, DATE '2024-05-11'),
(1029, 107, 300.00, DATE '2024-05-21'),
-- Transactions outside 2024 to test date filtering and LAG ordering
(1030, 101,  60.00, DATE '2023-12-20'),
(1031, 101, 260.00, DATE '2025-01-08'),
(1032, 102, 180.00, DATE '2025-03-03'),
(1033, 103, 400.00, DATE '2025-01-14'),
(1034, 104, 125.00, DATE '2023-02-02');

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name VARCHAR NOT NULL,
    email VARCHAR NOT NULL
);

INSERT INTO customers (customer_id, name, email) VALUES
(101, 'Ayesha Khan', 'ayesha.old@example.com'),
(102, 'Bilal Ahmed', 'bilal@example.com'),
(103, 'Sara Malik', 'sara.old@example.com'),
(104, 'Hamza Ali', 'hamza@example.com'),
(105, 'Noor Siddiqui', 'noor@example.com');

CREATE TABLE staging_customers (
    customer_id INTEGER NOT NULL,
    name VARCHAR NOT NULL,
    email VARCHAR NOT NULL
);

INSERT INTO staging_customers (customer_id, name, email) VALUES
-- Existing customers with updated details
(101, 'Ayesha Khan', 'ayesha.khan@example.com'),
(103, 'Sara Malik', 'sara.malik@example.com'),
-- New customers
(108, 'Zain Raza', 'zain@example.com'),
(109, 'Mariam Shah', 'mariam@example.com');

CREATE TABLE patient_records (
    record_id INTEGER PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    admission_date DATE NOT NULL,
    ward VARCHAR
);

INSERT INTO patient_records (record_id, patient_id, admission_date, ward) VALUES
(1, 201, DATE '2024-01-03', 'A'),
(2, 202, DATE '2024-01-04', 'B'),
(3, 203, DATE '2024-01-05', 'A'),
(4, 201, DATE '2024-01-03', 'A'), -- duplicate patient_id + admission_date
(5, 204, DATE '2024-02-10', 'C'),
(6, 202, DATE '2024-01-04', 'B'), -- duplicate patient_id + admission_date
(7, 205, DATE '2024-03-15', 'A'),
(8, 201, DATE '2024-04-01', 'B'); -- same patient, different admission date

-- LeetCode 175: Combine Two Tables
CREATE TABLE Person (
    personId INTEGER,
    lastName VARCHAR,
    firstName VARCHAR
);

CREATE TABLE Address (
    addressId INTEGER,
    personId INTEGER,
    city VARCHAR,
    state VARCHAR
);

INSERT INTO Person VALUES
    (1, 'Wang', 'Allen'),
    (2, 'Alice', 'Bob'),
    (3, 'Patel', 'Maya'),
    (4, 'Jones', 'Sam');

INSERT INTO Address VALUES
    (1, 2, 'New York City', 'New York'),
    (2, 3, 'Austin', 'Texas'),
    (3, 99, 'Nowhere', 'Unknown');


-- LeetCode 176, 184: Second Highest Salary / Department Highest Salary
CREATE TABLE Department (
    id INTEGER,
    name VARCHAR
);

CREATE TABLE Employee (
    id INTEGER,
    name VARCHAR,
    salary INTEGER,
    departmentId INTEGER
);

INSERT INTO Department VALUES
    (1, 'Engineering'),
    (2, 'Sales'),
    (3, 'Support');

INSERT INTO Employee VALUES
    (1, 'Alice', 90000, 1),
    (2, 'Bob',   80000, 1),
    (3, 'Carol', 90000, 1), -- tied department high
    (4, 'Dan',   70000, 2),
    (5, 'Eve',   60000, 2),
    (6, 'Finn',  60000, 2), -- tied salary, tests DISTINCT
    (7, 'Gail',  50000, 2),
    (8, 'Hugo',  40000, NULL); -- no matching department


-- LeetCode 178: Rank Scores
CREATE TABLE Scores (
    id INTEGER,
    score DECIMAL(4, 2)
);

INSERT INTO Scores VALUES
    (1, 3.50),
    (2, 3.65),
    (3, 4.00),
    (4, 3.85),
    (5, 4.00),
    (6, 3.65);


-- LeetCode 180: Consecutive Numbers
CREATE TABLE Logs (
    id INTEGER,
    num INTEGER
);

INSERT INTO Logs VALUES
    (1, 1),
    (2, 1),
    (3, 1), -- three consecutive 1s
    (4, 2),
    (5, 1),
    (6, 1),
    (7, 2),
    (8, 2),
    (9, 2), -- three consecutive 2s
    (10, 2); -- four consecutive 2s


-- LeetCode 197: Rising Temperature
CREATE TABLE Weather (
    id INTEGER,
    recordDate DATE,
    temperature INTEGER
);

INSERT INTO Weather VALUES
    (1, DATE '2024-01-01', 10),
    (2, DATE '2024-01-02', 12), -- warmer than previous day
    (3, DATE '2024-01-03', 11), -- cooler
    (4, DATE '2024-01-05', 14), -- date gap: not compared as yesterday
    (5, DATE '2024-01-06', 15), -- warmer than previous day
    (6, DATE '2024-01-07', 15), -- same temperature
    (7, DATE '2024-01-08', 16); -- warmer than previous day
