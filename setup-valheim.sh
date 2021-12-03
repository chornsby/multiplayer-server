#!/usr/bin/env bash
set -ex

BOX64_VERSION="v0.1.6"
BOX86_VERSION="v0.2.4"
PORT_MAX=2458
PORT_MIN=2456
STEAMCMD_URL="https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz"
STEAM_GAME_ID=896660

# Install system dependencies
sudo dpkg --add-architecture armhf
sudo apt-get update
sudo apt-get full-upgrade --assume-yes
sudo apt-get install build-essential cmake gcc-arm-linux-gnueabihf git libc6:armhf libncurses5:armhf libstdc++6:armhf --assume-yes

# Build and install x86 emulator (to run steamcmd)
git clone --branch $BOX86_VERSION https://github.com/ptitSeb/box86
mkdir box86/build
pushd box86/build
cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
make --jobs 4
sudo make install
popd
sudo systemctl restart systemd-binfmt

# Build and install x64 emulator (to run game)
git clone --branch $BOX64_VERSION https://github.com/ptitSeb/box64
mkdir box64/build
pushd box64/build
cmake .. -DRPI4ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo
make --jobs 4
sudo make install
popd
sudo systemctl restart systemd-binfmt

# Install steamcmd (to download game server)
mkdir steamcmd
pushd steamcmd
curl -sqL $STEAMCMD_URL | tar zxvf -
./steamcmd.sh +quit
./steamcmd.sh +@sSteamCmdForcePlatformType linux +force_install_dir "$HOME"/valheim_server +login anonymous +app_update $STEAM_GAME_ID validate +quit
popd

# Allow incoming connections on game server ports
sudo iptables --insert INPUT --protocol tcp --destination-port $PORT_MIN:$PORT_MAX --jump ACCEPT
sudo iptables --insert INPUT --protocol udp --destination-port $PORT_MIN:$PORT_MAX --jump ACCEPT
sudo iptables-save

# TODO: Copy and rewrite start-server.sh to customise password etc
