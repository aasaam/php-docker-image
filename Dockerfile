# Copyright(c) 2021 aasaam software development group
FROM php:8-fpm-alpine

ENV LANG=en_US.UTF-8

COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN apk --no-cache update \
  && apk --no-cache upgrade \
  && apk add --no-cache \
    ca-certificates \
    curl \
    fribidi \
    pango-dev \
    gettext \
    gmp-dev \
    icu-dev \
    imagemagick imagemagick-dev \
    libxml2-dev \
    libzip-dev \
    p7zip \
    postgresql-dev \
    tidyhtml \
    tidyhtml-dev \
    font-noto font-noto-arabic \
    vips-dev \
    autoconf gcc make g++ \
  && docker-php-ext-install opcache gmp dom xml simplexml zip intl pdo_pgsql pdo_mysql tidy \
  # composer
  && chmod +x /usr/bin/composer \
  && /usr/bin/composer selfupdate \
  && rm /root/.composer -rf \
  # extensions
  && cd /tmp \
  && echo 'no' | pecl install -o -f apcu \
  && docker-php-ext-enable apcu \
  && pecl install -o -f igbinary \
  && docker-php-ext-enable igbinary \
  && echo 'yes' | pecl install -o -f vips \
  && docker-php-ext-enable vips \
  && echo 'yes' | pecl install -o -f redis \
  && docker-php-ext-enable redis \
  && pecl install -o -f xdebug \
  && docker-php-ext-enable xdebug \
  && echo "; xdebug disabled on production" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
  && curl -Ls 'https://github.com/Imagick/imagick/archive/master.tar.gz' -o imagick.tgz \
  && tar -xf imagick.tgz \
  && cd imagick-* \
  && phpize && ./configure && make && make install \
  && docker-php-ext-enable imagick \
  # cleanup
  && apk del -f autoconf gcc make g++ \
  && fc-cache -f \
  && cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
  && cd / \
  && rm -rf /var/cache/apk/* && rm -rf /tmp && mkdir /tmp && chmod 777 /tmp && truncate -s 0 /var/log/*.log \
  && echo "===================" \
  && php -i \
  && echo "===================" \
  && rm /root/.ash_history -rf

ADD config/entrypoint-common.sh /entrypoint-common.sh
ADD config/entrypoint-fpm.sh /entrypoint-fpm.sh
ADD config/entrypoint-worker.sh /entrypoint-worker.sh
ADD config/php/zz-config.ini /zz-config.ini
ENTRYPOINT [ "/entrypoint-fpm.sh" ]
CMD [ "php-fpm" ]
