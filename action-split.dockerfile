FROM    ghcr.io/960018/debian:latest

ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive

USER    root

WORKDIR /

COPY    split/entrypoint.sh .

RUN     \
        set -eux \
&&      chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
