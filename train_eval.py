#!/usr/bin/env python3
"""
Lightweight training & evaluation (to avoid memory issues).
Trains a small RandomForest or LogisticRegression model on a 10k-row sample.
"""

import argparse
import json
from pathlib import Path
import joblib
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, f1_score, precision_score, recall_score

FEATURE_COLS = ['rolling_avg_10', 'volume_sum_10']

def load_data(processed_dir: str):
    processed_dir = Path(processed_dir)
    train = pd.read_csv(processed_dir / "train.csv")
    test = pd.read_csv(processed_dir / "test.csv")
    return train, test

def prepare_features(df: pd.DataFrame):
    df = df.copy()
    df['stock_name_cat'] = df['stock_name'].astype('category').cat.codes
    X = df[FEATURE_COLS + ['stock_name_cat']].fillna(0.0)
    y = df['target'].astype(int)
    return X, y

def train_and_eval(train_df, test_df, out_dir: Path, seed: int = 42):
    out_dir.mkdir(parents=True, exist_ok=True)

    X_train, y_train = prepare_features(train_df)
    X_test, y_test = prepare_features(test_df)

    # 💡 sample down for quick training
    if len(X_train) > 10000:
        X_train = X_train.sample(10000, random_state=seed)
        y_train = y_train.loc[X_train.index]

    # ⚙️ use very small random forest (light model)
    clf = RandomForestClassifier(
        n_estimators=10, max_depth=5, random_state=seed, n_jobs=-1
    )
    clf.fit(X_train, y_train)

    y_pred = clf.predict(X_test)

    metrics = {
        "accuracy": float(accuracy_score(y_test, y_pred)),
        "f1": float(f1_score(y_test, y_pred, zero_division=0)),
        "precision": float(precision_score(y_test, y_pred, zero_division=0)),
        "recall": float(recall_score(y_test, y_pred, zero_division=0)),
        "n_train": int(len(X_train)),
        "n_test": int(len(X_test))
    }

    joblib.dump(clf, out_dir / "model.joblib")

    preds = test_df.copy()
    preds["prediction"] = y_pred
    preds.to_csv(out_dir / "predictions.csv", index=False)

    with open(out_dir / "metrics.json", "w") as f:
        json.dump(metrics, f, indent=2)

    print(f"[OK] Trained lightweight model -> {out_dir}")
    print(f"Metrics: {metrics}")
    return metrics

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--processed-dir", required=True)
    p.add_argument("--out-dir", required=True)
    p.add_argument("--random-seed", type=int, default=42)
    args = p.parse_args()

    train_df, test_df = load_data(args.processed_dir)
    train_and_eval(train_df, test_df, Path(args.out_dir), seed=args.random_seed)
