#!/usr/bin/env bash

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
    kill -15 $PID
  done
}
trap kill_procs INT #EXIT ERR


# Start fake daemons
# ------------------
# - crontab: periodically run 'unpack_data' in 'stage/' dir
DELTA_CRONTAB='10'
fake_crontab "$DELTA_CRONTAB" &
add_pid $!

# - inotify: (periodically) run add data to 'upload'
DELTA_INOTIFY='RANDOM'
fake_inotify "$DELTA_INOTIFY" &
add_pid $!

# =============================================================================

# Copy a (random) file from 'tests/data' to 'upload'

# Run 'mv_stage'

wait
echo "Finishing run test."
