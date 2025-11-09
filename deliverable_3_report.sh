$ echo "=============================="
echo "🔹 DELIVERABLE 3 STATUS REPORT"
echo "=============================="

# Step 1: Folder overview
echo
echo "📂 Folder Structure:"
ls -lh deliverable_3
echo

# Step 2: Check processed data files
echo "📊 Processed Data Files:"
ls -lh deliverable_3/processed/*/*.csv 2>/dev/null || echo "No processed data found"
echo

# Step 3: Show dataset summary (train/test shapes, sample rows)
echo "📈 Dataset Summary:"
python - <<'PY'
import pandas as pd, glob
train_files = glob.glob("deliverable_3/processed/*/train.csv")
test_files = glob.glob("deliverable_3/processed/*/test.csv")
for f in train_files + test_files:
    df = pd.read_csv(f)
    print(f"\nFile: {f}")
    print("Shape:", df.shape)
    print("Target distribution:\n", df['target'].value_counts(dropna=False).to_dict())
    print("Head:\n", df.head(2))
PY
echo

# Step 4: Show artifacts (metrics, model, predictions)
echo "🧠 Model Artifacts:"
ls -lh deliverable_3/artifacts/* 2>/dev/null
echo

echo "📋 Model Metrics:"
cat deliverable_3/artifacts/*/metrics.json 2>/dev/null || echo "No metrics found"
echo "✅ Deliverable 3 verification complete!"ed, zero_division=0):.3f}")f}")}")csv"))[-1])e, f1_score
==============================
🔹 DELIVERABLE 3 STATUS REPORT
==============================

📂 Folder Structure:
total 28K
drwxrwxr-x 5 satishsharma1911 satishsharma1911 4.0K Nov  9 13:09 artifacts
-rwxrwxr-x 1 satishsharma1911 satishsharma1911 3.8K Nov  9 12:32 data_processing.py
drwxrwxr-x 2 satishsharma1911 satishsharma1911 4.0K Nov  9 12:39 merged_input_iter2
drwxrwxr-x 4 satishsharma1911 satishsharma1911 4.0K Nov  9 13:06 processed
-rw-rw-r-- 1 satishsharma1911 satishsharma1911   35 Nov  9 12:32 requirements.txt
-rwxrwxr-x 1 satishsharma1911 satishsharma1911 1.9K Nov  9 12:32 run_deliverable3.sh
-rwxrwxr-x 1 satishsharma1911 satishsharma1911 2.7K Nov  9 12:52 train_eval.py

📊 Processed Data Files:
-rw-rw-r-- 1 satishsharma1911 satishsharma1911  17K Nov  9 13:07 deliverable_3/processed/iter2_bigtest/test.csv
-rw-rw-r-- 1 satishsharma1911 satishsharma1911 126M Nov  9 13:07 deliverable_3/processed/iter2_bigtest/train.csv
-rw-rw-r-- 1 satishsharma1911 satishsharma1911 1.7K Nov  9 12:56 deliverable_3/processed/iter2/test.csv
-rw-rw-r-- 1 satishsharma1911 satishsharma1911 126M Nov  9 12:56 deliverable_3/processed/iter2/train.csv

📈 Dataset Summary:

File: deliverable_3/processed/iter2_bigtest/train.csv
Shape: (1620148, 10)
Target distribution:
 {0: 917319, 1: 702829}
Head:
              timestamp   open   high    low  close  volume stock_name  rolling_avg_10  volume_sum_10  target
0  2017-01-02 03:45:00  340.0  340.0  340.0  340.0    11.0   AARTIIND           340.0           11.0       1
1  2017-01-02 03:46:00  340.0  340.0  340.0  340.0     0.0   AARTIIND           340.0           11.0       0

File: deliverable_3/processed/iter2/train.csv
Shape: (1620328, 10)
Target distribution:
 {0: 917414, 1: 702914}
Head:
              timestamp   open   high    low  close  volume stock_name  rolling_avg_10  volume_sum_10  target
0  2017-01-02 03:45:00  340.0  340.0  340.0  340.0    11.0   AARTIIND           340.0           11.0       1
1  2017-01-02 03:46:00  340.0  340.0  340.0  340.0     0.0   AARTIIND           340.0           11.0       0

File: deliverable_3/processed/iter2_bigtest/test.csv
Shape: (200, 10)
Target distribution:
 {0: 112, 1: 88}
Head:
              timestamp    open   high    low   close  volume stock_name  rolling_avg_10  volume_sum_10  target
0  2021-01-01 06:40:00  375.40  375.4  375.2  375.40   354.0   ADANIGAS         375.370        19651.0       0
1  2021-01-01 06:41:00  375.45  375.8  375.4  375.45   492.0   ADANIGAS         375.405        18857.0       0

File: deliverable_3/processed/iter2/test.csv
Shape: (20, 10)
Target distribution:
 {0: 17, 1: 3}
Head:
              timestamp    open   high     low   close   volume stock_name  rolling_avg_10  volume_sum_10  target
0  2021-01-01 09:40:00  376.80  376.9  376.75  376.75   3177.0   ADANIGAS         376.635        68046.0       1
1  2021-01-01 09:41:00  376.75  377.0  376.75  376.95  11794.0   ADANIGAS         376.675        78446.0       1

🧠 Model Artifacts:
deliverable_3/artifacts/iter1:
total 2.9G
-rw-rw-r-- 1 satishsharma1911 satishsharma1911  120 Nov  9 12:39 metrics.json
-rw-rw-r-- 1 satishsharma1911 satishsharma1911 2.9G Nov  9 12:39 model.joblib
-rw-rw-r-- 1 satishsharma1911 satishsharma1911 1.7K Nov  9 12:39 predictions.csv

deliverable_3/artifacts/iter2:
total 56K
-rw-rw-r-- 1 satishsharma1911 satishsharma1911  108 Nov  9 12:56 metrics.json
-rw-rw-r-- 1 satishsharma1911 satishsharma1911  47K Nov  9 12:56 model.joblib
-rw-rw-r-- 1 satishsharma1911 satishsharma1911 1.7K Nov  9 12:56 predictions.csv

deliverable_3/artifacts/iter2_bigtest:
total 64K
-rw-rw-r-- 1 satishsharma1911 satishsharma1911 109 Nov  9 13:09 metrics.json
-rw-rw-r-- 1 satishsharma1911 satishsharma1911 44K Nov  9 13:09 model.joblib
-rw-rw-r-- 1 satishsharma1911 satishsharma1911 16K Nov  9 13:09 predictions.csv

📋 Model Metrics:
{
  "accuracy": 0.15,
  "f1": 0.2608695652173913,
  "precision": 0.15789473684210525,
  "recall": 0.75,
  "n_test": 20
}{
  "accuracy": 0.56,
  "f1": 0.0,
  "precision": 0.0,
  "recall": 0.0,
  "n_train": 10000,
  "n_test": 200
}{
  "accuracy": 0.85,
  "f1": 0.0,
  "precision": 0.0,
  "recall": 0.0,
  "n_train": 10000,
  "n_test": 20
}
🔍 Predictions Preview:
==> deliverable_3/artifacts/iter1/predictions.csv <==
timestamp,open,high,low,close,volume,stock_name,rolling_avg_10,volume_sum_10,target,prediction
2021-01-01 09:40:00,88.75,88.85,88.55,88.55,33764.0,ABCAPITAL,89.055,870375.0,1,0
2021-01-01 09:41:00,88.7,88.75,88.55,88.6,10715.0,ABCAPITAL,88.95,550976.0,1,1
2021-01-01 09:42:00,88.6,88.9,88.6,88.8,43783.0,ABCAPITAL,88.885,411126.0,0,1
2021-01-01 09:43:00,88.9,89.0,88.8,89.0,12709.0,ABCAPITAL,88.845,349906.0,0,1

==> deliverable_3/artifacts/iter2_bigtest/predictions.csv <==
timestamp,open,high,low,close,volume,stock_name,rolling_avg_10,volume_sum_10,target,prediction
2021-01-01 06:40:00,375.4,375.4,375.2,375.4,354.0,ADANIGAS,375.37,19651.0,0,0
2021-01-01 06:41:00,375.45,375.8,375.4,375.45,492.0,ADANIGAS,375.405,18857.0,0,0
2021-01-01 06:42:00,375.45,375.75,375.1,375.15,2848.0,ADANIGAS,375.405,20997.0,0,0
2021-01-01 06:43:00,375.1,375.45,374.85,375.05,2149.0,ADANIGAS,375.34,10622.0,0,0

==> deliverable_3/artifacts/iter2/predictions.csv <==
timestamp,open,high,low,close,volume,stock_name,rolling_avg_10,volume_sum_10,target,prediction
2021-01-01 09:40:00,376.8,376.9,376.75,376.75,3177.0,ADANIGAS,376.635,68046.0,1,0
2021-01-01 09:41:00,376.75,377.0,376.75,376.95,11794.0,ADANIGAS,376.675,78446.0,1,0
2021-01-01 09:42:00,376.95,378.0,376.8,377.5,10600.0,ADANIGAS,376.77,86602.0,0,0
2021-01-01 09:43:00,377.5,377.65,377.05,377.4,3645.0,ADANIGAS,376.865,86477.0,0,0

📊 Model Evaluation Snapshot:
Test shape: (200, 10) | Pred shape: (200, 11)
Confusion matrix:
 [[112   0]
 [ 88   0]]
Accuracy:  0.560
Precision: 0.000
Recall:    0.000
F1 Score:  0.000

🧾 Git Version Info:
26c5517 (HEAD -> main, origin/main) Merge branch 'main' of https://github.com/23f3001764/23F3001764_IITMBS_MLOPS_OPPE1
eeea7e6 Deliverable1: restore DVC remote config, track v0 & v1 datasets, and push data to GCS
050adf5 dvc: add StockAnalyticaData v0
5625b44 dvc: add StockAnalyticaData v0
13a7d9c dvc: add StockAnalyticaData v1

✅ Deliverable 3 verification complete!
(venv) satishsharma1911@cloudshell:~/oppe1 (carbon-zone-473306-g5)$ 