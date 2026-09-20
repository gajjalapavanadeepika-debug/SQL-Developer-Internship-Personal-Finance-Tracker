-- ============================================================
--  PERSONAL FINANCE TRACKER — BUDGET & ANALYTICAL QUERIES
--  Task 9 | SQL Developer Internship | G. Pavana Deepika
--  Run AFTER 01_schema.sql, 02_seed_data.sql, 03_views.sql
-- ============================================================

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION A: MONTHLY SUMMARIES
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- A1. Monthly Income vs Expense vs Net Savings (all users)
-- Uses the vw_MonthlyBalance view.
SELECT
    full_name,
    month,
    total_income,
    total_expense,
    net_savings,
    savings_rate_pct || '%' AS savings_rate
FROM   vw_MonthlyBalance
ORDER  BY full_name, month;

-- ─────────────────────────────────────────────────────────────
-- A2. Summarize expenses month-by-month for a specific user
--     (User 1 — Pavana Deepika)
SELECT
    STRFTIME('%Y-%m', expense_date)  AS month,
    STRFTIME('%B %Y', expense_date)  AS month_label,
    COUNT(*)                          AS num_transactions,
    ROUND(SUM(amount), 2)             AS total_expenses,
    ROUND(AVG(amount), 2)             AS avg_per_transaction,
    ROUND(MIN(amount), 2)             AS smallest_expense,
    ROUND(MAX(amount), 2)             AS largest_expense
FROM   Expenses
WHERE  user_id = 1
GROUP  BY STRFTIME('%Y-%m', expense_date)
ORDER  BY month;

-- ─────────────────────────────────────────────────────────────
-- A3. Monthly income breakdown by category (User 1)
SELECT
    STRFTIME('%Y-%m', i.received_date) AS month,
    c.name                              AS income_source,
    ROUND(SUM(i.amount), 2)             AS total_income
FROM   Income i
JOIN   Categories c ON c.category_id = i.category_id
WHERE  i.user_id = 1
GROUP  BY STRFTIME('%Y-%m', i.received_date), c.name
ORDER  BY month, total_income DESC;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION B: CATEGORY-WISE SPENDING (GROUP BY)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- B1. All-time category-wise spending for User 1
SELECT
    c.icon,
    c.name                          AS category,
    COUNT(e.expense_id)             AS total_transactions,
    ROUND(SUM(e.amount),   2)       AS total_spent,
    ROUND(AVG(e.amount),   2)       AS avg_spent,
    ROUND(MAX(e.amount),   2)       AS max_single_expense,
    ROUND(MIN(e.amount),   2)       AS min_single_expense
FROM   Expenses e
JOIN   Categories c ON c.category_id = e.category_id
WHERE  e.user_id = 1
GROUP  BY c.category_id, c.name, c.icon
ORDER  BY total_spent DESC;

-- ─────────────────────────────────────────────────────────────
-- B2. Category-wise spending for a specific month (September 2026)
SELECT
    c.icon,
    c.name                          AS category,
    ROUND(SUM(e.amount), 2)         AS spent,
    COUNT(*)                         AS txns,
    ROUND(SUM(e.amount) * 100.0 /
          (SELECT SUM(amount) FROM Expenses
           WHERE user_id = 1
           AND STRFTIME('%Y-%m', expense_date) = '2026-09'),
          1)                         AS pct_of_month_total
FROM   Expenses e
JOIN   Categories c ON c.category_id = e.category_id
WHERE  e.user_id = 1
  AND  STRFTIME('%Y-%m', e.expense_date) = '2026-09'
GROUP  BY c.category_id, c.name, c.icon
ORDER  BY spent DESC;

-- ─────────────────────────────────────────────────────────────
-- B3. Month-over-month category spending trend (pivot style)
--     Compare category spending across Jul / Aug / Sep 2026
SELECT
    c.icon,
    c.name                                               AS category,
    ROUND(SUM(CASE WHEN STRFTIME('%Y-%m', e.expense_date) = '2026-07'
                   THEN e.amount ELSE 0 END), 2)         AS jul_2026,
    ROUND(SUM(CASE WHEN STRFTIME('%Y-%m', e.expense_date) = '2026-08'
                   THEN e.amount ELSE 0 END), 2)         AS aug_2026,
    ROUND(SUM(CASE WHEN STRFTIME('%Y-%m', e.expense_date) = '2026-09'
                   THEN e.amount ELSE 0 END), 2)         AS sep_2026
FROM   Expenses e
JOIN   Categories c ON c.category_id = e.category_id
WHERE  e.user_id = 1
  AND  STRFTIME('%Y-%m', e.expense_date) IN ('2026-07','2026-08','2026-09')
GROUP  BY c.category_id, c.name, c.icon
ORDER  BY (jul_2026 + aug_2026 + sep_2026) DESC;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION C: BUDGET QUERIES
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- C1. Full budget status for September 2026 (User 1)
SELECT
    icon,
    category_name,
    budget_limit,
    actual_spent,
    remaining,
    used_pct || '%' AS used,
    budget_status
FROM   vw_BudgetStatus
WHERE  user_id = 1
  AND  month   = '2026-09'
ORDER  BY used_pct DESC;

-- ─────────────────────────────────────────────────────────────
-- C2. Budget vs Actual for all months (User 1)
SELECT
    month,
    category_name,
    budget_limit,
    actual_spent,
    remaining,
    budget_status
FROM   vw_BudgetStatus
WHERE  user_id = 1
ORDER  BY month DESC, used_pct DESC;

-- ─────────────────────────────────────────────────────────────
-- C3. Categories that EXCEEDED budget (any month, User 1)
SELECT
    month,
    category_name,
    budget_limit,
    actual_spent,
    ROUND(actual_spent - budget_limit, 2) AS overspent_by
FROM   vw_BudgetStatus
WHERE  user_id = 1
  AND  budget_status = '🔴 EXCEEDED'
ORDER  BY month DESC, overspent_by DESC;

-- ─────────────────────────────────────────────────────────────
-- C4. Overall monthly budget utilization (all categories combined)
SELECT
    month,
    ROUND(SUM(budget_limit),  2) AS total_budget,
    ROUND(SUM(actual_spent),  2) AS total_spent,
    ROUND(SUM(remaining),     2) AS total_remaining,
    ROUND(SUM(actual_spent) * 100.0 / SUM(budget_limit), 1) || '%'
                                   AS overall_utilization
FROM   vw_BudgetStatus
WHERE  user_id = 1
GROUP  BY month
ORDER  BY month DESC;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  SECTION D: ADVANCED ANALYTICAL QUERIES
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- D1. Payment method preference analysis (User 1)
SELECT
    payment_method,
    COUNT(*)                          AS transactions,
    ROUND(SUM(amount),  2)            AS total_spent,
    ROUND(AVG(amount),  2)            AS avg_amount,
    ROUND(SUM(amount) * 100.0 /
          (SELECT SUM(amount) FROM Expenses WHERE user_id = 1), 1)
                                      AS pct_of_total
FROM   Expenses
WHERE  user_id = 1
GROUP  BY payment_method
ORDER  BY total_spent DESC;

-- ─────────────────────────────────────────────────────────────
-- D2. Top 10 most expensive single transactions (User 1)
SELECT
    e.expense_date,
    c.icon || ' ' || c.name  AS category,
    e.vendor,
    e.description,
    e.amount,
    e.payment_method
FROM   Expenses e
JOIN   Categories c ON c.category_id = e.category_id
WHERE  e.user_id = 1
ORDER  BY e.amount DESC
LIMIT  10;

-- ─────────────────────────────────────────────────────────────
-- D3. Running cumulative balance (User 1) — month by month
SELECT
    month,
    total_income,
    total_expense,
    net_savings,
    SUM(net_savings) OVER (ORDER BY month ROWS UNBOUNDED PRECEDING)
                        AS cumulative_savings
FROM   vw_MonthlyBalance
WHERE  user_id = 1
ORDER  BY month;

-- ─────────────────────────────────────────────────────────────
-- D4. Months where expenses exceed income (deficit months)
SELECT
    month,
    full_name,
    total_income,
    total_expense,
    net_savings,
    '⚠️ DEFICIT'  AS alert
FROM   vw_MonthlyBalance
WHERE  net_savings < 0
ORDER  BY month;

-- ─────────────────────────────────────────────────────────────
-- D5. Average daily spend per month (User 1)
SELECT
    STRFTIME('%Y-%m', expense_date)             AS month,
    ROUND(SUM(amount), 2)                        AS monthly_total,
    -- Number of days in that month (approx by counting distinct days)
    COUNT(DISTINCT expense_date)                 AS active_spend_days,
    ROUND(SUM(amount) /
          COUNT(DISTINCT expense_date), 2)       AS avg_per_active_day
FROM   Expenses
WHERE  user_id = 1
GROUP  BY STRFTIME('%Y-%m', expense_date)
ORDER  BY month;

-- ─────────────────────────────────────────────────────────────
-- D6. Recurring vs non-recurring expense breakdown
SELECT
    CASE is_recurring WHEN 1 THEN '🔄 Recurring' ELSE '📌 One-time' END
                          AS expense_type,
    COUNT(*)               AS num_transactions,
    ROUND(SUM(amount), 2)  AS total_amount,
    ROUND(AVG(amount), 2)  AS avg_amount
FROM   Expenses
WHERE  user_id = 1
GROUP  BY is_recurring;

-- ─────────────────────────────────────────────────────────────
-- D7. Which category saw the highest month-over-month increase?
--     Compares Aug vs Sep 2026 for User 1
SELECT
    c.icon || ' ' || c.name          AS category,
    ROUND(SUM(CASE WHEN STRFTIME('%Y-%m', e.expense_date) = '2026-08'
                   THEN e.amount ELSE 0 END), 2)  AS aug_spent,
    ROUND(SUM(CASE WHEN STRFTIME('%Y-%m', e.expense_date) = '2026-09'
                   THEN e.amount ELSE 0 END), 2)  AS sep_spent,
    ROUND(
        SUM(CASE WHEN STRFTIME('%Y-%m', e.expense_date) = '2026-09'
                 THEN e.amount ELSE 0 END) -
        SUM(CASE WHEN STRFTIME('%Y-%m', e.expense_date) = '2026-08'
                 THEN e.amount ELSE 0 END), 2)    AS change_amount,
    CASE
        WHEN SUM(CASE WHEN STRFTIME('%Y-%m', e.expense_date) = '2026-08'
                      THEN e.amount ELSE 0 END) = 0 THEN NULL
        ELSE ROUND(
            (SUM(CASE WHEN STRFTIME('%Y-%m', e.expense_date) = '2026-09'
                      THEN e.amount ELSE 0 END) -
             SUM(CASE WHEN STRFTIME('%Y-%m', e.expense_date) = '2026-08'
                      THEN e.amount ELSE 0 END)) * 100.0 /
             SUM(CASE WHEN STRFTIME('%Y-%m', e.expense_date) = '2026-08'
                      THEN e.amount ELSE 0 END), 1)
    END                               AS pct_change
FROM   Expenses e
JOIN   Categories c ON c.category_id = e.category_id
WHERE  e.user_id = 1
  AND  STRFTIME('%Y-%m', e.expense_date) IN ('2026-08', '2026-09')
GROUP  BY c.category_id, c.name, c.icon
ORDER  BY change_amount DESC;
