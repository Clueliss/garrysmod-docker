#!/bin/bash

if [ -n "${HOSTNAME}" ];
then
    ARGS="+hostname \"${HOSTNAME}\" ${ARGS}"
fi

if [ -n "${GSLT}" ];
then
    ARGS="+sv_setsteamaccount \"${GSLT}\" ${ARGS}"
fi

if [ -n "${AUTHKEY}" ];
then
    ARGS="-authkey \"${AUTHKEY}\" ${ARGS}"
fi

if [ -n "${PRODUCTION}" ] && [ "${PRODUCTION}" -ne 0 ];
then
    MODE="production"
    ARGS="-disableluarefresh ${ARGS}"
else
    MODE="development"
    ARGS="-gdb gdb -debug ${ARGS}"
fi

# START THE SERVER
echo "Starting server on ${MODE} mode..."

exec /home/gmod/server/srcds_run_x64 \
    -game garrysmod \
    -norestart \
    -strictportbind \
    -port "${PORT}" \
    -clientport "${CLIENTPORT}" \
    -maxplayers "${MAXPLAYERS}" \
    +gamemode "${GAMEMODE}" \
    +map "${MAP}" "${ARGS}"
