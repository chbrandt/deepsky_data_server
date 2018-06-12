#!/usr/bin/env bash

function fake_crontab () {
  # Argument "$1" is an integer value
  #
  local DELTA_CRONTAB="$1"

  while true; do
    ${HERE}/../bin/unpack_data.sh
    sleep "$DELTA_CRONTAB"
  done
}

function fake_inotify () {
  # Argument "$1" may be any integer number or the 'RANDOM' for dynamic values
  #
  local DELTA_INOTIFY="$1"

  local i=0
  while true; do
    echo "Loop $i:"

    SLEEP="$DELTA_INOTIFY"
    if [ "$DELTA_INOTIFY" = 'RANDOM' ]; then
      SLEEP=$(echo "scale=1; 10 * $RANDOM / 32767" | bc -l)
    fi
    sleep "$SLEEP"

    FILES=$(ls -1 "$DATA")
    if [ "$i" -ge "${#FILES[*]}" ]; then
      echo "Data files are finished. Exiting."
      exit
    fi
    FILE_i="${FILES[$i]}"

    echo cp "${DATA}/${FILE_i}" "${DIR_UPLOAD}/."
    echo "${HERE}/../bin/mv_stage.sh" _whatever_ "$FILE_i" "$DIR_UPLOAD"

    i=$((i+1))
  done
}
