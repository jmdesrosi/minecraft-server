#!/usr/bin/env bash

source /src/minecraft/script/server.env

# Clean up docker to avoid any errors
docker stop mc
docker rm mc

if [ -f /src/minecraft/world/shutdown.sh ]; then
  cd /src/minecraft/world && chmod +x ./shutdown.sh && ./shutdown.sh
fi

cd /src/minecraft/world 

git add -A
git commit -m "World update"
git push