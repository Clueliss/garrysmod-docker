# BASE IMAGE
FROM debian:buster-slim

LABEL maintainer="Clueliss"
LABEL description="A structured Garry's Mod dedicated server under a debian linux image"

ENV DEBIAN_FRONTEND=noninteractive

# INSTALL NECESSARY PACKAGES
RUN dpkg --add-architecture i386 && \
	apt-get update && \
	apt-get -y --no-install-recommends --no-install-suggests install \
    psmisc wget ca-certificates tar gcc g++ lib32gcc1 libgcc1 libcurl4-gnutls-dev:i386 libssl1.1 libcurl4:i386 libtinfo5 lib32z1 lib32stdc++6 libncurses5:i386 libcurl3-gnutls:i386 gdb libsdl2-2.0-0:i386 libsdl1.2debian libfontconfig

# CLEAN UP
RUN apt-get clean
RUN rm -rf /tmp/* /var/lib/apt/lists/*

# CREATE STEAM USER
RUN useradd --no-create-home steam
RUN mkdir -p /home/gmod/server && mkdir /home/gmod/steamcmd

# INSTALL STEAMCMD
RUN wget -P /home/gmod/steamcmd/ https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz \
    && tar -xvzf /home/gmod/steamcmd/steamcmd_linux.tar.gz -C /home/gmod/steamcmd \
    && rm -rf /home/gmod/steamcmd/steamcmd_linux.tar.gz

# SETUP STEAMCMD TO DOWNLOAD GMOD SERVER
COPY assets/update.sh /home/gmod/update.sh
RUN chmod +x /home/gmod/update.sh && \
    /home/gmod/update.sh

# SETUP CSS CONTENT
RUN /home/gmod/steamcmd/steamcmd.sh +login anonymous \
    +force_install_dir /home/gmod/temp \
    +app_update 232330 validate \
    +quit
RUN mkdir /home/gmod/mounts && mv /home/gmod/temp/cstrike /home/gmod/mounts/cstrike
RUN rm -rf /home/gmod/temp

# SETUP BINARIES FOR x32 and x64 bits
RUN mkdir -p /home/gmod/.steam/sdk32 \
    && cp -v /home/gmod/steamcmd/linux32/steamclient.so /home/gmod/.steam/sdk32/steamclient.so \
    && mkdir -p /home/gmod/.steam/sdk64 \
    && cp -v /home/gmod/steamcmd/linux64/steamclient.so /home/gmod/.steam/sdk64/steamclient.so

# SET GMOD MOUNT CONTENT
RUN echo '"mountcfg" {"cstrike" "/home/gmod/mounts/cstrike"}' > /home/gmod/server/garrysmod/cfg/mount.cfg

# CREATE DATABASE FILE
RUN touch /home/gmod/server/garrysmod/sv.db

# CREATE CACHE FOLDERS
RUN mkdir -p /home/gmod/server/steam_cache/content && mkdir -p /home/gmod/server/garrysmod/cache/srcds

# USER ID AND GROUP ID
ENV PGID="0"
ENV PUID="0"

# PORT FORWARDING
# https://developer.valvesoftware.com/wiki/Source_Dedicated_Server#Connectivity
EXPOSE 27015/tcp
EXPOSE 27015/udp
EXPOSE 27005/udp

# SET ENVIRONMENT VARIABLES
ENV MAXPLAYERS="16"
ENV GAMEMODE="sandbox"
ENV MAP="gm_construct"
ENV PORT="27015"
ENV CLIENTPORT="27005"


# CREATE EMPTY MOUNTTAB
RUN touch /etc/mounttab.conf

# ADD INIT SCRIPT
COPY assets/init.sh /home/gmod/init.sh
RUN chmod +x /home/gmod/init.sh

# ADD START SCRIPT
COPY assets/start.sh /home/gmod/start.sh
RUN chmod +x /home/gmod/start.sh

# CREATE HEALTH CHECK
COPY assets/health.sh /home/gmod/health.sh
RUN chmod +x /home/gmod/health.sh
HEALTHCHECK --start-period=10s \
    CMD /home/gmod/health.sh

# START THE SERVER
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/home/gmod/init.sh"]
