# Cloud-Native Retail Basket Analytics Platform on AWS

## Project Overview

This project implements an end-to-end AWS data engineering pipeline using the Instacart Market Basket dataset. The goal is to build a cloud-native retail analytics platform that ingests raw CSV data, catalogs it, queries it with Athena, optimizes it into Parquet, creates gold-layer analytics tables, automates ETL using AWS Glue PySpark jobs, and orchestrates the pipeline using AWS Step Functions.

The project is designed to demonstrate practical skills aligned with AWS Data Engineer Associate certification topics and real-world data engineering responsibilities.

## Business Problem

Retail and grocery platforms need to understand customer basket behavior, repeat purchase patterns, department demand, and peak ordering times. This project builds a serverless analytics platform to answer questions such as:

- Which products are reordered most often?
- Which departments drive the most purchases?
- What are the peak ordering hours?
- What is the average basket size?
- Which customers show high reorder behavior?

## Dataset

Dataset: Instacart Market Basket Analysis dataset.

Core files used:

```text
aisles.csv
departments.csv
products.csv
orders.csv
order_products_prior_small.csv
order_products__train.csv
```

A sampled version of `order_products__prior.csv` was created with 500,000 rows to keep AWS usage cost-safe while still preserving realistic scale for joins and analytics.

## Architecture

```text
Local CSV files
      ↓
Amazon S3 Raw Layer
      ↓
AWS Glue Data Catalog
      ↓
Amazon Athena Raw SQL Queries
      ↓
Parquet Curated Layer
      ↓
Athena CTAS + Partitioned Tables
      ↓
Gold Analytics Tables
      ↓
AWS Glue PySpark ETL Jobs
      ↓
AWS Step Functions Orchestration
```

## S3 Layout

```text
s3://instacart-retail-platform/

├── data/                         # Raw CSV layer
│   ├── aisles/
│   ├── departments/
│   ├── products/
│   ├── orders/
│   └── order_products_prior_small/
│
├── curate_data/                  # Manually converted Parquet layer
│   ├── aisles_p/
│   ├── departments_p/
│   ├── products_p/
│   ├── orders_p/
│   └── orders_products_prior_p/
│
├── glue_curated/                 # Glue-generated Parquet layer
│   ├── orders/
│   ├── products/
│   └── order_products_prior/
│
├── auto_curated/                 # Athena CTAS-generated Parquet layer
├── partitioned/                  # Partitioned Parquet outputs
├── gold/                         # Business-ready analytics tables
└── athena-results/               # Athena query output location
```

## AWS Services Used

| Service | Purpose |
|---|---|
| Amazon S3 | Data lake storage for raw, curated, and gold layers |
| AWS Glue Data Catalog | Metadata catalog for Athena external tables |
| Amazon Athena | Serverless SQL querying over S3 |
| AWS Glue PySpark Jobs | Automated CSV-to-Parquet ETL |
| AWS Step Functions | Orchestration of multiple Glue jobs |
| IAM | Permissions for Glue, S3, Athena, and Step Functions |

## Implementation Steps

### 1. Raw Data Upload

Raw CSV files were uploaded into Amazon S3 under the `data/` prefix. Each dataset was stored in its own folder to avoid schema conflicts.

Example:

```text
s3://instacart-retail-platform/data/orders/orders.csv
s3://instacart-retail-platform/data/products/products.csv
s3://instacart-retail-platform/data/order_products_prior_small/order_products_prior_small.csv
```

### 2. Glue Catalog and Athena Raw Tables

External tables were created manually in Athena over raw CSV files. This avoided crawler issues and provided direct schema control.

Example raw table:

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS instacart_retail_db.orders (
  order_id INT,
  user_id INT,
  eval_set STRING,
  order_number INT,
  order_dow INT,
  order_hour_of_day INT,
  days_since_prior_order DOUBLE
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '"'
)
LOCATION 's3://instacart-retail-platform/data/orders/'
TBLPROPERTIES (
  'skip.header.line.count'='1',
  'use.null.for.invalid.data'='true'
);
```

The `use.null.for.invalid.data` setting was required because `days_since_prior_order` contains blank values.

### 3. Raw Analytics Queries

Athena was used to query raw CSV tables and generate initial insights.

Examples:

- Top reordered products
- Department demand
- Peak order hours
- Average basket size

### 4. Local CSV to Parquet Conversion

A local Python script converted CSV files into Snappy-compressed Parquet files. Large files were split into multiple Parquet part files.

Script:

```text
local_scripts/convert_csv_to_parquet.py
```

### 5. Curated Parquet Athena Tables

External Athena tables were created over the Parquet curated layer.

Example:

```sql
CREATE EXTERNAL TABLE IF NOT EXISTS instacart_retail_db.curated_products (
  product_id BIGINT,
  product_name STRING,
  aisle_id BIGINT,
  department_id BIGINT
)
STORED AS PARQUET
LOCATION 's3://instacart-retail-platform/curate_data/products_p/';
```

### 6. Athena CTAS and Partitioning

Athena CTAS was used to automate Parquet generation and create a partitioned orders table.

Example:

```sql
CREATE TABLE instacart_retail_db.partitioned_orders_by_hour
WITH (
  format = 'PARQUET',
  external_location = 's3://instacart-retail-platform/partitioned/orders_by_hour/',
  partitioned_by = ARRAY['order_hour_of_day'],
  parquet_compression = 'SNAPPY'
) AS
SELECT
  order_id,
  user_id,
  eval_set,
  order_number,
  order_dow,
  days_since_prior_order,
  order_hour_of_day
FROM instacart_retail_db.orders;
```

The raw CSV query and partitioned Parquet query returned the same result, while the partitioned table scanned less data.

### 7. Gold Analytics Layer

Gold tables were created as business-ready Parquet tables.

Gold tables:

```text
gold_top_reordered_products
gold_department_demand
gold_peak_order_hours
gold_avg_basket_size
gold_customer_reorder_behavior
```

These tables are suitable for dashboarding, reporting, and downstream analytics.

### 8. Glue PySpark ETL Automation

AWS Glue PySpark jobs automated CSV-to-Parquet transformation.

Glue jobs:

```text
orders_csv_to_parquet_job
products_csv_to_parquet_job
order_products_csv_to_parquet_job
```

Validated row counts:

| Glue Curated Table | Row Count |
|---|---:|
| glue_curated_orders | 3,421,083 |
| glue_curated_products | 49,688 |
| glue_curated_order_products_prior | 500,000 |

### 9. Step Functions Orchestration

AWS Step Functions orchestrated the Glue jobs sequentially:

```text
products_csv_to_parquet_job
      ↓
orders_csv_to_parquet_job
      ↓
order_products_csv_to_parquet_job
```

State machine definition:

```text
step_functions/instacart_etl_pipeline_state_machine.json
```

## Key Analytics Results

### Top Reordered Products

| Product | Reorder Count |
|---|---:|
| Banana | 6,171 |
| Bag of Organic Bananas | 4,820 |
| Organic Strawberries | 3,228 |
| Organic Baby Spinach | 2,901 |
| Organic Hass Avocado | 2,535 |

### Department Demand

| Department | Total Purchases |
|---|---:|
| produce | 146,266 |
| dairy eggs | 83,751 |
| snacks | 44,416 |
| beverages | 41,584 |
| frozen | 34,199 |

### Peak Ordering Hours

The highest order volumes occurred during daytime hours, especially between 10 AM and 4 PM.

## Cost Optimization

This project was designed for AWS Free Tier / credit-safe learning.

Cost-conscious decisions:

- Used sampled data for large transaction table
- Used Athena instead of Redshift for serverless querying
- Converted CSV to Parquet to reduce scan cost
- Used Snappy compression
- Used small Glue worker configuration
- Avoided NAT Gateway, Redshift clusters, and SageMaker notebooks
- Created reusable gold tables instead of repeatedly scanning raw CSV

## Important Troubleshooting Notes

### Glue Crawler Issues

Glue crawlers did not reliably create tables from multiple CSV files. The solution was to manually create Athena external tables, which gave better schema control.

### CSV Blank Numeric Values

`orders.csv` contains blank values in `days_since_prior_order`. Athena initially failed to parse this column as `DOUBLE`. The fix was:

```sql
'use.null.for.invalid.data'='true'
```

### Glue S3 Permissions

Glue jobs initially failed because the role needed S3 access. The learning fix was to attach:

```text
AmazonS3FullAccess
```

to:

```text
AWSGlueServiceRole
```

In production, this should be replaced with least-privilege bucket-level access.

## Repository Structure

```text
instacart-aws-data-engineering/

├── README.md
├── local_scripts/
│   ├── convert_csv_to_parquet.py
│   └── create_order_products_sample.py
│
├── glue_jobs/
│   ├── orders_csv_to_parquet_job.py
│   ├── products_csv_to_parquet_job.py
│   └── order_products_csv_to_parquet_job.py
│
├── athena_sql/
│   ├── 01_raw_external_tables.sql
│   ├── 02_curated_parquet_tables.sql
│   ├── 03_athena_ctas_and_partitioning.sql
│   ├── 04_gold_tables.sql
│   ├── 05_glue_curated_tables.sql
│   └── 06_validation_queries.sql
│
├── step_functions/
│   └── instacart_etl_pipeline_state_machine.json
│
└── docs/
    ├── aws_services_used.md
    └── project_results.md
```

## Skills Demonstrated

- AWS S3 data lake design
- Raw/curated/gold layered architecture
- Glue Data Catalog and schema-on-read design
- Athena SQL over CSV and Parquet
- CSV parsing and data quality debugging
- Parquet and Snappy compression
- Partitioning and partition pruning
- Athena CTAS transformations
- Glue PySpark ETL automation
- Step Functions orchestration
- IAM/S3 permission debugging
- Cost-aware serverless data engineering

## Resume Bullet Example

Built an end-to-end AWS retail basket analytics platform using S3, Glue, Athena, PySpark, Parquet, and Step Functions to ingest Instacart transaction data, automate CSV-to-Parquet ETL pipelines, create curated and gold analytics layers, optimize query performance with compression and partitioning, and orchestrate production-style data workflows.
