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
