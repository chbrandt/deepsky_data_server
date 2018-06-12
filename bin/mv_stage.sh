#!/bin/bash
set -ue

# The arguments are comming from incron; There order is:
# - event: $1
# - filename: $2
# - source directory: $3

EVENT="$1"
FILE="$2"
DIR="$3"

echo "New file received: $FILE"
echo "Origin directory: $DIR"

# Read environment definitions
# source "${DIR}/env.sh"
HERE=$(cd `dirname $BASH_SOURCE`; pwd)
source "${HERE}/env.sh"

: ${DEEPSKY_STAGE_DIR:?'DeepSky data stage dir not defined.'}

UNIQ=`date +%s`"_${RANDOM}"

FILEOUT=$(echo `basename $FILE` | tr -d "[:space:]")
#FN="${FILEOUT%.*}"
#XT="${FILEOUT##*.}"
FILEOUT="${UNIQ}_${FILEOUT}"

# To avoid concurrence (specially when commit/fetching git)
# we'll place a short random sleep before proceeding
#WAIT=$(echo "scale=2 ; 3*$RANDOM/32768" | bc -l)
#WAIT=$(echo "scale=2 ; ${WAIT}*${WAIT}" | bc -l)
#sleep "$WAIT"s
#unset WAIT

OUTDIR=${DEEPSKY_STAGE_DIR}
[[ -d $OUTDIR ]] || mkdir -p $OUTDIR

echo "File new name: $FILEOUT"
echo "Destiny directory: $OUTDIR"

FILEIN="${DIR}/${FILE}"
FILETMP="${OUTDIR}/.${FILEOUT}"
FILEOUT="${OUTDIR}/${FILEOUT}"
cp -v "$FILEIN" "$FILETMP"
mv -v "$FILETMP" "$FILEOUT"
echo "File move complete"

rm -f $FILEIN && echo "Origin cleaned"
