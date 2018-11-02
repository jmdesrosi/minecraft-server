#!/usr/bin/env bash

# Clean up docker to avoid any errors
docker stop mc 
docker rm mc

cd /src/minecraft/world
git add -A
git commit -m "World update" 
git push