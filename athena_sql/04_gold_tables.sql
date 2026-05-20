-- Gold business-ready analytics tables.

DROP TABLE IF EXISTS instacart_retail_db.gold_top_reordered_products;
DROP TABLE IF EXISTS instacart_retail_db.gold_department_demand;
DROP TABLE IF EXISTS instacart_retail_db.gold_peak_order_hours;
DROP TABLE IF EXISTS instacart_retail_db.gold_avg_basket_size;
DROP TABLE IF EXISTS instacart_retail_db.gold_customer_reorder_behavior;

CREATE TABLE instacart_retail_db.gold_top_reordered_products
WITH (
  format = 'PARQUET',
  external_location = 's3://instacart-retail-platform/gold/top_reordered_products/',
  parquet_compression = 'SNAPPY'
) AS
SELECT 
    p.product_id,
    p.product_name,
    COUNT(*) AS reorder_count
FROM instacart_retail_db.curated_order_products_prior op
JOIN instacart_retail_db.curated_products p
    ON op.product_id = p.product_id
WHERE op.reordered = 1
GROUP BY p.product_id, p.product_name;

CREATE TABLE instacart_retail_db.gold_department_demand
WITH (
  format = 'PARQUET',
  external_location = 's3://instacart-retail-platform/gold/department_demand/',
  parquet_compression = 'SNAPPY'
) AS
SELECT 
    d.department_id,
    d.department,
    COUNT(*) AS total_purchases
FROM instacart_retail_db.curated_order_products_prior op
JOIN instacart_retail_db.curated_products p
    ON op.product_id = p.product_id
JOIN instacart_retail_db.curated_departments d
    ON p.department_id = d.department_id
GROUP BY d.department_id, d.department;

CREATE TABLE instacart_retail_db.gold_peak_order_hours
WITH (
  format = 'PARQUET',
  external_location = 's3://instacart-retail-platform/gold/peak_order_hours/',
  parquet_compression = 'SNAPPY'
) AS
SELECT 
    order_hour_of_day,
    COUNT(*) AS total_orders
FROM instacart_retail_db.curated_orders
GROUP BY order_hour_of_day;

CREATE TABLE instacart_retail_db.gold_avg_basket_size
WITH (
  format = 'PARQUET',
  external_location = 's3://instacart-retail-platform/gold/avg_basket_size/',
  parquet_compression = 'SNAPPY'
) AS
SELECT 
    AVG(product_count) AS avg_basket_size,
    MIN(product_count) AS min_basket_size,
    MAX(product_count) AS max_basket_size,
    COUNT(*) AS total_orders
FROM (
    SELECT 
        order_id,
        COUNT(product_id) AS product_count
    FROM instacart_retail_db.curated_order_products_prior
    GROUP BY order_id
) t;

CREATE TABLE instacart_retail_db.gold_customer_reorder_behavior
WITH (
  format = 'PARQUET',
  external_location = 's3://instacart-retail-platform/gold/customer_reorder_behavior/',
  parquet_compression = 'SNAPPY'
) AS
SELECT 
    o.user_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(op.product_id) AS total_products,
    SUM(op.reordered) AS total_reordered_products,
    CAST(SUM(op.reordered) AS DOUBLE) / COUNT(op.product_id) AS reorder_rate
FROM instacart_retail_db.curated_orders o
JOIN instacart_retail_db.curated_order_products_prior op
    ON o.order_id = op.order_id
GROUP BY o.user_id;
