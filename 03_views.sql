-- ============================================================
--  PERSONAL FINANCE TRACKER — VIEWS
--  Task 9 | SQL Developer Internship | G. Pavana Deepika
--  Run AFTER 01_schema.sql and 02_seed_data.sql
-- ============================================================

-- Drop existing views
DROP VIEW IF EXISTS vw_MonthlyBalance;
DROP VIEW IF EXISTS vw_CategoryExpenseSummary;
DROP VIEW IF EXISTS vw_BudgetStatus;
DROP VIEW IF EXISTS vw_TransactionHistory;
DROP VIEW IF EXISTS vw_TopSpenders;
DROP VIEW IF EXISTS vw_RecurringTransactions;

-- ============================================================
-- VIEW 1: vw_MonthlyBalance
-- Shows total income, total expense, and net savings per user
-- per month. Useful for the main dashboard balance card.
-- ============================================================
CREATE VIEW vw_MonthlyBalance AS
SELECT
    u.user_id,
    u.full_name,
    u.currency,
    -- Derive month from both income and expense dates
    month_data.txn_month                                     AS month,
    COALESCE(month_data.total_income,  0)                    AS total_income,
    COALESCE(month_data.total_expense, 0)                    AS total_expense,
    ROUND(
        COALESCE(month_data.total_income, 0) -
        COALESCE(month_data.total_expense, 0), 2)            AS net_savings,
    -- Savings rate as percentage
    CASE
        WHEN COALESCE(month_data.total_income, 0) = 0 THEN 0
        ELSE ROUND(
            (COALESCE(month_data.total_income, 0) -
             COALESCE(month_data.total_expense, 0))
            / COALESCE(month_data.total_income, 0) * 100, 1)
    END                                                       AS savings_rate_pct
FROM Users u
JOIN (
    -- Union of months from income and expenses
    SELECT user_id,
           STRFTIME('%Y-%m', received_date) AS txn_month,
           SUM(amount) AS total_income,
           0           AS total_expense
    FROM   Income
    GROUP  BY user_id, STRFTIME('%Y-%m', received_date)

    UNION ALL

    SELECT user_id,
           STRFTIME('%Y-%m', expense_date) AS txn_month,
           0           AS total_income,
           SUM(amount) AS total_expense
    FROM   Expenses
    GROUP  BY user_id, STRFTIME('%Y-%m', expense_date)
) AS raw
ON u.user_id = raw.user_id
JOIN (
    SELECT
        user_id,
        txn_month,
        SUM(total_income)  AS total_income,
        SUM(total_expense) AS total_expense
    FROM (
        SELECT user_id, STRFTIME('%Y-%m', received_date) AS txn_month,
               SUM(amount) AS total_income, 0 AS total_expense
        FROM   Income
        GROUP  BY user_id, STRFTIME('%Y-%m', received_date)
        UNION ALL
        SELECT user_id, STRFTIME('%Y-%m', expense_date) AS txn_month,
               0 AS total_income, SUM(amount) AS total_expense
        FROM   Expenses
        GROUP  BY user_id, STRFTIME('%Y-%m', expense_date)
    )
    GROUP BY user_id, txn_month
) AS month_data
ON u.user_id = month_data.user_id
GROUP BY u.user_id, u.full_name, u.currency, month_data.txn_month;

-- ============================================================
-- VIEW 2: vw_CategoryExpenseSummary
-- Category-wise spending per user per month.
-- Powers the "Category Breakdown" pie/bar chart.
-- ============================================================
CREATE VIEW vw_CategoryExpenseSummary AS
SELECT
    u.user_id,
    u.full_name,
    STRFTIME('%Y-%m', e.expense_date)  AS month,
    c.category_id,
    c.name                             AS category_name,
    c.icon,
    COUNT(e.expense_id)                AS transaction_count,
    ROUND(SUM(e.amount), 2)            AS total_spent,
    ROUND(AVG(e.amount), 2)            AS avg_transaction
FROM   Expenses  e
JOIN   Users     u ON u.user_id     = e.user_id
JOIN   Categories c ON c.category_id = e.category_id
GROUP  BY u.user_id, u.full_name, STRFTIME('%Y-%m', e.expense_date),
          c.category_id, c.name, c.icon
ORDER  BY month DESC, total_spent DESC;

-- ============================================================
-- VIEW 3: vw_BudgetStatus
-- Compares actual spending against monthly budget limits.
-- Shows status: UNDER / WARNING (>80%) / EXCEEDED (>100%).
-- ============================================================
CREATE VIEW vw_BudgetStatus AS
SELECT
    b.user_id,
    u.full_name,
    b.month,
    c.name                                   AS category_name,
    c.icon,
    b.limit_amount                           AS budget_limit,
    COALESCE(spent.actual_spent, 0)          AS actual_spent,
    ROUND(b.limit_amount -
          COALESCE(spent.actual_spent, 0), 2) AS remaining,
    ROUND(COALESCE(spent.actual_spent, 0)
          / b.limit_amount * 100, 1)         AS used_pct,
    CASE
        WHEN COALESCE(spent.actual_spent, 0) > b.limit_amount
             THEN '🔴 EXCEEDED'
        WHEN COALESCE(spent.actual_spent, 0) > b.limit_amount * 0.8
             THEN '🟡 WARNING'
        ELSE '🟢 UNDER BUDGET'
    END                                      AS budget_status
FROM   Budgets    b
JOIN   Users      u ON u.user_id     = b.user_id
JOIN   Categories c ON c.category_id = b.category_id
LEFT JOIN (
    SELECT user_id,
           category_id,
           STRFTIME('%Y-%m', expense_date) AS month,
           SUM(amount)                     AS actual_spent
    FROM   Expenses
    GROUP  BY user_id, category_id, STRFTIME('%Y-%m', expense_date)
) AS spent
ON  spent.user_id    = b.user_id
AND spent.category_id = b.category_id
AND spent.month       = b.month
ORDER BY b.month DESC, used_pct DESC;

-- ============================================================
-- VIEW 4: vw_TransactionHistory
-- Unified ledger of all income and expense transactions.
-- Useful for the "All Transactions" list view.
-- ============================================================
CREATE VIEW vw_TransactionHistory AS
SELECT
    'INCOME'           AS txn_type,
    i.income_id        AS txn_id,
    u.full_name,
    c.name             AS category_name,
    c.icon,
    i.amount,
    i.source           AS party,
    i.description,
    i.received_date    AS txn_date,
    i.payment_method,
    i.is_recurring
FROM   Income     i
JOIN   Users      u ON u.user_id     = i.user_id
JOIN   Categories c ON c.category_id = i.category_id

UNION ALL

SELECT
    'EXPENSE'          AS txn_type,
    e.expense_id       AS txn_id,
    u.full_name,
    c.name             AS category_name,
    c.icon,
    -e.amount          AS amount,   -- Negative to indicate outflow
    e.vendor           AS party,
    e.description,
    e.expense_date     AS txn_date,
    e.payment_method,
    e.is_recurring
FROM   Expenses   e
JOIN   Users      u ON u.user_id     = e.user_id
JOIN   Categories c ON c.category_id = e.category_id

ORDER  BY txn_date DESC;

-- ============================================================
-- VIEW 5: vw_TopSpenders
-- Ranks users by total spending (all time).
-- ============================================================
CREATE VIEW vw_TopSpenders AS
SELECT
    u.user_id,
    u.full_name,
    u.email,
    COUNT(e.expense_id)     AS total_transactions,
    ROUND(SUM(e.amount), 2) AS total_spent,
    ROUND(AVG(e.amount), 2) AS avg_per_transaction,
    MAX(e.expense_date)     AS last_expense_date
FROM   Users   u
JOIN   Expenses e ON e.user_id = u.user_id
GROUP  BY u.user_id, u.full_name, u.email
ORDER  BY total_spent DESC;

-- ============================================================
-- VIEW 6: vw_RecurringTransactions
-- Shows all recurring income and expense transactions.
-- Useful for a "Fixed Commitments" or "Subscriptions" panel.
-- ============================================================
CREATE VIEW vw_RecurringTransactions AS
SELECT
    'INCOME'        AS txn_type,
    i.income_id     AS txn_id,
    u.full_name,
    c.name          AS category_name,
    i.amount,
    i.source        AS party,
    i.description,
    i.payment_method
FROM   Income     i
JOIN   Users      u ON u.user_id     = i.user_id
JOIN   Categories c ON c.category_id = i.category_id
WHERE  i.is_recurring = 1

UNION ALL

SELECT
    'EXPENSE'       AS txn_type,
    e.expense_id    AS txn_id,
    u.full_name,
    c.name          AS category_name,
    e.amount,
    e.vendor        AS party,
    e.description,
    e.payment_method
FROM   Expenses   e
JOIN   Users      u ON u.user_id     = e.user_id
JOIN   Categories c ON c.category_id = e.category_id
WHERE  e.is_recurring = 1

ORDER  BY txn_type, full_name;
