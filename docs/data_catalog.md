📊 Sales Data Warehouse - Complete Data Catalog
Medallion Architecture (Bronze → Silver → Gold)
---
📑 Table of Contents
Architecture Overview
Bronze Layer (Raw Data)
Silver Layer (Cleaned Data)
Gold Layer (Business Ready)
Data Flow & Transformations
Data Quality Standards
Sample Queries
---
🏗️ Architecture Overview
Medallion Architecture Pattern
```
┌─────────────────────────────────────────────────────────────────┐
│  BRONZE LAYER (Raw/Ingestion)                                   │
│  - Raw data dumps from source systems (CRM, ERP)                │
│  - Minimal transformation, full data retention                  │
│  - Data quality issues present (duplicates, nulls, bad formats) │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                    (Cleaning & Validation)
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  SILVER LAYER (Cleaned/Standardized)                            │
│  - Deduplicated, validated, standardized data                   │
│  - Consistent naming conventions and data types                 │
│  - Business logic applied, quality issues resolved              │
│  - Single source of truth for business metrics                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
                  (Business Modeling)
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│  GOLD LAYER (Analytics/Reporting)                               │
│  - Optimized for business queries and dashboards                │
│  - Star schema for fast analytics                               │
│  - Aggregations, calculations, KPIs ready                       │
│  - Used by BI tools and end users                               │
└─────────────────────────────────────────────────────────────────┘
```
Update Cadence:
Bronze: Real-time / Daily ingestion
Silver: Daily / Weekly transformations
Gold: Daily / On-demand
---
🟫 Bronze Layer (Raw Data)
Purpose: Ingest raw data from source systems with minimal transformation.  
Data Quality: ⚠️ Low (duplicates, nulls, inconsistent formatting expected)  
Retention: Keep all historical data  
Source Systems: CRM (Customer Relationship Management), ERP (Enterprise Resource Planning)
---
1. bronze.crm_cust_info
CRM Customer Information - Raw Dump
Column Name	Data Type	Description	Nullable	Example
cst_id	INT	Customer ID from CRM	No	1001
cst_key	NVARCHAR(50)	Customer unique key/code	Yes	CUST-2024-001
cst_firstname	NVARCHAR(50)	Customer first name	Yes	John
cst_lastname	NVARCHAR(50)	Customer last name	Yes	Doe
cst_marital_status	NVARCHAR(50)	Marital status	Yes	Married, Single
cst_gndr	NVARCHAR(50)	Gender	Yes	M, F
cst_create_date	DATE	Record creation date	Yes	2024-01-15
Data Quality Issues Expected:
Duplicates (same customer entered multiple times)
Inconsistent formatting in names (spaces, case)
Gender might be "M"/"F" or "Male"/"Female"
Missing marital status values
Record Count: ~100K (sample)  
Last Updated: Daily
---
2. bronze.crm_prd_info
CRM Product Information - Raw Dump
Column Name	Data Type	Description	Nullable	Example
prd_id	INT	Product ID	No	501
prd_key	NVARCHAR(50)	Product unique key	Yes	PROD-2024-001
prd_nm	NVARCHAR(50)	Product name	Yes	Laptop Pro 15"
prd_cost	INT	Product cost/price	Yes	50000
prd_line	NVARCHAR(50)	Product line/brand	Yes	Pro Series
prd_start_dt	DATE	Product launch date	Yes	2024-01-01
prd_end_dt	DATE	Product discontinue date	Yes	NULL (if active)
Data Quality Issues Expected:
Typos in product names
Cost values might be in different currencies
End dates might be missing for active products
Duplicate products with different keys
Record Count: ~5K (sample)  
Last Updated: Daily
---
3. bronze.crm_sales_details
CRM Sales Transactions - Raw Dump
Column Name	Data Type	Description	Nullable	Example
sls_ord_num	NVARCHAR(50)	Order number	No	ORD-2024-10001
sls_prd_key	NVARCHAR(50)	Product key (FK to product)	Yes	PROD-2024-001
sls_cust_id	INT	Customer ID (FK to customer)	Yes	1001
sls_order_dt	INT	Order date (stored as INT - needs conversion)	Yes	20240915 (YYYYMMDD)
sls_ship_dt	INT	Shipping date (stored as INT)	Yes	20240918
sls_due_dt	INT	Due/Delivery date (stored as INT)	Yes	20240925
sls_sales	INT	Total sales amount	Yes	50000
sls_quantity	INT	Quantity ordered	Yes	10
sls_price	INT	Unit price	Yes	5000
Data Quality Issues Expected:
Dates as integers (needs conversion to DATE type)
Order date > Shipping date (logic errors)
Missing dates or customer IDs
Amount mismatches (sales ≠ quantity × price)
Duplicate orders
Record Count: ~1M (sample)  
Last Updated: Real-time / Daily
---
4. bronze.erp_cust_az12
ERP Customer Additional Attributes
Column Name	Data Type	Description	Nullable	Example
CID	NVARCHAR(50)	Customer ID (different format from CRM)	No	CUST-ERP-A101
BDATE	DATE	Birth date	Yes	1990-05-20
GEN	NVARCHAR(10)	Gender	Yes	Male, Female
Data Quality Issues Expected:
Different customer ID format than CRM (reconciliation needed)
Gender format different from CRM ("Male" vs "M")
Some customers in ERP might not be in CRM
Record Count: ~80K (sample)  
Last Updated: Weekly
---
5. bronze.erp_loc_a101
ERP Customer Location/Country Information
Column Name	Data Type	Description	Nullable	Example
CID	NVARCHAR(50)	Customer ID	No	CUST-ERP-A101
CNTRY	NVARCHAR(50)	Country	Yes	India, USA, Germany
Data Quality Issues Expected:
Country names inconsistent ("India" vs "IND" vs "IN")
Some customers missing country
Duplicate entries for same customer
Record Count: ~80K (sample)  
Last Updated: Weekly
---
6. bronze.erp_px_cat_g1v2
ERP Product Categories and Maintenance
Column Name	Data Type	Description	Nullable	Example
ID	NVARCHAR(50)	Product ID	No	PROD-ERP-001
CAT	NVARCHAR(50)	Product category	Yes	Electronics
SUBCAT	NVARCHAR(50)	Product subcategory	Yes	Computers
MAINTENANCE	NVARCHAR(50)	Maintenance cost/type	Yes	Annual Support
Data Quality Issues Expected:
Product ID format differs from CRM
Category names might have typos
Missing subcategories
Maintenance costs as text (needs numeric conversion)
Record Count: ~5K (sample)  
Last Updated: Weekly
---
🟩 Silver Layer (Cleaned & Standardized)
Purpose: Transform Bronze data into clean, consistent, business-ready format.  
Data Quality: ✅ High (deduplicated, validated, standardized)  
Retention: Keep historical data for analysis  
Transformations Applied:
✅ Deduplication (remove exact duplicates)
✅ Data type standardization (dates as DATE, not INT)
✅ Naming convention standardization (snake_case, descriptive names)
✅ NULL handling and validation
✅ Cross-source reconciliation (CRM ↔ ERP)
✅ Data quality checks and flags
---
1. silver.crm_cust_info
Cleaned Customer Information (CRM Source)
Column Name	Data Type	Description	Nullable
cst_id	INT	Customer ID	No
cst_key	NVARCHAR(50)	Customer unique key	No
first_name	NVARCHAR(50)	First name (standardized)	No
last_name	NVARCHAR(50)	Last name (standardized)	No
marital_status	NVARCHAR(20)	Marital status (standardized)	Yes
gender	NVARCHAR(10)	Gender (M/F standardized)	Yes
created_date	DATE	Record creation date	No
data_quality_flag	VARCHAR(1)	Q=Good, W=Warning, E=Error	No
loaded_date	DATE	Date record was loaded to Silver	No
Transformations from Bronze:
Removed duplicate records (kept latest by created_date)
Standardized column names (cst_gndr → gender)
Converted gender to uppercase (M/F)
Standardized marital status values (Married, Single, Divorced, Unknown)
Added data quality flags
Removed nulls in key fields (first_name, last_name)
Record Count: ~95K (deduped from ~100K)
---
2. silver.crm_prd_info
Cleaned Product Information (CRM Source)
Column Name	Data Type	Description	Nullable
prd_id	INT	Product ID	No
prd_key	NVARCHAR(50)	Product unique key	No
product_name	NVARCHAR(100)	Product name (cleaned/trimmed)	No
cost	DECIMAL(12,2)	Product cost	No
product_line	NVARCHAR(50)	Product line (standardized)	Yes
start_date	DATE	Product launch date	No
end_date	DATE	Product discontinue date	Yes
is_active	BIT	Active status (1=Active, 0=Inactive)	No
data_quality_flag	VARCHAR(1)	Q=Good, W=Warning, E=Error	No
loaded_date	DATE	Date record was loaded to Silver	No
Transformations from Bronze:
Removed duplicate products (based on prd_id)
Standardized column names (prd_nm → product_name)
Converted cost to DECIMAL with 2 decimal places
Added is_active flag (based on end_date)
Removed typos from product names
Trimmed whitespace from all string fields
Record Count: ~4.8K (deduped from ~5K)
---
3. silver.crm_sales_details
Cleaned Sales Transactions (CRM Source)
Column Name	Data Type	Description	Nullable
order_number	NVARCHAR(50)	Order number	No
product_key	NVARCHAR(50)	Product key (FK)	No
customer_id	INT	Customer ID (FK)	No
order_date	DATE	Order date (converted from INT)	No
shipping_date	DATE	Shipping date (converted from INT)	No
due_date	DATE	Due date (converted from INT)	No
sales_amount	DECIMAL(12,2)	Total sales amount	No
quantity	INT	Quantity ordered	No
unit_price	DECIMAL(12,2)	Unit price	No
data_quality_flag	VARCHAR(1)	Q=Good, W=Warning, E=Error	No
loaded_date	DATE	Date record was loaded to Silver	No
Transformations from Bronze:
✅ Converted dates from INT to DATE (e.g., 20240915 → 2024-09-15)
✅ Validated date logic (order_date ≤ shipping_date ≤ due_date)
✅ Fixed amount mismatches (recalculated sales_amount if needed)
✅ Removed duplicate orders
✅ Validated foreign keys exist in customer & product tables
✅ Standardized column names (sls_ord_num → order_number)
✅ Converted to DECIMAL for financial accuracy
Record Count: ~950K (deduped from ~1M)
---
4. silver.erp_cust_az12
Cleaned ERP Customer Attributes
Column Name	Data Type	Description	Nullable
customer_id	NVARCHAR(50)	Customer ID (standardized)	No
birthdate	DATE	Birth date	Yes
gender	NVARCHAR(10)	Gender (M/F standardized)	Yes
source_system	VARCHAR(10)	"ERP"	No
loaded_date	DATE	Date record loaded to Silver	No
Transformations from Bronze:
Standardized customer ID format (mapped to CRM customer_id)
Standardized gender (M/F format)
Removed duplicates per customer
---
5. silver.erp_loc_a101
Cleaned ERP Location/Country Information
Column Name	Data Type	Description	Nullable
customer_id	NVARCHAR(50)	Customer ID (standardized)	No
country	NVARCHAR(50)	Country (standardized names)	No
source_system	VARCHAR(10)	"ERP"	No
loaded_date	DATE	Date record loaded to Silver	No
Transformations from Bronze:
Standardized country names (IND → India, USA → United States)
Removed duplicates
Added standard country codes
---
6. silver.erp_px_cat_g1v2
Cleaned ERP Product Categories
Column Name	Data Type	Description	Nullable
product_id	NVARCHAR(50)	Product ID (standardized)	No
category	NVARCHAR(50)	Product category	No
subcategory	NVARCHAR(50)	Product subcategory	Yes
maintenance_cost	DECIMAL(12,2)	Maintenance cost (numeric)	Yes
source_system	VARCHAR(10)	"ERP"	No
loaded_date	DATE	Date record loaded to Silver	No
Transformations from Bronze:
Mapped product ID to CRM product_id format
Standardized category/subcategory names
Converted maintenance from text to DECIMAL
Removed duplicates
---
⭐ Gold Layer (Business Ready - Star Schema)
Purpose: Optimized for analytics, reporting, and BI tools.  
Data Quality: ✅✅ Excellent (aggregated, validated, business-aligned)  
Schema Type: Star Schema (1 Fact + Multiple Dimensions)  
Optimization: Indexed for fast queries, optimized for analytics
---
Fact Table: gold.fact_sales
Central transaction table - One row per order
Column Name	Data Type	Description	Nullable	Example
order_number	NVARCHAR(50)	Order ID (PK)	No	ORD-2024-10001
product_key	INT	Product FK to dim_products	No	5
customer_key	INT	Customer FK to dim_customers	No	1
order_date	DATE	Date order placed	No	2024-09-15
shipping_date	DATE	Date order shipped	No	2024-09-18
due_date	DATE	Expected delivery date	No	2024-09-25
sales_amount	DECIMAL(12,2)	Total revenue (quantity × price)	No	50000.00
quantity	INT	Units ordered	No	10
unit_price	DECIMAL(12,2)	Price per unit	No	5000.00
Primary Key: `order_number`  
Foreign Keys:
`product_key` → `gold.dim_products.product_key`
`customer_key` → `gold.dim_customers.customer_key`
Record Count: ~950K  
Business Questions Answered:
❓ Total revenue by month/quarter/year?
❓ Top 10 best-selling products?
❓ Customer lifetime value?
❓ Shipping delay analysis?
---
Dimension Table: gold.dim_customers
Customer attributes - One row per unique customer
Column Name	Data Type	Description	Nullable	Example
customer_key	INT	Surrogate key (PK)	No	1
customer_id	NVARCHAR(50)	Business key	No	CUST-2024-001
first_name	NVARCHAR(50)	First name	No	John
last_name	NVARCHAR(50)	Last name	No	Doe
birthdate	DATE	Date of birth	Yes	1990-05-20
gender	VARCHAR(10)	M or F	Yes	M
marital_status	VARCHAR(20)	Married/Single/Divorced	Yes	Married
country	NVARCHAR(50)	Country name	Yes	India
created_date	DATE	Record creation date	No	2024-01-15
Primary Key: `customer_key`  
Data Source: Merged from silver.crm_cust_info + silver.erp_cust_az12 + silver.erp_loc_a101
Record Count: ~95K  
Business Questions Answered:
❓ Customer demographics breakdown?
❓ Sales by country?
❓ Gender-wise spending patterns?
---
Dimension Table: gold.dim_products (or gold.cost)
Product attributes - One row per unique product
Column Name	Data Type	Description	Nullable	Example
product_key	INT	Surrogate key (PK)	No	5
product_id	NVARCHAR(50)	Business key	No	PROD-2024-001
product_name	NVARCHAR(100)	Product name	No	Laptop Pro 15"
category	NVARCHAR(50)	Product category	No	Electronics
subcategory	NVARCHAR(50)	Product subcategory	Yes	Computers
product_line	NVARCHAR(50)	Brand/line	Yes	Pro Series
cost	DECIMAL(12,2)	Unit cost	No	30000.00
maintenance_cost	DECIMAL(12,2)	Annual maintenance	Yes	5000.00
start_date	DATE	Launch date	No	2024-01-01
end_date	DATE	Discontinue date	Yes	NULL
is_active	BIT	Active status	No	1
Primary Key: `product_key`  
Data Source: Merged from silver.crm_prd_info + silver.erp_px_cat_g1v2
Record Count: ~4.8K  
Business Questions Answered:
❓ Product profitability (revenue - cost)?
❓ Sales by category?
❓ Product lifecycle analysis?
---
🔄 Data Flow & Transformations
End-to-End Data Pipeline
```
CRM System          ERP System
    │                   │
    ├─→ BRONZE LAYER ←─┤
    │   (Raw Dumps)     │
    │   • crm_cust_info │
    │   • crm_prd_info  │
    │   • erp_cust_az12 │
    │   • erp_loc_a101  │
    │   • crm_sales_details
    │   • erp_px_cat_g1v2
    │
    └──→ SILVER LAYER
        (Cleaned)
        • Deduplication
        • Standardization
        • Data Type Fixes
        • Quality Checks
        │
        └──→ GOLD LAYER
            (Star Schema)
            • dim_customers (merged CRM + ERP)
            • fact_sales (transactions)
            • dim_products (merged CRM + ERP)
            │
            └──→ BI TOOLS / DASHBOARDS
                (End User Analytics)
```
Key Transformation Rules
Transformation	Bronze → Silver	Silver → Gold
Customer ID	Standardize CRM/ERP IDs	Map to surrogate key (customer_key)
Dates	Convert INT to DATE	Already DATE, use for joins
Gender	Standardize to M/F	Standardize to M/F
Marital Status	Standardize values	Keep as-is
Product ID	Standardize CRM/ERP IDs	Map to surrogate key (product_key)
Cost/Price	Convert to DECIMAL	Use for profit calculations
Duplicates	Remove (keep latest)	Remove (keep latest)
Validation	Flag data quality issues	Ensure referential integrity
---
✅ Data Quality Standards
Bronze Layer Quality Checks
⚠️ Expected to have issues (raw data)
🔍 Flag duplicate records
🔍 Flag NULL values in key fields
🔍 Track data lineage
Silver Layer Quality Checks
✅ No duplicates (deduplicated)
✅ All key fields populated (no NULLs)
✅ Consistent data types (dates, decimals)
✅ Standardized naming and values
✅ Date logic validated (order_date ≤ ship_date ≤ due_date)
✅ Foreign key validation (products/customers exist)
Gold Layer Quality Checks
✅✅ All Silver quality rules apply
✅✅ No orphaned records (all FKs exist)
✅✅ Fact table grain consistency (one row = one order)
✅✅ Aggregations validated
✅✅ Indexes in place for performance
SLA & Monitoring
Layer	Freshness	Availability	Record Count
Bronze	Real-time	99%	~1M+
Silver	Daily	99.5%	~950K+
Gold	Daily	99.9%	Depends on query
---
📊 Sample Queries
Query 1: Total Revenue by Category (Last Quarter)
```sql
SELECT 
    p.category,
    SUM(f.sales_amount) AS total_revenue,
    COUNT(f.order_number) AS order_count,
    AVG(f.sales_amount) AS avg_order_value
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
WHERE f.order_date >= DATEADD(QUARTER, -1, CAST(GETDATE() AS DATE))
GROUP BY p.category
ORDER BY total_revenue DESC;
```
Query 2: Top 10 Customers by Spending
```sql
SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    c.country,
    COUNT(f.order_number) AS total_orders,
    SUM(f.sales_amount) AS lifetime_value,
    AVG(f.sales_amount) AS avg_order_value
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name, c.country
ORDER BY lifetime_value DESC;
```
Query 3: Product Profitability Analysis
```sql
SELECT 
    p.product_key,
    p.product_name,
    p.category,
    SUM(f.quantity) AS units_sold,
    SUM(f.sales_amount) AS revenue,
    SUM(p.cost * f.quantity) AS total_cost,
    SUM(f.sales_amount) - SUM(p.cost * f.quantity) AS profit,
    CAST(100.0 * (SUM(f.sales_amount) - SUM(p.cost * f.quantity)) / SUM(f.sales_amount) AS DECIMAL(5,2)) AS profit_margin_pct
FROM gold.fact_sales f
JOIN gold.dim_products p ON f.product_key = p.product_key
GROUP BY p.product_key, p.product_name, p.category
ORDER BY profit DESC;
```
Query 4: Shipping Delay Analysis
```sql
SELECT 
    COUNT(CASE WHEN DATEDIFF(DAY, f.shipping_date, f.due_date) > 0 THEN 1 END) AS delayed_orders,
    COUNT(f.order_number) AS total_orders,
    CAST(100.0 * COUNT(CASE WHEN DATEDIFF(DAY, f.shipping_date, f.due_date) > 0 THEN 1 END) / COUNT(f.order_number) AS DECIMAL(5,2)) AS delay_pct
FROM gold.fact_sales f
WHERE f.shipping_date IS NOT NULL;
```
Query 5: Customer Segmentation by Country
```sql
SELECT 
    c.country,
    COUNT(DISTINCT c.customer_key) AS customer_count,
    COUNT(f.order_number) AS total_orders,
    SUM(f.sales_amount) AS country_revenue,
    AVG(f.sales_amount) AS avg_order_value
FROM gold.fact_sales f
JOIN gold.dim_customers c ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY country_revenue DESC;
```
---
📁 GitHub Repository Structure
Recommended folder layout:
```
your-data-warehouse-repo/
│
├── README.md                          # Main overview
├── DATA_CATALOG.md                    # This file
│
├── sql/
│   ├── bronze/
│   │   └── 01_create_bronze_tables.sql
│   ├── silver/
│   │   ├── 02_create_silver_tables.sql
│   │   └── 03_transformations.sql
│   └── gold/
│       ├── 04_create_gold_schema.sql
│       └── 05_sample_queries.sql
│
├── docs/
│   ├── MEDALLION_ARCHITECTURE.md      # Detailed architecture explanation
│   ├── TRANSFORMATIONS.md             # Detailed transformation logic
│   ├── DATA_QUALITY.md                # Quality rules & monitoring
│   └── TROUBLESHOOTING.md             # Common issues & solutions
│
├── diagrams/
│   ├── data_flow.md                   # Mermaid diagrams
│   └── star_schema.png                # ERD diagram
│
└── datasets/
    └── sample_data.csv                # Sample data for testing
```
---
🎯 Quick Reference
Layer	Purpose	Quality	Source	Usage
Bronze	Raw ingestion	⚠️ Low	CRM, ERP	Data lineage, audit
Silver	Cleaned source	✅ High	Bronze	Analytics foundation
Gold	Analytics ready	✅✅ Excellent	Silver	BI, Reports, Dashboards
