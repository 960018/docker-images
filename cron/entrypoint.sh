#!/usr/bin/env bash

/usr/local/bin/update_crontab

# Start the original command
exec "$@"
