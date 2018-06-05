#!/usr/bin/env bash
set -u

# This for is to avoid triggerings from hidden ('.*') files
for arg in "$@"
do
    [[ "$arg" != .?* ]] || exit 1
done

# The arguments are comming from incron; There order is:
# - event: $1
# - filename: $2
# - source directory: $3

EVENT="$1"
FILE="$2"
DIR="$3"

# Presumably, DIR is '$SOMEPATH/deepsky_upload', where new data packages arrive.
# Then LOGDIR is '$SOMEPATH/deepsky_upload/log'.
# We will then create a big, unique logfile at '$SOMEPATH/deepsky_upload/log/incron.log'.
#
LOGDIR="${DIR}/log"
LOGFILE="${LOGDIR}/incron.log"
LOGERROR="${LOGDIR}/incron.error.log"
[ -d "$LOGDIR" ] || mkdir $LOGDIR

# But!...each new file log information will go first (before appending to LOGFILE)
# to a temporary logfile.
# This is simply because we want to deal (properly) with concurrency:
# * keep logfile information consistent
# * avoid corrupting the master logfile
#
TMPLOGFILE=$(mktemp)

# Define some traps to exit (0/1) clean ;)
#
on_exit() {
  local LOG="$1"
  cat $TMPLOGFILE >> $LOG
  rm -f $TMPLOGFILE
}

on_error() {
  echo 'ERROR'                                                 >> $TMPLOGFILE
  echo '-----------------------------------------------------' >> $TMPLOGFILE
  on_exit $LOGERROR
}
trap on_error ERR

on_success() {
  echo 'END'                                                   >> $TMPLOGFILE
  echo '-----------------------------------------------------' >> $TMPLOGFILE
  on_exit $LOGFILE
}
trap on_success EXIT


# Finally... do something
#
echo "Writing (temp) log to: $TMPLOGFILE"

echo '-----------------------------------------------------' >> $TMPLOGFILE
echo 'BEGIN'                                                 >> $TMPLOGFILE
echo 'Date:' `date`                                          >> $TMPLOGFILE

HERE=$(cd `dirname $BASH_SOURCE`; pwd)
${HERE}/mv_stage.sh $@                                    &>> $TMPLOGFILE

exit 0

