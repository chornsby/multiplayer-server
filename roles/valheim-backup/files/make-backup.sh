#!/usr/bin/env bash
set -e

TODAY=$(date --iso-8601 --utc)

# Archive the current game data
pushd valheim_data
zip -r "$TODAY" ./* -x ./*.zip
popd

# Move the archive to the backups folder
mkdir -p backups
mv "valheim_data/$TODAY.zip" backups/

# Retain only the last 5 backups
find backups/ -name '*.zip' -type f |
  sort --reverse |
  tail --lines +6 |
  xargs -I {} rm -- {}
