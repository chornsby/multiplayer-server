#!/usr/bin/env bash
set -ex

sudo systemctl stop valheim.service
sudo apt-get update
sudo apt-get upgrade -y

pushd /home/ubuntu

box64 box64/tests/bash steamcmd/steamcmd.sh \
  +@sSteamCmdForcePlatformType linux \
  +force_install_dir $HOME/valheim_server \
  +login anonymous \
  +app_update 896660 validate \
  +quit

popd

sudo reboot
