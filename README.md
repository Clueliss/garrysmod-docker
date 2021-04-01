[![Garry's mod containers](https://i.imgur.com/QEGv6GM.png "Garry's mod containers")][docker-hub-repo]

# Garry's Mod server
Run a Garry's Mod server easily inside a docker container

## Supported tags
* `latest` - a gmod server based on debian
* `latest-x64` - (NOT STABLE YET) a gmod server based on debian but running on beta version of srcds for x64 bit CPUs

## Features

* Run a server under linux as any user
* Run a server under an anonymous steam user
* Run server commands normally
* Installed CSS content
* Production and development build

## Documentation

### Ports
The container uses the following ports (by default):
* `:27015 TCP/UDP` as the game transmission, pings and RCON port
* `:27005 UDP` as the client port

You can read more about these ports on the [official srcds documentation][srcds-connectivity].

### Environment variables

**`PUID` / `PGID`**

When mounting volumes permission issues between host and container arise. To ensure the container accesses the volumes as the correct user
the UID and GID can be set.

Default is `0` for both.

**`PRODUCTION`**

Set if the server should be opened in production mode. This will make hot reload modifications to lua files not working. Possible values are `0`(default) or `1`.

**`HOSTNAME`**

Set the server name on startup.

**`MAXPLAYERS`**

Set the maximum players allowed to join the server. Default is `16`.

**`GAMEMODE`**

Set the server gamemode on startup. Default is `sandbox`.

**`MAP`**

Set the map gamemode on startup. Default is `gm_construct`.

**`PORT`**

Set the server port on container. Default is `27015`.

**`CLIENTPORT`**

**Warning**: for some unknown reason this feature does not seem to work.

Set the client port on container. Default is `27005`.

**`GSLT`**

Set the server GSLT credential to be used.

**`ARGS`**

Set any other custom args you want to pass to srcds runner.


### Directory structure
It's not the full directory tree, I just put the ones I thought are most important.
I am not totally familliar with the behaviour of the `Source Dedicated Server`
but it seems that it sometimes overwrites changes, so _when possible_ try to mount volumes as `read only`.

```cs
📦/home/gmod // The server root
|__📁steamcmd // Steam cmd, used to update the server when needed
|__📁mounts // All third party games should be installed here
|  |  |__📁cstrike // Counter strike: Source comes installed as default
|__📁server
|  |__📁garrysmod
|  |  |__📁addons // Put your addons here
|  |  |__📁gamemodes // Put your gamemodes here
|  |  |__📁data
|  |  |__📁cache
|  |  |__📁cfg
|  |  |  |__⚙️server.cfg
|  |  |  |__⚙️server.vdf
|  |  |__📁lua
|  |  |__📁cfg
|  |  |__💾sv.db
|  |__📃srcds_run
|  |__📁steam_cache
|__📃start.sh // Script to start the server
|__📃init.sh // Init script for the container
```

## Examples


This will start a simple server in a container named `gmod-server`:
```sh
docker run \
    -p 27015:27015/udp \
    -p 27015:27015 \
    -p 27005:27005/udp \
    --name gmod-server \
    -it \
    clueliss/gmod-server
```

This will start a server with host workshop collection pointing to [382793424][workshop-example] named `gmod-server`:
```sh
docker run \
    -p 27015:27015/udp \
    -p 27015:27015 \
    -p 27005:27005/udp \
    -e ARGS="+host_workshop_collection 382793424" \
    -it \
    clueliss/gmod-server
```

This will start a server named `my server` in production mode pointing to a local addons with a custom gamemode:
```sh
docker run \
    -p 27015:27015/udp \
    -p 27015:27015 \
    -p 27005:27005/udp \
    -v $PWD/addons:/home/gmod/server/garrysmod/addons \
    -v $PWD/gamemodes:/home/gmod/server/garrysmod/gamemodes \
    -e HOSTNAME="my server" \
    -e PRODUCTION=1 \
    -e GAMEMODE=darkrp \
    -it \
    clueliss/gmod-server
```

You can create a new docker image using this image as base too:

```dockerfile
FROM clueliss/gmod-server:latest

COPY ./deathrun-addons /home/gmod/server/garrysmod/addons

ENV NAME="Deathrun ~ Have fun!"
ENV ARGS="+host_workshop_collection 382793424"
ENV MAP="deathrun_atomic_warfare"
ENV GAMEMODE="deathrun"
ENV MAXPLAYERS="24"
```

More examples can be found at [my real use case github repository][lory-repo].

## Health Check

This image contains a health check to continually ensure the server is online. That can be observed from the STATUS column of docker ps

```sh
CONTAINER ID        IMAGE                    COMMAND                 CREATED             STATUS                    PORTS                                                                                     NAMES
e9c073a4b262        clueliss/gmod-server     "/home/gmod/init.sh"   21 minutes ago      Up 21 minutes (healthy)   0.0.0.0:27005->27005/tcp, 27005/udp, 0.0.0.0:27015->27015/tcp, 0.0.0.0:27015->27015/udp   distracted_cerf
```

You can also query the container's health in a script friendly way:

```sh
> docker container inspect -f "{{.State.Health.Status}}" e9c073a4b262
healthy
```

## License

This image is under the [MIT license](licence).


[docker-hub-repo]: https://hub.docker.com/r/clueliss/gmod-server "Docker hub repository"

[srcds-connectivity]: https://developer.valvesoftware.com/wiki/Source_Dedicated_Server#Connectivity "Valve srcds connectivity documentation"

[workshop-example]: https://steamcommunity.com/sharedfiles/filedetails/?id=382793424 "Steam workshop collection"

[licence]: https://github.com/clueliss/garrysmod-docker/blob/master/LICENSE "Licence of use"
