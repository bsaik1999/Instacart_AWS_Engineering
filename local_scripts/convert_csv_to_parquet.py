"""
Local CSV to Parquet conversion script for the Instacart AWS Data Engineering project.

Purpose:
- Reads raw Instacart CSV files from a local Windows project folder.
- Converts them to Snappy-compressed Parquet.
- Splits large files into multiple Parquet part files.

Update BASE_DIR if your local project path is different.
"""

from pathlib import Path
import pandas as pd

BASE_DIR = Path(r"C:\Users\SaiKrishna\OneDrive\Desktop\Instacart_AWS")
DATA_DIR = BASE_DIR / "data"
PARQUET_DIR = BASE_DIR / "parquet"
PARQUET_DIR.mkdir(exist_ok=True)

FILES = {
    "aisles": DATA_DIR / "aisles.csv",
    "departments": DATA_DIR / "departments.csv",
    "products": DATA_DIR / "products.csv",
    "orders": DATA_DIR / "orders.csv",
    "order_products_prior": DATA_DIR / "order_products__prior.csv",
    "order_products_train": DATA_DIR / "order_products__train.csv",
}

DTYPES = {
    "aisles": {"aisle_id": "Int64", "aisle": "string"},
    "departments": {"department_id": "Int64", "department": "string"},
    "products": {
        "product_id": "Int64",
        "product_name": "string",
        "aisle_id": "Int64",
        "department_id": "Int64",
    },
    "orders": {
        "order_id": "Int64",
        "user_id": "Int64",
        "eval_set": "string",
        "order_number": "Int64",
        "order_dow": "Int64",
        "order_hour_of_day": "Int64",
        "days_since_prior_order": "float64",
    },
    "order_products_prior": {
        "order_id": "Int64",
        "product_id": "Int64",
        "add_to_cart_order": "Int64",
        "reordered": "Int64",
    },
    "order_products_train": {
        "order_id": "Int64",
        "product_id": "Int64",
        "add_to_cart_order": "Int64",
        "reordered": "Int64",
    },
}


def convert_small_csv_to_parquet(name: str, input_path: Path) -> None:
    print(f"Processing {name}...")
    df = pd.read_csv(input_path, dtype=DTYPES[name])
    output_path = PARQUET_DIR / f"{name}.parquet"
    df.to_parquet(output_path, engine="pyarrow", index=False, compression="snappy")
    print(f"Saved {output_path} | Rows: {len(df):,}")


def convert_large_csv_to_parquet(name: str, input_path: Path, chunksize: int = 500_000) -> None:
    print(f"Processing large file {name}...")
    output_folder = PARQUET_DIR / name
    output_folder.mkdir(exist_ok=True)
    total_rows = 0

    for i, chunk in enumerate(pd.read_csv(input_path, dtype=DTYPES[name], chunksize=chunksize)):
        output_path = output_folder / f"part_{i:04d}.parquet"
        chunk.to_parquet(output_path, engine="pyarrow", index=False, compression="snappy")
        total_rows += len(chunk)
        print(f"Saved {output_path} | Rows: {len(chunk):,}")

    print(f"Completed {name} | Total rows: {total_rows:,}")


def main() -> None:
    for name, input_path in FILES.items():
        if not input_path.exists():
            print(f"Skipping {name}: file not found at {input_path}")
            continue

        if name in {"orders", "order_products_prior"}:
            convert_large_csv_to_parquet(name, input_path)
        else:
            convert_small_csv_to_parquet(name, input_path)

    print("All available CSV files converted to Parquet.")


if __name__ == "__main__":
    main()
