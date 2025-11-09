# 🧠 StockAnalytica: MLOps Pipeline on GCP

## 📄 Overview

This project implements a **complete MLOps pipeline** for time-series stock price prediction using GCP services, DVC, and GitHub CI/CD workflows.  
It is developed in **four deliverables**, each focusing on a key MLOps concept — from data versioning to model training and tracking.

---

## 🚀 Deliverable Breakdown

### 🧩 **Deliverable 1: Data Version Control (DVC) Setup**

**Objective:**  
To set up and configure **DVC with Google Cloud Storage (GCS)** for data versioning and reproducibility.

**Key Steps:**
- Initialized DVC inside the Git repository.
- Added `gcsremote` (Google Cloud Storage bucket) as the DVC remote.
- Pushed versioned data (`StockAnalyticaData_v0` and `StockAnalyticaData_v1`) to GCS.
- Verified DVC integration using `dvc status` and `dvc push`.

**Important Files:**
| File | Description |
|------|--------------|
| `.dvc/config` | DVC configuration with remote setup |
| `.dvcignore` | Files ignored by DVC |
| `deliverable_1/scripts/setup_dvc.sh` | Initializes DVC and sets up remote GCS |
| `deliverable_1/scripts/dvc_add_and_push.sh` | Automates adding and pushing data to remote |
| `command.sh` | Shell script that executes all DVC setup commands |
| `requirements.txt` | List of Python dependencies for Deliverable 1 |

---

### ⚙️ **Deliverable 2: Data Processing Pipeline**

**Objective:**  
To create a preprocessing and feature engineering pipeline that prepares stock data for machine learning.

**Key Steps:**
- Reads multiple stock CSVs from GCS.
- Cleans missing values and adds engineered features (rolling average, volume sum, etc.).
- Splits data into **train/test sets**.
- Saves processed datasets to `deliverable_3/processed/iter2`.

**Important Files:**
| File | Description |
|------|--------------|
| `deliverable_3/data_processing.py` | Handles feature engineering and dataset preparation |
| `deliverable_3/merged_input_iter2/` | Input directory containing raw merged CSVs |
| `deliverable_3/processed/` | Stores final processed train/test CSVs |
| `requirements.txt` | Dependencies for pandas, numpy, and scikit-learn |

---

### 🤖 **Deliverable 3: Model Training and Evaluation**

**Objective:**  
To train, evaluate, and generate metrics for a lightweight ML model using scikit-learn.

**Key Steps:**
- Loads processed train/test datasets.
- Trains a simple logistic regression classifier.
- Saves model artifacts (`model.joblib`), predictions, and metrics.
- Produces `metrics.json` and `predictions.csv` for evaluation.

**Key Commands Used:**
```bash
python deliverable_3/train_eval.py \
  --processed-dir deliverable_3/processed/iter2 \
  --out-dir deliverable_3/artifacts/iter2 \
  --random-seed 42
