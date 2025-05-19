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

docker-php-entrypoint "$@"
