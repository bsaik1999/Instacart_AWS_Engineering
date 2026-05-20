-- Athena CTAS examples for automated Parquet creation and partitioning.

CREATE TABLE instacart_retail_db.auto_curated_orders
WITH (
  format = 'PARQUET',
  external_location = 's3://instacart-retail-platform/auto_curated/orders/',
  parquet_compression = 'SNAPPY'
) AS
SELECT
  order_id,
  user_id,
  eval_set,
  order_number,
  order_dow,
  order_hour_of_day,
  days_since_prior_order
FROM instacart_retail_db.orders;

CREATE TABLE instacart_retail_db.auto_curated_order_products
WITH (
  format = 'PARQUET',
  external_location = 's3://instacart-retail-platform/auto_curated/order_products/',
  parquet_compression = 'SNAPPY'
) AS
SELECT
  order_id,
  product_id,
  add_to_cart_order,
  reordered
FROM instacart_retail_db.order_products;

CREATE TABLE instacart_retail_db.auto_curated_products
WITH (
  format = 'PARQUET',
  external_location = 's3://instacart-retail-platform/auto_curated/products/',
  parquet_compression = 'SNAPPY'
) AS
SELECT
  product_id,
  product_name,
  aisle_id,
  department_id
FROM instacart_retail_db.products;

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

-- Partition pruning test
SELECT COUNT(*)
FROM instacart_retail_db.partitioned_orders_by_hour
WHERE order_hour_of_day = 10;

-- Raw comparison
SELECT COUNT(*)
FROM instacart_retail_db.orders
WHERE order_hour_of_day = 10;
