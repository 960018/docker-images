FROM    oven/bun:canary-debian AS builder

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
&&      usermod -l vairogs bun \
&&      usermod -d /home/vairogs -m vairogs \
&&      groupmod -n vairogs bun \
&&      mkdir --parents /home/vairogs \
&&      echo >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /root/.bashrc \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends procps unzip iputils-ping \
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
            /home/node \
            /root/.node-gyp \
            /usr/local/lib/node_modules/npm/man \
            /usr/local/lib/node_modules/npm/docs \
            /usr/local/lib/node_modules/npm/html \
            /root/.npm \
            /root/.cache \
&&      usermod -a -G dialout vairogs

USER    vairogs

FROM    ghcr.io/960018/scratch:latest

ARG BUN_RUNTIME_TRANSPILER_CACHE_PATH=0
ENV BUN_RUNTIME_TRANSPILER_CACHE_PATH=${BUN_RUNTIME_TRANSPILER_CACHE_PATH}

ARG BUN_INSTALL_BIN=/usr/local/bin
ENV BUN_INSTALL_BIN=${BUN_INSTALL_BIN}

COPY    --from=builder / /

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD     ["bash"]
