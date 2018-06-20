#!/usr/bin/env bash
set -ue
shopt -s nullglob

THIS=$(basename $BASH_SOURCE)
HERE=$(cd `dirname $BASH_SOURCE`; pwd)

echo "----------------------------------------------------------------------"
echo "BEGIN: ($THIS) unpack/extract data files and archive data bundles"


# This script will periodically visit the uploaded files in "Stage" area and
# handle them accordingly. (As a reminder, _uploaded files in "Stage"_ are
# tarballs produced (and uploaded) by the Swift-DeepSky pipeline; they contain,
# for instance, flux tables which are of our primordial interest here.)
# Files (tar) in "Stage" will be:
# (i) unpacked to have the table files extracted,
# (ii) move the extracted data/table files to an "Spool" dir,
# (iii) move uploaded data bundles to an "Archival" area.
#
# This script is run periodically by Cron (crontab); there may be none file in
# "Stage" as well as thousands. Directories and (data/table) filenames are read
# from 'env.sh' file and 'processing/env.sh'.
#
source "${HERE}/env.sh"

if [ -s "${DEEPSKY_PROC_ROOT}/env.sh" ]; then
  source "${DEEPSKY_PROC_ROOT}/env.sh"
fi

: ${DEEPSKY_STAGE_DIR:?'DeepSky data stage dir not defined.'}
: ${DEEPSKY_TEMP_DIR:?'DeepSky temp dir not defined'}
: ${DEEPSKY_ARCHIVE_DIR:?'DeepSky archive dir not defined'}
: ${DEEPSKY_TABLE_SPOOL:?'DeepSky spool dir not defined'}

function remove_lock () {
  rm -f "$LOCK_TABLE_WRITE" 2> /dev/null
}
trap remove_lock ERR EXIT


FILEIN_FLUX_TABLE='table_flux_detections.csv'
INPUT_GLOB='15*.tar'


# Append the flux table from SOURCE_DIR to global "Spool" table
#
function read_flux_table () {
  local SOURCE_DIR="$1"

  local RUNID=$(ls -1 $SOURCE_DIR | head -n1)

  local FILEIN="${SOURCE_DIR}/${RUNID}/${FILEIN_FLUX_TABLE}"
  local FILEOUT="${DEEPSKY_TABLE_SPOOL}/${FILENAME_TABLE_FLUX}"

  # Check there is anybody else (for instance, `table_preproc.sh`) reading
  # the output table file. If busy, wait; when free, create a lock and proceed.
  #
  while [ -f "${LOCK_TABLE_READ}" ]; do
    echo "File '$FILEOUT' in use, wait.."
    SLEEP=$(echo "scale=1; 2 * $RANDOM / 32767" | bc -l)
    sleep $SLEEP
  done
  touch "$LOCK_TABLE_WRITE"

  cat "$FILEIN" >> "$FILEOUT"
  echo "File '$FILEIN' appended to '$FILEOUT'"

  # Remove lock
  remove_lock
}


# Extract data files (for instance, flux table) from data bundles
# and archive uploded bundle.
#
function extract_files () {
  local TARBALLS="$@"

  echo "Extract files in temp area:"
  for TAR in ${TARBALLS[*]}; do
    echo "..extracting file '$TAR'.."

    TAR_DIR=$(basename $TAR)
    TAR_DIR=${TAR_DIR%.tar}
    mkdir ${DEEPSKY_TEMP_DIR}/${TAR_DIR}

    tar -x -f "$TAR" -C "${DEEPSKY_TEMP_DIR}/${TAR_DIR}" || { echo "..extraction failed"; return 1; }

    read_flux_table "${DEEPSKY_TEMP_DIR}/${TAR_DIR}" || { echo "..extraction failed"; return 1; }

    echo "..moving data bundle to archive.."
    mv $TAR $DEEPSKY_ARCHIVE_DIR

    echo "..cleaning temporary files.."
    rm -rf "${DEEPSKY_TEMP_DIR}/${TAR_DIR}"
  done
}


echo "Get the list of files (data bundles) from stage area.."
TARBALLS=(${DEEPSKY_STAGE_DIR}/${INPUT_GLOB})
echo "..${#TARBALLS[*]} files found"

if [[ ${#TARBALLS[*]} -gt 0 ]]; then
  extract_files ${TARBALLS[*]}
  echo "..files extracted."
fi

echo "END ($THIS)"
echo "----------------------------------------------------------------------"
