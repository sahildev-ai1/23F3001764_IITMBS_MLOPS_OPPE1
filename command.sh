#!/usr/bin/env bash
set -euo pipefail

# ============ USER CONFIG (edit if needed) ============
BUCKET="gs://mlopsga1_data/oppeD1"            # where requirements.txt is stored
GCS_DVC_REMOTE="gs://mlopsga1_data/oppe1/dvc_remote"  # remote path for dvc
# Source data (can be gs:// paths or local paths already present on VM)
DATA_V0="gs://mlopsga1_data/oppe1/StockAnalyticaData/v0"
DATA_V1="gs://mlopsga1_data/oppe1/StockAnalyticaData/v1"
# service account key if you need to use one (optional)
SA_KEY_PATH=""  # e.g. /home/youruser/sa.json  (leave empty to use VM credentials)
# Git repo path (assumes you've already cloned your repo to this path)
REPO_DIR="$HOME/oppe1"  # change to your cloned repo root
# =====================================================

echo "Starting Deliverable 1 setup script..."
echo "Using bucket: $BUCKET"
echo "Repo dir: $REPO_DIR"

# 1) Fetch requirements.txt from bucket
mkdir -p /tmp/oppe_setup
echo "Fetching requirements.txt from $BUCKET ..."
gsutil cp "${BUCKET}/requirements.txt" /tmp/oppe_setup/requirements.txt

# 2) Create a python venv and install requirements
echo "Creating python venv..."
python3 -m venv /tmp/oppe_setup/venv
# shellcheck disable=SC1091
source /tmp/oppe_setup/venv/bin/activate

echo "Upgrading pip and installing requirements..."
python -m pip install --upgrade pip
pip install -r /tmp/oppe_setup/requirements.txt
pip install dvc-gs

# 3) Create .gitignore in repo root (if not present)
mkdir -p "$REPO_DIR"
cat > "$REPO_DIR/.gitignore" <<'EOF'
# Python
__pycache__/
*.pyc
venv/
.env

# DVC cache and temp
/.dvc/cache
/.dvc/tmp

# local data, models
data/
models/
*.ckpt
*.h5
*.pkl

# OS
.DS_Store
Thumbs.db

# jupyter
.ipynb_checkpoints/
EOF

echo ".gitignore created at $REPO_DIR/.gitignore"

# 4) Create deliverable scripts folder and scripts (setup_dvc.sh & dvc_add_and_push.sh)
mkdir -p "$REPO_DIR/deliverable_1/scripts"

cat > "$REPO_DIR/deliverable_1/scripts/setup_dvc.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

GCS_REMOTE_PATH="${1:-}"
SA_JSON_PATH="${2:-}"

if [ -z "$GCS_REMOTE_PATH" ]; then
  echo "Usage: $0 gs://your-bucket/path [service-account.json]"
  exit 1
fi

# Ensure dvc (with gcs) is installed in env where this runs
if ! command -v dvc >/dev/null 2>&1; then
  echo "DVC not found in PATH. Please run in environment where requirements installed."
  exit 1
fi

# init dvc (skip if already)
dvc init --no-scm || true

# use SA key if provided
if [ -n "$SA_JSON_PATH" ]; then
  export GOOGLE_APPLICATION_CREDENTIALS="$SA_JSON_PATH"
fi

REMOTE_NAME="gcsremote"
dvc remote remove $REMOTE_NAME >/dev/null 2>&1 || true
dvc remote add -d $REMOTE_NAME "$GCS_REMOTE_PATH"
echo "Configured dvc remote '$REMOTE_NAME' -> $GCS_REMOTE_PATH"
SH

cat > "$REPO_DIR/deliverable_1/scripts/dvc_add_and_push.sh" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

DATA_V0=${1:-}
DATA_V1=${2:-}

if [ -z "$DATA_V0" ]; then
  echo "Usage: $0 <path-to-data-v0> [path-to-data-v1]"
  exit 1
fi

copy_to_local() {
  SRC="$1"
  DEST="$2"
  if [[ "$SRC" == gs://* ]]; then
    echo "Copying $SRC to $DEST"
    mkdir -p "$DEST"
    gsutil -m cp -r "${SRC}/*" "$DEST/" || true
  else
    if [ ! -e "$SRC" ]; then
      echo "Source path $SRC does not exist"
      exit 1
    fi
    mkdir -p "$DEST"
    cp -r "$SRC/"* "$DEST/"
  fi
}

DVC_DATA_DIR="dvc_data"
mkdir -p "$DVC_DATA_DIR"

DEST_V0="$DVC_DATA_DIR/StockAnalyticaData_v0"
rm -rf "$DEST_V0"
copy_to_local "$DATA_V0" "$DEST_V0"
echo "Adding v0 to dvc: $DEST_V0"
dvc add "$DEST_V0"
git add "$DEST_V0.dvc" .dvc/config || true
git commit -m "dvc: add StockAnalyticaData v0" || true

if [ -n "$DATA_V1" ]; then
  DEST_V1="$DVC_DATA_DIR/StockAnalyticaData_v1"
  rm -rf "$DEST_V1"
  copy_to_local "$DATA_V1" "$DEST_V1"
  echo "Adding v1 to dvc: $DEST_V1"
  dvc add "$DEST_V1"
  git add "$DEST_V1.dvc"
  git commit -m "dvc: add StockAnalyticaData v1" || true
fi

echo "Pushing data to DVC remote..."
dvc push
echo "DVC push completed."
SH

# make scripts executable
chmod +x "$REPO_DIR/deliverable_1/scripts/"*.sh
echo "Deliverable scripts created: $REPO_DIR/deliverable_1/scripts/"

# 5) Move into repo and run the setup script (configure dvc remote)
cd "$REPO_DIR"
echo "Running deliverable_1/scripts/setup_dvc.sh with remote: $GCS_DVC_REMOTE"
if [ -n "$SA_KEY_PATH" ]; then
  bash deliverable_1/scripts/setup_dvc.sh "$GCS_DVC_REMOTE" "$SA_KEY_PATH"
else
  bash deliverable_1/scripts/setup_dvc.sh "$GCS_DVC_REMOTE"
fi

# 6) Run dvc add and push (this will copy data from DATA_V0 and DATA_V1 into repo/dvc_data and push to remote)
echo "Running deliverable_1/scripts/dvc_add_and_push.sh for DATA_V0 and DATA_V1 ..."
bash deliverable_1/scripts/dvc_add_and_push.sh "$DATA_V0" "$DATA_V1"

echo "All done. Check 'dvc status' and 'dvc remote list' in $REPO_DIR"
echo "If you need to push git changes, run: git push origin main (or your branch)"
