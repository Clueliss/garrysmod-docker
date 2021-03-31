#!/bin/bash

STEAM_DIR="$1"
STEAMCMD_SCRIPT="$2"

OLDDIR="$(pwd)"
cd "$STEAM_DIR"
./steamcmd.sh +runscript $STEAMCMD_SCRIPT +quit
cd "$OLDDIR"
