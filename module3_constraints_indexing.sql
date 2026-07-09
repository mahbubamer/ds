-- =============================================================================
-- MODULE 3: INTEGRITY CONSTRAINTS & INDEX OPTIMIZATION
-- =============================================================================

CREATE DATABASE IF NOT EXISTS LabConstraintsIndex;
USE LabConstraintsIndex;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;

-- =============================================================================
-- TASK 1: Evaluating Referential Action Behaviors (ON DELETE)
-- =============================================================================

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Orders table demonstrating advanced relational delete operational constraints
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_id INT,
    product_id INT,
    -- CASCADE: Deleting a user purges all associated child orders automatically
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    -- RESTRICT: Blocks deletion of a product if any historical order references it
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
);

-- [EXAM VERIFICATION SCRIPTS FOR REFERENTIAL RULES]
-- Test RESTRICT: Attempting to delete a parent record with existing child rows
-- DELETE FROM products WHERE id = 1; -> Will fail with Error Code #1451

-- Test CASCADE: Attempting to delete a parent record to test automatic cascade purges
-- DELETE FROM users WHERE id = 1; -> Succeeds and cleanly eliminates matching orders

-- =============================================================================
-- TASK 2: Custom Indexing & Performance Execution Optimization (EXPLAIN)
-- =============================================================================

DROP TABLE IF EXISTS inventory;
CREATE TABLE inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    product_name VARCHAR(150) NOT NULL,
    category_unindexed VARCHAR(100) NOT NULL,
    stock_count INT NOT NULL,
    -- Explicitly adding a secondary index to optimize product searches
    INDEX idx_product_name (product_name)
);

-- Performance Testing Diagnostic 1: Searching an Unindexed Field
-- Exam Expectation: Plan outputs 'type: ALL' (Full Table Scan) and scans all rows.
EXPLAIN SELECT * FROM inventory WHERE category_unindexed = 'Computers';

-- Performance Testing Diagnostic 2: Searching an Indexed Field
-- Exam Expectation: Plan outputs 'type: ref' (Index Lookup) and limits scanned rows to 1.
EXPLAIN SELECT * FROM inventory WHERE product_name = 'Apple MacBook Pro 16';

-- =============================================================================
-- TASK 3: Multi-Column Composite Index Optimization
-- =============================================================================

-- Establish a compound multi-parameter structural traversal path
ALTER TABLE inventory ADD INDEX idx_name_stock (product_name, stock_count);

-- Diagnose optimization execution efficiency
-- Why it works: Evaluates both filter rules concurrently during a single pass
EXPLAIN SELECT * FROM inventory WHERE product_name = 'Razer DeathAdder Gaming Mouse' AND stock_count > 0;
