#!/bin/bash

process_mounts() {
    MODE="$1"
    
    if [[ "$USEMOUNTCONF" != 1 ]]; then
        echo "skipping ${MODE} mountphase (envvar USEMOUNTCONF not set)"
        return 0
    fi

    echo "${MODE} mount phase"
    echo "-------------------------------------"

    cat /etc/mounttab.conf | sed 's/[[:space:]]/ /g' | tr -s ' ' | grep -vE '^#' | while read -r line; do
        src=$(echo $line | cut -d' ' -f1)
        target=$(echo $line | cut -d' ' -f2)
        mode=$(echo $line | cut -d' ' -f3)

        if [[ $mode == $MODE ]]; then
            echo "mounting /data/$src -> /home/gmod/$target"
            mount --bind "/data/$src" "/home/gmod/$target"
        fi
    done

    echo "-------------------------------------"
}


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
    chown steam:steam /data
fi

echo "-------------------------------------"

# early mounting
process_mounts early

# update server
echo "
Update
-------------------------------------
"

su steam -P -c /home/gmod/update.sh

echo "-------------------------------------"

# deferred mounting
process_mounts deferred

# start server
exec su steam -P -c /home/gmod/start.sh
