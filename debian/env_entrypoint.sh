#!/usr/bin/env bash

set -e

if [ "$(id -u)" = "0" ]; then
    if [ -S /var/run/docker.sock ]; then
        SOCK_GID=$(stat -c '%g' /var/run/docker.sock)

        if ! getent group docker >/dev/null; then
            groupadd -g "$SOCK_GID" docker || true
        fi

        usermod -aG "$SOCK_GID" vairogs || true
    fi

    exec gosu vairogs "$0" "$@"
fi

exec "$@"
