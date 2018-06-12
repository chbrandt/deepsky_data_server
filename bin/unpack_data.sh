#!/usr/bin/env bash
# set -ue
shopt -s nullglob

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

ARCHIVE_DIR="${DEEPSKY_ARCHIVE_DIR}"
[ -d "$ARCHIVE_DIR" ] || mkdir -p "$ARCHIVE_DIR"

# NOW=$(date +%s)

INPUT_GLOB='15*.tar'
FILES_EXTRACT='table_flux_detections.csv'
OUTPUT_FILE='table_flux_all.csv'

# function get_tgz_list () {
#   local FILES=(${INPUT_DIR}/${INPUT_GLOB})
#   [ ! -z "$FILES" ] && echo $FILES
# }

function extract_files () {
  local TARBALLS="$@"
  echo ""
  echo ${TARBALLS[*]}
  echo ""
  for TAR in ${TARBALLS[*]}; do
    echo "..extracting file $TAR.."
    TAR_DIR=$(basename $TAR)
    TAR_DIR=${TAR_DIR%.tar}
    mkdir ${OUTPUT_DIR}/${TAR_DIR}
    tar -x -f "$TAR" -C "${OUTPUT_DIR}/${TAR_DIR}"
    echo "..extraction succeded, moving file to archive.."
    [ $? ] && mv $TAR $ARCHIVE_DIR
  done
}

echo "Get the list of files from stage area.."
TARBALLS=(${INPUT_DIR}/${INPUT_GLOB})
if [[ ${#TARBALLS[*]} -gt 0 ]]; then
  echo "..${#TARBALLS[*]} files found"
  echo "Extract all files in tmp area.."
  extract_files ${TARBALLS[*]}
  echo "..done"
else
  echo "..no files found"
fi
