#!/bin/bash

set -e

VERSION=$(cargo get package.version)
IMAGE=zvonimir/marker

# podman build  --platform linux/arm64 --tag $IMAGE:$VERSION .
podman tag $IMAGE:$VERSION $IMAGE:latest

podman push $IMAGE:$VERSION
podman push $IMAGE:latest
