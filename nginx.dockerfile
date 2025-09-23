FROM    nginx:mainline-bookworm AS builder

ARG     CACHE_BUSTER=default

ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive

SHELL   ["/bin/bash", "-o", "pipefail", "-c"]

COPY    global/01_nodoc  /etc/dpkg/dpkg.cfg.d/01_nodoc
COPY    global/02_nocache /etc/apt/apt.conf.d/02_nocache
COPY    global/compress  /etc/initramfs-tools/conf.d/compress
COPY    global/modules   /etc/initramfs-tools/conf.d/modules
COPY    global/90parallel   /etc/apt/apt.conf.d/90parallel

USER    root

RUN     \
        set -eux \
&&      usermod -l vairogs nginx \
&&      usermod -d /home/vairogs -m vairogs \
&&      groupmod -n vairogs nginx \
&&      usermod -u 1000 vairogs \
&&      groupmod -g 1000 vairogs \
&&      mkdir --parents /home/vairogs \
&&      mkdir --parents /etc/nginx/stream.d \
&&      mkdir --parents /etc/nginx/modules \
&&      echo >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /root/.bashrc \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends \
            bash procps telnet iputils-ping build-essential libpcre3-dev zlib1g-dev libssl-dev git wget cmake \
&&      NGINX_VERSION=$(nginx -v 2>&1 | sed 's/.*nginx\///; s/ .*//') \
&&      cd /tmp \
&&      wget "https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" \
&&      tar xzf "nginx-${NGINX_VERSION}.tar.gz" \
&&      git clone --recursive https://github.com/google/ngx_brotli.git \
&&      cd ngx_brotli/deps/brotli \
&&      mkdir out && cd out \
&&      cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF .. \
&&      cmake --build . --config Release --target brotlienc \
&&      cd /tmp/nginx-${NGINX_VERSION} \
&&      nginx -V 2>&1 | grep -o 'configure arguments: .*' | sed 's/configure arguments: //' > /tmp/nginx_args \
&&      eval "./configure $(cat /tmp/nginx_args) --with-compat --add-dynamic-module=../ngx_brotli" \
&&      make modules \
&&      cp objs/ngx_http_brotli_*.so /etc/nginx/modules/ \
&&      cd / && rm -rf /tmp/* \
&&      apt-get purge -y build-essential libpcre3-dev zlib1g-dev libssl-dev git wget cmake \
&&      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
&&      apt-get autoremove -y --purge \
&&      rm -rf \
            /etc/nginx/conf.d/* \
            /home/vairogs/*.deb \
            /*.deb \
            /tmp/* \
            /usr/share/man \
            /usr/share/doc \
            /usr/local/share/man \
            /var/lib/apt/lists/* \
            /usr/lib/python3.11/__pycache__ \
            /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh \
            /etc/nginx/nginx.conf \
&&      chown -R vairogs:vairogs /var/cache/nginx \
&&      chown -R vairogs:vairogs /var/log/nginx \
&&      chown -R vairogs:vairogs /etc/nginx/conf.d \
&&      chown -R vairogs:vairogs /etc/nginx/stream.d \
&&      chown -R vairogs:vairogs /etc/nginx/modules \
&&      touch /var/run/nginx.pid \
&&      chown -R vairogs:vairogs /var/run/nginx.pid \
&&      usermod -a -G dialout vairogs

RUN     ls -la /etc/nginx/modules/

COPY    nginx/nginx.conf /etc/nginx/nginx.conf

WORKDIR /var/www/html

FROM    ghcr.io/960018/scratch:latest

COPY    --from=builder / /

STOPSIGNAL SIGQUIT

EXPOSE  80
EXPOSE  443/tcp
EXPOSE  443/udp

WORKDIR /var/www/html

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD     ["nginx", "-g", "daemon off;"]

USER    vairogs