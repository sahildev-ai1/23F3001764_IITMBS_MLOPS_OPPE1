#!/usr/bin/env python3
"""
Create features and target for the stock dataset folder given.
Writes two files: train.csv (everything except last N rows) and test.csv (last N rows).
Usage:
    python data_processing.py --input-dir dvc_data/StockAnalyticaData_v0 --out-dir deliverable_3/processed/iter1 --test-rows 20
"""
import argparse
import os
from pathlib import Path

import numpy as np
import pandas as pd

def process_single_stock(csv_path: Path) -> pd.DataFrame:
    # Load csv
    df = pd.read_csv(csv_path, parse_dates=['timestamp'])
    # Ensure timezone-awareness may be present; convert to naive if needed
    if df['timestamp'].dt.tz is not None:
        df['timestamp'] = df['timestamp'].dt.tz_convert(None)
    df = df.sort_values('timestamp').reset_index(drop=True)
    df['stock_name'] = csv_path.stem.split('__')[0]
    # set index as timestamp for rolling by time
    df = df.set_index('timestamp')

    # Forward fill missing values
    df = df.ffill().bfill()

    # 10-minute rolling avg and volume sum. Input is minute-level; use rolling window of 10 observations.
    # If timestamps are strictly minute-by-minute, use window=10. Otherwise fallback to time-based.
    try:
        df['rolling_avg_10'] = df['close'].rolling(window=10, min_periods=1).mean()
        df['volume_sum_10'] = df['volume'].rolling(window=10, min_periods=1).sum()
    except Exception:
        # fallback to time-based
        df['rolling_avg_10'] = df['close'].rolling('10min', min_periods=1).mean()
        df['volume_sum_10'] = df['volume'].rolling('10min', min_periods=1).sum()

    # create future close shifted by -5 (5 minutes later)
    df['close_5min_future'] = df['close'].shift(-5)
    df['target'] = (df['close_5min_future'] > df['close']).astype(int)

    # Drop rows where target is NaN (last few rows)
    df = df.dropna(subset=['target'])

    # Flatten index back
    df = df.reset_index()

    # Keep relevant columns
    out_cols = ['timestamp', 'open', 'high', 'low', 'close', 'volume',
                'stock_name', 'rolling_avg_10', 'volume_sum_10', 'target']
    for c in out_cols:
        if c not in df.columns:
            df[c] = np.nan
    return df[out_cols]

def process_folder(input_dir: str, out_dir: str, test_rows: int = 20):
    input_dir = Path(input_dir)
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    all_dfs = []
    csvs = sorted([p for p in input_dir.glob("*.csv")])
    if not csvs:
        raise FileNotFoundError(f"No CSV files found in {input_dir}")

    for csv in csvs:
        print("Processing:", csv.name)
        df = process_single_stock(csv)
        all_dfs.append(df)

    combined = pd.concat(all_dfs, ignore_index=True, sort=False)
    # Sort by timestamp global (important)
    combined = combined.sort_values(['stock_name', 'timestamp']).reset_index(drop=True)

    # Per instructions: test set is last `test_rows` observations overall
    test_df = combined.tail(test_rows).copy()
    train_df = combined.iloc[:-test_rows].copy()

    train_path = out_dir / "train.csv"
    test_path = out_dir / "test.csv"
    train_df.to_csv(train_path, index=False)
    test_df.to_csv(test_path, index=False)

    print(f"Wrote train -> {train_path} ({len(train_df)} rows)")
    print(f"Wrote test  -> {test_path} ({len(test_df)} rows)")

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--input-dir", required=True, help="Path to folder with CSVs (local path)")
    p.add_argument("--out-dir", required=True, help="Output folder for processed train/test CSVs")
    p.add_argument("--test-rows", type=int, default=20, help="Number of rows to set aside as test")
    args = p.parse_args()
    process_folder(args.input_dir, args.out_dir, args.test_rows)