"""
Verification script for Personal Finance Tracker SQL
Reads all .sql files and executes them using Python's built-in sqlite3 module.
"""

import sqlite3
import os

BASE_DIR = r"c:\Users\deepika\Downloads\deepu\sql internship\Task9_PersonalFinanceTracker"

SQL_FILES = [
    "01_schema.sql",
    "02_seed_data.sql",
    "03_views.sql",
]

REPORT_QUERIES = [
    ("Monthly Balance (all users)", """
        SELECT full_name, month, total_income, total_expense, net_savings, savings_rate_pct
        FROM vw_MonthlyBalance
        ORDER BY full_name, month
        LIMIT 20
    """),
    ("Category Expense Summary Sep 2026 - User 1", """
        SELECT month, category_name, icon, total_spent, transaction_count
        FROM vw_CategoryExpenseSummary
        WHERE user_id = 1 AND month = '2026-09'
        ORDER BY total_spent DESC
    """),
    ("Budget Status Sep 2026 - User 1", """
        SELECT category_name, budget_limit, actual_spent, remaining, used_pct, budget_status
        FROM vw_BudgetStatus
        WHERE user_id = 1 AND month = '2026-09'
        ORDER BY used_pct DESC
    """),
    ("Category-wise spending all-time User 1 (GROUP BY)", """
        SELECT c.icon, c.name AS category,
               COUNT(e.expense_id) AS txns,
               ROUND(SUM(e.amount),2) AS total_spent
        FROM Expenses e
        JOIN Categories c ON c.category_id = e.category_id
        WHERE e.user_id = 1
        GROUP BY c.category_id, c.name, c.icon
        ORDER BY total_spent DESC
    """),
    ("Monthly Expense Summary User 1 (GROUP BY month)", """
        SELECT STRFTIME('%Y-%m', expense_date) AS month,
               COUNT(*) AS num_txns,
               ROUND(SUM(amount),2) AS total_expenses
        FROM Expenses WHERE user_id = 1
        GROUP BY STRFTIME('%Y-%m', expense_date)
        ORDER BY month
    """),
    ("Recurring vs One-time expenses User 1", """
        SELECT CASE is_recurring WHEN 1 THEN 'Recurring' ELSE 'One-time' END AS type,
               COUNT(*) AS txns,
               ROUND(SUM(amount),2) AS total
        FROM Expenses WHERE user_id = 1
        GROUP BY is_recurring
    """),
    ("Top Spenders View", """
        SELECT full_name, total_transactions, total_spent, avg_per_transaction
        FROM vw_TopSpenders
    """),
    ("Savings Trend with Grade", """
        SELECT month, total_income, total_expense, net_savings, savings_rate_pct,
               CASE
                   WHEN net_savings >= 15000 THEN 'Excellent'
                   WHEN net_savings >= 10000 THEN 'Good'
                   WHEN net_savings >= 5000  THEN 'Average'
                   WHEN net_savings >= 0     THEN 'Low'
                   ELSE 'Deficit'
               END AS grade
        FROM vw_MonthlyBalance WHERE user_id = 1 ORDER BY month
    """),
]

def print_table(rows, headers):
    if not rows:
        print("  (no results)")
        return
    col_widths = [max(len(str(h)), max(len(str(r[i])) for r in rows))
                  for i, h in enumerate(headers)]
    fmt = "  " + "  ".join(f"{{:<{w}}}" for w in col_widths)
    sep = "  " + "  ".join("-" * w for w in col_widths)
    print(fmt.format(*headers))
    print(sep)
    for row in rows:
        print(fmt.format(*[str(v) if v is not None else "NULL" for v in row]))

def main():
    db_path = os.path.join(BASE_DIR, "finance_tracker.db")
    # Remove old DB if exists
    if os.path.exists(db_path):
        os.remove(db_path)

    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    # Execute setup SQL files
    for fname in SQL_FILES:
        fpath = os.path.join(BASE_DIR, fname)
        print(f"\n{'='*60}")
        print(f"Executing: {fname}")
        print('='*60)
        with open(fpath, 'r', encoding='utf-8') as f:
            sql = f.read()
        try:
            conn.executescript(sql)
            print(f"  ✅ {fname} executed successfully")
        except Exception as ex:
            print(f"  ❌ ERROR in {fname}: {ex}")

    conn.commit()

    # Verify table row counts
    print(f"\n{'='*60}")
    print("TABLE ROW COUNTS")
    print('='*60)
    for table in ["Users", "Categories", "Income", "Expenses", "Budgets"]:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        print(f"  {table:<15} → {count:>4} rows")

    # Run and display report queries
    for title, query in REPORT_QUERIES:
        print(f"\n{'='*60}")
        print(f"📊 REPORT: {title}")
        print('='*60)
        try:
            cursor.execute(query)
            rows = cursor.fetchall()
            headers = [d[0] for d in cursor.description]
            print_table(rows, headers)
        except Exception as ex:
            print(f"  ❌ ERROR: {ex}")

    conn.close()
    print(f"\n{'='*60}")
    print(f"✅ All done! Database saved at: {db_path}")
    print('='*60)

if __name__ == "__main__":
    main()
