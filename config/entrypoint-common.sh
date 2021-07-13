#!/bin/sh
set -e

# env configuration
if [ $ASM_PUBLIC_APP_TEST = "true" ]; then
  echo "Start test/development environment"
  export XDEBUG_PATH=`find /usr/local/lib/php/extensions -name xdebug.so` \
    && echo "zend_extension=$XDEBUG_PATH" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
else
  echo "Start production environment"
  echo "; xdebug disabled on production" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
fi

# global
echo "Configure php fpm"
echo "pm.max_children = ${CONFIGURE_PHP_FPM_MAX_CHILDREN}" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
  && echo "pm.start_servers = ${CONFIGURE_PHP_FPM_START_SERVERS}" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
  && echo "pm.min_spare_servers = ${CONFIGURE_PHP_FPM_MIN_SPARE_SERVERS}" >> /usr/local/etc/php-fpm.d/zz-docker.conf \
  && echo "pm.max_spare_servers = ${CONFIGURE_PHP_FPM_MAX_SPARE_SERVERS}" >> /usr/local/etc/php-fpm.d/zz-docker.conf

echo "Configure php.ini"
envsubst < /zz-config.ini > /usr/local/etc/php/conf.d/zz-config.ini
