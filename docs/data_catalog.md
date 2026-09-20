# Data Catalog

## Overview

This data catalog describes the tables and columns in the Gold layer of the Data Warehouse project.

The Gold layer follows a **Star Schema** for the Sales Data Mart. It contains one central fact table, `gold.fact_sales`, connected to two dimension tables: `gold.dim_customers` and `gold.dim_products`.

> **Note:** Data types are not included here because they are not visible in the data model diagram. They can be added later from the Gold-layer SQL definitions.

---

# Gold Layer — Sales Data Mart

## 1. `gold.fact_sales`

**Table Type:** Fact Table

**Purpose:** Stores sales transaction records and the measurable business values used for sales analysis.

| Column | Role | Description |
|---|---|---|
| `order_number` | Business identifier | Identifies the sales order associated with the transaction. |
| `product_key` | Foreign Key | References `gold.dim_products.product_key` to identify the product associated with the sale. |
| `customer_key` | Foreign Key | References `gold.dim_customers.customer_key` to identify the customer associated with the sale. |
| `order_date` | Date | Date on which the sales order was placed. |
| `shipping_date` | Date | Date on which the order was shipped. |
| `due_date` | Date | Expected due date associated with the order. |
| `sales_amount` | Measure | Total sales amount associated with the transaction. |
| `quantity` | Measure | Number of units sold. |
| `price` | Measure | Price associated with the sold product. |

### Relationships

- `product_key` → `gold.dim_products.product_key`
- `customer_key` → `gold.dim_customers.customer_key`

---

## 2. `gold.dim_customers`

**Table Type:** Dimension Table

**Purpose:** Stores descriptive information about customers for customer-level analysis and reporting.

| Column | Role | Description |
|---|---|---|
| `customer_key` | Primary Key | Surrogate key used to uniquely identify a customer in the Gold layer. |
| `customer_id` | Business identifier | Identifier of the customer from the source system. |
| `customer_number` | Business identifier | Business/customer number used to identify the customer. |
| `first_name` | Attribute | Customer's first name. |
| `last_name` | Attribute | Customer's last name. |
| `country` | Attribute | Country associated with the customer. |
| `marital_status` | Attribute | Customer's marital status. |
| `gender` | Attribute | Customer's gender. |
| `birthdate` | Attribute | Customer's date of birth. |

### Relationships

- `customer_key` is referenced by `gold.fact_sales.customer_key`.

---

## 3. `gold.dim_products`

**Table Type:** Dimension Table

**Purpose:** Stores descriptive information about products for product, category, and sales analysis.

| Column | Role | Description |
|---|---|---|
| `product_key` | Primary Key | Surrogate key used to uniquely identify a product in the Gold layer. |
| `product_id` | Business identifier | Identifier of the product from the source system. |
| `product_number` | Business identifier | Business/product number used to identify the product. |
| `product_name` | Attribute | Name of the product. |
| `category_id` | Attribute / Identifier | Identifier associated with the product category. |
| `category` | Attribute | Category to which the product belongs. |
| `subcategory` | Attribute | Subcategory to which the product belongs. |
| `maintenance` | Attribute | Maintenance-related classification or information for the product. |
| `cost` | Measure / Attribute | Cost associated with the product. |
| `product_line` | Attribute | Product line classification. |
| `start_date` | Date | Start date associated with the product record. |

### Relationships

- `product_key` is referenced by `gold.fact_sales.product_key`.

---

# Star Schema Relationships

The Sales Data Mart follows a star schema design:

```text
                    gold.dim_customers
                           |
                           | customer_key
                           |
                           v
                    gold.fact_sales
                           ^
                           |
                           | product_key
                           |
                    gold.dim_products
```

The fact table is at the center of the model and connects the measurable sales data with descriptive customer and product information.

---

# Key Definitions

### Primary Key

A primary key uniquely identifies a record within a table.

- `gold.dim_customers.customer_key`
- `gold.dim_products.product_key`

### Foreign Key

A foreign key connects records in the fact table to records in dimension tables.

- `gold.fact_sales.customer_key`
- `gold.fact_sales.product_key`

### Fact Table

A fact table stores business events and measurable values used for analysis.

In this project:

- `gold.fact_sales`

### Dimension Table

A dimension table stores descriptive attributes used to filter, group, and analyze facts.

In this project:

- `gold.dim_customers`
- `gold.dim_products`
