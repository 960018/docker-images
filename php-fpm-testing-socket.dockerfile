FROM    ghcr.io/960018/php/fpm-testing:latest

ARG     CACHE_BUSTER=default

USER    root

RUN     \
        set -eux \
&&      sed -i -e "s|listen = 9000|listen = /tmp/sockets/php-fpm.sock|g" /usr/local/etc/php-fpm.d/www.conf

USER    vairogs

ENV     FCGI_CONNECT=/tmp/sockets/php-fpm.sock
