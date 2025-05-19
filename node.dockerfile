FROM    node:current-bookworm-slim AS builder

ENV     container=docker
ENV     DEBIAN_FRONTEND=noninteractive
ENV     NODE_COMPILE_CACHE=/home/vairogs/.node_cache

SHELL   ["/bin/bash", "-o", "pipefail", "-c"]

COPY    global/01_nodoc  /etc/dpkg/dpkg.cfg.d/01_nodoc
COPY    global/02_nocache /etc/apt/apt.conf.d/02_nocache
COPY    global/compress  /etc/initramfs-tools/conf.d/compress
COPY    global/modules   /etc/initramfs-tools/conf.d/modules
COPY    global/90parallel   /etc/apt/apt.conf.d/90parallel

USER    root

RUN     \
        set -eux \
&&      usermod -l vairogs node \
&&      usermod -d /home/vairogs -m vairogs \
&&      groupmod -n vairogs node \
&&      mkdir --parents /home/vairogs \
&&      echo >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /root/.bashrc \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends procps curl ca-certificates unzip \
&&      update-ca-certificates \
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
            /home/node \
            /root/.node-gyp \
            /usr/local/lib/node_modules/npm/man \
            /usr/local/lib/node_modules/npm/docs \
            /usr/local/lib/node_modules/npm/html \
            /root/.npm \
            /root/.cache \
&&      usermod -a -G dialout vairogs \
&&      npm i -g npm@latest \
&&      npm i -g n@latest \
&&      npm i -g pnpm@latest \
&&      chown -R vairogs:vairogs /home/vairogs \
&&      chown -R vairogs:vairogs /usr/local/lib/node_modules \
&&      chmod -R 755 /usr/local/lib/node_modules \
&&      mkdir --parents /usr/local/n \
&&      chown -R vairogs:vairogs /usr/local/n \
&&      chown -R vairogs:vairogs /usr/local/include \
&&      chown -R vairogs:vairogs /usr/local/share \
&&      chown -R vairogs:vairogs /usr/local/bin

RUN     echo 'if [ -f /home/vairogs/container_env.sh ]; then . /home/vairogs/container_env.sh; fi' >> /etc/bash.bashrc

USER    vairogs

RUN    \
        set -eux \
&&      mkdir --parents /home/vairogs/environment \
&&      env | sed 's/^\([^=]*\)=\(.*\)$/\1=\2/' >> /home/vairogs/environment/environment.txt

COPY    --chmod=0755 node/env_entrypoint.sh /home/vairogs/env_entrypoint.sh

FROM    ghcr.io/960018/scratch:latest

COPY    --from=builder / /

CMD     ["node"]

USER    vairogs
