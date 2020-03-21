#!/bin/sh

echo "Building container"
podman build -t quay.io/wcaban/poc-virtualbmc:latest -f poc-virtualbmc.dockerfile

echo "Removing unreferenced images"
podman images --format "table {{.ID}} {{.Repository}}" | grep "<none>" | cut -d" " -f1 | podman rmi `xargs`
