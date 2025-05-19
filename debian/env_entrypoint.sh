#!/usr/bin/env bash
set -e

SOCK_GID=$(stat -c '%g' /var/run/docker.sock)

if [ "$(id -u)" = "0" ]; then
    groupadd -o -g "$SOCK_GID" tempdocker 2>/dev/null || true
    usermod -aG "$SOCK_GID" vairogs || true
    exec "$@"
else
    sudo groupadd -o -g "$SOCK_GID" tempdocker 2>/dev/null || true
    sudo usermod -aG "$SOCK_GID" vairogs || true
    exec su - vairogs -c "exec \"$0\" \"$@\""
fi
