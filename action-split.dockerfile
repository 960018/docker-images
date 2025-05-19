FROM    ghcr.io/960018/debian:latest

ARG     CACHE_BUSTER=default

ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive

USER    root

WORKDIR /

COPY    split/entrypoint.sh .

RUN     \
        set -eux \
&&      chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
