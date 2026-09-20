# ❗ TOP 50 SQL INTERVIEW QUESTIONS — Short Answers
### G. Pavana Deepika | SQL Developer Internship

---

## 🟦 SECTION 1 — SQL Basics & Core Concepts

---

### 1. What is SQL? How is it different from MySQL or PostgreSQL?
**SQL** (Structured Query Language) is the standard language to query and manage relational databases.  
- **MySQL / PostgreSQL** are *database management systems (DBMS)* that *implement* SQL.  
- MySQL is fast & widely used for web apps; PostgreSQL is feature-rich & standards-compliant.

---

### 2. What are the different types of SQL statements?

| Type | Purpose | Examples |
|------|---------|---------|
| **DDL** | Define structure | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` |
| **DML** | Manipulate data | `SELECT`, `INSERT`, `UPDATE`, `DELETE` |
| **DCL** | Control access | `GRANT`, `REVOKE` |
| **TCL** | Manage transactions | `COMMIT`, `ROLLBACK`, `SAVEPOINT` |

---

### 3. Explain the difference between WHERE and HAVING.

| | WHERE | HAVING |
|-|-------|--------|
| **Works on** | Individual rows | Grouped rows |
| **Used with** | Any query | `GROUP BY` only |
| **Aggregate?** | ❌ No | ✅ Yes |

```sql
-- WHERE filters rows before grouping
SELECT dept, AVG(salary) FROM emp WHERE age > 25 GROUP BY dept;

-- HAVING filters after grouping
SELECT dept, AVG(salary) FROM emp GROUP BY dept HAVING AVG(salary) > 50000;
```

---

### 4. What are PRIMARY KEY, FOREIGN KEY, UNIQUE, and CHECK constraints?

| Constraint | Purpose |
|------------|---------|
| **PRIMARY KEY** | Uniquely identifies each row; NOT NULL + UNIQUE |
| **FOREIGN KEY** | Links to a PRIMARY KEY in another table (referential integrity) |
| **UNIQUE** | Ensures all values in a column are different (allows one NULL) |
| **CHECK** | Enforces a condition on column values e.g. `CHECK (age > 0)` |

---

### 5. What is the difference between DELETE, TRUNCATE, and DROP?

| | DELETE | TRUNCATE | DROP |
|-|--------|----------|------|
| **Removes** | Specific rows | All rows | Entire table |
| **WHERE clause** | ✅ Yes | ❌ No | ❌ No |
| **Rollback** | ✅ Yes | ❌ No (mostly) | ❌ No |
| **Keeps structure** | ✅ Yes | ✅ Yes | ❌ No |
| **Triggers fired** | ✅ Yes | ❌ No | ❌ No |

---

### 6. What is normalization? Explain different normal forms.

**Normalization** = organizing tables to reduce data redundancy and improve integrity.

| Normal Form | Rule |
|-------------|------|
| **1NF** | Atomic values; no repeating groups |
| **2NF** | 1NF + no partial dependency on composite PK |
| **3NF** | 2NF + no transitive dependency (non-key → non-key) |
| **BCNF** | Stronger 3NF — every determinant must be a candidate key |

---

### 7. What is denormalization and when is it useful?

**Denormalization** = intentionally adding redundancy to improve **read performance**.  
Use when: heavy reporting/analytics, joins are too slow, data warehouse scenarios.  
Trade-off: faster reads ↔ risk of inconsistency on writes.

---

### 8. Explain the difference between CHAR and VARCHAR.

| | CHAR(n) | VARCHAR(n) |
|-|---------|------------|
| **Storage** | Fixed length (always n bytes) | Variable length (actual + 1–2 bytes overhead) |
| **Speed** | Slightly faster (fixed) | Slightly slower |
| **Best for** | Fixed-width data (e.g., country code `'IN'`) | Variable text (names, emails) |

---

### 9. What are ACID properties in databases?

| Property | Meaning |
|----------|---------|
| **Atomicity** | Transaction is all-or-nothing |
| **Consistency** | DB moves from one valid state to another |
| **Isolation** | Concurrent transactions don't interfere |
| **Durability** | Committed data survives crashes |

---

### 10. Difference between INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL JOIN?

| Join | Returns |
|------|---------|
| **INNER JOIN** | Only matching rows in both tables |
| **LEFT JOIN** | All rows from left + matching from right (NULL if no match) |
| **RIGHT JOIN** | All rows from right + matching from left (NULL if no match) |
| **FULL JOIN** | All rows from both; NULL where no match on either side |

```sql
SELECT e.name, d.dept_name
FROM Employees e
LEFT JOIN Departments d ON e.dept_id = d.dept_id;
```

---

## 🟨 SECTION 2 — Practical / Query Writing

---

### 11. Write a query to find the second highest salary.

```sql
-- Method 1: LIMIT + OFFSET
SELECT DISTINCT salary FROM Employee
ORDER BY salary DESC LIMIT 1 OFFSET 1;

-- Method 2: Subquery
SELECT MAX(salary) FROM Employee
WHERE salary < (SELECT MAX(salary) FROM Employee);
```

---

### 12. Write a query to get department-wise average salary.

```sql
SELECT department, ROUND(AVG(salary), 2) AS avg_salary
FROM Employee
GROUP BY department
ORDER BY avg_salary DESC;
```

---

### 13. How would you retrieve duplicate records from a table?

```sql
-- Find emails that appear more than once
SELECT email, COUNT(*) AS cnt
FROM Customers
GROUP BY email
HAVING COUNT(*) > 1;
```

---

### 14. How do you update a column with a calculation (e.g., 10% tax)?

```sql
UPDATE Products
SET price = price * 1.10
WHERE category = 'Electronics';
```

---

### 15. How would you delete only duplicate rows from a table?

```sql
-- Keep the row with the lowest rowid, delete rest
DELETE FROM Customers
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM Customers
    GROUP BY email
);
```

---

### 16. Write a query to list customers who have placed more than 5 orders.

```sql
SELECT customer_id, COUNT(*) AS order_count
FROM Orders
GROUP BY customer_id
HAVING COUNT(*) > 5
ORDER BY order_count DESC;
```

---

### 17. Write a query to join three or more tables.

```sql
SELECT o.order_id, c.name AS customer, p.product_name, o.quantity
FROM Orders o
JOIN Customers c ON c.customer_id = o.customer_id
JOIN Products  p ON p.product_id  = o.product_id;
```

---

### 18. What is a subquery? How is it different from a JOIN?

**Subquery** = a query nested inside another query.  
- Subquery returns a value/set used by outer query.  
- JOIN combines columns from multiple tables horizontally.  
- Subqueries are more readable; JOINs are usually faster for large datasets.

```sql
-- Subquery
SELECT name FROM Employee
WHERE dept_id = (SELECT dept_id FROM Department WHERE dept_name = 'HR');
```

---

### 19. What is a correlated subquery? Give an example.

A **correlated subquery** references a column from the outer query — re-executes for each row.

```sql
-- Employees earning more than their department's average
SELECT name, salary, dept_id
FROM Employee e
WHERE salary > (
    SELECT AVG(salary) FROM Employee
    WHERE dept_id = e.dept_id   -- ← references outer row
);
```

---

### 20. How do you filter data based on a date range?

```sql
-- Between two dates (inclusive)
SELECT * FROM Expenses
WHERE expense_date BETWEEN '2026-01-01' AND '2026-09-30';

-- Current month
SELECT * FROM Expenses
WHERE STRFTIME('%Y-%m', expense_date) = STRFTIME('%Y-%m', 'now');
```

---

## 🟧 SECTION 3 — Window Functions & Advanced SQL

---

### 21. What are WINDOW FUNCTIONS? Name a few.

Window functions perform calculations **across a set of rows related to the current row** without collapsing them (unlike GROUP BY).

Common ones: `ROW_NUMBER()`, `RANK()`, `DENSE_RANK()`, `LAG()`, `LEAD()`, `SUM() OVER()`, `AVG() OVER()`, `NTILE()`

---

### 22. What is the use of RANK(), DENSE_RANK(), and ROW_NUMBER()?

| Function | Ties handling | Gap after tie? |
|----------|---------------|----------------|
| `ROW_NUMBER()` | Unique number always | N/A |
| `RANK()` | Same rank for ties | ✅ Yes (skips numbers) |
| `DENSE_RANK()` | Same rank for ties | ❌ No gap |

```sql
SELECT name, salary,
       RANK()       OVER (ORDER BY salary DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rnk,
       ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM Employee;
```

---

### 23. What is a CTE? How is it different from a subquery?

**CTE (Common Table Expression)** = a named temporary result set defined with `WITH`.

```sql
WITH TopEarners AS (
    SELECT name, salary FROM Employee WHERE salary > 80000
)
SELECT * FROM TopEarners WHERE name LIKE 'A%';
```

| | CTE | Subquery |
|-|-----|----------|
| **Readable** | ✅ More | ❌ Less |
| **Reusable** | ✅ Yes (in same query) | ❌ No |
| **Recursive** | ✅ Yes | ❌ No |

---

### 24. What are stored procedures? When should they be used?

**Stored procedure** = a saved, reusable block of SQL code executed by name.

```sql
CREATE PROCEDURE GetMonthlyReport(IN p_month TEXT)
BEGIN
    SELECT * FROM Expenses WHERE STRFTIME('%Y-%m', expense_date) = p_month;
END;
```

Use when: repeated complex logic, business rule enforcement, reducing network round-trips.

---

### 25. What is a trigger? Give a real-world example.

**Trigger** = SQL code that auto-executes on `INSERT`, `UPDATE`, or `DELETE`.

```sql
-- Auto-log when an expense is deleted
CREATE TRIGGER log_deleted_expense
AFTER DELETE ON Expenses
BEGIN
    INSERT INTO AuditLog(action, expense_id, deleted_at)
    VALUES ('DELETE', OLD.expense_id, DATETIME('now'));
END;
```

Real-world: audit trails, auto-updating inventory counts, timestamp updates.

---

### 26. What is a VIEW? What are its pros and cons?

**VIEW** = a saved SELECT query treated as a virtual table.

```sql
CREATE VIEW vw_MonthlySummary AS
SELECT STRFTIME('%Y-%m', expense_date) AS month, SUM(amount) AS total
FROM Expenses GROUP BY 1;
```

| Pros ✅ | Cons ❌ |
|---------|---------|
| Simplifies complex queries | Can't always be updated |
| Hides sensitive columns | No performance gain (re-executes each time) |
| Reusable abstraction | Dependent on base tables |

---

### 27. What are indexes? How do they improve performance?

**Index** = a data structure (B-tree) that speeds up row lookups, like a book index.

```sql
CREATE INDEX idx_expense_date ON Expenses(expense_date);
```

- ✅ Speeds up `SELECT` / `WHERE` / `JOIN`
- ❌ Slows down `INSERT` / `UPDATE` / `DELETE` (index must update too)

---

### 28. What is a materialized view?

A **materialized view** stores the query result physically on disk (unlike a regular view which re-runs every time). Refreshed periodically or on demand.

- ✅ Much faster reads
- ❌ Data can be stale until refreshed
- Available in: PostgreSQL, Oracle (not natively in MySQL/SQLite)

---

### 29. What are transactions? Explain COMMIT, ROLLBACK, SAVEPOINT.

**Transaction** = a unit of work that must fully succeed or fully fail.

```sql
BEGIN;
  UPDATE Accounts SET balance = balance - 500 WHERE id = 1;
  UPDATE Accounts SET balance = balance + 500 WHERE id = 2;
SAVEPOINT transfer_done;
  -- If error:
ROLLBACK TO transfer_done;
COMMIT;
```

| Command | Action |
|---------|--------|
| `COMMIT` | Permanently saves changes |
| `ROLLBACK` | Undoes all changes since last COMMIT |
| `SAVEPOINT` | Creates a checkpoint to partially rollback |

---

### 30. What are aggregate functions? List a few with examples.

Functions that operate on a set of rows and return one value:

```sql
SELECT
    COUNT(*)        AS total_rows,
    SUM(amount)     AS total_spent,
    AVG(amount)     AS avg_amount,
    MIN(amount)     AS min_expense,
    MAX(amount)     AS max_expense
FROM Expenses WHERE user_id = 1;
```

---

## 🟥 SECTION 4 — Performance & Optimization

---

### 31. How can you optimize a slow-running SQL query?

1. Add **indexes** on WHERE / JOIN / ORDER BY columns  
2. Use **EXPLAIN** to find full table scans  
3. Avoid `SELECT *` — select only needed columns  
4. Replace correlated subqueries with JOINs or CTEs  
5. Use **pagination** (`LIMIT`/`OFFSET`) for large results  
6. Partition large tables  
7. Avoid functions on indexed columns in WHERE  

---

### 32. What is the EXPLAIN / EXPLAIN PLAN statement used for?

Shows the **query execution plan** — how the DB engine will execute a query.

```sql
EXPLAIN SELECT * FROM Expenses WHERE user_id = 1;
EXPLAIN ANALYZE SELECT ...;  -- PostgreSQL: also runs the query
```

Look for: `FULL TABLE SCAN` (bad) vs `INDEX SCAN` (good), row estimates, join order.

---

### 33. How does indexing affect INSERT, UPDATE, and DELETE performance?

- **INSERT** → slower (index entry must be added)
- **UPDATE** → slower if indexed column changes (old entry removed, new added)
- **DELETE** → slower (index entry must be removed)

**Rule:** Don't over-index write-heavy tables; index strategically for reads.

---

### 34. What is a composite index and when should it be used?

**Composite index** = index on multiple columns together.

```sql
CREATE INDEX idx_user_date ON Expenses(user_id, expense_date);
```

Use when: queries frequently filter/sort by **multiple columns together**.  
Order matters — left-most column must be in the WHERE for the index to be used.

---

### 35. What is normalization overhead and how do you deal with it?

**Overhead** = extra JOINs needed to reassemble normalized data, slowing reads.

Solutions:
- Use **denormalization** / redundant columns for hot read paths
- Create **views** or **materialized views** for common joins
- Use **caching** at app layer

---

### 36. How do you avoid Cartesian products in JOINs?

A **Cartesian product** occurs when a JOIN has no ON condition → every row × every row.

```sql
-- ❌ Dangerous (no join condition)
SELECT * FROM A, B;

-- ✅ Safe — always specify ON
SELECT * FROM A JOIN B ON A.id = B.a_id;
```

Always provide an explicit `ON` (or `USING`) clause for every JOIN.

---

### 37. What is partitioning in SQL?

**Partitioning** = splitting a large table into smaller physical pieces (partitions) based on a column value, while appearing as one table.

Types:
- **Range** — by date ranges (e.g., one partition per year)
- **List** — by specific values (e.g., by country)
- **Hash** — by hash of column value

Benefit: queries on one partition skip others → faster scans.

---

### 38. What causes a deadlock in SQL, and how can you prevent it?

**Deadlock** = two transactions each waiting for a lock held by the other.

Prevention:
- Access tables in the **same order** in all transactions
- Keep transactions **short**
- Use **NOWAIT** or **SKIP LOCKED**
- Use appropriate **isolation levels**

---

### 39. Difference between clustered and non-clustered indexes?

| | Clustered | Non-Clustered |
|-|-----------|---------------|
| **Data storage** | Data rows stored in index order | Separate structure; pointer to row |
| **Per table** | Only 1 allowed | Many allowed |
| **Speed** | Faster for range scans | Faster for lookup by value |
| **Example** | PRIMARY KEY (auto-clustered) | `CREATE INDEX idx_name ON ...` |

---

### 40. What tools do you use to monitor SQL query performance?

| Tool | Use |
|------|-----|
| `EXPLAIN` / `EXPLAIN ANALYZE` | Query execution plan |
| MySQL **Slow Query Log** | Identify slow queries |
| **pgAdmin** / **DBeaver** | GUI query profiling |
| **MySQL Workbench** | Visual EXPLAIN, performance dashboard |
| **sys schema** (MySQL) | Waits, bottlenecks |
| **pg_stat_statements** | PostgreSQL query stats |

---

## 🟪 SECTION 5 — Design & Scenario-Based

---

### 41. Design a student-course grading system.

```sql
Students (student_id PK, name, email, dob)
Courses  (course_id PK, course_name, credits, instructor_id)
Enrollments (enrollment_id PK,
             student_id FK → Students,
             course_id  FK → Courses,
             grade CHAR(2),
             semester TEXT)
Instructors (instructor_id PK, name, department)
```

Relationships: Students ↔ Courses is **many-to-many** via Enrollments.

---

### 42. How would you store and retrieve employee attendance scalably?

```sql
-- Schema
Employees   (emp_id PK, name, department)
Attendance  (att_id PK, emp_id FK, date DATE,
             check_in TIME, check_out TIME,
             status TEXT CHECK(status IN ('Present','Absent','Half-Day','Leave')))

-- Index for performance
CREATE INDEX idx_att_emp_date ON Attendance(emp_id, date);

-- Query: Monthly attendance summary
SELECT emp_id, COUNT(*) AS present_days
FROM Attendance
WHERE status = 'Present'
  AND STRFTIME('%Y-%m', date) = '2026-09'
GROUP BY emp_id;
```

---

### 43. Track overdue books and fines in a library system.

```sql
Books      (book_id PK, title, author)
Members    (member_id PK, name, email)
Loans      (loan_id PK, book_id FK, member_id FK,
            issued_date DATE, due_date DATE, returned_date DATE)

-- Overdue books + fine calculation
SELECT l.loan_id, m.name, b.title,
       l.due_date,
       JULIANDAY('now') - JULIANDAY(l.due_date) AS days_overdue,
       ROUND((JULIANDAY('now') - JULIANDAY(l.due_date)) * 2, 2) AS fine_inr
FROM Loans l
JOIN Members m ON m.member_id = l.member_id
JOIN Books   b ON b.book_id   = l.book_id
WHERE l.returned_date IS NULL
  AND l.due_date < DATE('now');
```

---

### 44. What would you do if production DB is missing records due to a failed update?

1. **Don't panic** — stop further writes immediately if data loss is ongoing
2. Check **transaction logs** / **audit tables** for the failed statement
3. Restore from the latest **backup** to a staging DB
4. **Compare** staging vs production to identify missing rows
5. **Re-insert** verified records within a transaction
6. `COMMIT` only after validation; keep rollback ready
7. Do a **post-mortem** — add retry logic, idempotent updates, better error handling

---

### 45. How would you implement role-based access to sensitive data?

```sql
-- Create roles
CREATE ROLE hr_role;
CREATE ROLE finance_role;
CREATE ROLE read_only;

-- Grant specific privileges
GRANT SELECT ON Employees TO read_only;
GRANT SELECT, UPDATE ON Salaries TO finance_role;
GRANT ALL ON Employees TO hr_role;

-- Assign roles to users
GRANT hr_role TO 'hr_user'@'localhost';

-- Hide sensitive columns via a VIEW
CREATE VIEW vw_PublicEmployees AS
SELECT emp_id, name, department FROM Employees;  -- no salary column
GRANT SELECT ON vw_PublicEmployees TO read_only;
```

---

### 46. You have a raw CSV with dirty data. How do you load and clean it in SQL?

```sql
-- Step 1: Load into a staging table (all TEXT columns)
CREATE TABLE staging_raw (
    name TEXT, email TEXT, amount TEXT, date TEXT
);
-- Load via: .import data.csv staging_raw  (SQLite)
--           LOAD DATA INFILE (MySQL)

-- Step 2: Identify dirty rows
SELECT * FROM staging_raw WHERE amount NOT GLOB '[0-9]*';
SELECT * FROM staging_raw WHERE date NOT LIKE '____-__-__';

-- Step 3: Clean & insert into target table
INSERT INTO Expenses (vendor, amount, expense_date)
SELECT
    TRIM(name),
    CAST(REPLACE(amount, ',', '') AS REAL),
    DATE(date)
FROM staging_raw
WHERE amount GLOB '[0-9.]*'
  AND date LIKE '____-__-__'
  AND email LIKE '%@%.%';
```

---

### 47. How would you calculate monthly retention from a user login dataset?

```sql
-- Monthly active users
WITH MonthlyUsers AS (
    SELECT user_id,
           STRFTIME('%Y-%m', login_date) AS month
    FROM Logins
    GROUP BY user_id, STRFTIME('%Y-%m', login_date)
),
-- Retention: users who logged in month M and also M+1
Retention AS (
    SELECT m1.month,
           COUNT(DISTINCT m2.user_id) AS retained_users,
           COUNT(DISTINCT m1.user_id) AS base_users
    FROM MonthlyUsers m1
    LEFT JOIN MonthlyUsers m2
           ON m1.user_id = m2.user_id
          AND m2.month = STRFTIME('%Y-%m',
                DATE(m1.month || '-01', '+1 month'))
    GROUP BY m1.month
)
SELECT month,
       base_users,
       retained_users,
       ROUND(retained_users * 100.0 / base_users, 1) AS retention_pct
FROM Retention ORDER BY month;
```

---

### 48. What measures would you take to secure a database with sensitive data?

| Layer | Measure |
|-------|---------|
| **Access** | Principle of least privilege; role-based access control |
| **Authentication** | Strong passwords; MFA for DB admin accounts |
| **Encryption** | Encrypt data at rest (TDE) and in transit (SSL/TLS) |
| **Masking** | Use views to mask PII (e.g., show only last 4 digits of card) |
| **Audit** | Enable audit logs; log all DDL and sensitive DML |
| **Patching** | Keep DB engine updated against CVEs |
| **Backup** | Encrypted, offsite backups with tested restore |
| **SQL Injection** | Use parameterized queries / prepared statements only |

---

### 49. How do you create daily backup and restore plans for a SQL database?

**Backup Plan:**
```bash
# SQLite — daily dump
sqlite3 finance_tracker.db .dump > backup_$(date +%Y%m%d).sql

# MySQL
mysqldump -u root -p mydb > backup_$(date +%Y%m%d).sql

# PostgreSQL
pg_dump mydb > backup_$(date +%Y%m%d).sql
```

**Automation:** Schedule with cron (Linux) or Task Scheduler (Windows):
```
0 2 * * * /scripts/backup.sh   # runs at 2 AM daily
```

**Restore:**
```bash
# SQLite
sqlite3 new_finance.db < backup_20260920.sql

# MySQL
mysql -u root -p mydb < backup_20260920.sql
```

**Best Practices:**
- Keep 7-day rolling backups (daily) + monthly archives
- Store off-site (cloud bucket / separate server)
- **Test restore monthly** — an untested backup is not a backup
- Use **point-in-time recovery** (PITR) for production DBs

---

## 📊 Quick Reference Cheat Sheet

```
WHERE vs HAVING      → WHERE=rows, HAVING=groups
DELETE vs TRUNCATE   → DELETE=rows+rollback, TRUNCATE=all rows, no rollback
CHAR vs VARCHAR      → CHAR=fixed, VARCHAR=variable
RANK vs DENSE_RANK   → RANK skips numbers after tie, DENSE_RANK doesn't
CTE vs Subquery      → CTE=readable+reusable, Subquery=inline
Clustered vs Non     → Clustered=data order on disk, Non=pointer to data
ACID                 → Atomicity, Consistency, Isolation, Durability
```

---
*G. Pavana Deepika | SQL Developer Internship | September 2026*
