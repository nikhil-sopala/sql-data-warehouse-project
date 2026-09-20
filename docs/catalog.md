# Data Catalog

## Overview

This document describes the tables and columns in the Gold layer
of the data warehouse. The Gold layer follows a star schema
designed for analytical and reporting purposes.

---

# Gold Layer

## Dimension Tables

### gold.dim_customers

| Column | Data Type | Description |
|---|---|---|
| customer_key | INT | Surrogate key identifying the customer |
| customer_id | INT | Source customer identifier |
| first_name | NVARCHAR | Customer first name |
| last_name | NVARCHAR | Customer last name |
| gender | NVARCHAR | Customer gender |
| marital_status | NVARCHAR | Customer marital status |
| country | NVARCHAR | Customer country |

---

### gold.dim_products

| Column | Data Type | Description |
|---|---|---|
| product_key | INT | Surrogate key identifying the product |
| product_id | INT | Source product identifier |
| product_name | NVARCHAR | Name of the product |
| category | NVARCHAR | Product category |
| subcategory | NVARCHAR | Product subcategory |
| cost | INT | Product cost |

---

## Fact Tables

### gold.fact_sales

| Column | Data Type | Description |
|---|---|---|
| order_number | NVARCHAR | Sales order number |
| product_key | INT | Foreign key referencing dim_products |
| customer_key | INT | Foreign key referencing dim_customers |
| order_date | DATE | Date when the order was placed |
| shipping_date | DATE | Date when the order was shipped |
| due_date | DATE | Expected delivery date |
| sales_amount | INT | Sales amount |
| quantity | INT | Quantity sold |
| price | INT | Product selling price |

---

# Relationships

The Gold layer follows a star schema.

- `fact_sales` connects to `dim_customers`
- `fact_sales` connects to `dim_products`
- Dimensions provide descriptive information
- The fact table contains measurable business events

```text
                 dim_customers
                       │
                       │
                       ▼
                  fact_sales
                       ▲
                       │
                       │
                  dim_products
