# sql-data-warehouse-project
Building modern data warehouse with SQL Server,Icluding ETL process,data modelling  and analytics


# Data Warehouse Project

## Overview

This project focuses on building a data warehouse using SQL Server. It demonstrates how raw data from different source systems can be loaded and organized into a structured data warehouse for analytical purposes.

The project follows a layered architecture consisting of Bronze, Silver, and Gold layers.

## Bronze Layer

The Bronze Layer is the first layer of the data warehouse. It stores raw data from the source systems with minimal transformation.

### Source Systems

The project contains data from two source systems:

 **CRM** – Customer, product, and sales data
**ERP** – Customer, location, and product category data

### Bronze Tables

The Bronze layer contains the following tables:

--> bronze.crm_cust_info
--> bronze.crm_prd_info
--> bronze.crm_sales_details
--> bronze.erp_cust_az12
--> bronze.erp_loc_a101
-->bronze.erp_px_cat_g1v2

### Data Loading

A stored procedure named `bronze.load_bronze` is used to load the source data into the Bronze tables.

The procedure:

* Truncates the Bronze tables before loading new data.
* Uses 'BULK INSERT' to load the source data.
* Loads data from both CRM and ERP sources.
* Skips the header row during data loading.
* Tracks the loading time for each table.
* Tracks the total Bronze layer loading time.
* Includes basic error handling using `TRY...CATCH`.

### Data Flow
CRM Source Data ──┐
                  ├──> Bronze Layer
ERP Source Data ──┘
                       ↓
                  Silver Layer
                       ↓
                   Gold Layer 

## Technologies Used

* SQL Server
* T-SQL
* Stored Procedures
* BULK INSERT
* SQL Server Management Studio (SSMS)
