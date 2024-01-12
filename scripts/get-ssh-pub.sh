#!/bin/bash

set -ex

NAMESPACE=${1:-marker}
NAME=${2:-git}

kubectl get secret -n $NAMESPACE $NAME -o json | jq '.data.sshPublicKey' -r | base64 -d
