#!/usr/bin/env bash
# set -ue

HERE=$(cd `dirname $BASH_SOURCE`; pwd)
source "${HERE}/env.sh"

# This script is meant to be called by `cron` every hour or so.

# This script will unpack all DeepSky results (.tgz) in  the staged area and
# move the files of interest to 'temp/' dirs.
# Files of interest are the flux tables, which will simply be moved to temp.
# The results tarball will then be moved to "archive".

: ${DEEPSKY_STAGE_DIR:?'DeepSky data stage dir not defined.'}
: ${DEEPSKY_TEMP_DIR:?'DeepSky temp dir not defined'}

INPUT_DIR="${DEEPSKY_STAGE_DIR}"
OUTPUT_DIR="${DEEPSKY_TEMP_DIR}"
[ -d "$OUTPUT_DIR" ] || mkdir -p "$OUTPUT_DIR"

# NOW=$(date +%s)

INPUT_GLOB='15*.tar'
FILES_EXTRACT='table_flux.csv'
OUTPUT_FILE='table_flux_all.csv'

function get_tgz_list () {
  local FILES=$(ls -1 "${INPUT_DIR}/${INPUT_GLOB}")
  [ ! -z "$FILES" ] && echo $FILES
}

function extract_files () {
  local TARBALLS="$1"
  for tgz in $TARBALLS; do
    tar -xz -O -f "$tgz" "$FILES_EXTRACT" >> "${OUTPUT_DIR}/${OUTPUT_FILE}"
  done
}

echo "Get the list of files from stage area.."
TARBALLS=$(get_tgz_list)
[ -z $TARBALLS ] && echo "..no files found" || echo "..${#TARBALLS[*]} files found"

if [ ! -z $TARBALLS]; then
  echo "Extract each and all files in tmp area.."
  extract_files "$TARBALLS"
  echo "..done"
fi
