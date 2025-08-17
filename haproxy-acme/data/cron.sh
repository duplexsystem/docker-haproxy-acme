#!/bin/bash
set -e

if [ "$ACME_CRON" -ne 1 ] 2>/dev/null; then
    # Cronjob is disabled in configuration
    exit 0
fi

trap "exit 0" SIGTERM

args=(
    "--cron"
)

if [ "$ACME_DEBUG" -eq 1 ] 2>/dev/null; then
    args+=("--debug")
fi

# Determine interval based on ACME_VALID_TO
# Default: 24 hours (86400 seconds)
interval=86400

if [ -n "$ACME_VALID_TO" ]; then
    # Check if it's a relative format in hours
    if [[ "$ACME_VALID_TO" =~ ^\+([0-9]+)h$ ]]; then
        hours="${BASH_REMATCH[1]}"
        if [ "$hours" -le 24 ]; then
            interval=3600  # 1 hour
        fi
    fi
fi

echo "Running ACME cron every $((interval / 3600)) hour(s)"

while :
do
    now=$(date +%s) # timestamp in seconds
    sleep $((interval - now % interval)) & wait $!

    acme.sh "${args[@]}"
done
