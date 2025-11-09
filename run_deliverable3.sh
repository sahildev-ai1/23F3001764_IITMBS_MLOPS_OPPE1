#!/usr/bin/env bash
set -euo pipefail

# This wrapper runs two iterations:
# Iteration 1: use v0 only
# Iteration 2: use v0 + v1 merged (we copy both into same processed dir)

REPO_ROOT="${1:-$HOME/oppe1}"   # change if your repo root different
WORKDIR="$REPO_ROOT/deliverable_3"
DVC_PULL=true   # change to false if data already available locally

# Input DVC-managed paths (these were the folders we tracked earlier)
DATA_V0_LOCAL="dvc_data/StockAnalyticaData_v0"
DATA_V1_LOCAL="dvc_data/StockAnalyticaData_v1"

# Activate venv
source /tmp/oppe_setup/venv/bin/activate

mkdir -p "$WORKDIR/processed"
mkdir -p "$WORKDIR/artifacts"

pushd "$REPO_ROOT" >/dev/null

if [ "$DVC_PULL" = true ]; then
  echo "Pulling DVC data (this will fetch remote data into dvc cache / workspace)..."
  dvc pull || true
fi

# --- Iteration 1: v0 only ---
ITER=1
echo "=== Iteration $ITER: using v0 only ==="
python deliverable_3/data_processing.py --input-dir "$DATA_V0_LOCAL" --out-dir "$WORKDIR/processed/iter${ITER}" --test-rows 20
python deliverable_3/train_eval.py --processed-dir "$WORKDIR/processed/iter${ITER}" --out-dir "$WORKDIR/artifacts/iter${ITER}" --random-seed 42

# --- Iteration 2: v0 + v1 (merged) ---
ITER=2
echo "=== Iteration $ITER: using v0 + v1 merged ==="
# create a temporary merged folder and copy v0 & v1 csvs there
MERGED_IN="$WORKDIR/merged_input_iter${ITER}"
rm -rf "$MERGED_IN"
mkdir -p "$MERGED_IN"
cp "$DATA_V0_LOCAL"/*.csv "$MERGED_IN/" || true
cp "$DATA_V1_LOCAL"/*.csv "$MERGED_IN/" || true

python deliverable_3/data_processing.py --input-dir "$MERGED_IN" --out-dir "$WORKDIR/processed/iter${ITER}" --test-rows 20
python deliverable_3/train_eval.py --processed-dir "$WORKDIR/processed/iter${ITER}" --out-dir "$WORKDIR/artifacts/iter${ITER}" --random-seed 42

popd >/dev/null

echo "Deliverable 3 finished. Artifacts are in $WORKDIR/artifacts"
