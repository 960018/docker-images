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
        exec sudo -E -u "$(whoami)" env REEXEC_DONE=1 "$0" "$@"
    fi
fi

if [ -f /home/vairogs/environment/environment.txt ]; then \
	while IFS= read -r line; do \
		export "$line"; \
	done < /home/vairogs/environment/environment.txt; \
fi

echo "" > /home/vairogs/container_env.sh

while IFS='=' read -r key value; do
	if [ -n "$key" ]; then
		echo "export $key=\"$value\"" >> /home/vairogs/container_env.sh
	fi
done < /home/vairogs/environment/environment.txt

chmod +x /home/vairogs/container_env.sh

exec "$@"
