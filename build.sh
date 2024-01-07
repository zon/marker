#!/bin/bash

cargo build --release

podman build . --tag zvonimir/marker:latest
podman push zvonimir/marker:latest
