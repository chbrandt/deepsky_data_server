#!/bin/bash
set -ue

THIS=$(basename $BASH_SOURCE)
HERE=$(cd `dirname $BASH_SOURCE`; pwd)

echo "----------------------------------------------------------------------"
echo "BEGIN: ($THIS) move upload data to stage area "

# This script is responsible for moving a file from the "Upload" directory
# to the "Stage" directory where the file will be eventually handled by
# another process.
# Every time a new file arrives (in "Upload") this script is triggered
# (currently, `incrontab/inotify` is the triggerer).
# This script handles one, and only one file.
# Its duty is to guarantee the file in hands will go to the "Stage" directory
# and NOT overwrite any old version of equally named uploaded file.
# Since uploaded files can have the same name, this script has to modify the
# filename at hands when moving it to "Stage". That is done by prepending the
# filename with the Unix time of file arrival AND a random value:
# Ex: (UNIX-TIME)_(RANDOM)_'filename'

# Directory "Stage" is defined in the environment file 'env.sh':
#
source "${HERE}/env.sh"

: ${DEEPSKY_STAGE_DIR:?'DeepSky data stage dir not defined.'}

# This script receives three arguments from the caller/triggerer (incontrab):
# - event: $1 -- inotify event; we're whatching 'ON_CREATE' (but not used here)
# - filename: $2 -- name of the uploaded 'file'
# - source directory: $3 -- the directory where 'file' wad uploaded to
EVENT="$1"
FILE="$2"
UPLOAD_DIR="$3"

echo "-> File received: $FILE"
echo "-> Origin directory: $UPLOAD_DIR"
echo "-> Event triggered: $EVENT"

TIME=$(date +%s)
RAND=${RANDOM}
UNIQ="${TIME}_${RAND}"
echo "Arrival time (unix epoch): $TIME"

FILEOUT=$(echo `basename $FILE` | tr -d "[:space:]")
FILEOUT="${UNIQ}_${FILEOUT}"

echo "-> File new name: $FILEOUT"
echo "-> Destiny directory: $DEEPSKY_STAGE_DIR"

FILEIN="${UPLOAD_DIR}/${FILE}"
FILETMP="${DEEPSKY_STAGE_DIR}/.${FILEOUT}"
FILEOUT="${DEEPSKY_STAGE_DIR}/${FILEOUT}"
cp -v "$FILEIN" "$FILETMP" && mv -v "$FILETMP" "$FILEOUT"
[ $? ] && echo "File move complete." || echo "File move failed."

echo "Cleaning upload dir.."
rm -f $FILEIN && echo "..dir cleaned"

echo "END ($THIS)"
echo "----------------------------------------------------------------------"
