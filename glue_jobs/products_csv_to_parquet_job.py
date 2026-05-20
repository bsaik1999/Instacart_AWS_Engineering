"""
AWS Glue PySpark job: products_csv_to_parquet_job

Reads raw products CSV from S3 and writes Snappy-compressed Parquet to the Glue curated layer.
"""

import sys

from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

args = getResolvedOptions(sys.argv, ["JOB_NAME"])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session

job = Job(glueContext)
job.init(args["JOB_NAME"], args)

input_path = "s3://instacart-retail-platform/data/products/"
output_path = "s3://instacart-retail-platform/glue_curated/products/"

df = (
    spark.read
    .format("csv")
    .option("header", "true")
    .option("inferSchema", "true")
    .load(input_path)
)

print("ROW COUNT:", df.count())
print("COLUMNS:", df.columns)

df.show(5, truncate=False)

df.write.mode("overwrite").option("compression", "snappy").parquet(output_path)

job.commit()
