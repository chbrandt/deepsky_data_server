#!/usr/bin/env bash
set -u
shopt -s nullglob

function fake_crontab_unpack () {
  # Argument "$1" is an integer value
  #
  local DELTA_CRONTAB="$1"

  while true; do
    ${HERE}/../bin/data_unpack.sh
    sleep "$DELTA_CRONTAB"
  done
}

function fake_crontab_table_temp () {
  # Argument "$1" is an integer value
  #
  local DELTA_CRONTAB="$1"

  while true; do
    ${HERE}/../bin/table_preproc.sh
    sleep "$DELTA_CRONTAB"
  done
}

function fake_inotify () {
  # Argument "$1" may be any integer number or the 'RANDOM' for dynamic values
  #
  local DELTA_INOTIFY="$1"

  local i=0
  while true; do

    SLEEP="$DELTA_INOTIFY"
    if [ "$DELTA_INOTIFY" = 'RANDOM' ]; then
      SLEEP=$(echo "scale=1; 10 * $RANDOM / 32767" | bc -l)
    fi
    sleep "$SLEEP"

    FILES=(${DATA}/*.tar)
    if [ "$i" -ge "${#FILES[@]}" ]; then
      echo "Data files (in $DATA) are finished. Finishing this process."
      return 0
    fi
    FILE_i=$(basename "${FILES[$i]}")

    # These lines effectivelly simulate 'incrontab' process:
    # - first, somebody moves/copy the file to monitored directory
    # - then, 'mv_stage.sh' is triggered with a signal, filename and dir
    #
    cp "${DATA}/${FILE_i}" "${DIR_UPLOAD}/."
    "${HERE}/../bin/data_move_stage.sh" _fakesignal_ "$FILE_i" "$DIR_UPLOAD"

    # # Check if copy was done right.
    # # Moved file should have a name starting with '15*'
    # #
    # FILE_MV=(${DIR_UPLOAD}/15*${FILE_i})
    # if [[ -z "$FILE_MV" || "${#FILE_MV[*]}" = 0 ]]; then
    #   echo "File NOT copied. Exiting"
    #   return 2
    # fi

    i=$((i+1))
  done
}
