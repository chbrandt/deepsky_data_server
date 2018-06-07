#!/usr/bin/env bash -ue

HERE=$(cd `dirname $BASH_SOURCE`; pwd)

DEEPSKY_ROOT="${HERE}/../"

DEEPSKY_STAGE_DIR="${DEEPSKY_ROOT}/stage/"
export DEEPSKY_STAGE_DIR

DEEPSKY_TEMP_DIR="${DEEPSKY_ROOT}/temp/"
export DEEPSKY_TEMP_DIR
