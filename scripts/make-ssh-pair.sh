#!/bin/bash

set -ex

NAMESPACE=${1:-marker}
NAME=${2:-git}

PRIVATE_KEY=$NAME-id
PUBLIC_KEY=$NAME-id.pub

rm -f $PRIVATE_KEY
rm -f $PUBLIC_KEY

ssh-keygen -P "" -f $PRIVATE_KEY -C "zon@orange"

kubectl delete secret -n $NAMESPACE $NAME --ignore-not-found

kubectl create secret generic -n $NAMESPACE $NAME \
    --from-literal=type=git \
    --from-file=sshPrivateKey=$PRIVATE_KEY \
    --from-file=sshPublicKey=$PUBLIC_KEY

rm -f $PRIVATE_KEY
rm -f $PUBLIC_KEY
