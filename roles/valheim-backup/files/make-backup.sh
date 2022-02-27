#!/usr/bin/env bash
set -e

BACKUPS_FOLDER=backups/valheim
DATA_FOLDER=valheim_data
TODAY=$(date --iso-8601 --utc)

# Archive the current game data
pushd $DATA_FOLDER
zip -r "$TODAY" ./* -x ./*.zip
popd

# Move the archive to the backups folder
mkdir -p $BACKUPS_FOLDER
mv "$DATA_FOLDER/$TODAY.zip" $BACKUPS_FOLDER/

# Retain only the last 5 backups
find $BACKUPS_FOLDER/ -name '*.zip' -type f |
  sort --reverse |
  tail --lines +6 |
  xargs -I {} rm -- {}
