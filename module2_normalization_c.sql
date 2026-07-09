-- =============================================================================
-- MODULE 2: RELATIONAL DATABASE NORMALIZATION (1NF -> 2NF -> 3NF)
-- Blueprint for constructing a fully normalized, redundancy-free database schema.
-- =============================================================================

CREATE DATABASE IF NOT EXISTS LabNormalization;
USE LabNormalization;

-- Drop dependent tables first to handle foreign key dependencies gracefully
DROP TABLE IF EXISTS Enrollments;
DROP TABLE IF EXISTS Courses;
DROP TABLE IF EXISTS Instructors;
DROP TABLE IF EXISTS Students;

-- 1. Students Table (Primary Entity)
-- Satisfies 1NF: Contains atomic attributes tracking individual student identities.
CREATE TABLE Students (
    StudentID INT PRIMARY KEY,
    StudentName VARCHAR(100) NOT NULL
);

-- 2. Instructors Table (Lookup Entity)
-- Resolves 3NF Transitive Dependencies: Extracts Department mapping away from
-- the Courses table, ensuring non-key attributes rely exclusively on the Primary Key.
CREATE TABLE Instructors (
    Instructor VARCHAR(100) PRIMARY KEY,
    Department VARCHAR(100) NOT NULL
);

-- 3. Courses Table (Dependent Entity)
-- Links to Instructors via a Foreign Key reference to guarantee referential integrity.
CREATE TABLE Courses (
    CourseName VARCHAR(100) PRIMARY KEY,
    Instructor VARCHAR(100),
    FOREIGN KEY (Instructor) REFERENCES Instructors(Instructor)
);

-- 4. Enrollments Table (Composite Associative/Junction Entity)
-- Resolves 2NF Partial Dependencies & Resolves Many-to-Many Relationships.
-- Composite Primary Key ensures that every student-course enrollment record is unique.
CREATE TABLE Enrollments (
    StudentID INT,
    CourseName VARCHAR(100),
    PRIMARY KEY (StudentID, CourseName),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseName) REFERENCES Courses(CourseName)
);

-- =============================================================================
-- DATA POPULATION
-- Insert in parent-to-child order: Students & Instructors first, then Courses
-- (depends on Instructors), then Enrollments (depends on Students & Courses).
-- =============================================================================

-- Students
INSERT INTO Students (StudentID, StudentName) VALUES
(1, 'Alice Johnson'),
(2, 'Bob Lee'),
(3, 'Carol Davis');

-- Instructors
INSERT INTO Instructors (Instructor, Department) VALUES
('Dr. Smith', 'Science'),
('Dr. Brown', 'Science'),
('Dr. Green', 'Science'),
('Prof. White', 'Humanities'),
('Prof. Black', 'Humanities'),
('Dr. Yellow', 'Science');

-- Courses
INSERT INTO Courses (CourseName, Instructor) VALUES
('Math', 'Dr. Smith'),
('Physics', 'Dr. Brown'),
('Chemistry', 'Dr. Green'),
('English', 'Prof. White'),
('History', 'Prof. Black'),
('Biology', 'Dr. Yellow');

-- Enrollments
INSERT INTO Enrollments (StudentID, CourseName) VALUES
(1, 'Math'),
(1, 'Physics'),
(1, 'Chemistry'),
(2, 'English'),
(2, 'History'),
(3, 'Math'),
(3, 'Biology');

-- =============================================================================
-- DATA VERIFICATION & RECONSTRUCTION
-- Rebuilds the original full business spreadsheet view using INNER JOIN operations.
-- =============================================================================
SELECT 
    S.StudentID, 
    S.StudentName, 
    E.CourseName, 
    C.Instructor, 
    I.Department
FROM Students S
INNER JOIN Enrollments E ON S.StudentID = E.StudentID
INNER JOIN Courses C ON E.CourseName = C.CourseName
INNER JOIN Instructors I ON C.Instructor = I.Instructor;
