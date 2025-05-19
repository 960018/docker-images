FROM    ghcr.io/960018/debian:latest AS builder

ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive

ARG     GO_VERSION
ENV     GO_VERSION=${GO_VERSION}

USER    root

RUN     \
        set -eux \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends make g++ gcc libc6-dev \
&&      rm -rf \
            /var/cache/* \
            /usr/share/man \
            /usr/share/doc \
            /usr/local/share/man \
            /var/lib/apt/lists/*

ENV     GOTOOLCHAIN=local
ENV     GOPATH=/go
ENV     PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

COPY    go-root/go /usr/local/go

RUN     \
        set -eux \
&&      mkdir -p "$GOPATH/src" "$GOPATH/bin" \
&&      chmod -R 1777 "$GOPATH" \
&&      chown -R vairogs:vairogs $GOPATH

WORKDIR $GOPATH

RUN     echo 'if [ -f /home/vairogs/container_env.sh ]; then . /home/vairogs/container_env.sh; fi' >> /etc/bash.bashrc

USER    vairogs

RUN    \
        set -eux \
&&      mkdir --parents /home/vairogs/environment \
&&      env | sed 's/^\([^=]*\)=\(.*\)$/\1=\2/' >> /home/vairogs/environment/environment.txt

COPY    --chmod=0755 go/env_entrypoint.sh /home/vairogs/env_entrypoint.sh

USER    root
