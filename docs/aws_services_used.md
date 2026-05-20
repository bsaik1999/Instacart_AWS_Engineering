# AWS Services Used

## Amazon S3
Used as the data lake storage layer.

Folders/layers:

```text
s3://instacart-retail-platform/data/          # raw CSV layer
s3://instacart-retail-platform/curate_data/   # manually converted Parquet layer
s3://instacart-retail-platform/glue_curated/  # Glue-generated Parquet layer
s3://instacart-retail-platform/gold/          # business-ready analytics tables
s3://instacart-retail-platform/athena-results/# Athena query outputs
```

## AWS Glue Data Catalog
Used as the metadata catalog for Athena external tables.

Database:

```text
instacart_retail_db
```

## Amazon Athena
Used to query CSV and Parquet data directly from S3 using SQL.

Use cases:
- Raw CSV querying
- Parquet table querying
- CTAS transformations
- Partition pruning experiments
- Gold analytics table creation

## AWS Glue PySpark Jobs
Used to automate CSV-to-Parquet ETL.

Jobs:

```text
orders_csv_to_parquet_job
products_csv_to_parquet_job
order_products_csv_to_parquet_job
```

## AWS Step Functions
Used to orchestrate multiple Glue ETL jobs into one workflow.

State machine:

```text
instacart_etl_pipeline_state_machine
```

## IAM
Used to grant Glue and Step Functions permissions to access S3 and start jobs.

Role:

```text
AWSGlueServiceRole
```

For the learning setup, `AmazonS3FullAccess` was attached to resolve S3 access issues. In production, this should be restricted to least-privilege bucket-level permissions.
