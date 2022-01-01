#!/usr/bin/env bash
set -e

TODAY=$(date --iso-8601 --utc)

pushd valheim_data
zip -r "$TODAY" ./* -x ./*.zip
popd

mkdir -p backups
mv "valheim_data/$TODAY.zip" backups/
