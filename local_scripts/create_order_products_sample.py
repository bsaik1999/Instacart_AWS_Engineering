"""
Create a smaller sample from the full order_products__prior.csv file.
Useful for safe AWS Free Tier / credit usage.
"""

import pandas as pd

INPUT_FILE = r"C:\Users\SaiKrishna\OneDrive\Desktop\Instacart_AWS\data\order_products__prior.csv"
OUTPUT_FILE = r"C:\Users\SaiKrishna\OneDrive\Desktop\Instacart_AWS\data\order_products_prior_small.csv"

sample_size = 500_000

df = pd.read_csv(INPUT_FILE)
sample_df = df.sample(n=sample_size, random_state=42)
sample_df.to_csv(OUTPUT_FILE, index=False)

print(f"Reduced dataset created with {sample_size:,} rows")
print(f"Saved to: {OUTPUT_FILE}")
