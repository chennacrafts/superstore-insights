# etl_superstore.py
# ETL for Sample Superstore + Returns -> MySQL 'superstore' table
# BEFORE RUNNING:
# pip install pandas sqlalchemy mysql-connector-python python-dotenv openpyxl xlrd

import os
from dotenv import load_dotenv
import pandas as pd
from sqlalchemy import create_engine

# Load DB credentials from .env
load_dotenv()
DB_USER = os.getenv("DB_USER", "root")
DB_PASS = os.getenv("DB_PASS", "")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "3306")
DB_NAME = os.getenv("DB_NAME", "superstore_db")

# File names (place them in same folder)
ORDERS_FILE = "sample_superstore.csv"
RETURNS_FILE = "returns.csv"

# --- 1. Read input files (CSV assumed). If your files are xlsx, change to read_excel ---
def read_csv_flexible(path):
    # try utf-8 then latin1
    try:
        return pd.read_csv(path, encoding="utf-8", low_memory=False)
    except Exception:
        return pd.read_csv(path, encoding="latin1", low_memory=False)

print("Reading orders file:", ORDERS_FILE)
orders = read_csv_flexible(ORDERS_FILE)
print("Reading returns file:", RETURNS_FILE)
returns = read_csv_flexible(RETURNS_FILE)

# --- 2. Print detected headers (helpful to confirm) ---
print("\nOrders columns (original):")
for i,c in enumerate(orders.columns,1):
    print(f"{i:02d}. {c}")
print("\nReturns columns (original):")
for i,c in enumerate(returns.columns,1):
    print(f"{i:02d}. {c}")

# --- 3. Rename columns to canonical names (exact mapping to your header row) ---
orders = orders.rename(columns={
    "Row ID": "row_id",
    "Order ID": "order_id",
    "Order Date": "order_date",
    "Ship Date": "ship_date",
    "Ship Mode": "ship_mode",
    "Customer ID": "customer_id",
    "Customer Name": "customer_name",
    "Segment": "segment",
    "Country/Region": "country_region",
    "City": "city",
    "State/Province": "state_province",
    "Postal Code": "postal_code",
    "Region": "region",
    "Product ID": "product_id",
    "Category": "category",
    "Sub-Category": "sub_category",
    "Product Name": "product_name",
    "Sales": "sales",
    "Quantity": "quantity",
    "Discount": "discount",
    "Profit": "profit"
})

returns = returns.rename(columns={
    "Returned": "returned",
    "Order ID": "order_id"
})

# --- 4. Convert types and clean numeric columns ---
# Dates to datetime
for dt in ["order_date", "ship_date"]:
    if dt in orders.columns:
        orders[dt] = pd.to_datetime(orders[dt], errors="coerce")

# Numeric cleanup: remove currency symbols, convert to numeric
for col in ["sales", "quantity", "discount", "profit"]:
    if col in orders.columns:
        # remove $ , if any and convert
        orders[col] = orders[col].astype(str).str.replace(r'[\$,]', '', regex=True)
        orders[col] = pd.to_numeric(orders[col], errors="coerce")

# Clean postal code
if "postal_code" in orders.columns:
    orders["postal_code"] = orders["postal_code"].fillna(-1)

# --- 5. Derived columns ---
if "order_date" in orders.columns:
    orders["order_year"] = orders["order_date"].dt.year
    orders["order_month"] = orders["order_date"].dt.to_period("M").astype(str)

if all(c in orders.columns for c in ("sales","profit")):
    orders["profit_margin"] = (orders["profit"] / orders["sales"]).replace([float('inf'), -float('inf')], 0).fillna(0)

# --- 6. Merge returns info with left join on order_id ---
merged = orders.merge(returns[["order_id","returned"]], on="order_id", how="left")
# Standardize returned column: fill NA -> "No", keep "Yes" if present
merged["returned"] = merged["returned"].fillna("No").astype(str)

# --- 7. Remove duplicates and invalid orders ---
merged = merged.drop_duplicates()
if "order_id" in merged.columns:
    merged = merged[merged["order_id"].notna()]

# -- Print quick summary --
print("\nAfter cleaning:")
print("Rows:", len(merged))
if "sales" in merged.columns:
    print("Total sales:", merged["sales"].sum())
if "profit" in merged.columns:
    print("Total profit:", merged["profit"].sum())

# --- 8. Write to MySQL ---
engine_url = f"mysql+mysqlconnector://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
print("\nConnecting to MySQL with:", engine_url.replace(DB_PASS, "****"))

try:
    engine = create_engine(engine_url)
    # Ensure DB exists — to_sql will fail if DB doesn't exist.
    merged.to_sql("superstore", con=engine, if_exists="replace", index=False, chunksize=5000)
    print("\n✅ Data written to MySQL table 'superstore' in database:", DB_NAME)
except Exception as e:
    print("\n Failed to write to MySQL. Error:")
    print(e)
    print("\nIf the database does not exist, open MySQL Workbench and run:")
    print("  CREATE DATABASE", DB_NAME, ";")
    print("Then re-run this script.")
