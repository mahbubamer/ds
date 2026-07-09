-- =============================================================================
-- MODULE 1: DBMS TRANSACTIONS & TRANSACTION CONTROL LANGUAGE (TCL)
-- ENGINE REQUIREMENT: InnoDB (Transactions are ignored on MyISAM)
-- =============================================================================

-- STEP 1: Environment Setup & Session Configuration
-- By default, MySQL automatically saves every state alteration instantly.
-- To execute and test multi-step transaction controls, autocommit must be disabled.
SET autocommit = 0;

-- STEP 2: Database and Table Initialization
CREATE DATABASE IF NOT EXISTS LabTransactions;
USE LabTransactions;

DROP TABLE IF EXISTS Accounts;
CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    name VARCHAR(50),
    balance DECIMAL(10,2)
) ENGINE=InnoDB;

-- STEP 3: Seed Base Testing Records
INSERT INTO Accounts VALUES (1, 'Alice', 1000.00);
INSERT INTO Accounts VALUES (2, 'Bob', 500.00);

-- =============================================================================
-- EXERCISE 1: Successful Transaction Lifecycle (COMMIT)
-- Scenario: Safe, error-free transfer of $200.00 from Alice to Bob.
-- Both steps must succeed for changes to be written to non-volatile storage.
-- =============================================================================
START TRANSACTION;

-- 1. Deduct funds from Alice's account balance
UPDATE Accounts 
SET balance = balance - 200.00 
WHERE account_id = 1;

-- 2. Add matching funds to Bob's account balance
UPDATE Accounts 
SET balance = balance + 200.00 
WHERE account_id = 2;

-- 3. Finalize and permanently save the state alterations
COMMIT;

-- Verification Query (Expected Result: Alice = 800.00, Bob = 700.00)
SELECT * FROM Accounts;

-- =============================================================================
-- EXERCISE 2: Failed Transaction State Recovery (ROLLBACK)
-- Scenario: Simulated processing error midway through a $300.00 transfer.
-- The database must erase uncommitted modifications and revert to its pre-transaction boundary.
-- =============================================================================
START TRANSACTION;

-- 1. Deduct partial funds from Alice
UPDATE Accounts 
SET balance = balance - 300.00 
WHERE account_id = 1;

-- [SIMULATED PROCESSING ERROR OR SYSTEM CRASH OCCURS HERE]
-- The uncommitted changes are discarded, protecting the system from data corruption.
ROLLBACK;

-- Verification Query (Expected Result: Alice remains at 800.00, Bob remains at 700.00)
SELECT * FROM Accounts;

-- =============================================================================
-- EXERCISE 3: Partial Rollbacks & Landmarks (SAVEPOINT)
-- Scenario: Apply a valid $100.00 bonus to Alice, but selectively roll back
-- an accidental $500.00 mistake credited to Bob within the same block.
-- =============================================================================
START TRANSACTION;

-- 1. Apply valid corporate bonus reward to Alice
UPDATE Accounts 
SET balance = balance + 100.00 
WHERE account_id = 1;

-- 2. Establish a landmark checkpoint boundary
SAVEPOINT BonusAdded;

-- 3. Apply an accidental, mistaken corporate bonus to Bob
UPDATE Accounts 
SET balance = balance + 500.00 
WHERE account_id = 2;

-- 4. Purge ONLY the processing mistake targeting Bob's account
ROLLBACK TO SAVEPOINT BonusAdded;

-- 5. Commit remaining valid changes to the database engine
COMMIT;

-- Verification Query (Expected Result: Alice = 900.00, Bob = 700.00)
SELECT * FROM Accounts;
