#!/usr/bin/env bash
# set -ue
shopt -s nullglob

HERE=$(cd `dirname $BASH_SOURCE`; pwd)
source "${HERE}/env.sh"

function remove_lock () {
  rm -f "$LOCK_TABLE_WRITE" 2> /dev/null
}
trap remove_lock ERR EXIT

# This script is meant to be called by `cron` every hour or so.

# This script will unpack all DeepSky results (.tgz) in  the staged area and
# move the files of interest to 'temp/' dirs.
# Files of interest are the flux tables, which will simply be moved to temp.
# The results tarball will then be moved to "archive".

: ${DEEPSKY_STAGE_DIR:?'DeepSky data stage dir not defined.'}
: ${DEEPSKY_TEMP_DIR:?'DeepSky temp dir not defined'}

INPUT_DIR="${DEEPSKY_STAGE_DIR}"

TEMP_DIR="${DEEPSKY_TEMP_DIR}"
[ -d "$TEMP_DIR" ] || mkdir -p "$TEMP_DIR"

OUTPUT_DIR="${DEEPSKY_PROC_SPOOL}"
[ -d "$OUTPUT_DIR" ] || mkdir -p "$OUTPUT_DIR"

ARCHIVE_DIR="${DEEPSKY_ARCHIVE_DIR}"
[ -d "$ARCHIVE_DIR" ] || mkdir -p "$ARCHIVE_DIR"

# NOW=$(date +%s)

INPUT_GLOB='15*.tar'

FILEIN_FLUX_TABLE='table_flux_detections.csv'
FILEOUT_FLUX_TABLE=('table_flux_all.csv')

# function get_tgz_list () {
#   local FILES=(${INPUT_DIR}/${INPUT_GLOB})
#   [ ! -z "$FILES" ] && echo $FILES
# }

function read_flux_table () {
  SOURCE_DIR="$1"
  RUNID=$(ls -1 $SOURCE_DIR | head -n1)
  while [ -f "${LOCK_TABLE_READ}" ]; do
    SLEEP=$(echo "scale=1; 2 * $RANDOM / 32767" | bc -l)
    sleep $SLEEP
  done
  touch "$LOCK_TABLE_WRITE"
  cat "${SOURCE_DIR}/${RUNID}/${FILEIN_FLUX_TABLE}" >> "${OUTPUT_DIR}/${FILEOUT_FLUX_TABLE}"
  remove_lock
}

function extract_files () {
  local TARBALLS="$@"
  echo ""
  echo ${TARBALLS[*]}
  echo ""
  for TAR in ${TARBALLS[*]}; do
    echo "..extracting file $TAR.."
    TAR_DIR=$(basename $TAR)
    TAR_DIR=${TAR_DIR%.tar}
    mkdir ${TEMP_DIR}/${TAR_DIR}
    tar -x -f "$TAR" -C "${TEMP_DIR}/${TAR_DIR}" || { echo "..extraction failed"; return 1; }
    read_flux_table "${TEMP_DIR}/${TAR_DIR}" || { echo "..extraction failed"; return 1; }
    echo "..extraction succeded, moving file to archive.."
    mv $TAR $ARCHIVE_DIR
    echo "..cleaning temporary files.."
    rm -rf "${TEMP_DIR}/${TAR_DIR}"
  done
}

echo "Get the list of files from stage area.."
TARBALLS=(${INPUT_DIR}/${INPUT_GLOB})
if [[ ${#TARBALLS[*]} -gt 0 ]]; then
  echo "..${#TARBALLS[*]} files found"
  echo "Extract all files in tmp area.."
  extract_files ${TARBALLS[*]}
  [ $? ] && echo "..done"
else
  echo "..no files found"
fi
