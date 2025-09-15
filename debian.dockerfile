FROM    debian:sid-slim AS builder

ARG     CACHE_BUSTER=default

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

WORKDIR /home/vairogs

RUN     \
        set -eux \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends sudo \
&&      groupadd --system --gid 1000 vairogs \
&&      useradd --system --uid 1000 -g vairogs --shell /bin/bash --home /home/vairogs vairogs \
&&      passwd -d vairogs \
&&      usermod -a -G dialout vairogs \
&&      groupadd docker \
&&      usermod -a -G docker vairogs \
&&      echo 'vairogs ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vairogs \
&&      chmod 0440 /etc/sudoers.d/vairogs \
&&      mkdir --parents /home/vairogs/.docker \
&&      chown vairogs:vairogs /home/vairogs/.docker -R \
&&      chmod g+rwx "/home/vairogs/.docker" -R \
&&      mkdir --parents /home/vairogs \
&&      echo 'alias ll="ls -lahs"' >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /root/.bashrc \
&&      chown -R vairogs:vairogs /home/vairogs \
&&      apt-get install -y --no-install-recommends \
        bash ca-certificates cron git iputils-ping jq openssh-client pkg-config procps telnet tzdata unzip util-linux vim-tiny wget \
&&      chown vairogs:vairogs /usr/local/bin/wait-for-it \
&&      chmod +x /usr/local/bin/wait-for-it \
&&      ln -sf /usr/bin/vi /usr/bin/vim \
&&      rm -rf \
            /var/cache/* \
            /usr/share/man \
            /usr/share/doc \
            /usr/local/share/man \
            /var/lib/apt/lists/* \
            /*.deb

RUN     echo 'if [ -f /home/vairogs/container_env.sh ]; then . /home/vairogs/container_env.sh; fi' >> /etc/bash.bashrc

USER    vairogs

RUN     \
        set -eux \
&&      mkdir --parents /home/vairogs/environment \
&&      env | sed 's/^\([^=]*\)=\(.*\)$/\1=\2/' >> /home/vairogs/environment/environment.txt

COPY    --chmod=0755 debian/env_entrypoint.sh /home/vairogs/env_entrypoint.sh

FROM    ghcr.io/960018/scratch:latest

COPY    --from=builder / /

WORKDIR /home/vairogs
