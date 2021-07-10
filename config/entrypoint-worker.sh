#!/bin/sh
set -e

/entrypoint-common.sh

exec "$@"
