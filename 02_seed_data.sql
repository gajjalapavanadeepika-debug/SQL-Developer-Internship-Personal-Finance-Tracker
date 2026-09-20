-- ============================================================
--  PERSONAL FINANCE TRACKER — SEED DATA
--  Task 9 | SQL Developer Internship | G. Pavana Deepika
--  Run AFTER 01_schema.sql
-- ============================================================

-- ============================================================
-- USERS  (3 sample users)
-- ============================================================
INSERT INTO Users (username, full_name, email, currency, created_at) VALUES
  ('pavana_d',  'G. Pavana Deepika',  'pavana@example.com',  'INR', '2025-01-01'),
  ('rahul_m',   'Rahul Mehta',        'rahul@example.com',   'INR', '2025-02-15'),
  ('sneha_p',   'Sneha Patil',        'sneha@example.com',   'INR', '2025-03-01');

-- ============================================================
-- CATEGORIES  (global + per-user)
-- ============================================================
-- Global EXPENSE categories
INSERT INTO Categories (user_id, name, type, icon, color_hex) VALUES
  (NULL, 'Housing',        'EXPENSE', '🏠', '#FF6B6B'),
  (NULL, 'Food & Dining',  'EXPENSE', '🍔', '#FF9F43'),
  (NULL, 'Groceries',      'EXPENSE', '🛒', '#FFC312'),
  (NULL, 'Transportation', 'EXPENSE', '🚗', '#5F27CD'),
  (NULL, 'Utilities',      'EXPENSE', '💡', '#00D2D3'),
  (NULL, 'Healthcare',     'EXPENSE', '🏥', '#FF6B6B'),
  (NULL, 'Education',      'EXPENSE', '📚', '#48DBFB'),
  (NULL, 'Entertainment',  'EXPENSE', '🎬', '#FF9FF3'),
  (NULL, 'Shopping',       'EXPENSE', '🛍️', '#54A0FF'),
  (NULL, 'EMI / Loans',    'EXPENSE', '🏦', '#C4E538'),
  (NULL, 'Subscriptions',  'EXPENSE', '📱', '#B2BABB'),
  (NULL, 'Travel',         'EXPENSE', '✈️', '#6AB04C'),
  (NULL, 'Miscellaneous',  'EXPENSE', '🔖', '#BDC3C7');

-- Global INCOME categories
INSERT INTO Categories (user_id, name, type, icon, color_hex) VALUES
  (NULL, 'Salary',          'INCOME', '💼', '#2ECC71'),
  (NULL, 'Freelance',       'INCOME', '💻', '#3498DB'),
  (NULL, 'Investments',     'INCOME', '📈', '#8E44AD'),
  (NULL, 'Rental Income',   'INCOME', '🏘️', '#E67E22'),
  (NULL, 'Business',        'INCOME', '🏢', '#1ABC9C'),
  (NULL, 'Gifts / Bonus',   'INCOME', '🎁', '#F39C12'),
  (NULL, 'Other Income',    'INCOME', '💵', '#95A5A6');

-- ============================================================
-- Helper: category_id reference chart
-- ============================================================
-- EXPENSE IDs:
--  1-Housing, 2-Food, 3-Groceries, 4-Transport, 5-Utilities
--  6-Healthcare, 7-Education, 8-Entertainment, 9-Shopping
--  10-EMI/Loans, 11-Subscriptions, 12-Travel, 13-Misc
-- INCOME IDs:
--  14-Salary, 15-Freelance, 16-Investments, 17-Rental
--  18-Business, 19-Gifts/Bonus, 20-Other Income

-- ============================================================
-- INCOME DATA — User 1 (Pavana) | Jan–Sep 2026
-- ============================================================
INSERT INTO Income (user_id, category_id, amount, source, description, received_date, payment_method, is_recurring) VALUES
-- January 2026
  (1, 14, 65000.00, 'TechCorp Pvt Ltd', 'January salary',        '2026-01-01', 'Bank Transfer', 1),
  (1, 15, 12000.00, 'Upwork Client',    'UI design project',     '2026-01-15', 'Bank Transfer', 0),
-- February 2026
  (1, 14, 65000.00, 'TechCorp Pvt Ltd', 'February salary',       '2026-02-01', 'Bank Transfer', 1),
-- March 2026
  (1, 14, 65000.00, 'TechCorp Pvt Ltd', 'March salary',          '2026-03-01', 'Bank Transfer', 1),
  (1, 19,  8000.00, 'Annual Bonus',     'Q1 performance bonus',  '2026-03-31', 'Bank Transfer', 0),
-- April 2026
  (1, 14, 65000.00, 'TechCorp Pvt Ltd', 'April salary',          '2026-04-01', 'Bank Transfer', 1),
  (1, 15, 15000.00, 'Fiverr Client',    'App mockup design',     '2026-04-20', 'Bank Transfer', 0),
-- May 2026
  (1, 14, 65000.00, 'TechCorp Pvt Ltd', 'May salary',            '2026-05-01', 'Bank Transfer', 1),
-- June 2026
  (1, 14, 65000.00, 'TechCorp Pvt Ltd', 'June salary',           '2026-06-01', 'Bank Transfer', 1),
  (1, 16,  5500.00, 'Zerodha MF',       'Mutual fund dividend',  '2026-06-15', 'Bank Transfer', 0),
-- July 2026
  (1, 14, 65000.00, 'TechCorp Pvt Ltd', 'July salary',           '2026-07-01', 'Bank Transfer', 1),
  (1, 15, 18000.00, 'Toptal Project',   'Backend consulting',    '2026-07-22', 'Bank Transfer', 0),
-- August 2026
  (1, 14, 65000.00, 'TechCorp Pvt Ltd', 'August salary',         '2026-08-01', 'Bank Transfer', 1),
  (1, 16,  7200.00, 'Zerodha MF',       'Stock dividend',        '2026-08-10', 'Bank Transfer', 0),
-- September 2026
  (1, 14, 65000.00, 'TechCorp Pvt Ltd', 'September salary',      '2026-09-01', 'Bank Transfer', 1),
  (1, 19,  5000.00, 'Festival Bonus',   'Onam bonus',            '2026-09-05', 'Bank Transfer', 0);

-- ============================================================
-- INCOME DATA — User 2 (Rahul) | Jan–Sep 2026
-- ============================================================
INSERT INTO Income (user_id, category_id, amount, source, description, received_date, payment_method, is_recurring) VALUES
  (2, 14, 80000.00, 'FinBank Ltd',      'January salary',        '2026-01-01', 'Bank Transfer', 1),
  (2, 17, 15000.00, 'Tenant A',         'Flat rent Jan',         '2026-01-05', 'Bank Transfer', 1),
  (2, 14, 80000.00, 'FinBank Ltd',      'February salary',       '2026-02-01', 'Bank Transfer', 1),
  (2, 17, 15000.00, 'Tenant A',         'Flat rent Feb',         '2026-02-05', 'Bank Transfer', 1),
  (2, 14, 80000.00, 'FinBank Ltd',      'March salary',          '2026-03-01', 'Bank Transfer', 1),
  (2, 17, 15000.00, 'Tenant A',         'Flat rent Mar',         '2026-03-05', 'Bank Transfer', 1),
  (2, 14, 80000.00, 'FinBank Ltd',      'April salary',          '2026-04-01', 'Bank Transfer', 1),
  (2, 17, 15000.00, 'Tenant A',         'Flat rent Apr',         '2026-04-05', 'Bank Transfer', 1),
  (2, 14, 80000.00, 'FinBank Ltd',      'May salary',            '2026-05-01', 'Bank Transfer', 1),
  (2, 17, 15000.00, 'Tenant A',         'Flat rent May',         '2026-05-05', 'Bank Transfer', 1),
  (2, 14, 80000.00, 'FinBank Ltd',      'June salary',           '2026-06-01', 'Bank Transfer', 1),
  (2, 17, 15000.00, 'Tenant A',         'Flat rent Jun',         '2026-06-05', 'Bank Transfer', 1),
  (2, 14, 80000.00, 'FinBank Ltd',      'July salary',           '2026-07-01', 'Bank Transfer', 1),
  (2, 17, 15000.00, 'Tenant A',         'Flat rent Jul',         '2026-07-05', 'Bank Transfer', 1),
  (2, 14, 80000.00, 'FinBank Ltd',      'August salary',         '2026-08-01', 'Bank Transfer', 1),
  (2, 17, 15000.00, 'Tenant A',         'Flat rent Aug',         '2026-08-05', 'Bank Transfer', 1),
  (2, 14, 80000.00, 'FinBank Ltd',      'September salary',      '2026-09-01', 'Bank Transfer', 1),
  (2, 17, 15000.00, 'Tenant A',         'Flat rent Sep',         '2026-09-05', 'Bank Transfer', 1);

-- ============================================================
-- EXPENSE DATA — User 1 (Pavana) | Jan–Sep 2026
-- ============================================================
INSERT INTO Expenses (user_id, category_id, amount, vendor, description, expense_date, payment_method, is_recurring) VALUES
-- ===== JANUARY 2026 =====
  (1,  1, 12000.00, 'Landlord',          'House rent Jan',          '2026-01-01', 'Net Banking', 1),
  (1,  2,   850.00, 'Zomato',            'Lunch order',             '2026-01-05', 'UPI',         0),
  (1,  3,  3200.00, 'D-Mart',            'Monthly groceries',       '2026-01-07', 'Debit Card',  0),
  (1,  4,   650.00, 'Ola / Metro',       'Commute Jan week1',       '2026-01-08', 'UPI',         0),
  (1,  5,  1500.00, 'BESCOM',            'Electricity bill Jan',    '2026-01-10', 'Net Banking', 1),
  (1,  2,   550.00, 'Swiggy',            'Dinner order',            '2026-01-14', 'UPI',         0),
  (1,  8,   999.00, 'BookMyShow',        'Movie tickets',           '2026-01-18', 'Credit Card', 0),
  (1, 11,  1499.00, 'Netflix + Spotify', 'Streaming subs Jan',      '2026-01-20', 'Credit Card', 1),
  (1,  4,   700.00, 'Ola',               'Weekend travel',          '2026-01-24', 'UPI',         0),
  (1,  3,  1800.00, 'Big Bazaar',        'Snacks & personal care',  '2026-01-28', 'Debit Card',  0),
-- ===== FEBRUARY 2026 =====
  (1,  1, 12000.00, 'Landlord',          'House rent Feb',          '2026-02-01', 'Net Banking', 1),
  (1,  5,  1600.00, 'BESCOM',            'Electricity bill Feb',    '2026-02-05', 'Net Banking', 1),
  (1,  3,  3500.00, 'D-Mart',            'Monthly groceries Feb',   '2026-02-06', 'Debit Card',  0),
  (1,  2,  1200.00, 'Zomato',            'Valentine dinner',        '2026-02-14', 'Credit Card', 0),
  (1, 11,  1499.00, 'Netflix + Spotify', 'Streaming subs Feb',      '2026-02-20', 'Credit Card', 1),
  (1,  9,  3200.00, 'Myntra',            'Winter clothing sale',    '2026-02-22', 'Credit Card', 0),
  (1,  4,   800.00, 'Metro + Ola',       'Commute Feb',             '2026-02-25', 'UPI',         0),
-- ===== MARCH 2026 =====
  (1,  1, 12000.00, 'Landlord',          'House rent Mar',          '2026-03-01', 'Net Banking', 1),
  (1,  5,  1400.00, 'BESCOM',            'Electricity bill Mar',    '2026-03-05', 'Net Banking', 1),
  (1,  3,  3100.00, 'D-Mart',            'Monthly groceries Mar',   '2026-03-07', 'Debit Card',  0),
  (1,  7,  8500.00, 'Udemy / Coursera',  'SQL + Data Sci courses',  '2026-03-10', 'Credit Card', 0),
  (1,  2,   750.00, 'Swiggy',            'Weekend food orders',     '2026-03-15', 'UPI',         0),
  (1, 11,  1499.00, 'Netflix + Spotify', 'Streaming subs Mar',      '2026-03-20', 'Credit Card', 1),
  (1,  8,  1500.00, 'PVR',               'Holi movie outing',       '2026-03-25', 'Cash',        0),
-- ===== APRIL 2026 =====
  (1,  1, 12000.00, 'Landlord',          'House rent Apr',          '2026-04-01', 'Net Banking', 1),
  (1,  5,  1550.00, 'BESCOM',            'Electricity bill Apr',    '2026-04-05', 'Net Banking', 1),
  (1,  3,  3300.00, 'D-Mart',            'Monthly groceries Apr',   '2026-04-07', 'Debit Card',  0),
  (1,  4,  2500.00, 'Indian Railways',   'Weekend trip tickets',    '2026-04-12', 'Net Banking', 0),
  (1,  2,  1050.00, 'Zomato',            'Team lunch',              '2026-04-17', 'UPI',         0),
  (1, 11,  1499.00, 'Netflix + Spotify', 'Streaming subs Apr',      '2026-04-20', 'Credit Card', 1),
  (1,  9,  5500.00, 'Amazon',            'New headphones',          '2026-04-25', 'Credit Card', 0),
-- ===== MAY 2026 =====
  (1,  1, 12000.00, 'Landlord',          'House rent May',          '2026-05-01', 'Net Banking', 1),
  (1,  5,  1700.00, 'BESCOM',            'Electricity bill May',    '2026-05-05', 'Net Banking', 1),
  (1,  3,  3600.00, 'D-Mart',            'Monthly groceries May',   '2026-05-07', 'Debit Card',  0),
  (1,  6,  2500.00, 'Apollo Pharmacy',   'Medicine + health check', '2026-05-12', 'Cash',        0),
  (1,  2,   900.00, 'Swiggy',            'Food orders May',         '2026-05-18', 'UPI',         0),
  (1, 11,  1499.00, 'Netflix + Spotify', 'Streaming subs May',      '2026-05-20', 'Credit Card', 1),
  (1, 12,  9500.00, 'MakeMyTrip',        'Goa trip booking',        '2026-05-26', 'Credit Card', 0),
-- ===== JUNE 2026 =====
  (1,  1, 12000.00, 'Landlord',          'House rent Jun',          '2026-06-01', 'Net Banking', 1),
  (1,  5,  1800.00, 'BESCOM',            'Electricity bill Jun',    '2026-06-05', 'Net Banking', 1),
  (1,  3,  3400.00, 'D-Mart',            'Monthly groceries Jun',   '2026-06-06', 'Debit Card',  0),
  (1,  2,  1100.00, 'Zomato',            'Monsoon food cravings',   '2026-06-14', 'UPI',         0),
  (1, 11,  1499.00, 'Netflix + Spotify', 'Streaming subs Jun',      '2026-06-20', 'Credit Card', 1),
  (1,  8,   850.00, 'Steam',             'Gaming purchase',         '2026-06-22', 'Credit Card', 0),
-- ===== JULY 2026 =====
  (1,  1, 12000.00, 'Landlord',          'House rent Jul',          '2026-07-01', 'Net Banking', 1),
  (1,  5,  1650.00, 'BESCOM',            'Electricity bill Jul',    '2026-07-05', 'Net Banking', 1),
  (1,  3,  3250.00, 'D-Mart',            'Monthly groceries Jul',   '2026-07-07', 'Debit Card',  0),
  (1,  9,  7800.00, 'Croma',             'Smartwatch',              '2026-07-11', 'Credit Card', 0),
  (1,  2,   980.00, 'Swiggy',            'Food orders Jul',         '2026-07-18', 'UPI',         0),
  (1, 11,  1499.00, 'Netflix + Spotify', 'Streaming subs Jul',      '2026-07-20', 'Credit Card', 1),
  (1,  4,  1800.00, 'Uber',              'Office commute Jul',      '2026-07-25', 'UPI',         0),
-- ===== AUGUST 2026 =====
  (1,  1, 12000.00, 'Landlord',          'House rent Aug',          '2026-08-01', 'Net Banking', 1),
  (1,  5,  1750.00, 'BESCOM',            'Electricity bill Aug',    '2026-08-05', 'Net Banking', 1),
  (1,  3,  3450.00, 'D-Mart',            'Monthly groceries Aug',   '2026-08-07', 'Debit Card',  0),
  (1,  2,   770.00, 'Zomato',            'Lunch Aug',               '2026-08-12', 'UPI',         0),
  (1, 11,  1499.00, 'Netflix + Spotify', 'Streaming subs Aug',      '2026-08-20', 'Credit Card', 1),
  (1,  6,  1800.00, 'Fortis Hospital',   'Routine check-up',        '2026-08-22', 'Debit Card',  0),
  (1,  8,  1200.00, 'BookMyShow',        'Concert tickets',         '2026-08-28', 'Credit Card', 0),
-- ===== SEPTEMBER 2026 =====
  (1,  1, 12000.00, 'Landlord',          'House rent Sep',          '2026-09-01', 'Net Banking', 1),
  (1,  5,  1600.00, 'BESCOM',            'Electricity bill Sep',    '2026-09-05', 'Net Banking', 1),
  (1,  3,  3300.00, 'D-Mart',            'Monthly groceries Sep',   '2026-09-07', 'Debit Card',  0),
  (1, 11,  1499.00, 'Netflix + Spotify', 'Streaming subs Sep',      '2026-09-10', 'Credit Card', 1),
  (1,  2,   650.00, 'Swiggy',            'Onam specials',           '2026-09-15', 'UPI',         0),
  (1,  9,  4200.00, 'Flipkart',          'Onam sale shopping',      '2026-09-17', 'Credit Card', 0);

-- ============================================================
-- EXPENSE DATA — User 2 (Rahul) | Jan–Sep 2026
-- ============================================================
INSERT INTO Expenses (user_id, category_id, amount, vendor, description, expense_date, payment_method, is_recurring) VALUES
  (2,  1, 25000.00, 'Home Loan EMI',    'SBI home loan EMI Jan',   '2026-01-05', 'Net Banking', 1),
  (2, 10, 15000.00, 'HDFC Car Loan',    'Car EMI Jan',             '2026-01-07', 'Net Banking', 1),
  (2,  3,  5500.00, 'D-Mart',           'Groceries Jan',           '2026-01-08', 'Debit Card',  0),
  (2,  2,  3200.00, 'Zomato/Swiggy',    'Family food orders Jan',  '2026-01-15', 'UPI',         0),
  (2,  5,  3500.00, 'BESCOM',           'Electricity Jan',         '2026-01-10', 'Net Banking', 1),
  (2,  1, 25000.00, 'Home Loan EMI',    'SBI home loan EMI Feb',   '2026-02-05', 'Net Banking', 1),
  (2, 10, 15000.00, 'HDFC Car Loan',    'Car EMI Feb',             '2026-02-07', 'Net Banking', 1),
  (2,  3,  5200.00, 'D-Mart',           'Groceries Feb',           '2026-02-08', 'Debit Card',  0),
  (2,  2,  2800.00, 'Zomato',           'Family food orders Feb',  '2026-02-14', 'UPI',         0),
  (2,  5,  3200.00, 'BESCOM',           'Electricity Feb',         '2026-02-10', 'Net Banking', 1),
  (2,  1, 25000.00, 'Home Loan EMI',    'SBI home loan EMI Mar',   '2026-03-05', 'Net Banking', 1),
  (2, 10, 15000.00, 'HDFC Car Loan',    'Car EMI Mar',             '2026-03-07', 'Net Banking', 1),
  (2,  3,  5800.00, 'Big Bazaar',       'Groceries Mar',           '2026-03-09', 'Debit Card',  0),
  (2,  2,  4500.00, 'Restaurant',       'Family dinner Holi',      '2026-03-25', 'Cash',        0),
  (2,  9, 12000.00, 'Amazon',           'Laptop accessories',      '2026-03-20', 'Credit Card', 0),
  (2,  1, 25000.00, 'Home Loan EMI',    'SBI home loan EMI Apr',   '2026-04-05', 'Net Banking', 1),
  (2, 10, 15000.00, 'HDFC Car Loan',    'Car EMI Apr',             '2026-04-07', 'Net Banking', 1),
  (2,  3,  5300.00, 'D-Mart',           'Groceries Apr',           '2026-04-08', 'Debit Card',  0),
  (2,  2,  3100.00, 'Swiggy',           'Food orders Apr',         '2026-04-18', 'UPI',         0),
  (2,  5,  3400.00, 'BESCOM',           'Electricity Apr',         '2026-04-10', 'Net Banking', 1);

-- ============================================================
-- BUDGETS — User 1 (Pavana) monthly limits
-- ============================================================
INSERT INTO Budgets (user_id, category_id, month, limit_amount) VALUES
-- July budgets
  (1,  1, '2026-07', 12500.00),   -- Housing
  (1,  2, '2026-07',  2000.00),   -- Food
  (1,  3, '2026-07',  3500.00),   -- Groceries
  (1,  4, '2026-07',  1500.00),   -- Transport
  (1,  5, '2026-07',  2000.00),   -- Utilities
  (1,  9, '2026-07',  5000.00),   -- Shopping
  (1, 11, '2026-07',  1600.00),   -- Subscriptions
-- August budgets
  (1,  1, '2026-08', 12500.00),
  (1,  2, '2026-08',  1500.00),
  (1,  3, '2026-08',  3500.00),
  (1,  4, '2026-08',  1200.00),
  (1,  5, '2026-08',  2000.00),
  (1,  6, '2026-08',  1000.00),   -- Healthcare
  (1,  8, '2026-08',  1000.00),   -- Entertainment
  (1, 11, '2026-08',  1600.00),
-- September budgets
  (1,  1, '2026-09', 12500.00),
  (1,  2, '2026-09',  1500.00),
  (1,  3, '2026-09',  3500.00),
  (1,  5, '2026-09',  2000.00),
  (1,  9, '2026-09',  3000.00),
  (1, 11, '2026-09',  1600.00);
