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
COPY    --from=docker:28-dind-rootless --chmod=0755 /usr/local/bin/docker /usr/local/bin/docker

USER    root

RUN     \
        set -eux \
&&      groupadd --system --gid 1000 vairogs \
&&      useradd --system --uid 1000 -g vairogs --shell /bin/bash --home /home/vairogs vairogs \
&&      passwd -d vairogs \
&&      usermod -a -G dialout vairogs \
&&      mkdir --parents /home/vairogs \
&&      echo 'alias ll="ls -lahs"' >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /root/.bashrc \
&&      chown -R vairogs:vairogs /home/vairogs

WORKDIR /home/vairogs

RUN     \
        set -eux \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends \
        apt-utils bash ca-certificates cron git iputils-ping jq pkg-config procps telnet tzdata unzip vim-tiny wget \
&&      chown vairogs:vairogs /usr/local/bin/wait-for-it \
&&      chmod +x /usr/local/bin/wait-for-it \
&&      ln -sf /usr/bin/vi /usr/bin/vim \
&&      rm -rf \
            /var/cache/* \
            /usr/share/man \
            /usr/share/doc \
            /usr/local/share/man \
            /var/lib/apt/lists/*

FROM    ghcr.io/960018/scratch:latest

COPY    --from=builder / /

WORKDIR /home/vairogs
