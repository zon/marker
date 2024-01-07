#!/bin/bash

set -ex

VERSION=$(cargo get package.version)
IMAGE=zvonimir/marker

podman build . --tag $IMAGE:$VERSION
podman tag $IMAGE:$VERSION $IMAGE:latest

podman push $IMAGE:$VERSION
podman push $IMAGE:latest
