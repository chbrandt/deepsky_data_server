#!/usr/bin/env bash

HERE=$(cd `dirname $BASH_SOURCE`; pwd)

DATA="${HERE}/data"

DIR_UPLOAD="${HERE}/../upload"

source ${HERE}/fake_daemons.sh

# =============================================================================
# Start fake daemons:

# - crontab: periodically run 'unpack_data' in 'stage/' dir
DELTA_CRONTAB='10'
fake_crontab $DELTA_CRONTAB

# - inotify: (periodically) run add data to 'upload'
DELTA_INOTIFY='RANDOM'
fake_inotify $DELTA_INOTIFY

# =============================================================================

# Copy a (random) file from 'tests/data' to 'upload'

# Run 'mv_stage'
