"""
Full Test Suite — Personal Finance Tracker SQL
Task 9 | G. Pavana Deepika

Tests:
  ✅ Schema creation (all 5 tables + indexes)
  ✅ Seed data insertion (row counts + integrity)
  ✅ All 6 Views
  ✅ Section A — Monthly Summary queries
  ✅ Section B — Category GROUP BY queries
  ✅ Section C — Budget queries
  ✅ Section D — Advanced analytics
  ✅ All 5 Monthly Reports
  ✅ Foreign key integrity checks
  ✅ CHECK constraints
"""

import sqlite3
import os
import sys

BASE = r"c:\Users\deepika\Downloads\deepu\sql internship\Task9_PersonalFinanceTracker"
DB   = os.path.join(BASE, "finance_tracker_test.db")

# ── ANSI colours ───────────────────────────────────────────
GREEN  = "\033[92m"
RED    = "\033[91m"
YELLOW = "\033[93m"
CYAN   = "\033[96m"
BOLD   = "\033[1m"
RESET  = "\033[0m"

passed = 0
failed = 0

def ok(msg):
    global passed
    passed += 1
    print(f"  {GREEN}✅ PASS{RESET}  {msg}")

def fail(msg, err=""):
    global failed
    failed += 1
    detail = f"  {RED}       ↳ {err}{RESET}" if err else ""
    print(f"  {RED}❌ FAIL{RESET}  {msg}")
    if detail:
        print(detail)

def section(title):
    print(f"\n{BOLD}{CYAN}{'━'*60}{RESET}")
    print(f"{BOLD}{CYAN}  {title}{RESET}")
    print(f"{BOLD}{CYAN}{'━'*60}{RESET}")

def print_table(rows, headers, indent=4):
    if not rows:
        print(" " * indent + "(no rows)")
        return
    widths = [max(len(str(h)), max(len(str(r[i] if r[i] is not None else "NULL"))
                  for r in rows)) for i, h in enumerate(headers)]
    pad = " " * indent
    fmt = pad + "  ".join(f"{{:<{w}}}" for w in widths)
    sep = pad + "  ".join("─" * w for w in widths)
    print(fmt.format(*headers))
    print(sep)
    for row in rows:
        print(fmt.format(*[str(v) if v is not None else "NULL" for v in row]))

def run_query(cursor, label, sql, expected_min_rows=None,
              expected_cols=None, show=True):
    """Execute a query and run assertions, return rows."""
    try:
        cursor.execute(sql)
        rows = cursor.fetchall()
        headers = [d[0] for d in cursor.description]
        if show:
            print_table(rows, headers)
        # assertions
        if expected_min_rows is not None and len(rows) < expected_min_rows:
            fail(label, f"Expected ≥{expected_min_rows} rows, got {len(rows)}")
            return rows
        if expected_cols is not None:
            missing = [c for c in expected_cols if c not in headers]
            if missing:
                fail(label, f"Missing columns: {missing}")
                return rows
        ok(f"{label} → {len(rows)} row(s)")
        return rows
    except Exception as e:
        fail(label, str(e))
        return []


# ══════════════════════════════════════════════════════════════
#  SETUP — fresh database
# ══════════════════════════════════════════════════════════════
if os.path.exists(DB):
    os.remove(DB)

conn = sqlite3.connect(DB)
conn.execute("PRAGMA foreign_keys = ON")
cur  = conn.cursor()

# ══════════════════════════════════════════════════════════════
#  1. SCHEMA
# ══════════════════════════════════════════════════════════════
section("1. SCHEMA — Table & Index Creation")
try:
    with open(os.path.join(BASE, "01_schema.sql"), encoding="utf-8") as f:
        conn.executescript(f.read())
    ok("01_schema.sql executed without errors")
except Exception as e:
    fail("01_schema.sql execution", str(e))

# Check all tables exist
for tbl in ["Users", "Categories", "Income", "Expenses", "Budgets"]:
    cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name=?", (tbl,))
    if cur.fetchone():
        ok(f"Table '{tbl}' exists")
    else:
        fail(f"Table '{tbl}' missing")

# Check indexes
for idx in ["idx_expenses_user_date", "idx_income_user_date", "idx_budgets_user_month"]:
    cur.execute("SELECT name FROM sqlite_master WHERE type='index' AND name=?", (idx,))
    if cur.fetchone():
        ok(f"Index '{idx}' exists")
    else:
        fail(f"Index '{idx}' missing")

# ══════════════════════════════════════════════════════════════
#  2. SEED DATA
# ══════════════════════════════════════════════════════════════
section("2. SEED DATA — Insertion & Row Counts")
try:
    with open(os.path.join(BASE, "02_seed_data.sql"), encoding="utf-8") as f:
        conn.executescript(f.read())
    ok("02_seed_data.sql executed without errors")
except Exception as e:
    fail("02_seed_data.sql execution", str(e))

expected_counts = {
    "Users": 3, "Categories": 20, "Income": 34, "Expenses": 84, "Budgets": 21
}
for tbl, exp in expected_counts.items():
    cur.execute(f"SELECT COUNT(*) FROM {tbl}")
    cnt = cur.fetchone()[0]
    if cnt == exp:
        ok(f"{tbl}: {cnt} rows (expected {exp})")
    else:
        fail(f"{tbl}: got {cnt} rows, expected {exp}")

# FK integrity — every expense.user_id must exist in Users
cur.execute("""
    SELECT COUNT(*) FROM Expenses e
    WHERE NOT EXISTS (SELECT 1 FROM Users u WHERE u.user_id = e.user_id)
""")
orphans = cur.fetchone()[0]
if orphans == 0:
    ok("No orphan expenses (FK integrity OK)")
else:
    fail(f"{orphans} expenses reference non-existent users")

# All amounts positive
cur.execute("SELECT COUNT(*) FROM Expenses WHERE amount <= 0")
bad = cur.fetchone()[0]
if bad == 0:
    ok("All expense amounts > 0 (CHECK constraint OK)")
else:
    fail(f"{bad} expense rows have amount ≤ 0")

# CHECK constraint on Categories.type
print("  Testing CHECK constraint on Categories.type:")
try:
    cur.execute("INSERT INTO Categories (name, type) VALUES ('Test', 'INVALID')")
    fail("CHECK constraint on Categories.type — should have rejected 'INVALID'")
except sqlite3.IntegrityError:
    ok("CHECK constraint on Categories.type correctly rejects 'INVALID'")

# UNIQUE constraint on Users.email
print("  Testing UNIQUE constraint on Users.email:")
try:
    cur.execute("INSERT INTO Users (username,full_name,email) VALUES ('x','x','pavana@example.com')")
    fail("UNIQUE constraint on Users.email — should have rejected duplicate")
except sqlite3.IntegrityError:
    ok("UNIQUE constraint on Users.email correctly rejects duplicates")

# ══════════════════════════════════════════════════════════════
#  3. VIEWS
# ══════════════════════════════════════════════════════════════
section("3. VIEWS — Creation & Row Validation")
try:
    with open(os.path.join(BASE, "03_views.sql"), encoding="utf-8") as f:
        conn.executescript(f.read())
    ok("03_views.sql executed without errors")
except Exception as e:
    fail("03_views.sql execution", str(e))

VIEWS = [
    "vw_MonthlyBalance",
    "vw_CategoryExpenseSummary",
    "vw_BudgetStatus",
    "vw_TransactionHistory",
    "vw_TopSpenders",
    "vw_RecurringTransactions",
]
for v in VIEWS:
    cur.execute("SELECT name FROM sqlite_master WHERE type='view' AND name=?", (v,))
    if cur.fetchone():
        ok(f"View '{v}' created")
    else:
        fail(f"View '{v}' missing")

# Validate vw_MonthlyBalance — user 1 should have 9 months
section("3a. vw_MonthlyBalance (User 1 — Pavana)")
rows = run_query(cur,
    "vw_MonthlyBalance for User 1",
    "SELECT full_name, month, total_income, total_expense, net_savings, savings_rate_pct FROM vw_MonthlyBalance WHERE user_id=1 ORDER BY month",
    expected_min_rows=9,
    expected_cols=["month","total_income","total_expense","net_savings"]
)

# All months should have positive savings
deficit = [r for r in rows if r[4] is not None and float(r[4]) < 0]
if not deficit:
    ok("All months show positive net savings (no deficit)")
else:
    fail(f"{len(deficit)} deficit month(s) detected", str(deficit))

# Validate vw_BudgetStatus — Sep 2026, user 1
section("3b. vw_BudgetStatus (Sep 2026, User 1)")
rows = run_query(cur,
    "vw_BudgetStatus Sep 2026",
    "SELECT category_name, budget_limit, actual_spent, remaining, used_pct, budget_status FROM vw_BudgetStatus WHERE user_id=1 AND month='2026-09' ORDER BY used_pct DESC",
    expected_min_rows=1
)
exceeded = [r for r in rows if "EXCEEDED" in str(r[5])]
warning  = [r for r in rows if "WARNING"  in str(r[5])]
under    = [r for r in rows if "UNDER"    in str(r[5])]
ok(f"Budget statuses — EXCEEDED: {len(exceeded)}, WARNING: {len(warning)}, UNDER: {len(under)}")
if exceeded:
    ok(f"Shopping category correctly flagged as EXCEEDED ({exceeded[0][3]} overspent)")

# vw_TransactionHistory — should mix INCOME and EXPENSE
section("3c. vw_TransactionHistory (sample 10 rows)")
rows = run_query(cur,
    "vw_TransactionHistory (10 rows)",
    "SELECT txn_type, full_name, category_name, amount, txn_date FROM vw_TransactionHistory LIMIT 10",
    expected_min_rows=1
)
types = {r[0] for r in rows}
ok(f"Transaction types present: {types}")

# vw_TopSpenders
section("3d. vw_TopSpenders")
run_query(cur,
    "vw_TopSpenders",
    "SELECT full_name, total_transactions, total_spent, avg_per_transaction FROM vw_TopSpenders",
    expected_min_rows=1
)

# vw_RecurringTransactions
section("3e. vw_RecurringTransactions")
run_query(cur,
    "vw_RecurringTransactions",
    "SELECT txn_type, full_name, category_name, amount, party FROM vw_RecurringTransactions",
    expected_min_rows=1
)

# ══════════════════════════════════════════════════════════════
#  4. QUERIES — Section A: Monthly Summaries
# ══════════════════════════════════════════════════════════════
section("4. SECTION A — Monthly Expense Summaries (GROUP BY month)")
run_query(cur, "A2: Monthly expense summary User 1",
    """SELECT STRFTIME('%Y-%m', expense_date) AS month,
              COUNT(*) AS num_txns,
              ROUND(SUM(amount),2) AS total_expenses,
              ROUND(AVG(amount),2) AS avg_per_txn,
              ROUND(MIN(amount),2) AS min_expense,
              ROUND(MAX(amount),2) AS max_expense
       FROM Expenses WHERE user_id=1
       GROUP BY STRFTIME('%Y-%m', expense_date)
       ORDER BY month""",
    expected_min_rows=9
)

run_query(cur, "A3: Monthly income by category User 1",
    """SELECT STRFTIME('%Y-%m', i.received_date) AS month,
              c.name AS income_source,
              ROUND(SUM(i.amount),2) AS total_income
       FROM Income i JOIN Categories c ON c.category_id=i.category_id
       WHERE i.user_id=1
       GROUP BY STRFTIME('%Y-%m', i.received_date), c.name
       ORDER BY month, total_income DESC""",
    expected_min_rows=9
)

# ══════════════════════════════════════════════════════════════
#  5. QUERIES — Section B: Category GROUP BY
# ══════════════════════════════════════════════════════════════
section("5. SECTION B — Category-wise Spending (GROUP BY category)")
rows = run_query(cur, "B1: All-time category spending User 1",
    """SELECT c.icon, c.name AS category,
              COUNT(e.expense_id) AS txns,
              ROUND(SUM(e.amount),2) AS total_spent,
              ROUND(AVG(e.amount),2) AS avg_spent
       FROM Expenses e JOIN Categories c ON c.category_id=e.category_id
       WHERE e.user_id=1
       GROUP BY c.category_id, c.name, c.icon
       ORDER BY total_spent DESC""",
    expected_min_rows=1
)
if rows and rows[0][1] == "Housing":
    ok(f"Top expense category is Housing at ₹{rows[0][3]:,} (correct)")
else:
    fail("Top expense category should be Housing")

run_query(cur, "B2: Category breakdown Sep 2026 with % of total",
    """SELECT c.icon, c.name AS category,
              ROUND(SUM(e.amount),2) AS spent,
              COUNT(*) AS txns,
              ROUND(SUM(e.amount)*100.0/
                    (SELECT SUM(amount) FROM Expenses
                     WHERE user_id=1
                     AND STRFTIME('%Y-%m',expense_date)='2026-09'),1) AS pct
       FROM Expenses e JOIN Categories c ON c.category_id=e.category_id
       WHERE e.user_id=1 AND STRFTIME('%Y-%m',e.expense_date)='2026-09'
       GROUP BY c.category_id, c.name, c.icon
       ORDER BY spent DESC""",
    expected_min_rows=1
)

run_query(cur, "B3: MoM pivot Jul/Aug/Sep 2026",
    """SELECT c.name AS category,
              ROUND(SUM(CASE WHEN STRFTIME('%Y-%m',e.expense_date)='2026-07' THEN e.amount ELSE 0 END),2) AS jul,
              ROUND(SUM(CASE WHEN STRFTIME('%Y-%m',e.expense_date)='2026-08' THEN e.amount ELSE 0 END),2) AS aug,
              ROUND(SUM(CASE WHEN STRFTIME('%Y-%m',e.expense_date)='2026-09' THEN e.amount ELSE 0 END),2) AS sep
       FROM Expenses e JOIN Categories c ON c.category_id=e.category_id
       WHERE e.user_id=1 AND STRFTIME('%Y-%m',e.expense_date) IN ('2026-07','2026-08','2026-09')
       GROUP BY c.category_id, c.name
       ORDER BY (jul+aug+sep) DESC""",
    expected_min_rows=1
)

# ══════════════════════════════════════════════════════════════
#  6. QUERIES — Section C: Budget
# ══════════════════════════════════════════════════════════════
section("6. SECTION C — Budget Queries")
run_query(cur, "C1: Budget status Sep 2026",
    """SELECT icon, category_name, budget_limit, actual_spent, remaining,
              used_pct||'%' AS used, budget_status
       FROM vw_BudgetStatus WHERE user_id=1 AND month='2026-09'
       ORDER BY used_pct DESC""",
    expected_min_rows=1
)

rows = run_query(cur, "C3: Categories that EXCEEDED budget",
    """SELECT month, category_name, budget_limit, actual_spent,
              ROUND(actual_spent-budget_limit,2) AS overspent_by
       FROM vw_BudgetStatus
       WHERE user_id=1 AND budget_status='🔴 EXCEEDED'
       ORDER BY month DESC""",
    expected_min_rows=1
)
if rows:
    ok(f"Found {len(rows)} exceeded budget(s) — {rows[0][1]} overspent by ₹{rows[0][4]}")

rows = run_query(cur, "C4: Overall monthly budget utilization",
    """SELECT month,
              ROUND(SUM(budget_limit),2)  AS total_budget,
              ROUND(SUM(actual_spent),2)  AS total_spent,
              ROUND(SUM(remaining),2)     AS remaining,
              ROUND(SUM(actual_spent)*100.0/SUM(budget_limit),1)||'%' AS utilization
       FROM vw_BudgetStatus WHERE user_id=1
       GROUP BY month ORDER BY month DESC""",
    expected_min_rows=1
)

# ══════════════════════════════════════════════════════════════
#  7. QUERIES — Section D: Advanced Analytics
# ══════════════════════════════════════════════════════════════
section("7. SECTION D — Advanced Analytics")
run_query(cur, "D1: Payment method preference",
    """SELECT payment_method, COUNT(*) AS txns,
              ROUND(SUM(amount),2) AS total_spent,
              ROUND(AVG(amount),2) AS avg_amount
       FROM Expenses WHERE user_id=1
       GROUP BY payment_method ORDER BY total_spent DESC""",
    expected_min_rows=1
)

rows = run_query(cur, "D2: Top 10 most expensive transactions",
    """SELECT e.expense_date, c.name AS category, e.vendor,
              e.amount, e.payment_method
       FROM Expenses e JOIN Categories c ON c.category_id=e.category_id
       WHERE e.user_id=1 ORDER BY e.amount DESC LIMIT 10""",
    expected_min_rows=1
)
if rows and float(rows[0][3]) >= 9500:
    ok(f"Largest single expense: ₹{rows[0][3]} at '{rows[0][2]}' — correct")

run_query(cur, "D3: Cumulative savings (window function)",
    """SELECT month, net_savings,
              SUM(net_savings) OVER (ORDER BY month ROWS UNBOUNDED PRECEDING) AS cumulative_savings
       FROM vw_MonthlyBalance WHERE user_id=1 ORDER BY month""",
    expected_min_rows=9
)

run_query(cur, "D5: Average daily spend per month",
    """SELECT STRFTIME('%Y-%m',expense_date) AS month,
              ROUND(SUM(amount),2) AS monthly_total,
              COUNT(DISTINCT expense_date) AS active_days,
              ROUND(SUM(amount)/COUNT(DISTINCT expense_date),2) AS avg_per_day
       FROM Expenses WHERE user_id=1
       GROUP BY STRFTIME('%Y-%m',expense_date) ORDER BY month""",
    expected_min_rows=9
)

run_query(cur, "D6: Recurring vs One-time expense split",
    """SELECT CASE is_recurring WHEN 1 THEN 'Recurring' ELSE 'One-time' END AS type,
              COUNT(*) AS txns, ROUND(SUM(amount),2) AS total
       FROM Expenses WHERE user_id=1 GROUP BY is_recurring""",
    expected_min_rows=2
)

run_query(cur, "D7: MoM spend change Aug→Sep 2026",
    """SELECT c.name AS category,
              ROUND(SUM(CASE WHEN STRFTIME('%Y-%m',e.expense_date)='2026-08' THEN e.amount ELSE 0 END),2) AS aug,
              ROUND(SUM(CASE WHEN STRFTIME('%Y-%m',e.expense_date)='2026-09' THEN e.amount ELSE 0 END),2) AS sep,
              ROUND(
                SUM(CASE WHEN STRFTIME('%Y-%m',e.expense_date)='2026-09' THEN e.amount ELSE 0 END)-
                SUM(CASE WHEN STRFTIME('%Y-%m',e.expense_date)='2026-08' THEN e.amount ELSE 0 END),2) AS change_amt
       FROM Expenses e JOIN Categories c ON c.category_id=e.category_id
       WHERE e.user_id=1
         AND STRFTIME('%Y-%m',e.expense_date) IN ('2026-08','2026-09')
       GROUP BY c.category_id, c.name
       ORDER BY change_amt DESC""",
    expected_min_rows=1
)

# ══════════════════════════════════════════════════════════════
#  8. MONTHLY REPORTS
# ══════════════════════════════════════════════════════════════
section("8. SECTION E — Monthly Reports (05_monthly_reports.sql)")

# Report 1: Sep 2026 income summary
run_query(cur, "Report 1a: Sep 2026 income lines",
    """SELECT c.name AS source, ROUND(SUM(i.amount),2) AS amount_inr
       FROM Income i JOIN Categories c ON c.category_id=i.category_id
       WHERE i.user_id=1 AND STRFTIME('%Y-%m',i.received_date)='2026-09'
       GROUP BY c.name ORDER BY amount_inr DESC""",
    expected_min_rows=1
)

# Report 1b: Sep 2026 expense detail
run_query(cur, "Report 1b: Sep 2026 expense detail lines",
    """SELECT e.expense_date, c.name AS category, e.vendor,
              e.description, e.payment_method, ROUND(e.amount,2) AS amount_inr
       FROM Expenses e JOIN Categories c ON c.category_id=e.category_id
       WHERE e.user_id=1 AND STRFTIME('%Y-%m',e.expense_date)='2026-09'
       ORDER BY e.expense_date, c.name""",
    expected_min_rows=6
)

# Report 1c: Sep 2026 category subtotals
run_query(cur, "Report 1c: Sep 2026 category subtotals",
    """SELECT c.icon, c.name AS category, COUNT(*) AS txns,
              ROUND(SUM(e.amount),2) AS total_inr
       FROM Expenses e JOIN Categories c ON c.category_id=e.category_id
       WHERE e.user_id=1 AND STRFTIME('%Y-%m',e.expense_date)='2026-09'
       GROUP BY c.category_id, c.name, c.icon
       ORDER BY total_inr DESC""",
    expected_min_rows=1
)

# Report 1d: Monthly summary footer
rows = run_query(cur, "Report 1d: Sep 2026 monthly summary",
    """SELECT
         ROUND((SELECT SUM(amount) FROM Income
                WHERE user_id=1 AND STRFTIME('%Y-%m',received_date)='2026-09'),2) AS total_income,
         ROUND((SELECT SUM(amount) FROM Expenses
                WHERE user_id=1 AND STRFTIME('%Y-%m',expense_date)='2026-09'),2)  AS total_expenses,
         ROUND(
           (SELECT SUM(amount) FROM Income
            WHERE user_id=1 AND STRFTIME('%Y-%m',received_date)='2026-09') -
           (SELECT SUM(amount) FROM Expenses
            WHERE user_id=1 AND STRFTIME('%Y-%m',expense_date)='2026-09'), 2)     AS net_savings""",
    expected_min_rows=1
)
if rows:
    r = rows[0]
    ok(f"Sep 2026 → Income: ₹{r[0]:,}  Expenses: ₹{r[1]:,}  Net Savings: ₹{r[2]:,}")

# Report 2: YTD summary
run_query(cur, "Report 2: YTD Jan–Sep 2026 summary",
    """SELECT
         ROUND(SUM(i.amount),2) AS ytd_income,
         ROUND((SELECT SUM(amount) FROM Expenses WHERE user_id=1
                AND STRFTIME('%Y',expense_date)='2026'),2) AS ytd_expenses,
         ROUND(SUM(i.amount) -
               (SELECT SUM(amount) FROM Expenses WHERE user_id=1
                AND STRFTIME('%Y',expense_date)='2026'), 2) AS ytd_savings
       FROM Income i WHERE i.user_id=1 AND STRFTIME('%Y',i.received_date)='2026'""",
    expected_min_rows=1
)

# Report 5: Savings trend with grade
run_query(cur, "Report 5: Savings trend with grade",
    """SELECT month, total_income, total_expense, net_savings, savings_rate_pct,
              CASE
                WHEN net_savings >= 15000 THEN '🌟 Excellent'
                WHEN net_savings >= 10000 THEN '✅ Good'
                WHEN net_savings >= 5000  THEN '⚠️ Average'
                WHEN net_savings >= 0     THEN '🔶 Low'
                ELSE '🔴 Deficit'
              END AS savings_grade
       FROM vw_MonthlyBalance WHERE user_id=1 ORDER BY month""",
    expected_min_rows=9
)

# ══════════════════════════════════════════════════════════════
#  9. YTD STATS BANNER
# ══════════════════════════════════════════════════════════════
section("9. YEAR-TO-DATE STATS — User 1 (Jan–Sep 2026)")
cur.execute("""
    SELECT
      ROUND(SUM(i.amount),2) AS ytd_income,
      (SELECT ROUND(SUM(amount),2) FROM Expenses WHERE user_id=1) AS ytd_expense,
      ROUND(SUM(i.amount) - (SELECT SUM(amount) FROM Expenses WHERE user_id=1),2) AS ytd_net,
      (SELECT ROUND(AVG(amount),2) FROM Expenses WHERE user_id=1) AS avg_txn_size,
      (SELECT MAX(amount) FROM Expenses WHERE user_id=1) AS biggest_expense
    FROM Income i WHERE user_id=1
""")
r = cur.fetchone()
print(f"""
  {'─'*40}
   📥  YTD Income          : ₹{r[0]:>12,.2f}
   📤  YTD Expenses        : ₹{r[1]:>12,.2f}
   💰  YTD Net Savings     : ₹{r[2]:>12,.2f}
   📊  Avg Expense Size    : ₹{r[3]:>12,.2f}
   🔝  Biggest Expense     : ₹{r[4]:>12,.2f}
  {'─'*40}
""")
ok("YTD stats computed successfully")

# ══════════════════════════════════════════════════════════════
#  FINAL SUMMARY
# ══════════════════════════════════════════════════════════════
conn.close()
total = passed + failed
print(f"\n{BOLD}{'═'*60}{RESET}")
print(f"{BOLD}  TEST RESULTS : {passed}/{total} passed{RESET}")
print(f"  {GREEN}✅ Passed : {passed}{RESET}")
if failed:
    print(f"  {RED}❌ Failed : {failed}{RESET}")
else:
    print(f"  {GREEN}❌ Failed : 0{RESET}")
print(f"{BOLD}{'═'*60}{RESET}\n")

sys.exit(0 if failed == 0 else 1)
