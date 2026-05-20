-- Raw CSV external tables over S3 data layer.
-- Database used: instacart_retail_db

CREATE EXTERNAL TABLE IF NOT EXISTS instacart_retail_db.aisles (
  aisle_id INT,
  aisle STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '"'
)
LOCATION 's3://instacart-retail-platform/data/aisles/'
TBLPROPERTIES (
  'skip.header.line.count'='1',
  'use.null.for.invalid.data'='true'
);

CREATE EXTERNAL TABLE IF NOT EXISTS instacart_retail_db.departments (
  department_id INT,
  department STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '"'
)
LOCATION 's3://instacart-retail-platform/data/departments/'
TBLPROPERTIES (
  'skip.header.line.count'='1',
  'use.null.for.invalid.data'='true'
);

CREATE EXTERNAL TABLE IF NOT EXISTS instacart_retail_db.products (
  product_id INT,
  product_name STRING,
  aisle_id INT,
  department_id INT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '"'
)
LOCATION 's3://instacart-retail-platform/data/products/'
TBLPROPERTIES (
  'skip.header.line.count'='1',
  'use.null.for.invalid.data'='true'
);

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

CREATE EXTERNAL TABLE IF NOT EXISTS instacart_retail_db.order_products (
  order_id INT,
  product_id INT,
  add_to_cart_order INT,
  reordered INT
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar' = '"'
)
LOCATION 's3://instacart-retail-platform/data/order_products_prior_small/'
TBLPROPERTIES (
  'skip.header.line.count'='1',
  'use.null.for.invalid.data'='true'
);
