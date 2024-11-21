FROM    debian:sid-slim AS builder

ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive

SHELL   ["/bin/bash", "-o", "pipefail", "-c"]

COPY    global/01_nodoc   /etc/dpkg/dpkg.cfg.d/01_nodoc
COPY    global/02_nocache /etc/apt/apt.conf.d/02_nocache
COPY    global/compress   /etc/initramfs-tools/conf.d/compress
COPY    global/modules    /etc/initramfs-tools/conf.d/modules
COPY    global/90parallel /etc/apt/apt.conf.d/90parallel

COPY    --chmod=0755 global/wait-for-it.sh /usr/local/bin/wait-for-it

USER    root

RUN     \
        set -eux \
&&      groupadd --system --gid 1000 vairogs \
&&      useradd --system --uid 1000 -g vairogs --shell /bin/bash --home /home/vairogs vairogs \
&&      passwd -d vairogs \
&&      usermod -a -G dialout vairogs

WORKDIR /home/vairogs

RUN     \
        set -eux \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends vim-tiny tzdata bash ca-certificates procps iputils-ping telnet unzip apt-utils pkg-config \
&&      echo 'alias ll="ls -lahs"' >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /root/.bashrc \
&&      chown vairogs:vairogs /usr/local/bin/wait-for-it \
&&      chmod +x /usr/local/bin/wait-for-it \
&&      ln -sf /usr/bin/vi /usr/bin/vim \
&&      chown -R vairogs:vairogs /home/vairogs

WORKDIR /home/vairogs

COPY    curl/source/ /home/vairogs/curl
COPY    curl/wolfssl/ /home/vairogs/wolfssl
COPY    curl/ngtcp2/ /home/vairogs/ngtcp2
COPY    curl/nghttp3/ /home/vairogs/nghttp3

RUN     \
        set -eux \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends make automake autoconf libtool ca-certificates gcc g++ libbrotli1 libbrotli-dev zstd libzstd-dev librtmp-dev librtmp1 rtmpdump pkg-config \
        libgsasl-dev libgsasl18 libpsl-dev perl libnghttp2-dev nghttp2 libssl-dev libssl3t64 libpsl5t64 libssh2-1-dev libssh2-1t64 libldap-dev libldap2-dev libldap-common libldap-2.5-0 \
&&      cd nghttp3 \
&&      autoreconf -fi \
&&      ./configure --prefix=/usr/local --enable-lib-only \
&&      make \
&&      make install \
&&      cd ../wolfssl \
&&      autoreconf -fi \
&&      ./configure --enable-session-ticket --enable-earlydata --enable-psk --enable-altcertchains --disable-examples \
                    --enable-dtls --enable-sctp --enable-opensslextra --enable-opensslall --enable-sniffer --enable-sha512 \
                    --enable-ed25519 --enable-rsapss --enable-base64encode --enable-tlsx --enable-scrypt --disable-crypttests \
                    --enable-fastmath --enable-harden --enable-quic --enable-all --enable-experimental --enable-aesgcm \
                    --enable-chacha --enable-alpn --enable-certgen --enable-certreq --enable-ecc --enable-dtls-mtu \
                    --enable-curve25519 --enable-pkcs11 --enable-aesxts --enable-aesccm --enable-aeseax --enable-aessiv \
                    --enable-aesctr --enable-aesofb --enable-aescfb --enable-aeskeywrap --enable-sp --enable-heapmath \
                    --enable-certgencache --enable-dilithium --enable-iopool --enable-wolfsentry \
                    --enable-wpas --enable-haproxy --enable-libssh2 --enable-signal --enable-openldap --enable-memcached \
                    --enable-mosquitto --enable-dtls13 --enable-secure-renegotiation --enable-wolftpm --enable-rwlock \
                    --enable-libwebsockets --enable-dtls-frag-ch \
&&      make \
&&      make install \
&&      cd ../ngtcp2 \
&&      autoreconf -fi \
&&      ./configure LDFLAGS="-Wl,-rpath,/usr/local/lib" --prefix=/usr/local --with-wolfssl --enable-lib-only \
&&      make \
&&      make install \
&&      cd ../curl \
&&      autoreconf -fi \
&&      ./configure CFLAGS='-fstack-protector-strong -fpic -fpie -O3 -ftree-vectorize -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -march=native -mtune=native' --prefix=/usr/local \
            --with-wolfssl --with-zlib --with-brotli --enable-ipv6 --with-libidn2 --enable-sspi --with-librtmp --with-ngtcp2 --with-nghttp3 --with-nghttp2 --enable-websockets --with-zstd --disable-manual --disable-docs \
            --enable-ech --with-libssh2 --enable-ldap --enable-ldaps \
&&      make \
&&      make install \
&&      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false libbrotli-dev git cmake make automake autoconf libtool gcc g++ libzstd-dev libssl-dev librtmp-dev krb5-multidev libcrypt-dev libnsl-dev libtirpc-dev linux-libc-dev comerr-dev perl libnghttp3-dev \
            libnghttp2-dev libgsasl-dev libgssglue-dev libidn-dev libidn11-dev libntlm0-dev libpsl-dev curl libcurl4 libgss-dev libssh2-1-dev libldap-dev libldap2-dev \
&&      apt-get autoremove -y --purge \
&&      ldconfig \
&&      sed -i 's/Requires.private/Requires/' /usr/local/lib/pkgconfig/libcurl.pc \
&&      sed -i '0,/^Requires:.*$/s///' /usr/local/lib/pkgconfig/libcurl.pc \
&&      sed -i '/^Libs:/ { N; s/\nLibs\.private: / /; }' /usr/local/lib/pkgconfig/libcurl.pc \
&&      rm -rf \
            /home/vairogs/curl \
            /home/vairogs/wolfssl \
            /home/vairogs/ngtcp2 \
            /home/vairogs/nghttp3 \
            /home/vairogs/*.deb \
            /*.deb \
            /tmp/* \
            /var/cache/* \
            /usr/share/man \
            /usr/share/doc \
            /usr/local/share/man \
            /var/lib/apt/lists/* \
            /usr/lib/python3.12/__pycache__ \
            /usr/lib/python3.12/__phello__ \
            /usr/lib/python3.12/__hello__.py

RUN echo 'if [ -f /home/vairogs/container_env.sh ]; then . /home/vairogs/container_env.sh; fi' >> /etc/bash.bashrc

USER    vairogs

RUN    \
        set -eux \
&&      mkdir --parents /home/vairogs/environment \
&&      env | sed 's/^\([^=]*\)=\(.*\)$/\1=\2/' >> /home/vairogs/environment/environment.txt

COPY    --chmod=0755 curl/env_entrypoint.sh /home/vairogs/env_entrypoint.sh

FROM    ghcr.io/960018/scratch:latest

COPY    --from=builder / /

WORKDIR /home/vairogs

CMD     ["/bin/bash"]
