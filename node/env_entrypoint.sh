#!/usr/bin/env bash

set -e

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

docker-entrypoint.sh "$@"
