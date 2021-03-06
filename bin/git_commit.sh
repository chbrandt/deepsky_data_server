#!/usr/bin/bash
set -ue

# LOCK will avoid concurrence between instances of 'git_commit' function
#
LOCKGIT="/tmp/deepsky_git_table_flux.lock"

create_git_lock() {
  touch $LOCKGIT
}

remove_git_lock() {
  if [ -f $LOCKGIT ]; then
    rm $LOCKGIT
  fi
}

# Clean temp files when before leaving
#
clean_exit() {
  remove_git_lock
}
trap clean_exit EXIT ERR


git_commit() {
  # Arguments:
  local FILENAME="$1"
  local FILETYPE="$2"
  # local FILES="${@:2}"

  x=0
  while [ -f $LOCKGIT ]
  do
    sleep 1
    let x=x+1
    [ "$x" -lt "120" ] || { 1>&2 echo "Lock file got stuck."; exit 1; }
  done
  create_git_lock

  local REPO_DATA_DIR="${REPO_GAVO_DEEPSKY}/${FILETYPE}"
  [ -d "$REPO_DATA_DIR" ] || mkdir "$REPO_DATA_DIR"

  cp "$FILENAME" "${REPO_DATA_DIR}/."

  local FILEBASENAME=$(basename "$FILENAME")

  # Do the commit/push
  (
    cd "$REPO_DATA_DIR"
    git add "${FILEBASENAME}"
    DATE=$(date)
    git commit -am "Update ${FILETYPE} at $DATE"
    git push
  )

  remove_git_lock
}
