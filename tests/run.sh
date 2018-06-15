#!/usr/bin/env bash

set -eE

HERE=$(cd `dirname $BASH_SOURCE`; pwd)

# LOGFILE="${HERE}/sds_test.log"

DATA="${HERE}/data"

DIR_UPLOAD="${HERE}/../upload"

source ${HERE}/fake_daemons.sh

# =============================================================================
# Manage fake daemons
# -------------------
PIDS=()

# define a function to stack the "daemons"
function add_pid () {
  PID="$1"
  PIDS[${#PIDS[@]}]="$PID"
}

# define a trap to clean background tasks
function kill_procs () {
  for PID in ${PIDS[@]}; do
    [ `kill -15 $PID` ] \
      && echo "Process $PID killed" \
      || echo "Process $PID was already dead"
  done
}
trap kill_procs INT ERR


# Start fake daemons
# ------------------

# - inotify: (periodically) run add data to 'upload'
DELTA_INOTIFY='RANDOM'
fake_inotify "$DELTA_INOTIFY" &
PID=$!
echo "Fake inotify PID: $PID"
add_pid $PID

# - crontab: periodically run 'unpack_data' in 'stage/' dir
DELTA_CRONTAB='5'
fake_crontab "$DELTA_CRONTAB" &
PID=$!
echo "Fake crontab PID: $PID"
add_pid $PID

unset PID
# =============================================================================

# Copy a (random) file from 'tests/data' to 'upload'

# Run 'mv_stage'

wait
echo "Finishing test."
