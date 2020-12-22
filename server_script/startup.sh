#!/usr/bin/env bash

# Clean up docker to avoid any errors
function clearContainers () {
  CONTAINER_IDS=$(docker ps -aq | grep mc)
  if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" == " " ]; then
    echo "---- No containers available for deletion ----"
  else
    docker rm -f $CONTAINER_IDS
  fi
}

clearContainers

if [ -f /src/minecraft/world/startup.sh ]; then
  pushd /src/minecraft/world
  ./startup.sh
  popd
else 
  docker run -d --rm -p 25565:25565 -e EULA=TRUE -e RCON_PASSWORD=$1 -e INIT_MEMORY=8g -e MAX_MEMORY=16g -e USE_AIKAR_FLAGS=true -e VIEW_DISTANCE=8 -e GUI=FALSE -v /src/minecraft/world:/data --name mc itzg/minecraft-server
fi