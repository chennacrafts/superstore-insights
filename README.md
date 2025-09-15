# Data Analyst Portfolio Project: Superstore Insights

## Overview
End-to-end retail analytics project using the Sample Superstore dataset.  
This project demonstrates an ETL pipeline in Python (pandas), storage and querying in MySQL, and an interactive Power BI dashboard to surface business insights about sales, profit and returns.

## Contents
- `etl_superstore.py` — Python ETL: reads `sample_superstore.csv` and `returns.csv`, cleans data, adds derived columns, merges returns, and writes cleaned table to MySQL.
- `queries.sql` — Useful SQL queries (sales by region, monthly trend, top products, returns).
- `dashboard.pbix` — Power BI report (KPIs, monthly trend, category performance, map, top products) — stored with Git LFS if large.
- `README.md` — This file.

## Tech stack
- Python (pandas, SQLAlchemy)
- MySQL
- Power BI Desktop
- Git & GitHub (Git LFS for large files)

## Quick start (run locally)
1. Install Python 3.8+, MySQL, Power BI Desktop.
2. Create a database in MySQL Workbench:
   ```sql
   CREATE DATABASE IF NOT EXISTS superstore_db;

