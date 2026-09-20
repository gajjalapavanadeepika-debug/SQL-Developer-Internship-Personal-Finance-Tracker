# 💰 Personal Finance Tracker — SQL Database
### Task 9 | SQL Developer Internship | G. Pavana Deepika

---

## 📋 Project Overview

A complete SQL-based personal finance tracking system built with **SQLite** (MySQL-compatible). It tracks income, expenses, budgets, and categories for multiple users, and generates monthly financial reports using views and analytical queries.

---

## 📁 File Structure

```
Task9_PersonalFinanceTracker/
├── 01_schema.sql          ← Database schema (tables + indexes)
├── 02_seed_data.sql       ← Dummy data (users, transactions, budgets)
├── 03_views.sql           ← 6 analytical views
├── 04_queries.sql         ← Budget & analytical queries (GROUP BY etc.)
├── 05_monthly_reports.sql ← Monthly report export queries
├── finance_tracker.db     ← Generated SQLite database (auto-created)
├── verify.py              ← Python verification script
└── README.md              ← This file
```

---

## 🗄️ Database Schema

### Tables

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| **Users** | Registered users | `user_id`, `username`, `full_name`, `email`, `currency` |
| **Categories** | Expense/Income categories | `category_id`, `name`, `type` (EXPENSE/INCOME/BOTH), `icon` |
| **Income** | All income transactions | `income_id`, `user_id`, `category_id`, `amount`, `source`, `received_date` |
| **Expenses** | All expense transactions | `expense_id`, `user_id`, `category_id`, `amount`, `vendor`, `expense_date` |
| **Budgets** | Monthly budget limits per category | `budget_id`, `user_id`, `category_id`, `month` (YYYY-MM), `limit_amount` |

### Entity-Relationship Diagram

```
Users ──< Income    >── Categories
     ──< Expenses   >── Categories
     ──< Budgets    >── Categories
```

### Storage Schema Versioning
Data model follows a versioned pattern. Any future schema changes should:
1. Add a `schema_version` table
2. Increment version on each migration
3. Run `ALTER TABLE` or data migrations accordingly

---

## 🔧 How to Run

### Option A — Python (No installation required)
```bash
python verify.py
```
This automatically creates `finance_tracker.db` and runs all reports.

### Option B — SQLite CLI
```bash
sqlite3 finance_tracker.db < 01_schema.sql
sqlite3 finance_tracker.db < 02_seed_data.sql
sqlite3 finance_tracker.db < 03_views.sql
sqlite3 finance_tracker.db < 04_queries.sql
```

### Option C — MySQL
Replace `AUTOINCREMENT` with `AUTO_INCREMENT` and `STRFTIME('%Y-%m', date)` with `DATE_FORMAT(date, '%Y-%m')`.

### Option D — DB Browser for SQLite (GUI)
1. Download [DB Browser for SQLite](https://sqlitebrowser.org/)
2. Open `finance_tracker.db`
3. Use **Execute SQL** tab to run any `.sql` file

---

## ✨ Features

### ✅ Core Features
- **Multi-user support** — 3 sample users with independent data
- **20 categories** — 13 expense + 7 income, with emoji icons
- **84 expense transactions** spanning Jan–Sep 2026
- **34 income transactions** with recurring salary support
- **21 budget rules** across 3 months

### 📊 Views (03_views.sql)

| View | Description |
|------|-------------|
| `vw_MonthlyBalance` | Income vs Expense vs Net Savings per month |
| `vw_CategoryExpenseSummary` | Category-wise spending per month |
| `vw_BudgetStatus` | Budget limits vs actual spending with traffic-light status |
| `vw_TransactionHistory` | Unified ledger (income + expenses in one view) |
| `vw_TopSpenders` | User ranking by total spending |
| `vw_RecurringTransactions` | All recurring commitments (rent, EMI, subscriptions) |

### 🔍 Queries (04_queries.sql)

**Section A — Monthly Summaries:**
- A1: Monthly income vs expense vs savings (via view)
- A2: Month-by-month expense summary with min/max/avg
- A3: Monthly income by category

**Section B — Category GROUP BY:**
- B1: All-time category spending (count, sum, avg, min, max)
- B2: Category breakdown for a specific month with % of total
- B3: Month-over-month pivot comparing Jul/Aug/Sep 2026

**Section C — Budget Queries:**
- C1: Full budget status for September 2026
- C2: Budget vs actual all months
- C3: Categories that **exceeded** budget
- C4: Overall monthly budget utilization %

**Section D — Advanced Analytics:**
- D1: Payment method preference analysis
- D2: Top 10 most expensive single transactions
- D3: Running cumulative savings (window function)
- D4: Deficit months detection
- D5: Average daily spend per month
- D6: Recurring vs one-time expense breakdown
- D7: Month-over-month category spend change %

### 📄 Reports (05_monthly_reports.sql)
- Report 1: September 2026 full monthly report (header + detail + subtotals + footer)
- Report 2: Year-to-Date (Jan–Sep 2026) financial summary
- Report 3: All-months flat expense table (CSV-exportable)
- Report 4: Budget vs Actuals for all months
- Report 5: Savings trend with grade (Excellent/Good/Average/Low/Deficit)

---

## 📊 Sample Report Output (Sep 2026 — Pavana)

### Income Summary
| Source | Amount (INR) |
|--------|-------------|
| Salary | ₹65,000 |
| Festival Bonus | ₹5,000 |
| **Total** | **₹70,000** |

### Expense Category Breakdown
| Category | Spent | Budget | Status |
|----------|-------|--------|--------|
| 🏠 Housing | ₹12,000 | ₹12,500 | 🟡 WARNING (96%) |
| 🛍️ Shopping | ₹4,200 | ₹3,000 | 🔴 EXCEEDED (140%) |
| 🛒 Groceries | ₹3,300 | ₹3,500 | 🟡 WARNING (94.3%) |
| 💡 Utilities | ₹1,600 | ₹2,000 | 🟢 UNDER (80%) |
| 📱 Subscriptions | ₹1,499 | ₹1,600 | 🟡 WARNING (93.7%) |
| 🍔 Food | ₹650 | ₹1,500 | 🟢 UNDER (43.3%) |
| **Total** | **₹23,249** | | |

### Net Savings: ₹46,751 (66.8% savings rate) — 🌟 Excellent

---

## 🧪 Manual Test Checklist

### Schema & Data
- [ ] Run `01_schema.sql` — no errors, 5 tables + indexes created
- [ ] Run `02_seed_data.sql` — 3 users, 20 categories, 34 income rows, 84 expense rows, 21 budgets
- [ ] Run `03_views.sql` — 6 views created successfully

### Views
- [ ] `SELECT * FROM vw_MonthlyBalance WHERE user_id = 1;` — returns 9 months
- [ ] `SELECT * FROM vw_BudgetStatus WHERE month = '2026-09';` — shows 🔴/🟡/🟢 statuses
- [ ] `SELECT * FROM vw_TransactionHistory LIMIT 10;` — mixed INCOME/EXPENSE rows

### Queries
- [ ] Section B1 query (category GROUP BY) — Housing is highest at ₹1,08,000
- [ ] Section B2 query (Sep 2026 breakdown) — Shopping is 18% of total
- [ ] Section C3 query (exceeded budgets) — Shopping exceeded in Sep 2026
- [ ] Section D3 query (cumulative savings) — window function works correctly
- [ ] Section D6 query (recurring vs one-time) — Recurring: ₹1,36,041 | One-time: ₹94,699

### Reports
- [ ] Report 1 (Sep 2026 monthly report) — 6 expense categories listed
- [ ] Report 5 (savings trend) — all 9 months grade as "Excellent"

---

## 📈 Sample Key Stats (from verify.py)

| Metric | Value |
|--------|-------|
| Total Rows — Expenses | 84 |
| Total Rows — Income | 34 |
| Largest single expense | Travel ₹9,500 (Goa trip) |
| Highest spending month | May 2026 — ₹31,699 |
| Best savings month | June 2026 — 70.7% rate |
| All-time top category | 🏠 Housing — ₹1,08,000 |

---

## 🚀 Future Improvements

1. **MySQL migration** — add stored procedures for recurring transaction auto-generation
2. **Triggers** — auto-update `updatedAt` timestamps on row changes
3. **Full-text search** — add FTS5 virtual table for note/description search
4. **Multi-currency support** — add exchange rate table and convert all amounts
5. **Savings goals** — add a `Goals` table with target amount and target date
6. **Reports as stored views** — parameterized views for any user/month
7. **Python web UI** — Flask dashboard to visualize charts from this database

---

*Task 9 | SQL Developer Internship | G. Pavana Deepika | September 2026*
