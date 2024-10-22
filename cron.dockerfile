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
COPY    --chmod=0755 cron/update_crontab.sh /usr/local/bin/update_crontab
COPY    --chmod=0755 cron/entrypoint.sh /usr/local/bin/entrypoint

COPY    --from=docker:27-dind-rootless --chmod=0755 /usr/local/bin/docker /usr/local/bin/docker

VOLUME  ["/var/run/docker.sock"]

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
&&      echo 'alias ll="ls -lahs"' >> /home/vairogs/.bashrc \
&&      echo 'alias ll="ls -lahs"' >> /root/.bashrc \
&&      apt-get update \
&&      apt-get upgrade -y \
&&      apt-get install -y --no-install-recommends vim-tiny cron procps iputils-ping telnet \
&&      ln -sf /usr/bin/vi /usr/bin/vim \
&&      chown vairogs:vairogs /usr/local/bin/wait-for-it \
&&      chown vairogs:vairogs /usr/local/bin/update_crontab \
&&      chown vairogs:vairogs /usr/local/bin/entrypoint \
&&      mkdir --parents /cron/scripts \
&&      mkdir --parents /var/spool/cron/crontabs \
&&      mkdir --parents /var/run/crond \
&&      chown -R vairogs:vairogs /cron \
&&      chown -R vairogs:vairogs /var/spool/cron/crontabs \
&&      chown -R vairogs:vairogs /var/run/crond \
&&      rm -rf \
            ~/.pearrc \
            /home/vairogs/*.deb \
            /home/vairogs/*.gz \
            /*.deb \
            /tmp/* \
            /var/cache/* \
            /usr/share/vim/vim90/doc \
            /usr/share/man/*

WORKDIR /cron

CMD     ["cron", "-f"]

FROM    ghcr.io/960018/scratch:latest

COPY    --from=builder / /

WORKDIR /cron

USER    root

RUN     mkdir -p /var/run/crond && chown -R vairogs:vairogs /var/run/crond

ENTRYPOINT ["/usr/local/bin/entrypoint"]

CMD     ["cron", "-f"]
