FROM    ghcr.io/960018/php/fpm:latest AS builder

ARG     CACHE_BUSTER=default

USER    root

ENV     PHP_VERSION=8.5.0-dev
ENV     PHP_INI_DIR=/usr/local/etc/php
ENV     PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O3 -ftree-vectorize -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -march=native -mtune=native"
ENV     PHP_CPPFLAGS="$PHP_CFLAGS"
ENV     PHP_LDFLAGS="-Wl,-O3 -pie"

COPY    php/docker/docker-php-ext-enable    /usr/local/bin/docker-php-ext-enable
COPY    php/build/build-extensions.sh /tmp/build-extensions.sh
COPY    php/build/extensions-dev.json /tmp/extensions.json

WORKDIR /tmp

RUN    \
        set -eux \
&&      composer self-update --snapshot \
&&      mkdir --parents /tmp/extensions \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends --allow-downgrades make libc-dev libc6-dev gcc g++ cpp git dpkg-dev autoconf fontconfig

COPY    php/aspect/ /tmp/extensions/aspect/
COPY    php/pcov/ /tmp/extensions/pcov/
COPY    php/xdebug/ /tmp/extensions/xdebug/

RUN     \
        set -eux \
&&      chmod +x /tmp/build-extensions.sh \
&&      /tmp/build-extensions.sh \
&&      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false make libc-dev libc6-dev cpp gcc g++ autoconf dpkg-dev fontconfig \
&&      rm -rf \
            ~/.pearrc \
            /home/vairogs/*.deb \
            /home/vairogs/*.gz \
            /*.deb \
            /tmp/* \
            /usr/local/bin/docker-php-ext-enable \
            /usr/local/bin/phpdbg \
            /usr/local/php/man/* \
            /usr/src/php \
            /var/cache/* \
            /usr/share/vim/vim90/doc \
            /usr/local/bin/install-php-extensions \
            /usr/share/man/* \
            /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
            /usr/local/etc/php/php.ini \
&&      mv /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
&&      chown -R vairogs:vairogs /home/vairogs \
&&      echo 'alias upd="composer update -nW --ignore-platform-reqs"' >> /home/vairogs/.bashrc \
&&      echo 'alias ins="composer install -n --ignore-platform-reqs"' >> /home/vairogs/.bashrc \
&&      echo 'alias req="composer require -nW --ignore-platform-reqs"' >> /home/vairogs/.bashrc \
&&      echo 'alias rem="composer remove -nW --ignore-platform-reqs"' >> /home/vairogs/.bashrc

COPY    php/ini/opcache.no-jit.ini /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

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

RUN     \
        set -eux \
&&      git config --global --add safe.directory "*"

CMD     ["php-fpm"]
