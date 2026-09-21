# Data Warehouse Project

## Overview

This project demonstrates the development of a data warehouse using **SQL Server** and **T-SQL**.

The project integrates data from CRM and ERP source systems and transforms the data through a layered data warehouse architecture consisting of **Bronze, Silver, and Gold layers**.

The Gold layer follows a **Star Schema** design to provide business-ready data for analytical purposes.

## Architecture

The data warehouse follows a three-layer architecture:

- **Bronze Layer** – Stores raw data from the source systems.
- **Silver Layer** – Cleans, standardizes, and transforms the raw data.
- **Gold Layer** – Contains business-ready data organized into a Star Schema.

Detailed architecture, data flow, and data model diagrams are available in the `docs/` folder.

## Bronze Layer

The Bronze Layer is the first layer of the data warehouse. It stores raw data from the source systems with minimal transformation.

### Source Systems

The project contains data from two source systems:

- **CRM** – Customer, product, and sales data
- **ERP** – Customer, location, and product category data

### Bronze Tables

- `bronze.crm_cust_info`
- `bronze.crm_prd_info`
- `bronze.crm_sales_details`
- `bronze.erp_cust_az12`
- `bronze.erp_loc_a101`
- `bronze.erp_px_cat_g1v2`

### Data Loading

The `bronze.load_bronze` stored procedure is used to load the source data into the Bronze tables.

The procedure:

- Truncates the Bronze tables before loading.
- Uses `BULK INSERT` to load source data.
- Loads data from both CRM and ERP sources.
- Skips source file headers.
- Tracks individual table loading times.
- Tracks the total Bronze layer loading time.
- Includes basic error handling using `TRY...CATCH`.

## Silver Layer

The Silver Layer is responsible for cleaning, standardizing, and transforming the raw data from the Bronze Layer.

The Silver layer:

- Cleans and standardizes source data.
- Handles data quality issues and inconsistent values.
- Applies transformations to prepare the data for analysis.
- Integrates data from different source tables.
- Uses SQL transformations and stored procedures to load the Silver tables.

## Gold Layer

The Gold Layer contains business-ready data designed for analytical purposes.

The Gold layer follows a **Star Schema** consisting of one central fact table and two dimension tables.

### Fact Table

- `gold.fact_sales` – Stores sales transactions and measurable sales information.

### Dimension Tables

- `gold.dim_customers` – Contains descriptive customer information.
- `gold.dim_products` – Contains descriptive product information.

The fact table connects to the dimension tables using surrogate keys:

- `fact_sales.customer_key` → `dim_customers.customer_key`
- `fact_sales.product_key` → `dim_products.product_key`

This structure supports analytical queries, aggregations, and reporting.

## Documentation

Supporting project documentation is available in the `docs/` folder.

It includes:

- **Data Architecture** – Overall structure of the data warehouse.
- **Data Flow** – How data moves through the Bronze, Silver, and Gold layers.
- **Data Model** – Gold-layer Star Schema and table relationships.
- **Data Catalog** – Description of tables, columns, keys, relationships, and their purpose.

## Requirements

### Software

- **SQL Server** – Database engine used to create and run the data warehouse.
- **SQL Server Management Studio (SSMS)** – Used to execute SQL scripts and manage the database.
- **Git/GitHub** – Used for version control and project documentation.

### Data

The project requires the CRM and ERP source datasets used by the Bronze layer.

The source files should be placed in the expected dataset directories before running the Bronze loading procedure.

### Environment

This project uses SQL Server-specific T-SQL features including:

- `BULK INSERT`
- Stored Procedures
- `TRY...CATCH`
- SQL Server schemas

The Bronze loading procedure uses local file paths with `BULK INSERT`. These paths may need to be updated when running the project on another machine.
---

## Project Structure

```text
data-warehouse-project/
│
├── datasets/
│   ├── source_crm/
│   └── source_erp/
│
├── docs/
│   ├── data_architecture.png
│   ├── data_flow.png
│   ├── data_model.png
│   └── data_catalog.md
│
├── scripts/
│   ├── bronze/
│   ├── silver/
│   └── gold/
│
├── tests/
│
└── README.md
```

# Data Warehouse Project

## 🌟 About Me

Hi there! I'm **Nikhil Sopala**, a recent Data Science graduate actively looking for a job opportunity in the data space. I am open to all data-related roles and deeply eager to learn and grow. 

To turn my knowledge into practical skills, I built this end-to-end data warehouse project from scratch! 

Let's connect! Feel free to reach out to me:

* 💼 **LinkedIn:** [linkedin.com/in/sopalanikhil12345](https://linkedin.com/in/sopalanikhil12345)
* 📧 **Email:** linkedin.sopalanikhil40@gmail.com

---

---

