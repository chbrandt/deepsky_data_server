#!/usr/bin/env bash
set -ue
shopt -s nullglob

function do_inotify_job () {
  local UPLOAD_DIR="$1"

  FILES=(${UPLOAD_DIR}/*.tar)
  for FILE in ${FILES[*]}; do
    "${HERE}/../bin/data_move_stage.sh" _fakesignal_ "$FILE" "$UPLOAD_DIR"
    sleep 1
  done
}

do_inotify_job "$1"
