#!/usr/bin/env bash
set -e

if [ -z "$REEXEC_DONE" ]; then
    SOCK_GID=$(stat -c '%g' /var/run/docker.sock)

    if [ "$(id -u)" = "0" ]; then
        groupadd -o -g "$SOCK_GID" tempdocker 2>/dev/null || true
        usermod -aG "$SOCK_GID" vairogs || true
    else
        sudo groupadd -o -g "$SOCK_GID" tempdocker 2>/dev/null || true
        sudo usermod -aG "$SOCK_GID" "$(whoami)" || true

        export REEXEC_DONE=1
        exec su - "$(whoami)" -c "exec \"$0\" \"$@\""
    fi
fi

exec "$@"
