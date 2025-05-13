FROM    debian:sid-slim

ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive

SHELL   ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /

COPY    global/01_nodoc   /etc/dpkg/dpkg.cfg.d/01_nodoc
COPY    global/02_nocache /etc/apt/apt.conf.d/02_nocache
COPY    global/compress   /etc/initramfs-tools/conf.d/compress
COPY    global/modules    /etc/initramfs-tools/conf.d/modules
COPY    global/90parallel /etc/apt/apt.conf.d/90parallel

COPY    split/entrypoint.sh .

RUN     \
        set -eux \
&&      apt-get update \
&&      apt-get install -y --no-install-recommends git jq wget ca-certificates \
&&      rm -rf /var/lib/apt/lists/* \
&&      chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
