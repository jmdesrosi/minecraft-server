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

docker run -d --rm -p 25565:25565 -e EULA=TRUE -e RCON_PASSWORD=$1 -v /src/minecraft/world:/data --name mc itzg/minecraft-server
