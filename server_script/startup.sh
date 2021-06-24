#!/usr/bin/env bash

source /src/minecraft/script/server.env

# Clean up docker to avoid any errors
function clearContainers () {
  CONTAINER_IDS=$(docker ps -a | grep mc)
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    echo "---- No containers available for deletion ----"
  else
    docker rm -f mc
  fi
}

clearContainers

if [ -f /src/minecraft/world/startup.sh ]; then
  cd /src/minecraft/world && chmod +x ./startup.sh && ./startup.sh $RCON_PASSWORD
else 
  docker run -d --rm -p 25565:25565 -p 25575:25575 -e EULA=TRUE -e RCON_PASSWORD=$RCON_PASSWORD -e INIT_MEMORY=8g -e MAX_MEMORY=14g -e USE_AIKAR_FLAGS=true -e VIEW_DISTANCE=6 -e GUI=FALSE -e TYPE=PAPER -v /src/minecraft/world:/data --name mc itzg/minecraft-server
fi
