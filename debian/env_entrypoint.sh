#!/usr/bin/env bash

set -e

if [ -S /var/run/docker.sock ]; then
    SOCK_GID=$(stat -c '%g' /var/run/docker.sock)
    sudo groupadd -o -g "$SOCK_GID" tempdocker 2>/dev/null || true
    sudo usermod -aG "$SOCK_GID" vairogs || true
    newgrp
fi

exec "$@"
