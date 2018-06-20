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

# If there is NO table in the "Test" directory, there is nothing to do
#
[ -f "$FILENAME_TEST" ] || exit 0

# Check if table in "Test" is being handled, wait if that's the case
#
while [ -f "$LOCK_TABLE_READ" ]; do
  sleep 10
done

# Copy the final table so that we can append the new (TEST) content to it,
# `table_proc_xmatch.py` will select the primary sources from such (combined) table
#
# if [ -f "$FILENAME_FINAL" ]; then
#   cp "$FILENAME_FINAL" "$FILENAME_FINAL_TMP"
#   tail -n +2 "$FILENAME_TEST" >> "$FILENAME_FINAL_TMP"
# else
  cp "$FILENAME_TEST" "$FILENAME_FINAL_TMP"
# fi

source activate xmatch
python "${HERE}/table_proc_xmatch.py" "$FILENAME_FINAL_TMP" "$FILENAME_FINAL"

rm "$FILENAME_FINAL_TMP"
rm "$FILENAME_TEST"
