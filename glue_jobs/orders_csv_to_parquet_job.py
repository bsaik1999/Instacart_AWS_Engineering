"""
AWS Glue PySpark job: orders_csv_to_parquet_job

Reads raw orders CSV from S3 and writes Snappy-compressed Parquet to the Glue curated layer.
"""

import sys

from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from pyspark.sql.types import StructType, StructField, LongType, StringType, DoubleType

args = getResolvedOptions(sys.argv, ["JOB_NAME"])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args["JOB_NAME"], args)

input_path = "s3://instacart-retail-platform/data/orders/"
output_path = "s3://instacart-retail-platform/glue_curated/orders/"

schema = StructType([
    StructField("order_id", LongType(), True),
    StructField("user_id", LongType(), True),
    StructField("eval_set", StringType(), True),
    StructField("order_number", LongType(), True),
    StructField("order_dow", LongType(), True),
    StructField("order_hour_of_day", LongType(), True),
    StructField("days_since_prior_order", DoubleType(), True),
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
