FROM    ghcr.io/960018/debian:latest AS builder

ARG     CACHE_BUSTER=default

ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive

USER    root

WORKDIR /home/vairogs

COPY    curl/source/ /home/vairogs/curl
COPY    curl/wolfssl/ /home/vairogs/wolfssl
COPY    curl/ngtcp2/ /home/vairogs/ngtcp2
COPY    curl/nghttp3/ /home/vairogs/nghttp3

RUN     \
        set -eux \
;       jobs="$(( $(nproc) - 1 ))" \
;       [ "$jobs" -lt 1 ] && jobs=1 \
;       apt-get update \
&&      apt-get upgrade -y \
&&      apt-get purge -y curl* \
&&      apt-get install -y --no-install-recommends make automake autoconf libtool gcc g++ libbrotli1 libbrotli-dev zstd libzstd-dev librtmp-dev librtmp1 rtmpdump \
        libgsasl-dev libgsasl18 libpsl-dev perl libnghttp2-dev nghttp2 libssl-dev libssl3t64 libpsl5t64 libssh2-1-dev libssh2-1t64 libldap-dev libldap2-dev libldap-common libldap-2.5-0 libldap2 \
&&      cd nghttp3 \
&&      autoreconf -fi \
&&      ./configure --prefix=/usr/local --enable-lib-only \
&&      make -j"$jobs" \
&&      make install \
&&      cd ../wolfssl \
&&      autoreconf -fi \
&&      CFLAGS="-DWOLFSSL_NO_STRICT -DWOLFSSL_NO_ASN_STRICT" ./configure \
          --disable-crypttests \
          --disable-examples \
          --disable-lighty \
          --disable-sniffer \
          --disable-wpas \
          --enable-alpn \
          --enable-altcertchains \
          --enable-base64encode \
          --enable-certgen \
          --enable-certgencache \
          --enable-certreq \
          --enable-chacha \
          --enable-curve25519 \
          --enable-earlydata \
          --enable-ecc \
          --enable-ed25519 \
          --enable-fastmath \
          --enable-openldap \
          --enable-opensslall \
          --enable-opensslextra \
          --enable-psk \
          --enable-quic \
          --enable-rsapss \
          --enable-secure-renegotiation \
          --enable-session-ticket \
          --enable-sha512 \
          --enable-tlsx \
&&      make -j"$jobs" \
&&      make install \
&&      cd ../ngtcp2 \
&&      autoreconf -fi \
&&      CFLAGS="-DWOLFSSL_NO_STRICT -DWOLFSSL_NO_ASN_STRICT" ./configure LDFLAGS="-Wl,-rpath,/usr/local/lib" --prefix=/usr/local --with-wolfssl --with-crypto-backend=wolfssl --enable-lib-only \
&&      make -j"$jobs" \
&&      make install \
&&      cd ../curl \
&&      autoreconf -fi \
&&      ./configure CFLAGS='-fstack-protector-strong -fpic -fpie -O3 -ftree-vectorize -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -march=native -mtune=native -DWOLFSSL_NO_STRICT -DWOLFSSL_NO_ASN_STRICT' --prefix=/usr/local \
            --with-wolfssl --with-zlib --with-brotli --enable-ipv6 --with-libidn2 --enable-sspi --with-librtmp --with-ngtcp2 --with-nghttp3 --with-nghttp2 --enable-websockets --with-zstd --disable-manual --disable-docs \
            --with-libssh2 --enable-ldap --enable-ldaps \
&&      make -j"$jobs" \
&&      make install \
&&      apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false libbrotli-dev cmake make automake autoconf libtool gcc g++ libzstd-dev libssl-dev librtmp-dev krb5-multidev libcrypt-dev libnsl-dev libtirpc-dev linux-libc-dev comerr-dev perl libnghttp3-dev \
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

RUN     echo 'if [ -f /home/vairogs/container_env.sh ]; then . /home/vairogs/container_env.sh; fi' >> /etc/bash.bashrc

USER    vairogs

RUN     \
        set -eux \
&&      mkdir --parents /home/vairogs/environment \
&&      env | sed 's/^\([^=]*\)=\(.*\)$/\1=\2/' >> /home/vairogs/environment/environment.txt

COPY    --chmod=0755 curl/env_entrypoint.sh /home/vairogs/env_entrypoint.sh

FROM    ghcr.io/960018/scratch:latest

COPY    --from=builder / /
