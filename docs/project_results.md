# Project Results

## Validated Row Counts

| Table | Count |
|---|---:|
| glue_curated_orders | 3,421,083 |
| glue_curated_products | 49,688 |
| glue_curated_order_products_prior | 500,000 |

## Top Reordered Products

Sample result from Athena query over the Glue curated layer:

| Rank | Product | Reorder Count |
|---:|---|---:|
| 1 | Banana | 6,171 |
| 2 | Bag of Organic Bananas | 4,820 |
| 3 | Organic Strawberries | 3,228 |
| 4 | Organic Baby Spinach | 2,901 |
| 5 | Organic Hass Avocado | 2,535 |
| 6 | Organic Avocado | 2,103 |
| 7 | Organic Whole Milk | 1,721 |
| 8 | Large Lemon | 1,629 |
| 9 | Organic Raspberries | 1,614 |
| 10 | Strawberries | 1,523 |

## Department Demand Insights

Top department demand from Athena analytics:

| Department | Total Purchases |
|---|---:|
| produce | 146,266 |
| dairy eggs | 83,751 |
| snacks | 44,416 |
| beverages | 41,584 |
| frozen | 34,199 |

## Peak Ordering Hours

Highest order volume occurred during daytime shopping windows, especially around 10 AM to 4 PM.

| Hour | Total Orders |
|---:|---:|
| 10 | 288,418 |
| 11 | 284,728 |
| 15 | 283,639 |
| 14 | 283,042 |
| 13 | 277,999 |

## Engineering Outcomes

This project demonstrates:

- Raw data ingestion into S3
- Schema-on-read querying using Athena and Glue Catalog
- CSV parsing and data quality issue handling
- Parquet conversion with Snappy compression
- Partitioning and partition-pruning comparison
- Gold-layer analytics modeling
- Glue PySpark ETL automation
- Step Functions orchestration
- Cost-aware serverless data engineering on AWS
