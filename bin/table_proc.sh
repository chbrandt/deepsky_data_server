#!/usr/bin/env bash
set -ue

# This script merges the alrealdy existing table in DEEPSKY_TABLE_FINAL_DIR
# to keep the unique, primary sources.

HERE=$(cd `dirname $BASH_SOURCE`; pwd)
source "${HERE}/env.sh"

if [ -s "${DEEPSKY_PROC_ROOT}/env.sh" ]; then
  source "${DEEPSKY_PROC_ROOT}/env.sh"
fi

function remove_lock () {
  rm -f "$LOCK_TABLE_READ_TEMP" 2> /dev/null
}
trap remove_lock ERR EXIT


# Move table from the "Test" area to a temporary file to be combined with
# (possibly) existing "Final" table and xmatch/filter for primary sources.
# The concatenation of "Test" table to "Final" (if there is one already)
# is done *inside* the python script `table_proc_xmatch.py`.
#
function xmatch_table () {
  # local FILENAME_FINAL="${DEEPSKY_TABLE_FINAL_DIR}/${FILENAME_TABLE_FLUX}"
  local FILENAME_FINAL="$1"

  local FILENAME_TEST="${DEEPSKY_TABLE_TEMP_DIR}/${FILENAME_TABLE_FLUX}"
  local FILENAME_FINAL_TMP="${DEEPSKY_TABLE_FINAL_DIR}/${FILENAME_TABLE_FLUX}.tmp"

  # If there is NO table in the "Test" directory, there is nothing to do
  #
  [ -f "$FILENAME_TEST" ] || exit 0

  # Check if table in "Test" is being handled, wait if that's the case
  #
  while [ -f "$LOCK_TABLE_READ_SPOOL" ]; do
    sleep 10
  done
  touch "$LOCK_TABLE_READ_TEMP"

  # Move "Test" to the "Final" area; the *move* cleans the "Test" area for
  # subsequent "Test" table storage.
  #
  mv "$FILENAME_TEST" "$FILENAME_FINAL_TMP"

  # For the `xmatch` notice the (conda) virtualenv!
  #
  source activate xmatch
  python "${HERE}/table_proc_xmatch.py" "$FILENAME_FINAL_TMP" "$FILENAME_FINAL"

  rm "$FILENAME_FINAL_TMP"

  remove_lock
}

FILENAME_FINAL="${DEEPSKY_TABLE_FINAL_DIR}/${FILENAME_TABLE_FLUX}"

xmatch_table "$FILENAME_FINAL"

source "${HERE}/git_commit.sh"
git_commit "$FILENAME_FINAL" 'pub'
