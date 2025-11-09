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
