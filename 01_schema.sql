-- ============================================================
--  PERSONAL FINANCE TRACKER — DATABASE SCHEMA
--  Task 9 | SQL Developer Internship | G. Pavana Deepika
--  Compatible with: MySQL 8+ / SQLite 3.35+
-- ============================================================

-- Drop tables in safe order (children before parents)
DROP TABLE IF EXISTS Expenses;
DROP TABLE IF EXISTS Income;
DROP TABLE IF EXISTS Budgets;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Users;

-- ============================================================
-- TABLE 1: Users
-- Stores registered users of the finance tracker.
-- ============================================================
CREATE TABLE Users (
    user_id       INTEGER PRIMARY KEY AUTOINCREMENT,  -- Unique user identifier
    username      TEXT    NOT NULL UNIQUE,             -- Login username
    full_name     TEXT    NOT NULL,                    -- Display name
    email         TEXT    NOT NULL UNIQUE,             -- Email address
    currency      TEXT    NOT NULL DEFAULT 'INR',      -- Preferred currency (ISO 4217)
    created_at    TEXT    NOT NULL DEFAULT (DATE('now')), -- Account creation date
    is_active     INTEGER NOT NULL DEFAULT 1           -- 1 = active, 0 = deactivated
);

-- ============================================================
-- TABLE 2: Categories
-- Expense / Income categories (linked to a user or global).
-- ============================================================
CREATE TABLE Categories (
    category_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id       INTEGER,                             -- NULL = global/system category
    name          TEXT    NOT NULL,                    -- e.g. "Food", "Salary"
    type          TEXT    NOT NULL CHECK (type IN ('EXPENSE', 'INCOME', 'BOTH')),
    icon          TEXT    DEFAULT '💰',                -- Emoji icon for UI
    color_hex     TEXT    DEFAULT '#6C63FF',           -- Hex color for charts
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- ============================================================
-- TABLE 3: Income
-- Records all income transactions per user.
-- ============================================================
CREATE TABLE Income (
    income_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id         INTEGER NOT NULL,
    category_id     INTEGER NOT NULL,
    amount          REAL    NOT NULL CHECK (amount > 0),   -- Always positive
    source          TEXT    NOT NULL,                       -- e.g. "Employer", "Freelance"
    description     TEXT,                                   -- Optional note
    received_date   TEXT    NOT NULL,                       -- ISO date: YYYY-MM-DD
    payment_method  TEXT    DEFAULT 'Bank Transfer'
                            CHECK (payment_method IN
                                   ('Bank Transfer','Cash','UPI','Cheque','Crypto','Other')),
    is_recurring    INTEGER NOT NULL DEFAULT 0,            -- 1 = monthly recurring
    created_at      TEXT    NOT NULL DEFAULT (DATETIME('now')),
    FOREIGN KEY (user_id)     REFERENCES Users(user_id)     ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- ============================================================
-- TABLE 4: Expenses
-- Records all expense transactions per user.
-- ============================================================
CREATE TABLE Expenses (
    expense_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id         INTEGER NOT NULL,
    category_id     INTEGER NOT NULL,
    amount          REAL    NOT NULL CHECK (amount > 0),   -- Always positive
    vendor          TEXT    NOT NULL,                       -- Where money was spent
    description     TEXT,                                   -- Optional note
    expense_date    TEXT    NOT NULL,                       -- ISO date: YYYY-MM-DD
    payment_method  TEXT    DEFAULT 'UPI'
                            CHECK (payment_method IN
                                   ('Cash','UPI','Credit Card','Debit Card','Net Banking','Other')),
    is_recurring    INTEGER NOT NULL DEFAULT 0,            -- 1 = monthly recurring
    created_at      TEXT    NOT NULL DEFAULT (DATETIME('now')),
    FOREIGN KEY (user_id)     REFERENCES Users(user_id)     ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- ============================================================
-- TABLE 5: Budgets
-- Monthly budget limits per category per user.
-- ============================================================
CREATE TABLE Budgets (
    budget_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id       INTEGER NOT NULL,
    category_id   INTEGER NOT NULL,
    month         TEXT    NOT NULL,   -- Format: YYYY-MM  e.g. '2026-08'
    limit_amount  REAL    NOT NULL CHECK (limit_amount > 0),
    created_at    TEXT    NOT NULL DEFAULT (DATETIME('now')),
    UNIQUE (user_id, category_id, month),
    FOREIGN KEY (user_id)     REFERENCES Users(user_id)     ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- ============================================================
-- INDEXES for faster lookups
-- ============================================================
CREATE INDEX idx_expenses_user_date  ON Expenses (user_id, expense_date);
CREATE INDEX idx_income_user_date    ON Income   (user_id, received_date);
CREATE INDEX idx_budgets_user_month  ON Budgets  (user_id, month);
