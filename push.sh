#!/bin/bash

set -ex

DIR=$(dirname $0)
IMAGE=zvonimir/marker

mkdir -p bin

cd src/marker

VERSION=$(cat version)

env GOOS=linux GOARCH=arm64 go build -o ../../bin .

cd ../..

podman build --platform linux/arm64 --tag $IMAGE:$VERSION .
podman tag $IMAGE:$VERSION $IMAGE:latest

podman push $IMAGE:$VERSION
podman push $IMAGE:latest
