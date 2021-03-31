#!/bin/bash

OLDDIR="$(pwd)"
cd /home/gmod/steamcmd

./steamcmd.sh \
    +login anonymous \
    +force_install_dir /home/gmod/server \
    +app_update 4020 -beta x86-64 validate \
    +quit

cd "$OLDDIR"
