#!/bin/bash

# Setup users
usermod -o -u "$PUID" -g "$PGID" -d /home/gmod steam

echo "
User
-------------------------------------
User uid:    $(id -u steam)
User gid:    $(id -g steam)"

# Set owner of directories
if [[ $PUID != 0 ]] || [[ $PGID != 0 ]]; then
    echo ""
    echo "Setting permissions, this may take a while..."
    chown -R steam:steam /home/gmod
fi

echo "-------------------------------------"
echo ""

# start server
exec su steam -P -c /home/gmod/start.sh
