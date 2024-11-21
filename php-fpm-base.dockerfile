FROM    ghcr.io/960018/curl:latest AS builder

ARG     PHP_COMMIT_HASH
ARG     ARCH

USER    root

ENV     PHP_VERSION=8.5.0-dev
ENV     PHP_INI_DIR=/usr/local/etc/php
ENV     PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O3 -ftree-vectorize -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -march=native -mtune=native"
ENV     PHP_CPPFLAGS="$PHP_CFLAGS"
ENV     PHP_LDFLAGS="-Wl,-O3 -pie"
ENV     PHP_CS_FIXER_IGNORE_ENV=1
ENV     PHP_COMMIT_HASH=${PHP_COMMIT_HASH}
ENV     PHP_BUILD_PROVIDER='https://github.com/960018/docker-images'
ENV     PHP_UNAME="Linux (${ARCH}) - Docker"

COPY    php/no-debian-php /etc/apt/preferences.d/no-debian-php
COPY    php/source/          /usr/src/php

COPY    php/docker/fpm/docker-php-entrypoint    /usr/local/bin/docker-php-entrypoint
COPY    php/docker/docker-php-ext-configure /usr/local/bin/docker-php-ext-configure
COPY    php/docker/docker-php-ext-enable    /usr/local/bin/docker-php-ext-enable
COPY    php/docker/docker-php-ext-install   /usr/local/bin/docker-php-ext-install
COPY    php/docker/docker-php-source        /usr/local/bin/docker-php-source

STOPSIGNAL SIGQUIT

WORKDIR /home/vairogs

RUN     \
        set -eux \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends --allow-downgrades make libc-dev libc6-dev gcc g++ cpp git dpkg-dev autoconf jq wget \
&&      apt-get install -y --no-install-recommends --allow-downgrades bison re2c valgrind libxml2 libssl3t64 libsqlite3-0 libbz2-1.0 libidn2-0 gdb-minimal \
        zstd libbrotli1 libpsl5t64 libgsasl18 rtmpdump librtmp1 libnghttp3-9 nghttp2 libonig5 libpq5 libsodium23 libargon2-1 libtidy58 libfcgi-bin \
        libzip4t64 libgmp10 zlib1g libffi8 libssh2-1t64 libldap-common libldap-2.5-0 \
&&      apt-get install -y --no-install-recommends --allow-downgrades libxml2-dev libssl-dev libsqlite3-dev libbz2-dev libidn2-dev libzstd-dev \
        libbrotli-dev libpsl-dev libgsasl-dev librtmp-dev libnghttp2-dev libnghttp3-dev libonig-dev libpq-dev libsodium-dev libargon2-dev libtidy-dev \
        libzip-dev libgmp-dev zlib1g-dev libffi-dev libssh2-1-dev libldap-dev libldap2-dev \
&&      chmod -R 1777 /usr/local/bin \
&&      mkdir --parents "$PHP_INI_DIR/conf.d" \
&&      [ ! -d /var/www/html ]; \
        mkdir --parents /var/www/html \
&&      chown vairogs:vairogs /var/www/html \
&&      chmod 1777 -R /var/www/html \
&&      export \
            CFLAGS="$PHP_CFLAGS" \
            CPPFLAGS="$PHP_CPPFLAGS" \
            LDFLAGS="$PHP_LDFLAGS" \
&&      cd /usr/src/php \
&&      gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
&&      ./buildconf --force \
&&      ./configure \
            --build="${gnuArch}" \
            --with-config-file-path="$PHP_INI_DIR" \
            --with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
            --disable-cgi \
            --disable-ftp \
            --disable-short-tags \
            --disable-mysqlnd \
            --disable-phpdbg \
            --enable-bcmath \
            --enable-calendar \
            --enable-exif \
            --enable-fpm \
            --enable-huge-code-pages \
            --enable-intl \
            --enable-mbstring \
            --enable-opcache \
            --enable-option-checking=fatal \
            --enable-sysvsem \
            --enable-sysvshm \
            --enable-sysvmsg \
            --enable-shmop \
            --enable-soap \
            --enable-sockets \
            --with-bz2 \
            --with-curl \
            --with-ffi \
            --with-fpm-group=vairogs \
            --with-fpm-user=vairogs \
            --with-gmp \
            --with-openssl \
            --with-password-argon2 \
            --with-pear \
            --with-pic \
            --with-pdo-pgsql \
            --with-pdo-sqlite=/usr \
            --with-sodium=shared \
            --with-sqlite3=/usr \
            --with-tidy \
            --with-valgrind \
            --without-readline \
&&      make \
&&      find -type f -name '*.a' -delete \
&&      make install \
&&      find /usr/local -type f -perm '/0111' -exec sh -euxc ' strip --strip-all "$@" || : ' -- '{}' + \
&&      make clean \
&&      mkdir --parents "$PHP_INI_DIR" \
&&      cp -v php.ini-* "$PHP_INI_DIR/" \
&&      cd / \
&&      pecl update-channels \
&&      rm -rf \
            /tmp/pear \
            ~/.pearrc \
&&      php --version \
&&      mkdir --parents "$PHP_INI_DIR/conf.d" \
&&      chmod -R 1777 /usr/local/bin \
&&      mkdir --parents --mode=777 --verbose /run/php-fpm \
&&      touch /run/php-fpm/.keep_dir \
&&      wget -O /usr/local/bin/php-fpm-healthcheck https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
&&      chmod +x /usr/local/bin/php-fpm-healthcheck \
&&      chown www-data:www-data /usr/local/bin/php-fpm-healthcheck \
&&      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false make libc-dev libc6-dev cpp gcc g++ autoconf dpkg-dev \
&&      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false libxml2-dev libssl-dev libsqlite3-dev libbz2-dev libidn2-dev \
        libzstd-dev libbrotli-dev libpsl-dev libgsasl-dev librtmp-dev libnghttp2-dev libnghttp3-dev libonig-dev libpq-dev libsodium-dev \
        libargon2-dev libtidy-dev libzip-dev libgmp-dev zlib1g-dev libffi-dev libssh2-1-dev libldap-dev libldap2-dev \
&&      mkdir --parents /var/lib/php/sessions \
&&      chown -R vairogs:vairogs /var/lib/php/sessions \
&&      mkdir --parents /var/lib/php/opcache \
&&      chown -R vairogs:vairogs /var/lib/php/opcache \
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
            /usr/local/etc/php-fpm.conf \
            /usr/local/etc/php-fpm.d/* \
            /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
            /usr/local/etc/php/php.ini \
            /usr/local/php/man/* \
            /usr/src/php \
            /var/cache/* \
            /usr/share/vim/vim90/doc \
            /usr/local/bin/install-php-extensions \
            /usr/share/man/* \
            /home/vairogs/env_entrypoint.sh \
            /usr/lib/python3.12/__pycache__ \
            /usr/lib/python3.12/__phello__ \
            /usr/lib/python3.12/__hello__.py \
&&      mv /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

COPY    php/ini/fpm/php-fpm.conf /usr/local/etc/php-fpm.conf
COPY    php/ini/fpm/www.conf /usr/local/etc/php-fpm.d/www.conf
COPY    php/ini/fpm/zz.ini /usr/local/etc/php/conf.d/zz.ini
COPY    php/ini/opcache.ini /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
COPY    php/preload.php /var/www/preload.php

RUN     \
        set -eux \
&&      chmod 644 /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \
&&      git config --global --add safe.directory "*" \
&&      chown -R vairogs:vairogs /home/vairogs \
&&      chown vairogs:vairogs /var/www/preload.php

WORKDIR /var/www/html

USER    vairogs

RUN    \
        set -eux \
&&      mkdir --parents /home/vairogs/environment \
&&      env | sed 's/^\([^=]*\)=\(.*\)$/\1=\2/' >> /home/vairogs/environment/environment.txt

COPY    --chmod=0755 php/env_entrypoint.sh /home/vairogs/env_entrypoint.sh

FROM    ghcr.io/960018/scratch:latest

COPY    --from=builder / /

STOPSIGNAL SIGQUIT

WORKDIR /var/www/html

EXPOSE  9000

CMD     ["php-fpm"]
