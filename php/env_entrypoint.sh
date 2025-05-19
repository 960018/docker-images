#!/usr/bin/env bash

set -e

if [ "$(id -u)" = "0" ]; then
    if [ -t 0 ] && [ -t 1 ]; then
        exec "$@"
    fi

    if [ -S /var/run/docker.sock ]; then
        SOCK_GID=$(stat -c '%g' /var/run/docker.sock)
        groupadd -o -g "$SOCK_GID" tempdocker 2>/dev/null || true
        usermod -aG "$SOCK_GID" vairogs || true
    fi

    exec su - vairogs -c "exec script -q -c '$0 $*' /dev/null"
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
