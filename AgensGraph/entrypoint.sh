#!/bin/bash
set -e

# starting the server
ag_ctl start
sleep 3

exec "$@"
