FROM    ghcr.io/960018/php/fpm-base:latest-base AS builder

USER    root

ENV     PHP_VERSION=8.5.0-dev
ENV     PHP_INI_DIR=/usr/local/etc/php
ENV     PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O3 -ftree-vectorize -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -march=native -mtune=native"
ENV     PHP_CPPFLAGS="$PHP_CFLAGS"
ENV     PHP_LDFLAGS="-Wl,-O3 -pie"

COPY    php/source/          /usr/src/php

COPY    php/docker/docker-php-entrypoint    /usr/local/bin/docker-php-entrypoint
COPY    php/docker/docker-php-ext-configure /usr/local/bin/docker-php-ext-configure
COPY    php/docker/docker-php-ext-enable    /usr/local/bin/docker-php-ext-enable
COPY    php/docker/docker-php-ext-install   /usr/local/bin/docker-php-ext-install
COPY    php/docker/docker-php-source        /usr/local/bin/docker-php-source

COPY    php/build/build-extensions.sh /tmp/build-extensions.sh
COPY    php/build/extensions.json /tmp/extensions.json

COPY    --from=composer:latest              /usr/bin/composer /usr/bin/

STOPSIGNAL SIGQUIT

WORKDIR /tmp

RUN    \
        set -eux \
&&      composer self-update --snapshot \
&&      mkdir --parents /tmp/extensions \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends --allow-downgrades make libc-dev libc6-dev gcc g++ cpp git dpkg-dev autoconf jq wget \
&&      apt-get install -y --no-install-recommends --allow-downgrades libpng16-16t64 libjpeg62-turbo libbrotli1 libwebp7 libfreetype6 \
&&      apt-get install -y --no-install-recommends --allow-downgrades zlib1g-dev libbrotli-dev libjpeg62-turbo-dev libpng-dev libwebp-dev libfreetype-dev \
&&      chmod -R 1777 /usr/local/bin \
&&      export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" \
&&      docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-webp=/usr/include/ \
&&      docker-php-ext-install gd \
&&      docker-php-ext-enable gd

COPY    php/apcu/ /tmp/extensions/apcu/
COPY    php/ext-ds/ /tmp/extensions/ext-ds/
COPY    php/igbinary/ /tmp/extensions/igbinary/
COPY    php/imagick/ /tmp/extensions/imagick/
COPY    php/mediawiki-php-excimer/ /tmp/extensions/mediawiki-php-excimer/
COPY    php/msgpack-php/ /tmp/extensions/msgpack-php/
COPY    php/pecl-event/ /tmp/extensions/pecl-event/
COPY    php/pecl-ev/ /tmp/extensions/pecl-ev/
COPY    php/pecl-file_formats-lzf/ /tmp/extensions/pecl-file_formats-lzf/
COPY    php/pecl-networking-uuid/ /tmp/extensions/pecl-networking-uuid/
COPY    php/php-ext-lz4/ /tmp/extensions/php-ext-lz4/
COPY    php/php-ext-zstd/ /tmp/extensions/php-ext-zstd/
COPY    php/php-inotify/ /tmp/extensions/php-inotify/
COPY    php/php-spx/ /tmp/extensions/php-spx/
COPY    php/php_zip/ /tmp/extensions/php_zip/
COPY    php/phpiredis/ /tmp/extensions/phpiredis/
COPY    php/phpredis/ /tmp/extensions/phpredis/
COPY    php/simdjson_php/ /tmp/extensions/simdjson_php/

RUN     \
        set -eux \
&&      chmod +x /tmp/build-extensions.sh \
&&      /tmp/build-extensions.sh \
&&      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false make libc-dev libc6-dev cpp gcc g++ autoconf dpkg-dev \
&&      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false zlib1g-dev libbrotli-dev libjpeg62-turbo-dev libpng-dev libwebp-dev libfreetype-dev \
&&      rm -rf \
            ~/.pearrc \
            /home/vairogs/*.deb \
            /home/vairogs/*.gz \
            /*.deb \
            /tmp/* \
            /usr/local/bin/docker-php-ext-configure \
            /usr/local/bin/docker-php-ext-enable \
            /usr/local/bin/docker-php-ext-install \
            /usr/local/bin/docker-php-source \
            /usr/local/bin/phpdbg \
            /usr/local/php/man/* \
            /usr/src/php \
            /var/cache/* \
            /usr/local/etc/php/php.ini-production \
            /usr/share/vim/vim90/doc \
            /usr/local/bin/install-php-extensions \
            /usr/share/man/*

WORKDIR /var/www/html

USER    vairogs

RUN    \
        set -eux \
&&      mkdir --parents /home/vairogs/environment \
&&      env | sed 's/^\([^=]*\)=\(.*\)$/\1=\2/' >> /home/vairogs/environment/environment.txt

FROM    ghcr.io/960018/scratch:latest

COPY    --from=builder / /

STOPSIGNAL SIGQUIT

WORKDIR /var/www/html

EXPOSE  9000

CMD     ["php-fpm"]
