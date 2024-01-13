#!/bin/bash

set -ex

DIR=$(dirname $0)
SOURCE=$DIR/../..
cd $SOURCE

IMAGE=zvonimir/marker
VERSION=$(cargo get package.version)

cargo build --release

podman build --tag $IMAGE:$VERSION .
podman tag $IMAGE:$VERSION $IMAGE:latest

podman push $IMAGE:$VERSION
podman push $IMAGE:latest
