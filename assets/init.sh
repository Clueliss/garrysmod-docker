#!/bin/bash

process_mounts() {
    MODE="$1"
    
    if [[ "$USEMOUNTCONF" != 1 ]]; then
        echo "skipping ${MODE} mountphase (envvar USEMOUNTCONF not set)"
        return 0
    fi
    
    mountconf=$(cat /etc/gmounttab.conf | sed 's/[[:space:]]/ /g' | tr -s ' ' | grep -vE '^#')

    echo "
    ${MODE} mount phase
    -------------------------------------
    "

    for line in $mountconf; do
        src=$(echo $line | cut -d ' ' -f1)
        target=$(echo $line | cut -d ' ' -f2)
        mode=$(echo $line | cut -d ' ' -f3)

        if [[ $mode == $MODE ]]; then
            echo "mounting /data/$src -> /home/gmod/$target"
            mount --bind "/data/$src" "/home/gmod/$target"
        fi
    done

    echo "-------------------------------------"
}

set -e

START_SCRIPT="$1"

# Setup users
groupmod -o -g "$PGID" steam
usermod -o -u "$PUID" steam

echo "
User
-------------------------------------
User uid:    $(id -u steam)
User gid:    $(id -g steam)
-------------------------------------
"

# Set owner of directories
chown -R steam:steam /home/gmod
chown steam:steam /data || true

# early mounting
process_mounts early

# update server
echo "
Update
-------------------------------------
"

/home/gmod/update.sh /home/gmod/steamcmd /home/gmod/update.txt

echo "-------------------------------------"

# deferred mounting
process_mounts deferred

# switch user
su - steam

# start server
exec /usr/local/bin/ptyrun "$START_SCRIPT"
