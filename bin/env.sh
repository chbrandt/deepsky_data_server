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

DEEPSKY_PROC_INPUT="${DEEPSKY_PROC_ROOT}/stage/"
export DEEPSKY_PROC_INPUT
