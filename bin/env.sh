#!/usr/bin/env bash -ue

HERE=$(cd `dirname $BASH_SOURCE`; pwd)

DEEPSKY_ROOT="${HERE}/../"

# Uploaded data (1st level) directories
#
DEEPSKY_STAGE_DIR="${DEEPSKY_ROOT}/stage/"
export DEEPSKY_STAGE_DIR

DEEPSKY_TEMP_DIR="${DEEPSKY_ROOT}/temp/"
export DEEPSKY_TEMP_DIR

DEEPSKY_ARCHIVE_DIR="${DEEPSKY_ROOT}/archive/"
export DEEPSKY_ARCHIVE_DIR

# Extracted data (2nd level) directories
#
DEEPSKY_PROC_ROOT="${DEEPSKY_ROOT}/processing/"

DEEPSKY_TABLE_SPOOL="${DEEPSKY_PROC_ROOT}/spool/"
export DEEPSKY_TABLE_SPOOL

DEEPSKY_TABLE_TEMP="${DEEPSKY_PROC_ROOT}/temp/"
export DEEPSKY_TABLE_TEMP

# Locker for table read/write
#
LOCK_TABLE_WRITE="${DEEPSKY_TABLE_SPOOL}/TABLE_WRITE.lock"
LOCK_TABLE_READ="${DEEPSKY_TABLE_SPOOL}/TABLE_READ.lock"
