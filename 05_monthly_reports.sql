-- ============================================================
--  PERSONAL FINANCE TRACKER — MONTHLY REPORT EXPORT QUERIES
--  Task 9 | SQL Developer Internship | G. Pavana Deepika
--  These queries generate formatted monthly report data.
--  In SQLite CLI: .mode csv  then  .output report_sep2026.csv
-- ============================================================

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  REPORT 1: September 2026 — Full Monthly Expense Report
--  (User 1 — Pavana Deepika)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Section 1a: Report Header — Income Summary
SELECT
    '=== MONTHLY FINANCIAL REPORT ===' AS report_section,
    'User: G. Pavana Deepika'           AS user,
    'Period: September 2026'            AS period;

SELECT
    'INCOME SUMMARY'                     AS section,
    c.name                               AS source,
    ROUND(SUM(i.amount), 2)              AS amount_inr
FROM   Income i
JOIN   Categories c ON c.category_id = i.category_id
WHERE  i.user_id = 1
  AND  STRFTIME('%Y-%m', i.received_date) = '2026-09'
GROUP  BY c.name
ORDER  BY amount_inr DESC;

-- Section 1b: Expense Detail Lines
SELECT
    'EXPENSE DETAIL'                      AS section,
    e.expense_date                        AS date,
    c.name                                AS category,
    e.vendor,
    e.description,
    e.payment_method,
    ROUND(e.amount, 2)                    AS amount_inr
FROM   Expenses e
JOIN   Categories c ON c.category_id = e.category_id
WHERE  e.user_id = 1
  AND  STRFTIME('%Y-%m', e.expense_date) = '2026-09'
ORDER  BY e.expense_date, c.name;

-- Section 1c: Category-wise Subtotals
SELECT
    'CATEGORY SUBTOTALS'                  AS section,
    c.icon                                AS icon,
    c.name                                AS category,
    COUNT(*)                               AS num_txns,
    ROUND(SUM(e.amount), 2)               AS total_inr
FROM   Expenses e
JOIN   Categories c ON c.category_id = e.category_id
WHERE  e.user_id = 1
  AND  STRFTIME('%Y-%m', e.expense_date) = '2026-09'
GROUP  BY c.category_id, c.name, c.icon
ORDER  BY total_inr DESC;

-- Section 1d: Monthly Summary Footer
SELECT
    'MONTHLY SUMMARY'                             AS section,
    ROUND((SELECT SUM(amount) FROM Income
           WHERE user_id = 1
             AND STRFTIME('%Y-%m', received_date) = '2026-09'), 2)
                                                   AS total_income_inr,
    ROUND((SELECT SUM(amount) FROM Expenses
           WHERE user_id = 1
             AND STRFTIME('%Y-%m', expense_date) = '2026-09'), 2)
                                                   AS total_expenses_inr,
    ROUND(
        (SELECT SUM(amount) FROM Income
         WHERE user_id = 1
           AND STRFTIME('%Y-%m', received_date) = '2026-09') -
        (SELECT SUM(amount) FROM Expenses
         WHERE user_id = 1
           AND STRFTIME('%Y-%m', expense_date) = '2026-09'), 2)
                                                   AS net_savings_inr;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--  REPORT 2: Year-to-Date (Jan–Sep 2026) Financial Summary
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SELECT
    'YTD SUMMARY Jan–Sep 2026'                    AS report,
    ROUND(SUM(i.amount), 2)                        AS ytd_total_income,
    NULL                                            AS ytd_total_expense,
    NULL                                            AS ytd_net_savings
FROM   Income i
WHERE  i.user_id = 1
  AND  STRFTIME('%Y', i.received_date) = '2026'

UNION ALL

SELECT
    'YTD SUMMARY Jan–Sep 2026',
    NULL,
    ROUND(SUM(e.amount), 2),
    NULL
FROM   Expenses e
WHERE  e.user_id = 1
  AND  STRFTIME('%Y', e.expense_date) = '2026';

-- ─────────────────────────────────────────────────────────────
--  REPORT 3: All-months expense report (CSV-friendly flat table)
-- ─────────────────────────────────────────────────────────────
SELECT
    STRFTIME('%Y-%m', e.expense_date)  AS month,
    e.expense_date                      AS date,
    c.name                              AS category,
    e.vendor,
    e.description,
    e.payment_method,
    CASE e.is_recurring WHEN 1 THEN 'Yes' ELSE 'No' END AS recurring,
    ROUND(e.amount, 2)                  AS amount_inr
FROM   Expenses e
JOIN   Categories c ON c.category_id = e.category_id
WHERE  e.user_id = 1
ORDER  BY e.expense_date, c.name;

-- ─────────────────────────────────────────────────────────────
--  REPORT 4: Budget vs Actuals Report (all months, User 1)
-- ─────────────────────────────────────────────────────────────
SELECT
    month,
    category_name,
    budget_limit        AS budget_inr,
    actual_spent        AS spent_inr,
    remaining           AS remaining_inr,
    used_pct || '%'     AS utilization,
    budget_status
FROM   vw_BudgetStatus
WHERE  user_id = 1
ORDER  BY month DESC, used_pct DESC;

-- ─────────────────────────────────────────────────────────────
--  REPORT 5: Savings Trend Report (month-over-month)
-- ─────────────────────────────────────────────────────────────
SELECT
    month,
    total_income         AS income_inr,
    total_expense        AS expense_inr,
    net_savings          AS savings_inr,
    savings_rate_pct || '%' AS savings_rate,
    CASE
        WHEN net_savings >= 15000 THEN '🌟 Excellent'
        WHEN net_savings >= 10000 THEN '✅ Good'
        WHEN net_savings >= 5000  THEN '⚠️ Average'
        WHEN net_savings >= 0     THEN '🔶 Low'
        ELSE '🔴 Deficit'
    END                  AS savings_grade
FROM   vw_MonthlyBalance
WHERE  user_id = 1
ORDER  BY month;
