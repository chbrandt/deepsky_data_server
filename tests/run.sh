#!/usr/bin/env bash

HERE=$(cd `dirname $BASH_SOURCE`; pwd)

DATA="${HERE}/data"

DIR_UPLOAD="${HERE}/../upload"

# =============================================================================
# Start fake daemons:
#
# - crontab: periodically run 'unpack_data' in 'stage/' dir
DELTA_CRONTAB='30'

bash << EOF
while true; do
  ${HERE}/../bin/unpack_data.sh
  sleep $DELTA_CRONTAB
done
EOF

# - inotify: (periodically) run add data to 'upload'
DELTA_INOTIFY='RANDOM'

bash << EOF
i=0
while true; do
  sleep $DELTA_INOTIFY
  FILES=$(ls -1 $DATA)
  FILE_i=${FILES[i]}
  cp ${DATA}/${FILE_i} ${DIR_UPLOAD}/.
  ${HERE}/../bin/mv_stage.sh _whatever_ $FILE_i $DIR_UPLOAD
done
EOF

# =============================================================================

# Copy a (random) file from 'tests/data' to 'upload'

# Run 'mv_stage'
