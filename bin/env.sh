#!/usr/bin/env bash -ue

HERE=$(cd `dirname $BASH_SOURCE`; pwd)

DEEPSKY_ROOT="${HERE}/../"

# Guarantee directories exist:
#
function create_dir () {
  local DIR="$1"
  [ -d "$DIR" ] || mkdir -p "$DIR"
}

# Uploaded data (1st level) directories
#
DEEPSKY_STAGE_DIR="${DEEPSKY_ROOT}/stage/"
create_dir "$DEEPSKY_STAGE_DIR"
export DEEPSKY_STAGE_DIR

DEEPSKY_TEMP_DIR="${DEEPSKY_ROOT}/temp/"
create_dir "$DEEPSKY_TEMP_DIR"
export DEEPSKY_TEMP_DIR

DEEPSKY_ARCHIVE_DIR="${DEEPSKY_ROOT}/archive/"
create_dir "$DEEPSKY_ARCHIVE_DIR"
export DEEPSKY_ARCHIVE_DIR

# Extracted data (2nd level) directories
#
DEEPSKY_PROC_ROOT="${DEEPSKY_ROOT}/processing/"

DEEPSKY_TABLE_SPOOL="${DEEPSKY_PROC_ROOT}/spool/"
create_dir "$DEEPSKY_TABLE_SPOOL"
export DEEPSKY_TABLE_SPOOL

DEEPSKY_TABLE_TEMP_DIR="${DEEPSKY_PROC_ROOT}/temp/"
create_dir "$DEEPSKY_TABLE_TEMP_DIR"
export DEEPSKY_TABLE_TEMP_DIR

DEEPSKY_TABLE_FINAL_DIR="${DEEPSKY_PROC_ROOT}/final/"
create_dir "$DEEPSKY_TABLE_FINAL_DIR"
export DEEPSKY_TABLE_FINAL_DIR

# Locker for table read/write
#
LOCK_TABLE_WRITE_SPOOL="${DEEPSKY_TABLE_SPOOL}/TABLE_WRITE.lock"
LOCK_TABLE_READ_SPOOL="${DEEPSKY_TABLE_SPOOL}/TABLE_READ.lock"
LOCK_TABLE_READ_TEMP="${DEEPSKY_TABLE_TEMP_DIR}/TABLE_READ.lock"

# Repository for GAVO tables
#
REPO_GAVO_DEEPSKY="${DEEPSKY_ROOT}/gavo_deepsky"
