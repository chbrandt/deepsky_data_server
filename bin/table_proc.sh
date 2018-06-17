#!/usr/bin/env bash
set -ue

# This script merge the alrealdy existing table in DEEPSKY_TABLE_FINAL
# to keep the unique, primary sources.

HERE=$(cd `dirname $BASH_SOURCE`; pwd)
source "${HERE}/env.sh"

if [ -s "${DEEPSKY_PROC_ROOT}/env.sh" ]; then
  source "${DEEPSKY_PROC_ROOT}/env.sh"
fi

FILENAME_TEST="${DEEPSKY_TABLE_TEMP}/${FILENAME_TABLE_FLUX}"
FILENAME_FINAL="${DEEPSKY_TABLE_FINAL}/${FILENAME_TABLE_FLUX}"
FILENAME_FINAL_TMP="${DEEPSKY_TABLE_FINAL}/${FILENAME_TABLE_FLUX}.tmp"

while [ -f "$LOCK_TABLE_READ"]; do
  sleep 10
done

cat "$FILENAME_TEST" >> "$FILENAME_FINAL"
mv "$FILENAME_FINAL" "$FILENAME_FINAL_TMP"

python table_proc_xmatch.py "$FILENAME_FINAL_TMP" "$FILENAME_FINAL"
