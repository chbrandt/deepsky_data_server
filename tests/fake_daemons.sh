#!/usr/bin/env bash
set -xv
shopt -s nullglob

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
  echo '-----------------------------------------------------------------------'
  echo 'INOTIFY-fake'
  # echo "Loop frequency: $DELTA_INOTIFY"

  local i=0
  while true; do
    # echo "Loop $i:"

    SLEEP="$DELTA_INOTIFY"
    if [ "$DELTA_INOTIFY" = 'RANDOM' ]; then
      SLEEP=$(echo "scale=1; 10 * $RANDOM / 32767" | bc -l)
    fi
    # echo "Sleeping $SLEEP (s)"
    sleep "$SLEEP"

    FILES=(*.tar)
    # echo "Files in '$DATA': " $FILES
    if [ "$i" -ge "${#FILES[@]}" ]; then
      # echo "Data files are finished. Exiting."
      exit
    fi
    FILE_i="${FILES[$i]}"
    # echo "Chosen file: "$FILE_i

    # echo "Copying file to '$DIR_UPLOAD'.."
    echo cp "${DATA}/${FILE_i}" "${DIR_UPLOAD}/."
    # echo "..testing 'mv_stage.sh'.."
    echo "${HERE}/../bin/mv_stage.sh" _whatever_ "$FILE_i" "$DIR_UPLOAD"

    # Check if copy was done right.
    # Moved file should have a name starting with '15*'
    #
    FILE_MV=$(ls -1 "${DIR_UPLOAD}/15*${FILE_i}")
    if [[ -z "$FILE_MV" || "${#FILE_MV[*]}" = 0 ]]; then
      # echo "File NOT copied. Exiting"
      exit 2
    fi

    i=$((i+1))
  done
  echo '-----------------------------------------------------------------------'
}
