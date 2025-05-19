#!/usr/bin/env bash

set -e

if [ "$(id -u)" = "0" ]; then
    if [ -S /var/run/docker.sock ]; then
        SOCK_GID=$(stat -c '%g' /var/run/docker.sock)
        groupadd -o -g "$SOCK_GID" tempdocker 2>/dev/null || true
        usermod -aG "$SOCK_GID" vairogs || true
    fi

    echo "[entrypoint] Switching to vairogs with interactive TTY support"
    exec su - vairogs -c "exec script -q -c '$0 $*' /dev/null"
fi

exec "$@"
