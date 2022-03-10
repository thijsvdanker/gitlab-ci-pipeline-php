#!/usr/bin/env bash

set -euo pipefail

export extensions=" \
  bcmath \
  bz2 \
  calendar \
  exif \
  gmp \
  intl \
  opcache \
  pcntl \
  soap \
  xsl \
  zip
  "

export buildDeps=" \
    libbz2-dev \
    libsasl2-dev \
    pkg-config \
    "

export runtimeDeps=" \
    imagemagick \
    libfreetype6-dev \
    libgmp-dev \
    libicu-dev \
    libjpeg-dev \
    libkrb5-dev \
    libldap2-dev \
    libmagickwand-dev \
    libmemcached-dev \
    libmemcachedutil2 \
    libpng-dev \
    libpq-dev \
    libssl-dev \
    libuv1-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    "

apt-get update \
  && apt-get install -yq $buildDeps \
  && apt-get install -yq $runtimeDeps \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-install -j$(nproc) $extensions

docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
  && docker-php-ext-install -j$(nproc) gd \
  && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
  && docker-php-ext-install -j$(nproc) ldap \
  && PHP_OPENSSL=yes docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
  && docker-php-ext-install -j$(nproc) imap \
  && docker-php-source delete

docker-php-source extract \
  && git clone https://github.com/php-memcached-dev/php-memcached /usr/src/php/ext/memcached/ \
  && docker-php-ext-install memcached \
  && docker-php-ext-enable memcached \
  && docker-php-source delete

pecl channel-update pecl.php.net \
  && pecl install redis \
  && pecl install imagick \
  && pecl install sqlsrv \
  && pecl install pdo_sqlsrv \
  && docker-php-ext-enable redis imagick sqlsrv pdo_sqlsrv

pear install PHP_CodeSniffer

{ \
    echo 'opcache.enable=1'; \
    echo 'opcache.revalidate_freq=0'; \
    echo 'opcache.validate_timestamps=1'; \
    echo 'opcache.max_accelerated_files=10000'; \
    echo 'opcache.memory_consumption=192'; \
    echo 'opcache.max_wasted_percentage=10'; \
    echo 'opcache.interned_strings_buffer=16'; \
    echo 'opcache.fast_shutdown=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

echo 'memory_limit=1024M' > /usr/local/etc/php/conf.d/zz-conf.ini

apt-get purge -yqq --auto-remove $buildDeps
