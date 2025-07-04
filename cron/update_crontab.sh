#!/usr/bin/env bash

set -e # Exit immediately if a command exits with a non-zero status.

cron_folder="/cron/scripts/"
tmp_crontab="/tmp/crontab"

# Check if the main cron folder exists
if ! [ -d "$cron_folder" ]; then
    echo "Error: $cron_folder does not exist." >&2  # Redirect error to stderr
    exit 1
fi

> "$tmp_crontab"  # Clear the temporary file

# Find all files recursively within the cron folder and concatenate them
find "$cron_folder" -type f -print0 | xargs -0 cat >> "$tmp_crontab"

# Check if any cron jobs were found
if [ ! -s "$tmp_crontab" ]; then # -s checks if the file is not empty
    echo "Warning: No cron job files found in $cron_folder" >&2
    exit 0 # Consider this a success if no crons were provided intentionally
fi

# Install the crontab
if ! crontab -u vairogs "$tmp_crontab"; then
    echo "Error installing crontab for vairogs." >&2
    exit 1
fi

rm "$tmp_crontab"

echo "Crontab updated for 'vairogs'"
