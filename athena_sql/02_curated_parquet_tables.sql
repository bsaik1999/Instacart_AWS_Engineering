-- External tables over manually uploaded/local-converted Parquet curated layer.

CREATE EXTERNAL TABLE IF NOT EXISTS instacart_retail_db.curated_orders (
  order_id BIGINT,
  user_id BIGINT,
  eval_set STRING,
  order_number BIGINT,
  order_dow BIGINT,
  order_hour_of_day BIGINT,
  days_since_prior_order DOUBLE
)
STORED AS PARQUET
LOCATION 's3://instacart-retail-platform/curate_data/orders_p/';

CREATE EXTERNAL TABLE IF NOT EXISTS instacart_retail_db.curated_aisles (
  aisle_id BIGINT,
  aisle STRING
)
STORED AS PARQUET
LOCATION 's3://instacart-retail-platform/curate_data/aisles_p/';

CREATE EXTERNAL TABLE IF NOT EXISTS instacart_retail_db.curated_departments (
  department_id BIGINT,
  department STRING
)
STORED AS PARQUET
LOCATION 's3://instacart-retail-platform/curate_data/departments_p/';

CREATE EXTERNAL TABLE IF NOT EXISTS instacart_retail_db.curated_products (
  product_id BIGINT,
  product_name STRING,
  aisle_id BIGINT,
  department_id BIGINT
)
STORED AS PARQUET
LOCATION 's3://instacart-retail-platform/curate_data/products_p/';

CREATE EXTERNAL TABLE IF NOT EXISTS instacart_retail_db.curated_order_products_prior (
  order_id BIGINT,
  product_id BIGINT,
  add_to_cart_order BIGINT,
  reordered BIGINT
)
STORED AS PARQUET
LOCATION 's3://instacart-retail-platform/curate_data/orders_products_prior_p/order_products_prior/';
