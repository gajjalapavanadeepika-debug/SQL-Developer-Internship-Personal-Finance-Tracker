# SQL-Developer-Internship-Task-1
**Name:** G.Pavana Deepika  
**Task:** Database Setup, Schema Design & Fundamentals  
**Domain:** E-Commerce Management System  
**Tools Used:** MySQL Workbench / SQLiteStudio  

---

## 📌 Project Overview
This repository contains the complete solution for Task 1 of the SQL Developer Internship. The project models a relational database schema for an **E-Commerce System** containing entities for users, categories, products, orders, and order items.

## 📁 Repository Contents
* **`Task_1_SQL_Developer_Internship_G_Pavana_Deepika.pdf`**: Complete task documentation, including the SQL schema design and comprehensive answers to all conceptual questions.

## 🗄️ Database Schema Details
The schema incorporates key relational database principles:
* **Entities:** `users`, `categories`, `products`, `orders`, `order_items`
* **Constraints:** `PRIMARY KEY`, `FOREIGN KEY`, `AUTO_INCREMENT`, `UNIQUE`, `NOT NULL`, `CHECK`, and `ON DELETE CASCADE`
* **Relationships:** 1:M (Categories ➔ Products, Users ➔ Orders) and M:N (Orders ➔ Products via `order_items` junction table)
