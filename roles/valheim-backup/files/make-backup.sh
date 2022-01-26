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
