"""
AWS Glue PySpark job: order_products_csv_to_parquet_job

Reads sampled raw order_products CSV from S3 and writes Snappy-compressed Parquet to the Glue curated layer.
"""

import sys

from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.types import StructType, StructField, LongType

args = getResolvedOptions(sys.argv, ["JOB_NAME"])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args["JOB_NAME"], args)

input_path = "s3://instacart-retail-platform/data/order_products_prior_small/"
output_path = "s3://instacart-retail-platform/glue_curated/order_products_prior/"

schema = StructType([
    StructField("order_id", LongType(), True),
    StructField("product_id", LongType(), True),
    StructField("add_to_cart_order", LongType(), True),
    StructField("reordered", LongType(), True),
])

df = (
    spark.read
    .option("header", "true")
    .option("sep", ",")
    .schema(schema)
    .csv(input_path)
)

print("ROW COUNT:", df.count())
print("COLUMNS:", df.columns)

df.write.mode("overwrite").option("compression", "snappy").parquet(output_path)

job.commit()
