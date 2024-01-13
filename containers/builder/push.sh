#!/bin/bash

set -ex

SOURCE=$(dirname $0)

IMAGE=zvonimir/marker-builder
VERSION=$(cat $SOURCE/version)

TAG=$IMAGE:$VERSION
AMD_TAG=$TAG-linux-amd64
ARM_TAG=$TAG-linux-arm64

cd $SOURCE

podman build --platform linux/amd64 --tag $AMD_TAG .
podman build --platform linux/arm64 --tag $ARM_TAG .

podman push $AMD_TAG
podman push $ARM_TAG

podman manifest create $TAG $AMD_TAG $ARM_TAG
podman manifest push $TAG $TAG
podman manifest rm $TAG
