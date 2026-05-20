-- Athena external tables over Glue PySpark ETL outputs.

DROP TABLE IF EXISTS instacart_retail_db.glue_curated_orders;
CREATE EXTERNAL TABLE instacart_retail_db.glue_curated_orders (
  order_id BIGINT,
  user_id BIGINT,
  eval_set STRING,
  order_number BIGINT,
  order_dow BIGINT,
  order_hour_of_day BIGINT,
  days_since_prior_order DOUBLE
)
STORED AS PARQUET
LOCATION 's3://instacart-retail-platform/glue_curated/orders/';

DROP TABLE IF EXISTS instacart_retail_db.glue_curated_products;
CREATE EXTERNAL TABLE instacart_retail_db.glue_curated_products (
  product_id BIGINT,
  product_name STRING,
  aisle_id BIGINT,
  department_id BIGINT
)
STORED AS PARQUET
LOCATION 's3://instacart-retail-platform/glue_curated/products/';

DROP TABLE IF EXISTS instacart_retail_db.glue_curated_order_products_prior;
CREATE EXTERNAL TABLE instacart_retail_db.glue_curated_order_products_prior (
  order_id BIGINT,
  product_id BIGINT,
  add_to_cart_order BIGINT,
  reordered BIGINT
)
STORED AS PARQUET
LOCATION 's3://instacart-retail-platform/glue_curated/order_products_prior/';

-- Validation
SELECT COUNT(*) FROM instacart_retail_db.glue_curated_orders;
SELECT COUNT(*) FROM instacart_retail_db.glue_curated_products;
SELECT COUNT(*) FROM instacart_retail_db.glue_curated_order_products_prior;

SELECT 
    p.product_name,
    COUNT(*) AS reorder_count
FROM instacart_retail_db.glue_curated_order_products_prior op
JOIN instacart_retail_db.glue_curated_products p
    ON op.product_id = p.product_id
WHERE op.reordered = 1
GROUP BY p.product_name
ORDER BY reorder_count DESC
LIMIT 20;
