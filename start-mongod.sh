#!/bin/sh
# Check if the QUIET environment variable is set to "true"
if [ "$QUIET" = "true" ]; then
    # Redirect all output to /dev/null, only keeping error output
    exec /usr/local/bin/docker-entrypoint.sh --replSet rs0 --bind_ip_all --keyFile /data/mongo-keyfile --quiet 2>&1 > /dev/null
else
    # Normal startup without suppressing output
    exec /usr/local/bin/docker-entrypoint.sh --replSet rs0 --bind_ip_all --keyFile /data/mongo-keyfile
fi