#!/bin/bash

set -e

helm upgrade --install --create-namespace --namespace marker marker charts/marker
