#!/bin/sh
set -e

/entrypoint-common.sh

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

echo "Starting php-fpm..."

exec "$@"
