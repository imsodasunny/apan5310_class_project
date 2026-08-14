# ABC Foodmart Relational Database Project

## Project Overview

This repository contains the database schema, cleaned sample data, ETL notebook, and Metabase SQL queries for the ABC Foodmart relational database project. ABC Foodmart is modeled as a neighborhood grocery chain with two active stores in Queens, New York and three planned expansion stores in Brooklyn, New York.

The project goal is to design a centralized relational database that replaces spreadsheet- and paper-based recordkeeping. The database supports store operations, staffing, inventory control, vendor purchasing, sales analysis, customer analysis, promotion review, return monitoring, and management dashboards.

## Files Included

| File | Description |
|---|---|
| `Group2_CP3_sqlcode.sql` | SQL DDL script used to create the ABC Foodmart relational database schema. It defines tables, primary keys, foreign keys, CHECK constraints, UNIQUE constraints, and indexes. |
| `ABC_Foodmart_18_CSV_Tables.zip` | Zip file containing the 18 cleaned CSV files used as sample data for the database tables. |
| `ABC_Foodmart_group2_ETL_process.ipynb` | Python ETL notebook used to clean, validate, transform, and load the CSV files into PostgreSQL. |
| `ABC_Foodmart_Group2_Metabase_SQL.rtf` | SQL queries used to create Metabase dashboard cards and analytical outputs. |

## Database Schema

The database schema contains 18 tables organized into three business modules.

### 1. Store Operations and Staffing

| Table | Purpose |
|---|---|
| `stores` | Stores basic information for each active or planned store, including address, borough, opening date, and store status. |
| `departments` | Stores department records for each store. |
| `positions` | Stores position titles and hourly rates. |
| `employees` | Stores employee information and links employees to departments and positions. |
| `employee_shifts` | Stores scheduled or completed shifts for employees. |
| `time_off_records` | Stores employee time-off periods. |
| `operating_expenses` | Stores store-level operating expenses such as rent, utilities, wages, and pre-opening costs. |

### 2. Products, Inventory, Vendors, and Purchasing

| Table | Purpose |
|---|---|
| `vendors` | Stores vendor information and vendor status. |
| `products` | Stores product master data, including category, vendor, unit of measure, selling price, and product status. |
| `inventory` | Stores quantity on hand and reorder point for each store-product combination. |
| `purchase_orders` | Stores purchase order header information, including vendor, store, order date, status, and expected delivery date. |
| `purchase_order_items` | Stores product-level detail for each purchase order. |
| `deliveries` | Stores delivery records linked to purchase orders and stores. |

### 3. Sales, Customers, Promotions, and Returns

| Table | Purpose |
|---|---|
| `customers` | Stores customer names, contact information, loyalty number, loyalty status, and account creation date. |
| `promotions` | Stores promotion details, discount type, discount value, active dates, and promotion status. |
| `sales` | Stores sales transaction headers, including store, customer, transaction time, register number, payment method, payment amount, and total amount. |
| `sale_items` | Stores product-level line items for each sale. This table connects sales and products. |
| `returns` | Stores returned sale items, refund details, return reason, and return status. |

## Key Relationships

- One store can have many departments, sales, inventory records, purchase orders, deliveries, and operating expenses.
- One department can have many employees.
- One position can be assigned to many employees.
- One employee can have many shifts and many time-off records.
- One vendor can supply many products and can be linked to many purchase orders.
- One product can appear in many inventory records, purchase order items, sale items, and promotions.
- One purchase order can have many purchase order items and can be linked to delivery records.
- One customer can have many sales and many returns.
- One sale can have many sale items.
- One sale item can be connected to a return if the item was returned.
- Promotions are linked to products and may also be referenced by sale items when a discount is applied.

## Main Assumptions

Because ABC Foodmart is a fictional client scenario, the final data is a realistic academic sample rather than actual company operating data.

### Business Scenario Assumptions

- ABC Foodmart has two active Queens stores and three planned Brooklyn stores.
- Active stores have sales, inventory, staffing, purchasing, and operating records.
- Planned Brooklyn stores may have pre-opening expenses and readiness-related records, but they do not necessarily have historical sales activity.
- The database is designed for management decision-making, dashboard reporting, and SQL analysis rather than for a live production grocery POS system.

### Data Source Assumptions

- Public retail and foodmart-related datasets were used as reference sources for realistic retail structures.
- The final database is populated with 18 cleaned CSV files prepared specifically for this project schema.
- Some operational fields not available in the public datasets were generated or supplemented using rule-based assumptions.
- Generated fields include employee schedules, time-off records, purchase orders, deliveries, promotions, returns, and selected expansion-related expenses.
- Sample data is used to test the schema, relationships, ETL process, and analytical queries. It should not be interpreted as actual ABC Foodmart historical data.

### Schema Design Assumptions

- The database is normalized around separate business entities such as stores, employees, products, vendors, customers, sales, purchase orders, and returns.
- Sales transaction payment information is stored directly in the `sales` table because each sample transaction uses one payment method.
- Return information is stored in the `returns` table and linked to `sale_items`, allowing the system to identify the exact item being returned.
- Store-level inventory is tracked in the `inventory` table using the combination of `store_id` and `product_id`.
- Product cost for gross margin analysis is not part of the original SQL schema, but the ETL process may derive `unit_cost_at_sale` from purchase order history or category-level assumptions for analytical use.
- The SQL schema includes constraints to protect data quality, including nonnegative amounts, valid status values, unique keys, and valid foreign-key relationships.

### ETL Assumptions

- The ETL process uses Python, pandas, SQLAlchemy, and PostgreSQL.
- Parent tables are loaded before child tables to satisfy foreign-key dependencies.
- Text values are trimmed and standardized before loading.
- Dates and timestamps are converted into database-compatible formats.
- Numeric values such as prices, quantities, costs, and amounts are converted and validated.
- Primary keys are checked for missing values and duplicates.
- Foreign keys are validated against previously loaded parent tables.
- Allowed status values are checked against the SQL schema rules.
- Negative prices, quantities, costs, and amounts are rejected or corrected before loading.

## Intended Analytical Use

The database supports analytical procedures and Metabase dashboards for:

- active store financial performance;
- daily sales trends by store;
- product category revenue and estimated gross profit;
- customer value segmentation;
- promotion performance;
- return and refund risk by product category;
- inventory reorder risk;
- vendor purchase-order fulfillment;
- scheduled labor cost by store and department;
- Brooklyn expansion pre-opening expense monitoring.

## Suggested Loading Order

The following loading order is recommended because of foreign-key dependencies:

1. `stores`
2. `positions`
3. `vendors`
4. `customers`
5. `departments`
6. `products`
7. `employees`
8. `employee_shifts`
9. `time_off_records`
10. `operating_expenses`
11. `inventory`
12. `purchase_orders`
13. `purchase_order_items`
14. `deliveries`
15. `promotions`
16. `sales`
17. `sale_items`
18. `returns`

## Notes for Reviewers

- The SQL file is the authoritative schema definition.
- The CSV zip file contains the cleaned sample data used to populate the 18 schema tables.
- The ETL notebook documents how the data was cleaned, validated, transformed, and loaded.
- The Metabase SQL file contains the analytical queries used for dashboard creation.
- The data is intentionally designed as a class-project prototype and should be evaluated based on relational design, ETL reasoning, and analytical usefulness rather than as a complete real-world grocery dataset.
